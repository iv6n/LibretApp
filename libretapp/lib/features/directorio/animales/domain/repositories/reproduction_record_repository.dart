/// features › directorio › animales › domain › repositories › reproduction_record_repository
library;

import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';

abstract class ReproductionRecordRepository {
  Future<List<ReproductionRecord>> getReproductionRecords(String animalUuid);

  /// Records for several animals in one query, keyed by animal uuid.
  ///
  /// Exists so building the indicators for a page of cards costs one round
  /// trip instead of one per card. Animals with no records are omitted.
  Future<Map<String, List<ReproductionRecord>>> getReproductionRecordsForAnimals(
    Set<String> animalUuids,
  );
  Future<ReproductionRecord> addReproductionRecord(
    String animalUuid,
    ReproductionRecord record,
  );
  Future<void> deleteReproductionRecord(String recordId);

  /// Returns records whose [expectedCalvingDate] falls within [from]..[to]
  /// and whose [actualCalvingDate] is null (birth hasn't happened yet).
  Future<List<({String animalUuid, DateTime expectedCalvingDate})>>
      getUpcomingCalvings(DateTime from, DateTime to);
}
