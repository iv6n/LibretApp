/// features › directorio › animales › infrastructure › cost_record_repository_isar
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_cost_record.dart';

class CostRecordRepositoryIsar implements CostRecordRepository {
  CostRecordRepositoryIsar(this._database);

  static const _logTag = 'CostRecordRepositoryIsar';
  final IsarDatabase _database;

  Future<Isar> get _isar async => _database.initialize();

  @override
  Future<List<CostRecord>> getCostRecords(String animalUuid) async {
    final isar = await _isar;
    final records = await isar.isarCostRecords
        .filter()
        .animalUuidEqualTo(animalUuid)
        .sortByDateDesc()
        .findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<CostRecord> addCostRecord(String animalUuid, CostRecord record) async {
    final isar = await _isar;
    final model = record.toIsar(animalUuid);
    await isar.writeTxn(() async {
      final id = await isar.isarCostRecords.put(model);
      model.id = id;
    });
    final saved = model.toEntity();
    LoggerService.i(
      'Costo guardado para $animalUuid (${saved.id})',
      tag: _logTag,
    );
    return saved;
  }

  @override
  Future<void> deleteCostRecord(String recordId) async {
    final isar = await _isar;
    final id = int.tryParse(recordId);
    if (id == null) return;
    await isar.writeTxn(() async {
      await isar.isarCostRecords.delete(id);
    });
  }
}
