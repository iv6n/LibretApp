/// Mixin for entities that support remote synchronization.
///
/// Provides a standardized set of sync-tracking fields:
/// - [synced]: Whether the entity is in sync with the remote
/// - [remoteId]: The entity's ID on the remote server
/// - [syncDate]: When the last successful sync occurred
/// - [contentHash]: Hash for detecting local vs remote changes
///
/// Usage:
/// ```dart
/// class MyEntity extends Equatable with Syncable {
///   @override
///   final bool synced;
///   @override
///   final String? remoteId;
///   @override
///   final DateTime? syncDate;
///   @override
///   final String? contentHash;
/// }
/// ```
mixin Syncable {
  bool get synced;
  String? get remoteId;
  DateTime? get syncDate;
  String? get contentHash;

  /// Whether this entity needs to be pushed to the remote.
  bool get needsSync => !synced;
}
