/// features › directorio › animales › domain › repositories › reproduction_record_repository
library;

import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';

abstract class ReproductionRecordRepository {
  Future<List<ReproductionRecord>> getReproductionRecords(String animalUuid);
  Future<ReproductionRecord> addReproductionRecord(
    String animalUuid,
    ReproductionRecord record,
  );
  Future<void> deleteReproductionRecord(String recordId);
}
