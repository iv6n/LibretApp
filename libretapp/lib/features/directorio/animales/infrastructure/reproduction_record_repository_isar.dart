/// features › directorio › animales › infrastructure › reproduction_record_repository_isar
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar_record_repository_base.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_projection_recalculator.dart';

class ReproductionRecordRepositoryIsar
    extends IsarRecordRepositoryBase<ReproductionRecord, IsarReproductionRecord>
    implements ReproductionRecordRepository, ReproductionRecordUuidLookup {
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
      getRecordsFor(animalUuid);

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
      ..sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
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
  ) => addRecordFor(
    animalUuid,
    record,
    onSaved: (isar, _) => _recalculateBothSides(isar, animalUuid, record),
  );

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

  @override
  Future<void> deleteReproductionRecord(String recordId) async {
    // The base only knows the animal the record was filed under. Capture the
    // sire before the row is gone, or his service dates keep the deleted
    // service in them.
    final db = await isar;
    final id = int.tryParse(recordId);
    final stored = id == null ? null : await db.isarReproductionRecords.get(id);
    final sireUuid = stored?.maleSireUuid?.trim();

    await deleteRecordById(recordId);

    if (sireUuid != null && sireUuid.isNotEmpty) {
      await db.writeTxn(
        () => AnimalProjectionRecalculator.recalculate(db, sireUuid),
      );
    }
  }

  @override
  Future<List<({String animalUuid, DateTime expectedCalvingDate})>>
  getUpcomingCalvings(DateTime from, DateTime to) async {
    final db = await isar;
    final records = await db.isarReproductionRecords
        .filter()
        .expectedCalvingDateBetween(from, to)
        .actualCalvingDateIsNull()
        .findAll();
    return records
        .map(
          (r) => (
            animalUuid: r.animalUuid,
            expectedCalvingDate: r.expectedCalvingDate!,
          ),
        )
        .toList(growable: false);
  }
}
