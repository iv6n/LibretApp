/// features › directorio › animales › infrastructure › reproduction_record_repository_isar
library;
import 'package:libretapp/core/database/isar_write_transaction.dart';

import 'package:isar_community/isar.dart';
import '../domain/services/animal_record_validation.dart';
import '../domain/services/reproductive_kpi_service.dart';
import '../domain/animal_domain.dart';
import 'isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar_record_repository_base.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_projection_recalculator.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/editable_record_repository.dart';

class ReproductionRecordRepositoryIsar
    extends IsarRecordRepositoryBase<ReproductionRecord, IsarReproductionRecord>
    implements
        ReproductionRecordRepository,
        ReproductionRecordUuidLookup,
        ReproductionOffspringLinker,
        EditableRecordRepository<ReproductionRecord> {
  ReproductionRecordRepositoryIsar(super.database);

  @override
  String get logTag => 'ReproductionRecordRepositoryIsar';

  @override
  IsarCollection<IsarReproductionRecord> collection(Isar isar) =>
      isar.isarReproductionRecords;

  @override
  Future<List<IsarReproductionRecord>> queryByAnimal(
    IsarCollection<IsarReproductionRecord> collection,
    String animalUuid,
  ) => collection
      .where()
      .animalUuidEqualTo(animalUuid)
      .sortByServiceDateDesc()
      .findAll();

  @override
  IsarReproductionRecord toIsarModel(
    ReproductionRecord record,
    String animalUuid,
  ) => record.toIsar(animalUuid);

  @override
  ReproductionRecord toEntity(IsarReproductionRecord model) => model.toEntity();

  @override
  void assignId(IsarReproductionRecord model, int id) => model.id = id;

  @override
  String describeSaved(String animalUuid, ReproductionRecord saved) =>
      'Evento reproductivo guardado para $animalUuid (${saved.id})';

  @override
  Future<List<ReproductionRecord>> getReproductionRecords(String animalUuid) =>
      getRecordsFor(animalUuid).then(
        (records) =>
            records..sort((a, b) => b.eventDate.compareTo(a.eventDate)),
      );

  @override
  Future<Map<String, ReproductionRecord>> getReproductionRecordsByRecordUuids(
    Set<String> recordUuids,
  ) async {
    if (recordUuids.isEmpty) return const {};
    final db = await isar;
    final records = await db.isarReproductionRecords
        .filter()
        .anyOf(recordUuids, (q, uuid) => q.recordUuidEqualTo(uuid))
        .findAll();
    return {for (final record in records) record.recordUuid: record.toEntity()};
  }

  @override
  Future<List<ReproductionRecord>> getRecordsBySire(String sireUuid) async {
    if (sireUuid.trim().isEmpty) return const [];

    final db = await isar;
    final records = await db.isarReproductionRecords
        .where()
        .maleSireUuidEqualTo(sireUuid)
        .findAll();

    final entities = records.map((record) => record.toEntity()).toList()
      ..sort((a, b) => b.eventDate.compareTo(a.eventDate));
    return List<ReproductionRecord>.unmodifiable(entities);
  }

  @override
  Future<Map<String, List<ReproductionRecord>>>
  getReproductionRecordsForAnimals(Set<String> animalUuids) async {
    if (animalUuids.isEmpty) return const {};

    final db = await isar;
    final records = await db.isarReproductionRecords
        .filter()
        .anyOf(animalUuids, (q, uuid) => q.animalUuidEqualTo(uuid))
        .sortByServiceDateDesc()
        .findAll();

    final grouped = <String, List<ReproductionRecord>>{};
    for (final record in records) {
      grouped
          .putIfAbsent(record.animalUuid, () => <ReproductionRecord>[])
          .add(record.toEntity());
    }
    return grouped;
  }

  @override
  Future<ReproductionRecord> addReproductionRecord(
    String animalUuid,
    ReproductionRecord record,
  ) async {
    AnimalRecordValidation.reproduction(record);
    final storedId = int.tryParse(record.id ?? '');
    if (storedId != null &&
        await (await isar).isarReproductionRecords.get(storedId) != null)
      return updateRecord(animalUuid, record);
    return addRecordFor(
      animalUuid,
      record,
      beforeWrite: (isar) =>
          _validateAnimalAndOffspring(isar, animalUuid, record),
      onSaved: (isar, _) => _recalculateBothSides(isar, animalUuid, record),
    );
  }

  /// A reproduction record moves the dam's dates and the sire's, so both have
  /// to be recomputed whenever one is written.
  Future<void> _recalculateBothSides(
    Isar isar,
    String animalUuid,
    ReproductionRecord record,
  ) async {
    await AnimalProjectionRecalculator.recalculate(isar, animalUuid);
    final sireUuid = record.maleSireUuid?.trim();
    if (sireUuid != null && sireUuid.isNotEmpty && sireUuid != animalUuid) {
      await AnimalProjectionRecalculator.recalculate(isar, sireUuid);
    }
  }

  Future<void> _validateAnimalAndOffspring(
    Isar db,
    String damUuid,
    ReproductionRecord record, {
    IsarReproductionRecord? previous,
  }) async {
    final dam = await db.isarAnimals.where().uuidEqualTo(damUuid).findFirst();
    if (dam == null) throw StateError('Animal no encontrado.');
    if (dam.sex != Sex.female.name)
      throw ArgumentError('El ciclo debe registrarse en una hembra.');
    AnimalRecordValidation.operation(
      dam.toEntity(),
      record.eventDate,
      editing: previous != null || record.id != null,
    );
    for (final date in [record.serviceDate, record.pregnancyCheckDate]) {
      if (date != null)
        AnimalRecordValidation.operation(
          dam.toEntity(),
          date,
          editing: previous != null || record.id != null,
        );
    }
    if (record.maleSireUuid != null) {
      final sire = await db.isarAnimals
          .where()
          .uuidEqualTo(record.maleSireUuid!)
          .findFirst();
      if (sire == null ||
          sire.sex != Sex.male.name ||
          sire.species != dam.species ||
          sire.uuid == dam.uuid) {
        throw ArgumentError('Selecciona un macho de la misma especie.');
      }
    }
    if (record.recordUuid != null) {
      final existing = await db.isarReproductionRecords
          .where()
          .recordUuidEqualTo(record.recordUuid!)
          .findFirst();
      if (existing != null && existing.animalUuid != damUuid)
        throw ArgumentError('El ciclo pertenece a otra hembra.');
    }
    if (record.offspringUuids.isEmpty) return;
    if (record.actualCalvingDate == null ||
        record.calvingOutcome != CalvingOutcome.liveBirth) {
      throw ArgumentError('Las crías requieren un parto con nacimiento vivo.');
    }
    final cycles = await db.isarReproductionRecords.where().findAll();
    for (final uuid in record.offspringUuids) {
      final calf = await db.isarAnimals.where().uuidEqualTo(uuid).findFirst();
      if (calf == null ||
          calf.uuid == damUuid ||
          calf.uuid == record.maleSireUuid ||
          calf.species != dam.species ||
          await _hasAncestor(db, dam, uuid)) {
        throw ArgumentError('Cría incompatible con este parto.');
      }
      if (cycles.any(
        (c) =>
            c.id.toString() != record.id &&
            c.recordUuid != record.recordUuid &&
            c.offspringUuids.contains(uuid),
      )) {
        throw ArgumentError('La cría ya pertenece a otro parto.');
      }
      if (calf.damUuid != null && calf.damUuid != damUuid)
        throw ArgumentError('La madre de la cría es incompatible.');
      final priorSire = previous?.maleSireUuid;
      if (calf.sireUuid != null &&
          record.maleSireUuid != null &&
          calf.sireUuid != record.maleSireUuid &&
          calf.sireUuid != priorSire) {
        throw ArgumentError('El padre de la cría es incompatible.');
      }
      final day = AnimalRecordValidation.day;
      if (calf.birthDatePrecision == BirthDatePrecision.exact.name &&
          day(calf.birthDate) != day(record.actualCalvingDate!) &&
          (previous?.actualCalvingDate == null ||
              day(calf.birthDate) != day(previous!.actualCalvingDate!))) {
        throw ArgumentError(
          'El nacimiento de la cría no coincide con el parto.',
        );
      }
      calf
        ..damUuid = damUuid
        ..sireUuid = record.maleSireUuid ?? calf.sireUuid
        ..birthDate = record.actualCalvingDate!
        ..birthDatePrecision = BirthDatePrecision.exact.name
        ..synced = false
        ..lastUpdateDate = DateTime.now();
      await db.isarAnimals.put(calf);
    }
  }

  Future<bool> _hasAncestor(
    Isar db,
    IsarAnimal child,
    String ancestorUuid,
  ) async {
    final pending = [
      child.damUuid,
      child.sireUuid,
    ].whereType<String>().toList();
    final seen = <String>{};
    while (pending.isNotEmpty) {
      final uuid = pending.removeLast();
      if (uuid == ancestorUuid) return true;
      if (!seen.add(uuid)) continue;
      final parent = await db.isarAnimals.where().uuidEqualTo(uuid).findFirst();
      if (parent != null)
        pending.addAll([parent.damUuid, parent.sireUuid].whereType<String>());
    }
    return false;
  }

  @override
  Future<void> linkOffspring(
    String damUuid,
    String recordId,
    String calfUuid,
  ) async {
    final db = await isar;
    await withIsarWriteTransaction(db, () async {
      final calving = await db.isarReproductionRecords.get(int.parse(recordId));
      final dam = await db.isarAnimals.where().uuidEqualTo(damUuid).findFirst();
      final calf = await db.isarAnimals
          .where()
          .uuidEqualTo(calfUuid)
          .findFirst();
      if (calving == null ||
          dam == null ||
          calf == null ||
          calving.animalUuid != damUuid) {
        throw StateError('El parto o la cría ya no existe.');
      }
      if (calving.actualCalvingDate == null ||
          calving.calvingOutcome != 'liveBirth') {
        throw ArgumentError(
          'Solo un parto con nacimiento vivo puede vincular crías.',
        );
      }
      if (calf.uuid == dam.uuid ||
          calf.uuid == calving.maleSireUuid ||
          calf.species != dam.species ||
          (calf.damUuid != null && calf.damUuid != damUuid) ||
          (calving.maleSireUuid != null &&
              calf.sireUuid != null &&
              calf.sireUuid != calving.maleSireUuid)) {
        throw ArgumentError(
          'La especie o los padres de la cría son incompatibles con este parto.',
        );
      }
      if (await _hasAncestor(db, dam, calfUuid))
        throw ArgumentError('El vínculo crearía un ciclo en la genealogía.');
      if (calf.birthDatePrecision == BirthDatePrecision.exact.name &&
          AnimalRecordValidation.day(calf.birthDate) !=
              AnimalRecordValidation.day(calving.actualCalvingDate!)) {
        throw ArgumentError(
          'La fecha de nacimiento de la cría no coincide con el parto.',
        );
      }
      final other = await db.isarReproductionRecords
          .where()
          .animalUuidEqualTo(damUuid)
          .findAll();
      if (other.any(
        (r) => r.id != calving.id && r.offspringUuids.contains(calfUuid),
      )) {
        throw ArgumentError('La cría ya pertenece a otro parto.');
      }
      calf
        ..damUuid = damUuid
        ..sireUuid = calving.maleSireUuid ?? calf.sireUuid
        ..birthDate = calving.actualCalvingDate!
        ..birthDatePrecision = BirthDatePrecision.exact.name
        ..synced = false
        ..lastUpdateDate = DateTime.now();
      if (!calving.offspringUuids.contains(calfUuid))
        calving.offspringUuids = [...calving.offspringUuids, calfUuid];
      calving.updatedAt = DateTime.now();
      await db.isarAnimals.put(calf);
      await db.isarReproductionRecords.put(calving);
      await _recalculateBothSides(db, damUuid, calving.toEntity());
    });
  }

  @override
  Future<void> deleteReproductionRecord(String recordId) async {
    final db = await isar;
    final id = int.tryParse(recordId);
    if (id == null) return;
    await withIsarWriteTransaction(db, () async {
      final stored = await db.isarReproductionRecords.get(id);
      if (stored == null) return;
      await db.isarReproductionRecords.delete(id);
      await _recalculateBothSides(db, stored.animalUuid, stored.toEntity());
    });
  }

  @override
  Future<List<({String animalUuid, DateTime expectedCalvingDate})>>
  getUpcomingCalvings(DateTime from, DateTime to) async {
    final db = await isar;
    final records = await db.isarReproductionRecords.where().findAll();
    final grouped = <String, List<ReproductionRecord>>{};
    for (final record in records) {
      (grouped[record.animalUuid] ??= []).add(record.toEntity());
    }
    final result = <({String animalUuid, DateTime expectedCalvingDate})>[];
    for (final entry in grouped.entries) {
      final cycle = ReproductiveKpiService.openCycleOf(entry.value);
      final expected = cycle?.expectedCalvingDate;
      if (expected != null &&
          !expected.isBefore(from) &&
          !expected.isAfter(to)) {
        result.add((animalUuid: entry.key, expectedCalvingDate: expected));
      }
    }
    return result;
  }

  @override
  Future<ReproductionRecord> updateRecord(
    String animalUuid,
    ReproductionRecord record,
  ) async {
    AnimalRecordValidation.reproduction(record);
    final db = await isar;
    final old = await db.isarReproductionRecords.get(int.parse(record.id!));
    if (old == null || old.animalUuid != animalUuid)
      throw StateError('El registro ya no existe.');
    return updateRecordFor(
      animalUuid,
      record,
      beforeWrite: (isar) =>
          _validateAnimalAndOffspring(isar, animalUuid, record, previous: old),
      onSaved: (isar, _) async {
        await _recalculateBothSides(isar, animalUuid, record);
        if (old.maleSireUuid != null &&
            old.maleSireUuid != record.maleSireUuid) {
          await AnimalProjectionRecalculator.recalculate(
            isar,
            old.maleSireUuid!,
          );
        }
      },
    );
  }
}
