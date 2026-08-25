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

/// Stable record that belongs to one animal.
///
/// Keeping this relationship in the type system lets shared repositories read
/// every animal record for export without relying on runtime casts.
abstract interface class StableAnimalRecordModel implements StableRecordModel {
  String get animalUuid;
  set animalUuid(String value);
}
