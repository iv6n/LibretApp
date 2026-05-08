/// features › directorio › animales › infrastructure › production_record_repository_isar
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/production_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_production_record.dart';

class ProductionRecordRepositoryIsar implements ProductionRecordRepository {
  ProductionRecordRepositoryIsar(this._database);

  static const _logTag = 'ProductionRecordRepositoryIsar';
  final IsarDatabase _database;

  Future<Isar> get _isar async => _database.initialize();

  @override
  Future<List<ProductionRecord>> getProductionRecords(String animalUuid) async {
    final isar = await _isar;
    final records = await isar.isarProductionRecords
        .filter()
        .animalUuidEqualTo(animalUuid)
        .sortByDateDesc()
        .findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<ProductionRecord> addProductionRecord(
    String animalUuid,
    ProductionRecord record,
  ) async {
    final isar = await _isar;
    final model = record.toIsar(animalUuid);
    await isar.writeTxn(() async {
      final id = await isar.isarProductionRecords.put(model);
      model.id = id;
    });
    final saved = model.toEntity();
    LoggerService.i(
      'Registro productivo guardado para $animalUuid (${saved.id})',
      tag: _logTag,
    );
    return saved;
  }

  @override
  Future<void> deleteProductionRecord(String recordId) async {
    final isar = await _isar;
    final id = int.tryParse(recordId);
    if (id == null) return;
    await isar.writeTxn(() async {
      await isar.isarProductionRecords.delete(id);
    });
  }
}
