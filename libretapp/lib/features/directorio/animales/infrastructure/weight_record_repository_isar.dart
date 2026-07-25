/// features › directorio › animales › infrastructure › weight_record_repository_isar
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_weight_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';

class WeightRecordRepositoryIsar implements WeightRecordRepository {
  WeightRecordRepositoryIsar(this._database);

  static const _logTag = 'WeightRecordRepositoryIsar';
  final IsarDatabase _database;

  Future<Isar> get _isar async => _database.initialize();

  @override
  Future<List<WeightRecord>> getWeightRecords(String animalUuid) async {
    final isar = await _isar;
    final records = await isar.isarWeightRecords
        .filter()
        .animalUuidEqualTo(animalUuid)
        .sortByDateDesc()
        .findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<WeightRecord> addWeightRecord(
    String animalUuid,
    WeightRecord record,
  ) async {
    final isar = await _isar;
    final model = record.toIsar(animalUuid);
    await isar.writeTxn(() async {
      final id = await isar.isarWeightRecords.put(model);
      model.id = id;
      final animal = await isar.isarAnimals.where().uuidEqualTo(animalUuid).findFirst();
      if (animal != null) {
        animal
          ..weight = record.weight
          ..lastUpdateDate = DateTime.now()
          ..synced = false;
        await isar.isarAnimals.put(animal);
      }
    });
    final saved = model.toEntity();
    LoggerService.i(
      'Peso registrado para $animalUuid (${saved.id})',
      tag: _logTag,
    );
    return saved;
  }

  @override
  Future<void> deleteWeightRecord(String recordId) async {
    final isar = await _isar;
    final id = int.tryParse(recordId);
    if (id == null) return;
    await isar.writeTxn(() async {
      await isar.isarWeightRecords.delete(id);
    });
  }
}
