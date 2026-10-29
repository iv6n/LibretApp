/// features › directorio › animales › infrastructure › weight_record_repository_isar
library;
import 'package:libretapp/core/database/isar_write_transaction.dart';

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';
import '../domain/services/animal_record_validation.dart';
import 'isar/isar_animal.dart';
import 'isar/isar_weaning_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_weight_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar_record_repository_base.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_projection_recalculator.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/editable_record_repository.dart';

class WeightRecordRepositoryIsar
    extends IsarRecordRepositoryBase<WeightRecord, IsarWeightRecord>
    implements
        WeightRecordRepository,
        WeightRecordUuidLookup,
        EditableRecordRepository<WeightRecord> {
  WeightRecordRepositoryIsar(super.database);

  @override
  String get logTag => 'WeightRecordRepositoryIsar';

  @override
  IsarCollection<IsarWeightRecord> collection(Isar isar) =>
      isar.isarWeightRecords;

  @override
  Future<List<IsarWeightRecord>> queryByAnimal(
    IsarCollection<IsarWeightRecord> collection,
    String animalUuid,
  ) => collection
      .where()
      .animalUuidEqualTo(animalUuid)
      .sortByDateDesc()
      .findAll();

  @override
  IsarWeightRecord toIsarModel(WeightRecord record, String animalUuid) =>
      record.toIsar(animalUuid);

  @override
  WeightRecord toEntity(IsarWeightRecord model) => model.toEntity();

  @override
  void assignId(IsarWeightRecord model, int id) => model.id = id;

  @override
  String describeSaved(String animalUuid, WeightRecord saved) =>
      'Peso registrado para $animalUuid (${saved.id})';

  @override
  Future<List<WeightRecord>> getWeightRecords(String animalUuid) async {
    final records = (await getRecordsFor(animalUuid)).toList();
    _sortNewestFirst(records);
    return records;
  }

  @override
  Future<List<WeightRecord>> getWeightRecordsForLot(String lotUuid) async {
    final db = await isar;
    final records = await db.isarWeightRecords
        .filter()
        .lotUuidEqualTo(lotUuid)
        .findAll();
    final entities = records.map((record) => record.toEntity()).toList();
    _sortNewestFirst(entities);
    return entities;
  }

  @override
  Future<Map<String, WeightRecord>> getWeightRecordsByRecordUuids(
    Set<String> recordUuids,
  ) async {
    if (recordUuids.isEmpty) return const {};
    final db = await isar;
    final records = await db.isarWeightRecords
        .filter()
        .anyOf(recordUuids, (q, uuid) => q.recordUuidEqualTo(uuid))
        .findAll();
    return {for (final record in records) record.recordUuid: record.toEntity()};
  }

  @override
  Future<WeightRecord> addWeightRecord(
    String animalUuid,
    WeightRecord record,
  ) async => (await addWeightRecordsAtomically([
    WeightBatchEntry(animalUuid: animalUuid,
      record: record.copyWith(recordUuid: record.recordUuid ?? const Uuid().v4())),
  ])).single;

  @override
  Future<List<WeightRecord>> addWeightRecordsAtomically(List<WeightBatchEntry> entries) async {
    final db = await isar;
    final saved = <WeightRecord>[];
    final identities = <String>{};
    await withIsarWriteTransaction(db, () async {
      for (final entry in entries) {
        final record = entry.record;
        final uuid = record.recordUuid;
        if (uuid == null || uuid.trim().isEmpty || !identities.add(uuid)) {
          throw ArgumentError('Cada pesaje necesita una identidad estable y única.');
        }
        final previous = await db.isarWeightRecords.where().recordUuidEqualTo(uuid).findFirst();
        if (previous != null) {
          if (previous.animalUuid != entry.animalUuid || previous.date != record.date ||
              previous.weight != record.weight || previous.method != record.method.name ||
              previous.lotUuid != record.lotUuid || previous.notes != record.notes ||
              previous.measuredBy != record.measuredBy) {
            throw ArgumentError('La identidad del pesaje ya corresponde a otra captura.');
          }
          saved.add(previous.toEntity());
          continue;
        }
        await _prepare(db, entry.animalUuid, record);
        final requestedId = int.tryParse(record.id ?? '');
        if (requestedId != null && await db.isarWeightRecords.get(requestedId) != null) {
          throw ArgumentError('El identificador local ya pertenece a otro pesaje.');
        }
        final model = record.toIsar(entry.animalUuid)..id = requestedId ?? Isar.autoIncrement;
        await db.isarWeightRecords.put(model);
        await _project(db, entry.animalUuid, model);
        saved.add(model.toEntity());
      }
    });
    return saved;
  }

  @override
  Future<Map<String, List<WeightRecord>>> getWeightRecordsForAnimals(
    Set<String> animalUuids,
  ) async {
    if (animalUuids.isEmpty) return const {};

    final db = await isar;
    final records = await db.isarWeightRecords
        .filter()
        .anyOf(animalUuids, (q, uuid) => q.animalUuidEqualTo(uuid))
        .sortByDateDesc()
        .findAll();

    final grouped = <String, List<WeightRecord>>{};
    for (final record in records) {
      grouped
          .putIfAbsent(record.animalUuid, () => <WeightRecord>[])
          .add(record.toEntity());
    }
    for (final history in grouped.values) {
      _sortNewestFirst(history);
    }
    return grouped;
  }

  @override
  Future<void> deleteWeightRecord(String recordId) async {
    final db = await isar;
    final id = int.tryParse(recordId);
    if (id == null) return;
    await withIsarWriteTransaction(db, () async {
      final stored = await db.isarWeightRecords.get(id);
      if (stored == null) return;
      await AnimalProjectionRecalculator.prepareWeightProjection(
        db,
        stored.animalUuid,
      );
      final owner = await db.isarWeaningRecords
          .filter()
          .weightRecordUuidEqualTo(stored.recordUuid)
          .findFirst();
      if (owner != null) {
        owner.weightKg = null;
        owner.updatedAt = DateTime.now();
        await db.isarWeaningRecords.put(owner);
      }
      await db.isarWeightRecords.delete(id);
      await AnimalProjectionRecalculator.recalculate(db, stored.animalUuid);
    });
  }

  Future<void> _prepare(Isar db, String animalUuid, WeightRecord record) async {
    if (!record.weight.isFinite || record.weight <= 0)
      throw ArgumentError('Ingresa un peso positivo en kg.');
    final animal = await db.isarAnimals
        .where()
        .uuidEqualTo(animalUuid)
        .findFirst();
    if (animal == null) throw StateError('Animal no encontrado.');
    AnimalRecordValidation.operation(
      animal.toEntity(),
      record.date,
      editing: record.id != null,
    );
    if (record.recordUuid != null) {
      final previous = await db.isarWeightRecords
          .where()
          .recordUuidEqualTo(record.recordUuid!)
          .findFirst();
      if (previous != null && previous.animalUuid != animalUuid)
        throw ArgumentError('El pesaje pertenece a otro animal.');
    }
    await AnimalProjectionRecalculator.prepareWeightProjection(db, animalUuid);
  }

  Future<void> _project(
    Isar db,
    String animalUuid,
    IsarWeightRecord saved,
  ) async {
    final owner = await db.isarWeaningRecords
        .filter()
        .weightRecordUuidEqualTo(saved.recordUuid)
        .findFirst();
    if (owner != null) {
      owner
        ..date = saved.date
        ..weightKg = saved.weight
        ..weightMethod = saved.method
        ..performedBy = saved.measuredBy
        ..updatedAt = DateTime.now();
      await db.isarWeaningRecords.put(owner);
    }
    await AnimalProjectionRecalculator.recalculate(db, animalUuid);
  }

  @override
  Future<WeightRecord> updateRecord(String animalUuid, WeightRecord record) =>
      updateRecordFor(
        animalUuid,
        record,
        beforeWrite: (isar) => _prepare(isar, animalUuid, record),
        onSaved: (isar, saved) => _project(isar, animalUuid, saved),
      );

  static void _sortNewestFirst(List<WeightRecord> records) {
    records.sort((a, b) {
      final measured = b.date.compareTo(a.date);
      if (measured != 0) return measured;
      final created = (b.createdAt ?? b.date).compareTo(a.createdAt ?? a.date);
      if (created != 0) return created;
      return (b.recordUuid ?? b.id ?? '').compareTo(a.recordUuid ?? a.id ?? '');
    });
  }
}
