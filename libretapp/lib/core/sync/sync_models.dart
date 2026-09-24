/// Offline-first synchronization contracts.
library;

enum SyncOperationType { upsert, delete }
enum SyncConflictResolution { pending, keepLocal, keepRemote, merged }

class SyncOperation {
  const SyncOperation({
    required this.uuid,
    required this.farmId,
    required this.entityKind,
    required this.entityUuid,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.baseRevision,
    this.attempts = 0,
    this.lastError,
  });

  final String uuid;
  final String farmId;
  final String entityKind;
  final String entityUuid;
  final SyncOperationType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int? baseRevision;
  final int attempts;
  final String? lastError;

  Map<String, dynamic> toJson() => {
    'uuid': uuid, 'farmId': farmId, 'entityKind': entityKind,
    'entityUuid': entityUuid, 'type': type.name, 'payload': payload,
    'createdAt': createdAt.toUtc().toIso8601String(), 'baseRevision': baseRevision,
    'attempts': attempts, 'lastError': lastError,
  };

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
    uuid: json['uuid'] as String,
    farmId: json['farmId'] as String,
    entityKind: json['entityKind'] as String,
    entityUuid: json['entityUuid'] as String,
    type: SyncOperationType.values.byName(json['type'] as String),
    payload: Map<String, dynamic>.from(json['payload'] as Map),
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    baseRevision: (json['baseRevision'] as num?)?.toInt(),
    attempts: (json['attempts'] as num?)?.toInt() ?? 0,
    lastError: json['lastError'] as String?,
  );

  SyncOperation retry(String error) => SyncOperation(
    uuid: uuid, farmId: farmId, entityKind: entityKind, entityUuid: entityUuid,
    type: type, payload: payload, createdAt: createdAt, baseRevision: baseRevision,
    attempts: attempts + 1, lastError: error,
  );
}

class SyncCursor {
  const SyncCursor({required this.farmId, required this.value});
  final String farmId;
  final String value;
  Map<String, dynamic> toJson() => {'farmId': farmId, 'value': value};
  factory SyncCursor.fromJson(Map<String, dynamic> json) => SyncCursor(
    farmId: json['farmId'] as String, value: json['value'] as String,
  );
}

class ConflictRecord {
  const ConflictRecord({
    required this.uuid,
    required this.farmId,
    required this.entityKind,
    required this.entityUuid,
    required this.local,
    required this.remote,
    required this.detectedAt,
    this.resolution = SyncConflictResolution.pending,
  });

  final String uuid;
  final String farmId;
  final String entityKind;
  final String entityUuid;
  final Map<String, dynamic> local;
  final Map<String, dynamic> remote;
  final DateTime detectedAt;
  final SyncConflictResolution resolution;

  Map<String, dynamic> toJson() => {
    'uuid': uuid, 'farmId': farmId, 'entityKind': entityKind, 'entityUuid': entityUuid,
    'local': local, 'remote': remote, 'detectedAt': detectedAt.toUtc().toIso8601String(),
    'resolution': resolution.name,
  };

  factory ConflictRecord.fromJson(Map<String, dynamic> json) => ConflictRecord(
    uuid: json['uuid'] as String, farmId: json['farmId'] as String,
    entityKind: json['entityKind'] as String, entityUuid: json['entityUuid'] as String,
    local: Map<String, dynamic>.from(json['local'] as Map),
    remote: Map<String, dynamic>.from(json['remote'] as Map),
    detectedAt: DateTime.parse(json['detectedAt'] as String).toUtc(),
    resolution: SyncConflictResolution.values.byName(json['resolution'] as String? ?? 'pending'),
  );
}

class SyncBatch {
  const SyncBatch({required this.operations, required this.cursor});
  final List<SyncOperation> operations;
  final SyncCursor? cursor;
}

class SyncPushResult {
  const SyncPushResult({this.applied = const [], this.conflicts = const []});
  final List<String> applied;
  final List<ConflictRecord> conflicts;
}

abstract interface class SyncGateway {
  Future<SyncPushResult> push(List<SyncOperation> operations);
  Future<SyncBatch> pull({required String farmId, SyncCursor? cursor});
}
