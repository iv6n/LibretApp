/// features › directorio › animales › infrastructure › movement_record_repository_isar
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_movement_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar_record_repository_base.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_projection_recalculator.dart';

class MovementRecordRepositoryIsar
    extends IsarRecordRepositoryBase<MovementRecord, IsarMovementRecord>
    implements
        MovementRecordRepository,
        MovementRecordUuidLookup,
        MovementRecordRecentLookup {
  MovementRecordRepositoryIsar(super.database);

  @override
  String get logTag => 'MovementRecordRepositoryIsar';

  @override
  IsarCollection<IsarMovementRecord> collection(Isar isar) =>
      isar.isarMovementRecords;

  @override
  Future<List<IsarMovementRecord>> queryByAnimal(
    IsarCollection<IsarMovementRecord> collection,
    String animalUuid,
  ) => collection
      .where()
      .animalUuidEqualTo(animalUuid)
      .sortByDateDesc()
      .findAll();

  @override
  IsarMovementRecord toIsarModel(MovementRecord record, String animalUuid) =>
      record.toIsar(animalUuid);

  @override
  MovementRecord toEntity(IsarMovementRecord model) => model.toEntity();

  @override
  void assignId(IsarMovementRecord model, int id) => model.id = id;

  @override
  String describeSaved(String animalUuid, MovementRecord saved) =>
      'Movimiento guardado para $animalUuid (${saved.id})';

  @override
  Future<List<MovementRecord>> getMovementRecords(String animalUuid) =>
      getRecordsFor(animalUuid);

  @override
  Future<List<({String animalUuid, MovementRecord record})>>
  getRecentMovementRecords({int limit = 5}) async {
    final db = await isar;
    final models = await db.isarMovementRecords
        .where()
        .sortByDateDesc()
        .limit(limit)
        .findAll();
    return models
        .map((m) => (animalUuid: m.animalUuid, record: m.toEntity()))
        .toList(growable: false);
  }

  @override
  Future<Map<String, MovementRecord>> getMovementRecordsByRecordUuids(
    Set<String> recordUuids,
  ) async {
    if (recordUuids.isEmpty) return const {};
    final db = await isar;
    final records = await db.isarMovementRecords
        .filter()
        .anyOf(recordUuids, (q, uuid) => q.recordUuidEqualTo(uuid))
        .findAll();
    return {for (final record in records) record.recordUuid: record.toEntity()};
  }

  @override
  Future<MovementRecord> addMovementRecord(
    String animalUuid,
    MovementRecord record,
  ) => addRecordFor(
    animalUuid,
    record,
    onSaved: (isar, _) =>
        AnimalProjectionRecalculator.recalculate(isar, animalUuid),
  );

  @override
  Future<void> deleteMovementRecord(String recordId) =>
      deleteRecordById(recordId);
}
