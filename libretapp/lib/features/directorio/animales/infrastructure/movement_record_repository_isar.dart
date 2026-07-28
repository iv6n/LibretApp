/// features › directorio › animales › infrastructure › movement_record_repository_isar
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_movement_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar_record_repository_base.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/isar/isar_location.dart';

class MovementRecordRepositoryIsar
    extends IsarRecordRepositoryBase<MovementRecord, IsarMovementRecord>
    implements MovementRecordRepository {
  MovementRecordRepositoryIsar(super.database);

  @override
  String get logTag => 'MovementRecordRepositoryIsar';

  @override
  IsarCollection<IsarMovementRecord> collection(Isar isar) => isar.isarMovementRecords;

  @override
  Future<List<IsarMovementRecord>> queryByAnimal(
    IsarCollection<IsarMovementRecord> collection,
    String animalUuid,
  ) => collection.filter().animalUuidEqualTo(animalUuid).sortByDateDesc().findAll();

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
  Future<MovementRecord> addMovementRecord(
    String animalUuid,
    MovementRecord record,
  ) => addRecordFor(
    animalUuid,
    record,
    onSaved: (isar, _) => _applyLocationEffect(isar, animalUuid, record),
  );

  @override
  Future<void> deleteMovementRecord(String recordId) => deleteRecordById(recordId);

  Future<void> _applyLocationEffect(
    Isar isar,
    String animalUuid,
    MovementRecord record,
  ) async {
    final animal = await isar.isarAnimals.where().uuidEqualTo(animalUuid).findFirst();
    if (animal == null) return;
    final destination =
        await isar.isarLocations.where().uuidEqualTo(record.toLocation).findFirst() ??
        await isar.isarLocations.filter().nameEqualTo(record.toLocation).findFirst();
    animal
      ..currentLocationId = destination?.uuid
      ..lastMovementDate = record.date
      ..lastUpdateDate = DateTime.now()
      ..synced = false;
    await isar.isarAnimals.put(animal);
  }
}
