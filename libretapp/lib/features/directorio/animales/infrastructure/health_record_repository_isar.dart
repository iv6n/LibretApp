/// features › directorio › animales › infrastructure › health_record_repository_isar
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_health_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar_record_repository_base.dart';

class HealthRecordRepositoryIsar
    extends IsarRecordRepositoryBase<HealthRecord, IsarHealthRecord>
    implements HealthRecordRepository {
  HealthRecordRepositoryIsar(super.database);

  @override
  String get logTag => 'HealthRecordRepositoryIsar';

  @override
  IsarCollection<IsarHealthRecord> collection(Isar isar) => isar.isarHealthRecords;

  @override
  Future<List<IsarHealthRecord>> queryByAnimal(
    IsarCollection<IsarHealthRecord> collection,
    String animalUuid,
  ) => collection.filter().animalUuidEqualTo(animalUuid).sortByDateDesc().findAll();

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
  Future<HealthRecord> addHealthRecord(
    String animalUuid,
    HealthRecord record,
  ) => addRecordFor(
    animalUuid,
    record,
    onSaved: (isar, _) => _applyHealthEffects(isar, animalUuid, record),
  );

  @override
  Future<void> addHealthRecordToMultiple(
    List<String> animalUuids,
    HealthRecord record,
  ) async {
    if (animalUuids.isEmpty) return;
    final db = await isar;
    final models = animalUuids
        .map((animalUuid) => record.toIsar(animalUuid))
        .toList(growable: false);
    await db.writeTxn(() async {
      await db.isarHealthRecords.putAll(models);
      final now = DateTime.now();
      for (final animalUuid in animalUuids) {
        await _applyHealthEffects(db, animalUuid, record, now: now);
      }
    });
    LoggerService.i(
      'Registro sanitario masivo guardado para ${animalUuids.length} animales',
      tag: logTag,
    );
  }

  @override
  Future<void> deleteHealthRecord(String recordId) => deleteRecordById(recordId);

  Future<void> _applyHealthEffects(
    Isar isar,
    String animalUuid,
    HealthRecord record, {
    DateTime? now,
  }) async {
    final animal = await isar.isarAnimals.where().uuidEqualTo(animalUuid).findFirst();
    if (animal == null) return;
    if (record.type == HealthRecordType.vaccine) animal.vaccinated = true;
    if (record.type == HealthRecordType.deworming) animal.dewormed = true;
    if (record.type == HealthRecordType.vitamins) animal.hasVitamins = true;
    if (record.type == HealthRecordType.disease) {
      animal
        ..underObservation = true
        ..requiresAttention = true;
    }
    animal
      ..lastUpdateDate = now ?? DateTime.now()
      ..synced = false;
    await isar.isarAnimals.put(animal);
  }
}
