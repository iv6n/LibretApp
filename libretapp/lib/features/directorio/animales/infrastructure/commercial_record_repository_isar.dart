/// features › directorio › animales › infrastructure › commercial_record_repository_isar
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_commercial_record.dart';

class CommercialRecordRepositoryIsar implements CommercialRecordRepository {
  CommercialRecordRepositoryIsar(this._database);

  static const _logTag = 'CommercialRecordRepositoryIsar';
  final IsarDatabase _database;

  Future<Isar> get _isar async => _database.initialize();

  @override
  Future<List<CommercialRecord>> getCommercialRecords(String animalUuid) async {
    final isar = await _isar;
    final records = await isar.isarCommercialRecords
        .filter()
        .animalUuidEqualTo(animalUuid)
        .sortByDateDesc()
        .findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<CommercialRecord> addCommercialRecord(
    String animalUuid,
    CommercialRecord record,
  ) async {
    final isar = await _isar;
    final model = record.toIsar(animalUuid);
    await isar.writeTxn(() async {
      final id = await isar.isarCommercialRecords.put(model);
      model.id = id;
    });
    final saved = model.toEntity();
    LoggerService.i(
      'Registro comercial guardado para $animalUuid (${saved.id})',
      tag: _logTag,
    );
    return saved;
  }

  @override
  Future<void> deleteCommercialRecord(String recordId) async {
    final isar = await _isar;
    final id = int.tryParse(recordId);
    if (id == null) return;
    await isar.writeTxn(() async {
      await isar.isarCommercialRecords.delete(id);
    });
  }
}
