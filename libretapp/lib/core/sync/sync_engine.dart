library;

import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/core/sync/sync_models.dart';
import 'package:uuid/uuid.dart';

class SyncEngine {
  SyncEngine({required FeatureRecordStore store, required SyncGateway gateway})
      : _store = store, _gateway = gateway;

  static const _operationKind = 'core.sync_operation';
  static const _conflictKind = 'core.sync_conflict';
  static const _cursorKind = 'core.sync_cursor';
  final FeatureRecordStore _store;
  final SyncGateway _gateway;
  bool _running = false;

  Future<void> enqueue({required FeatureRecord record, required SyncOperationType type}) async {
    final operation = SyncOperation(
      uuid: const Uuid().v4(), farmId: record.farmId, entityKind: record.kind,
      entityUuid: record.uuid, type: type, payload: record.payload,
      createdAt: DateTime.now().toUtc(), baseRevision: record.revision,
    );
    await _store.put(
      record.copyWith(synced: false),
      alsoPut: [_meta(operation.uuid, record.farmId, _operationKind, operation.toJson())],
    );
  }

  Future<SyncReport> sync(String farmId) async {
    if (_running) return const SyncReport(skipped: true);
    _running = true;
    try {
      final operationRows = await _store.list(farmId, _operationKind);
      final operations = operationRows.map((r) => SyncOperation.fromJson(r.payload)).toList();
      SyncPushResult push;
      try {
        push = operations.isEmpty ? const SyncPushResult() : await _gateway.push(operations);
      } catch (error) {
        // Keep the queue durable and record the attempt. A provider timeout
        // may have committed remotely, so the operation UUID remains the
        // idempotency key on the next retry.
        for (final operation in operations) {
          final retry = operation.retry(error.toString());
          await _store.put(_meta(operation.uuid, farmId, _operationKind, retry.toJson()));
        }
        return SyncReport(failed: operations.length);
      }
      for (final operation in operations.where((o) => push.applied.contains(o.uuid))) {
        if (operation.type == SyncOperationType.delete) {
          // Keep the tombstone locally until the server confirms the delete.
          // This makes deletes recoverable across retries and prevents a
          // later pull from resurrecting the record.
          await _store.softDelete(
            farmId: farmId,
            uuid: operation.entityUuid,
            kind: operation.entityKind,
          );
        }
        await _store.markSynced(farmId, operation.entityUuid, operation.baseRevision ?? 0);
        await _store.softDelete(farmId: farmId, uuid: operation.uuid, kind: _operationKind);
      }
      for (final conflict in push.conflicts) {
        await _store.put(_meta(conflict.uuid, farmId, _conflictKind, conflict.toJson()));
      }
      final current = await _cursor(farmId);
      final pulled = await _gateway.pull(farmId: farmId, cursor: current);
      for (final incoming in pulled.operations) {
        await _applyIncoming(incoming);
      }
      if (pulled.cursor != null) {
        final cursor = pulled.cursor!;
        await _store.put(_meta('cursor-$farmId', farmId, _cursorKind, cursor.toJson()));
      }
      return SyncReport(
        pushed: push.applied.length, pulled: pulled.operations.length,
        conflicts: push.conflicts.length,
      );
    } finally {
      _running = false;
    }
  }

  Future<void> _applyIncoming(SyncOperation incoming) async {
    final local = await _store.get(incoming.farmId, incoming.entityUuid);
    if (local != null && !local.synced && local.updatedAt.isAfter(incoming.createdAt)) {
      final conflict = ConflictRecord(
        uuid: const Uuid().v4(), farmId: incoming.farmId, entityKind: incoming.entityKind,
        entityUuid: incoming.entityUuid, local: local.payload, remote: incoming.payload,
        detectedAt: DateTime.now().toUtc(),
      );
      await _store.put(_meta(conflict.uuid, incoming.farmId, _conflictKind, conflict.toJson()));
      return;
    }
    if (incoming.type == SyncOperationType.delete) {
      if (local == null) {
        final now = DateTime.now().toUtc();
        await _store.put(FeatureRecord(
          uuid: incoming.entityUuid,
          farmId: incoming.farmId,
          kind: incoming.entityKind,
          payload: incoming.payload,
          createdAt: now,
          updatedAt: now,
          revision: (incoming.baseRevision ?? 0) + 1,
          synced: true,
          deletedAt: now,
        ));
      } else {
        await _store.softDelete(farmId: incoming.farmId, uuid: incoming.entityUuid, kind: incoming.entityKind);
      }
      return;
    }
    final now = DateTime.now().toUtc();
    await _store.put(FeatureRecord(
      uuid: incoming.entityUuid, farmId: incoming.farmId, kind: incoming.entityKind,
      payload: incoming.payload, createdAt: local?.createdAt ?? now, updatedAt: now,
      revision: (incoming.baseRevision ?? 0) + 1, synced: true,
    ));
  }

  Future<SyncCursor?> _cursor(String farmId) async {
    final row = await _store.get(farmId, 'cursor-$farmId');
    return row == null ? null : SyncCursor.fromJson(row.payload);
  }

  FeatureRecord _meta(String uuid, String farmId, String kind, Map<String, dynamic> payload) {
    final now = DateTime.now().toUtc();
    return FeatureRecord(uuid: uuid, farmId: farmId, kind: kind, payload: payload, createdAt: now, updatedAt: now);
  }
}

class SyncReport {
  const SyncReport({this.pushed = 0, this.pulled = 0, this.conflicts = 0, this.failed = 0, this.skipped = false});
  final int pushed;
  final int pulled;
  final int conflicts;
  final int failed;
  final bool skipped;
}
