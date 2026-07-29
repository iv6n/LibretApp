/// features › directorio › animales › domain › repositories › production_record_repository
library;

import 'package:libretapp/features/directorio/animales/domain/entities/production_record.dart';

abstract class ProductionRecordRepository {
  Future<List<ProductionRecord>> getProductionRecords(String animalUuid);
  Future<ProductionRecord> addProductionRecord(
    String animalUuid,
    ProductionRecord record,
  );
  Future<void> deleteProductionRecord(String recordId);
}
