/// features › directorio › animales › domain › repositories ›
/// editable_record_repository — correcting a record already on file.
library;

/// A record repository that can replace a stored record, not only append one.
///
/// Deliberately a narrow interface rather than a member of each
/// `*RecordRepository`, matching the shape already used by the `*UuidLookup`
/// and `*RecentLookup` contracts: only the Isar implementations can honour it,
/// and the fourteen test doubles across the suite should not have to grow a
/// method they never exercise.
///
/// Callers check for it the same way the agenda checks for `*UuidLookup`:
///
/// ```dart
/// final repo = ...;
/// if (repo is EditableRecordRepository<WeightRecord>) { ... }
/// ```
abstract interface class EditableRecordRepository<T> {
  /// Replaces the stored record that [record] identifies by its `id`, keeping
  /// that id and the record's stable uuid so anything referencing it — an
  /// agenda registration, a care cycle — still resolves.
  ///
  /// Throws if [record] carries no id, or if no such record exists: both mean
  /// the caller meant to add, and silently inserting would leave the breeder
  /// with two rows where they were correcting one.
  Future<T> updateRecord(String animalUuid, T record);
}
