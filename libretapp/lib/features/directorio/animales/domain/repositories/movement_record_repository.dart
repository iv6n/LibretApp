/// features › directorio › animales › domain › repositories › movement_record_repository
library;

import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';

abstract class MovementRecordRepository {
  Future<List<MovementRecord>> getMovementRecords(String animalUuid);
  Future<MovementRecord> addMovementRecord(
    String animalUuid,
    MovementRecord record,
  );
  Future<void> deleteMovementRecord(String recordId);
}
