/// features › directorio › animales › infrastructure › health_record_repository_isar
library;
import 'package:libretapp/core/database/isar_write_transaction.dart';

import 'package:isar_community/isar.dart';
import '../domain/services/animal_record_validation.dart';
import 'isar/isar_animal.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_health_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar_record_repository_base.dart';
import 'package:uuid/uuid.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_projection_recalculator.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_activity_tracker.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/editable_record_repository.dart';

class HealthRecordRepositoryIsar
    extends IsarRecordRepositoryBase<HealthRecord, IsarHealthRecord>
    implements
        HealthRecordRepository,
        HealthRecordUuidLookup,
        HealthRecordRecentLookup,
        EditableRecordRepository<HealthRecord> {
  HealthRecordRepositoryIsar(super.database);

  @override
  String get logTag => 'HealthRecordRepositoryIsar';

  @override
  IsarCollection<IsarHealthRecord> collection(Isar isar) =>
      isar.isarHealthRecords;

  @override
  Future<List<IsarHealthRecord>> queryByAnimal(
    IsarCollection<IsarHealthRecord> collection,
    String animalUuid,
  ) => collection
      .where()
      .animalUuidEqualTo(animalUuid)
      .sortByDateDesc()
      .findAll();

  @override
  IsarHealthRecord toIsarModel(HealthRecord record, String animalUuid) =>
      record.toIsar(animalUuid);

  @override
  HealthRecord toEntity(IsarHealthRecord model) => model.toEntity();

  @override
  void assignId(IsarHealthRecord model, int id) => model.id = id;

  @override
  String describeSaved(String animalUuid, HealthRecord saved) =>
      'Registro sanitario guardado para $animalUuid (${saved.id})';

  @override
  Future<List<HealthRecord>> getHealthRecords(String animalUuid) =>
      getRecordsFor(animalUuid);

  @override
  Future<List<({String animalUuid, HealthRecord record})>>
  getRecentHealthRecords({int limit = 5}) async {
    final db = await isar;
    final models = await db.isarHealthRecords
        .where()
        .sortByDateDesc()
        .limit(limit)
        .findAll();
    return models
        .map((m) => (animalUuid: m.animalUuid, record: m.toEntity()))
        .toList(growable: false);
  }

  @override
  Future<Map<String, HealthRecord>> getHealthRecordsByRecordUuids(
    Set<String> recordUuids,
  ) async {
    if (recordUuids.isEmpty) return const {};
    final db = await isar;
    final records = await db.isarHealthRecords
        .filter()
        .anyOf(recordUuids, (q, uuid) => q.recordUuidEqualTo(uuid))
        .findAll();
    return {for (final record in records) record.recordUuid: record.toEntity()};
  }

  @override
  Future<HealthRecord> addHealthRecord(
    String animalUuid,
    HealthRecord record,
  ) => addRecordFor(
    animalUuid,
    record,
    beforeWrite: (isar) => _validate(isar, animalUuid, record),
    onSaved: (isar, _) => AnimalProjectionRecalculator.recalculate(isar, animalUuid),
  );

  @override
  Future<void> addHealthRecordToMultiple(
    List<String> animalUuids,
    HealthRecord record,
  ) async {
    if (animalUuids.isEmpty) return;
    final db = await isar;
    final models = animalUuids
        .map(
          (animalUuid) =>
              record.toIsar(animalUuid)..recordUuid = const Uuid().v4(),
        )
        .toList(growable: false);
    await withIsarWriteTransaction(db, () async {
      for (final animalUuid in animalUuids.toSet()) { await _validate(db, animalUuid, record); }
      await db.isarHealthRecords.putAll(models);
      for (final animalUuid in animalUuids) {
        await AnimalActivityTracker.touch(db, animalUuid, DateTime.now());
        await AnimalProjectionRecalculator.recalculate(db, animalUuid);
      }
    });
    LoggerService.i(
      'Registro sanitario masivo guardado para ${animalUuids.length} animales',
      tag: logTag,
    );
  }

  Future<void> _validate(Isar db, String animalUuid, HealthRecord record) async {
    AnimalRecordValidation.health(record);
    final animal = await db.isarAnimals.where().uuidEqualTo(animalUuid).findFirst();
    if (animal == null) throw StateError('Animal no encontrado.');
    AnimalRecordValidation.operation(animal.toEntity(), record.date, editing: record.id != null);
  }

  @override
  Future<Map<String, DateTime>> getActiveWithdrawals(
    Set<String> animalUuids, {
    DateTime? asOf,
  }) async {
    if (animalUuids.isEmpty) return const {};

    final reference = asOf ?? DateTime.now();
    final db = await isar;
    final records = await db.isarHealthRecords
        .filter()
        .anyOf(animalUuids, (q, uuid) => q.animalUuidEqualTo(uuid))
        .withdrawalEndDateGreaterThan(reference)
        .findAll();

    // An animal can be under several treatments at once; the one that clears
    // last is the one that governs when its milk or meat may be sold.
    final latest = <String, DateTime>{};
    for (final record in records) {
      final endsOn = record.withdrawalEndDate;
      if (endsOn == null) continue;
      final current = latest[record.animalUuid];
      if (current == null || endsOn.isAfter(current)) {
        latest[record.animalUuid] = endsOn;
      }
    }
    return latest;
  }

  @override
  Future<void> deleteHealthRecord(String recordId) =>
      deleteRecordById(recordId);

  @override
  Future<HealthRecord> updateRecord(String animalUuid, HealthRecord record) =>
      updateRecordFor(
        animalUuid,
        record,
        beforeWrite: (isar) => _validate(isar, animalUuid, record),
        onSaved: (isar, _) => AnimalProjectionRecalculator.recalculate(isar, animalUuid),
      );
}
