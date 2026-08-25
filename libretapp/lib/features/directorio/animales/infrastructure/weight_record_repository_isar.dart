/// features › directorio › animales › infrastructure › weight_record_repository_isar
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_weight_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar_record_repository_base.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_projection_recalculator.dart';

class WeightRecordRepositoryIsar
    extends IsarRecordRepositoryBase<WeightRecord, IsarWeightRecord>
    implements WeightRecordRepository, WeightRecordUuidLookup {
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
  Future<List<WeightRecord>> getWeightRecords(String animalUuid) =>
      getRecordsFor(animalUuid);

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
    return grouped;
  }

  @override
  Future<void> deleteWeightRecord(String recordId) =>
      deleteRecordById(recordId);
}
