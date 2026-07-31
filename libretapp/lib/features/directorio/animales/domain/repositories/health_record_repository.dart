/// features › directorio › animales › domain › repositories › health_record_repository
library;

import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';

abstract class HealthRecordRepository {
  Future<List<HealthRecord>> getHealthRecords(String animalUuid);

  /// Latest withdrawal end date still in the future for each of [animalUuids],
  /// keyed by animal uuid. Animals with no running withdrawal are omitted.
  ///
  /// Deliberately narrower than "give me the health history": selling milk or
  /// meat from an animal under withdrawal is a food-safety breach, so this has
  /// to be answerable for a whole page of cards in one query.
  Future<Map<String, DateTime>> getActiveWithdrawals(
    Set<String> animalUuids, {
    DateTime? asOf,
  });
  Future<HealthRecord> addHealthRecord(String animalUuid, HealthRecord record);
  Future<void> addHealthRecordToMultiple(
    List<String> animalUuids,
    HealthRecord record,
  );
  Future<void> deleteHealthRecord(String recordId);
}
