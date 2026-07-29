/// features › directorio › animales › domain › repositories › cost_record_repository
library;

import 'package:libretapp/core/sync/syncable_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';

abstract class CostRecordRepository
    implements AnimalScopedSyncableRepository<CostRecord> {
  Future<List<CostRecord>> getCostRecords(String animalUuid);
  Future<CostRecord> addCostRecord(String animalUuid, CostRecord record);
  Future<void> deleteCostRecord(String recordId);
}
