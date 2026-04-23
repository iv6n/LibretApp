/// Mixin for entities that track creation and modification timestamps.
///
/// Provides a standardized pair of audit fields:
/// - [createdAt]: When the entity was first created
/// - [updatedAt]: When the entity was last modified
///
/// Usage:
/// ```dart
/// class MyEntity extends Equatable with Auditable {
///   @override
///   final DateTime createdAt;
///   @override
///   final DateTime updatedAt;
/// }
/// ```
mixin Auditable {
  DateTime get createdAt;
  DateTime get updatedAt;
}
