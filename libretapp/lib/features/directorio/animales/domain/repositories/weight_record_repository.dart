/// features › directorio › animales › domain › repositories › weight_record_repository
library;

import 'package:libretapp/core/sync/syncable_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';

abstract class WeightRecordRepository
    implements AnimalScopedSyncableRepository<WeightRecord> {
  Future<List<WeightRecord>> getWeightRecords(String animalUuid);
  Future<WeightRecord> addWeightRecord(String animalUuid, WeightRecord record);
  Future<void> deleteWeightRecord(String recordId);
}
