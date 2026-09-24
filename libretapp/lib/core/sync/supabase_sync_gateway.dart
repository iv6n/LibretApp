library;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:libretapp/core/sync/sync_models.dart';

class SupabaseSyncGateway implements SyncGateway {
  SupabaseSyncGateway(this._client);
  final SupabaseClient _client;

  @override
  Future<SyncPushResult> push(List<SyncOperation> operations) async {
    final applied = <String>[];
    final conflicts = <ConflictRecord>[];
    for (final operation in operations) {
      final seen = await _client.from('sync_operations').select('operation_uuid,applied_at').eq('operation_uuid', operation.uuid).maybeSingle();
      if (seen != null && seen['applied_at'] != null) {
        applied.add(operation.uuid);
        continue;
      }
      final current = await _client.from('feature_records').select('payload,revision,updated_at').eq('uuid', operation.entityUuid).eq('farm_id', operation.farmId).maybeSingle();
      final serverRevision = (current?['revision'] as num?)?.toInt();
      if (current != null && operation.baseRevision != null && serverRevision != operation.baseRevision) {
        conflicts.add(ConflictRecord(uuid: 'server-${operation.uuid}', farmId: operation.farmId, entityKind: operation.entityKind, entityUuid: operation.entityUuid, local: operation.payload, remote: Map<String, dynamic>.from(current['payload'] as Map), detectedAt: DateTime.now().toUtc()));
        continue;
      }
      final now = DateTime.now().toUtc().toIso8601String();
      if (operation.type == SyncOperationType.delete) {
        await _client.from('feature_records').update({'deleted_at': now, 'updated_at': now, 'revision': (serverRevision ?? 0) + 1, 'updated_by': _client.auth.currentUser?.id}).eq('uuid', operation.entityUuid).eq('farm_id', operation.farmId);
      } else {
        await _client.from('feature_records').upsert({'uuid': operation.entityUuid, 'farm_id': operation.farmId, 'kind': operation.entityKind, 'payload': operation.payload, 'created_at': now, 'updated_at': now, 'revision': (serverRevision ?? 0) + 1, 'updated_by': _client.auth.currentUser?.id});
      }
      await _client.from('sync_operations').upsert({'operation_uuid': operation.uuid, 'farm_id': operation.farmId, 'entity_uuid': operation.entityUuid, 'kind': operation.entityKind, 'operation': operation.type.name, 'base_revision': operation.baseRevision, 'applied_at': now});
      applied.add(operation.uuid);
    }
    return SyncPushResult(applied: applied, conflicts: conflicts);
  }

  @override
  Future<SyncBatch> pull({required String farmId, SyncCursor? cursor}) async {
    final filtered = _client.from('feature_records').select().eq('farm_id', farmId);
    final rows = await (cursor == null ? filtered : filtered.gt('updated_at', cursor.value)).order('updated_at').limit(1000);
    final operations = rows.map((row) {
      final map = Map<String, dynamic>.from(row);
      final deleted = map['deleted_at'] != null;
      return SyncOperation(uuid: 'remote-${map['uuid']}', farmId: farmId, entityKind: map['kind'] as String, entityUuid: map['uuid'] as String, type: deleted ? SyncOperationType.delete : SyncOperationType.upsert, payload: Map<String, dynamic>.from((map['payload'] as Map?) ?? const {}), createdAt: DateTime.parse(map['updated_at'] as String).toUtc(), baseRevision: (map['revision'] as num?)?.toInt());
    }).toList(growable: false);
    final next = rows.isEmpty ? cursor : SyncCursor(farmId: farmId, value: rows.last['updated_at'] as String);
    return SyncBatch(operations: operations, cursor: next);
  }
}

class UnavailableSyncGateway implements SyncGateway {
  const UnavailableSyncGateway();
  @override
  Future<SyncPushResult> push(List<SyncOperation> operations) => throw StateError('La sincronización remota no está configurada.');
  @override
  Future<SyncBatch> pull({required String farmId, SyncCursor? cursor}) => throw StateError('La sincronización remota no está configurada.');
}
