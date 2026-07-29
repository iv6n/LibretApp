/// features › directorio › animales › domain › repositories › reproduction_record_repository
library;

import 'package:libretapp/core/sync/syncable_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';

abstract class ReproductionRecordRepository
    implements AnimalScopedSyncableRepository<ReproductionRecord> {
  Future<List<ReproductionRecord>> getReproductionRecords(String animalUuid);
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
