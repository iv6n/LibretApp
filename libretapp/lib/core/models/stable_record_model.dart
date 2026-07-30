/// Structural contract for Isar records that need a database-independent ID.
library;

/// The Isar [id] remains an internal local key. [recordUuid] survives exports,
/// restores, and future cloud synchronization.
abstract interface class StableRecordModel {
  int get id;
  set id(int value);

  String get recordUuid;
  set recordUuid(String value);
}
