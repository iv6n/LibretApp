/// Persistence port for new domain verticals.
library;

class FeatureRecord {
  const FeatureRecord({
    required this.uuid,
    required this.farmId,
    required this.kind,
    required this.payload,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.revision = 0,
    this.synced = false,
  });

  final String uuid;
  final String farmId;
  final String kind;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int revision;
  final bool synced;

  FeatureRecord copyWith({
    Map<String, dynamic>? payload,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? revision,
    bool? synced,
  }) => FeatureRecord(
    uuid: uuid,
    farmId: farmId,
    kind: kind,
    payload: payload ?? this.payload,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
    revision: revision ?? this.revision,
    synced: synced ?? this.synced,
  );

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'farmId': farmId,
    'kind': kind,
    'payload': payload,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'deletedAt': deletedAt?.toUtc().toIso8601String(),
    'revision': revision,
    'synced': synced,
  };

  factory FeatureRecord.fromJson(Map<String, dynamic> json) => FeatureRecord(
    uuid: json['uuid'] as String,
    farmId: json['farmId'] as String,
    kind: json['kind'] as String,
    payload: Map<String, dynamic>.from(json['payload'] as Map),
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
    deletedAt: (json['deletedAt'] as String?) == null
        ? null
        : DateTime.parse(json['deletedAt'] as String).toUtc(),
    revision: (json['revision'] as num?)?.toInt() ?? 0,
    synced: json['synced'] as bool? ?? false,
  );
}

abstract interface class FeatureRecordStore {
  Future<FeatureRecord?> get(String farmId, String uuid);
  Future<List<FeatureRecord>> list(
    String farmId,
    String kind, {
    bool includeDeleted = false,
  });

  /// Enumerates the shared envelope for backup/migration tooling. Legacy
  /// repositories may leave this unsupported while their collections are
  /// migrated; new web/native stores implement it transactionally.
  Future<List<FeatureRecord>> listAll({bool includeDeleted = false}) async =>
      throw UnsupportedError('Este almacenamiento aún no expone listAll.');
  Future<void> put(
    FeatureRecord record, {
    List<FeatureRecord> alsoPut = const [],
  });
  Future<void> softDelete({
    required String farmId,
    required String uuid,
    required String kind,
  });
  Future<void> markSynced(String farmId, String uuid, int revision);
}

/// The callback receives a store bound to one atomic database transaction.
/// Reads used for availability/identity checks belong in the same callback.
abstract interface class TransactionalFeatureRecordStore {
  Future<T> runTransaction<T>(
    Future<T> Function(FeatureRecordStore store) action,
  );
}

/// Emits committed snapshots, including changes made by another repository or
/// browser tab. Failed transactions must never publish their intermediate rows.
abstract interface class WatchableFeatureRecordStore {
  Stream<List<FeatureRecord>> watch(String farmId, String kind);
}
