/// core › sync › syncable_repository — contract for repositories that can push
/// unsynced local records to the cloud backup (Fase 1: solo subida).
library;

/// Implemented by repositories whose Isar collection carries `synced`,
/// `remoteId`, `syncDate` and `contentHash` bookkeeping fields.
///
/// [localId] is whatever identifier the repository already exposes on its
/// domain entity's `id` (either a real UUID for root entities, or the
/// stringified Isar autoincrement id for child records that have no UUID
/// of their own).
abstract class SyncableRepository<T> {
  /// Local records that have never been pushed, or were pushed and then
  /// modified again (`synced == false`).
  Future<List<T>> getUnsynchronized();

  /// Marks a local record as pushed, storing the id assigned in the cloud
  /// table (a generated UUID) and the sync timestamp.
  Future<void> markAsSynced(String localId, String remoteId);

  /// Flags a local record as needing to be pushed again, e.g. after a local
  /// edit that happened after the last successful sync.
  Future<void> markAsUnsynchronized(String localId);
}

/// Same contract as [SyncableRepository], but for the animal "child record"
/// repositories (health, weight, movement, cost, commercial, production,
/// reproduction): their domain entities don't carry the owning animal's
/// uuid (it's a parameter, not a field — see e.g. `HealthRecord.toIsar
/// (animalUuid)`), so the cloud row's foreign key has to travel alongside
/// each record rather than living on the entity itself.
abstract class AnimalScopedSyncableRepository<T> {
  Future<List<(String animalUuid, T record)>> getUnsynchronized();

  Future<void> markAsSynced(String localId, String remoteId);

  Future<void> markAsUnsynchronized(String localId);
}
