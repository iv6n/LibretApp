/// features › directorio › animales › domain › repositories › health_record_repository
library;

import 'package:libretapp/core/sync/syncable_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';

abstract class HealthRecordRepository
    implements AnimalScopedSyncableRepository<HealthRecord> {
  Future<List<HealthRecord>> getHealthRecords(String animalUuid);
  Future<HealthRecord> addHealthRecord(String animalUuid, HealthRecord record);
  Future<void> addHealthRecordToMultiple(
    List<String> animalUuids,
    HealthRecord record,
  );
  Future<void> deleteHealthRecord(String recordId);
}
