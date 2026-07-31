/// features › directorio › animales › domain › repositories › weight_record_repository
library;

import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';

abstract class WeightRecordRepository {
  Future<List<WeightRecord>> getWeightRecords(String animalUuid);

  /// Weight history for several animals in one query, keyed by animal uuid and
  /// ordered newest first. Animals with no weighings are omitted.
  Future<Map<String, List<WeightRecord>>> getWeightRecordsForAnimals(
    Set<String> animalUuids,
  );
  Future<WeightRecord> addWeightRecord(String animalUuid, WeightRecord record);
  Future<void> deleteWeightRecord(String recordId);
}
