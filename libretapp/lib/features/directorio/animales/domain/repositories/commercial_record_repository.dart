/// features › directorio › animales › domain › repositories › commercial_record_repository
library;

import 'package:libretapp/core/sync/syncable_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';

abstract class CommercialRecordRepository
    implements AnimalScopedSyncableRepository<CommercialRecord> {
  Future<List<CommercialRecord>> getCommercialRecords(String animalUuid);
  Future<CommercialRecord> addCommercialRecord(
    String animalUuid,
    CommercialRecord record,
  );
  Future<void> deleteCommercialRecord(String recordId);
}
