/// features › directorio › animales › infrastructure › reproduction_record_repository_isar
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_reproduction_record.dart';

class ReproductionRecordRepositoryIsar implements ReproductionRecordRepository {
  ReproductionRecordRepositoryIsar(this._database);

  static const _logTag = 'ReproductionRecordRepositoryIsar';
  final IsarDatabase _database;

  Future<Isar> get _isar async => _database.initialize();

  @override
  Future<List<ReproductionRecord>> getReproductionRecords(
    String animalUuid,
  ) async {
    final isar = await _isar;
    final records = await isar.isarReproductionRecords
        .filter()
        .animalUuidEqualTo(animalUuid)
        .sortByServiceDateDesc()
        .findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<ReproductionRecord> addReproductionRecord(
    String animalUuid,
    ReproductionRecord record,
  ) async {
    final isar = await _isar;
    final model = record.toIsar(animalUuid);
    await isar.writeTxn(() async {
      final id = await isar.isarReproductionRecords.put(model);
      model.id = id;
    });
    final saved = model.toEntity();
    LoggerService.i(
      'Evento reproductivo guardado para $animalUuid (${saved.id})',
      tag: _logTag,
    );
    return saved;
  }

  @override
  Future<void> deleteReproductionRecord(String recordId) async {
    final isar = await _isar;
    final id = int.tryParse(recordId);
    if (id == null) return;
    await isar.writeTxn(() async {
      await isar.isarReproductionRecords.delete(id);
    });
  }

  @override
  Future<List<({String animalUuid, DateTime expectedCalvingDate})>>
      getUpcomingCalvings(DateTime from, DateTime to) async {
    final isar = await _isar;
    final records = await isar.isarReproductionRecords
        .filter()
        .expectedCalvingDateBetween(from, to)
        .actualCalvingDateIsNull()
        .findAll();
    return records
        .map(
          (r) => (
            animalUuid: r.animalUuid,
            expectedCalvingDate: r.expectedCalvingDate!,
          ),
        )
        .toList(growable: false);
  }
}
