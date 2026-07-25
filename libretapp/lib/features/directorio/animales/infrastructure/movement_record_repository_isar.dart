/// features › directorio › animales › infrastructure › movement_record_repository_isar
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_movement_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/isar/isar_location.dart';

class MovementRecordRepositoryIsar implements MovementRecordRepository {
  MovementRecordRepositoryIsar(this._database);

  static const _logTag = 'MovementRecordRepositoryIsar';
  final IsarDatabase _database;

  Future<Isar> get _isar async => _database.initialize();

  @override
  Future<List<MovementRecord>> getMovementRecords(String animalUuid) async {
    final isar = await _isar;
    final records = await isar.isarMovementRecords
        .filter()
        .animalUuidEqualTo(animalUuid)
        .sortByDateDesc()
        .findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<MovementRecord> addMovementRecord(
    String animalUuid,
    MovementRecord record,
  ) async {
    final isar = await _isar;
    final model = record.toIsar(animalUuid);
    await isar.writeTxn(() async {
      final id = await isar.isarMovementRecords.put(model);
      model.id = id;
      final animal = await isar.isarAnimals.where().uuidEqualTo(animalUuid).findFirst();
      if (animal != null) {
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
    });
    final saved = model.toEntity();
    LoggerService.i(
      'Movimiento guardado para $animalUuid (${saved.id})',
      tag: _logTag,
    );
    return saved;
  }

  @override
  Future<void> deleteMovementRecord(String recordId) async {
    final isar = await _isar;
    final id = int.tryParse(recordId);
    if (id == null) return;
    await isar.writeTxn(() async {
      await isar.isarMovementRecords.delete(id);
    });
  }
}
