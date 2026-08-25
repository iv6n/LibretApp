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

/// Herd-wide "what happened lately" lookup.
///
/// Kept off [MovementRecordRepository] for the same reason as
/// [MovementRecordUuidLookup]: only the Isar implementation can answer it
/// cheaply, and the test fakes should not have to.
abstract interface class MovementRecordRecentLookup {
  /// The [limit] most recent movements across the whole herd, newest first,
  /// each paired with the animal it belongs to.
  ///
  /// Exists because the reports screen wants "the last few things that
  /// happened" and had been asking per animal: one query each, every record
  /// mapped into an entity, then all but five thrown away.
  Future<List<({String animalUuid, MovementRecord record})>>
  getRecentMovementRecords({int limit = 5});
}

abstract interface class MovementRecordUuidLookup {
  Future<Map<String, MovementRecord>> getMovementRecordsByRecordUuids(
    Set<String> recordUuids,
  );
}
