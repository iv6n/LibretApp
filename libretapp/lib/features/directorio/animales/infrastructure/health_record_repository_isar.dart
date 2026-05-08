/// features › directorio › animales › infrastructure › health_record_repository_isar
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_health_record.dart';

class HealthRecordRepositoryIsar implements HealthRecordRepository {
  HealthRecordRepositoryIsar(this._database);

  static const _logTag = 'HealthRecordRepositoryIsar';
  final IsarDatabase _database;

  Future<Isar> get _isar async => _database.initialize();

  @override
  Future<List<HealthRecord>> getHealthRecords(String animalUuid) async {
    final isar = await _isar;
    final records = await isar.isarHealthRecords
        .filter()
        .animalUuidEqualTo(animalUuid)
        .sortByDateDesc()
        .findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<HealthRecord> addHealthRecord(
    String animalUuid,
    HealthRecord record,
  ) async {
    final isar = await _isar;
    final model = record.toIsar(animalUuid);
    await isar.writeTxn(() async {
      final id = await isar.isarHealthRecords.put(model);
      model.id = id;
    });
    final saved = model.toEntity();
    LoggerService.i(
      'Registro sanitario guardado para $animalUuid (${saved.id})',
      tag: _logTag,
    );
    return saved;
  }

  @override
  Future<void> addHealthRecordToMultiple(
    List<String> animalUuids,
    HealthRecord record,
  ) async {
    if (animalUuids.isEmpty) return;
    final isar = await _isar;
    final models = animalUuids
        .map((animalUuid) => record.toIsar(animalUuid))
        .toList(growable: false);
    await isar.writeTxn(() async {
      await isar.isarHealthRecords.putAll(models);
    });
    LoggerService.i(
      'Registro sanitario masivo guardado para ${animalUuids.length} animales',
      tag: _logTag,
    );
  }

  @override
  Future<void> deleteHealthRecord(String recordId) async {
    final isar = await _isar;
    final id = int.tryParse(recordId);
    if (id == null) return;
    await isar.writeTxn(() async {
      await isar.isarHealthRecords.delete(id);
    });
  }
}
