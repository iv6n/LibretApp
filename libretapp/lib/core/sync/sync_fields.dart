/// core › sync › sync_fields — structural contract for Isar models that carry
/// cloud-backup bookkeeping (`synced`, `remoteId`, `syncDate`, `contentHash`).
library;

/// Implemented by `@collection` classes via their own public fields of the
/// same name — `late bool synced = false;`, `String? remoteId;`, etc. — so no
/// behavior is added here, just a shared shape the generic sync plumbing can
/// operate on without knowing the concrete Isar model type.
abstract class SyncFields {
  bool get synced;
  set synced(bool value);

  String? get remoteId;
  set remoteId(String? value);

  DateTime? get syncDate;
  set syncDate(DateTime? value);

  String? get contentHash;
  set contentHash(String? value);
}

/// [SyncFields] plus the owning animal's uuid, for the animal "child record"
/// Isar models (health, weight, movement, cost, commercial, production,
/// reproduction) whose domain entities don't carry that uuid themselves.
abstract class AnimalRecordSyncFields implements SyncFields {
  String get animalUuid;
}
