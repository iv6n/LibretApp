/// features › directorio › animales › infrastructure › weight_record_repository_isar
library;

import 'package:isar/isar.dart';
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
  ) => addRecordFor(
    animalUuid,
    record,
    onSaved: (isar, _) =>
        AnimalProjectionRecalculator.recalculate(isar, animalUuid),
  );

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
  Future<void> deleteWeightRecord(String recordId) =>
      deleteRecordById(recordId);

  @override
  Future<WeightRecord> updateRecord(String animalUuid, WeightRecord record) =>
      updateRecordFor(
        animalUuid,
        record,
        onSaved: (isar, _) =>
            AnimalProjectionRecalculator.recalculate(isar, animalUuid),
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
