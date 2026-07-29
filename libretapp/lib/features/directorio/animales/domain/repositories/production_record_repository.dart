/// features › directorio › animales › domain › repositories › production_record_repository
library;

import 'package:libretapp/core/sync/syncable_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/production_record.dart';

abstract class ProductionRecordRepository
    implements AnimalScopedSyncableRepository<ProductionRecord> {
  Future<List<ProductionRecord>> getProductionRecords(String animalUuid);
  Future<ProductionRecord> addProductionRecord(
    String animalUuid,
    ProductionRecord record,
  );
  Future<void> deleteProductionRecord(String recordId);
}
