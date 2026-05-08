/// features › directorio › animales › domain › repositories › cost_record_repository
library;

import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';

abstract class CostRecordRepository {
  Future<List<CostRecord>> getCostRecords(String animalUuid);
  Future<CostRecord> addCostRecord(String animalUuid, CostRecord record);
  Future<void> deleteCostRecord(String recordId);
}
