library;

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:libretapp/core/persistence/drift_feature_database.dart';
import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/core/persistence/web_feature_database.dart';
import 'package:libretapp/core/utils/numeric_validation.dart';

/// Drift implementation used by the web/WASM composition root.
class DriftFeatureRecordStore
    implements
        FeatureRecordStore,
        TransactionalFeatureRecordStore,
        WatchableFeatureRecordStore {
  DriftFeatureRecordStore(this._database, {bool inTransaction = false})
    : _inTransaction = inTransaction;

  static Future<DriftFeatureRecordStore> open({
    String databaseName = 'libretapp_features',
  }) async {
    final database = await openWebFeatureDatabase(
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
      databaseName: databaseName,
    );
    return DriftFeatureRecordStore(database);
  }

  final DriftFeatureDatabase _database;
  final bool _inTransaction;
  @override
  Future<T> runTransaction<T>(
    Future<T> Function(FeatureRecordStore store) action,
  ) async {
    // Repositories retain the root store, so also join its asynchronous scope.
    // Nested savepoints can release OPFS's navigator lock before the outer
    // transaction finishes and deadlock against a waiting stream query.
    if (_inTransaction || Zone.current[_database] == true) return action(this);
    final result = await _database.transaction(
      () => runZoned(
        () => action(DriftFeatureRecordStore(_database, inTransaction: true)),
        zoneValues: {_database: true},
      ),
    );
    // Drift 2.35's IndexedDB WASM delegate flushes non-transactional custom
    // statements. COMMIT runs while its transaction flag is still set, so a
    // final write could otherwise be acknowledged before reaching IndexedDB.
    // This no-op runs after COMMIT and awaits that durable flush before the
    // caller can announce a saved draft or completion receipt.
    await _database.customStatement('SELECT 1');
    return result;
  }

  Future<void> close() => _database.close();

  @override
  Stream<List<FeatureRecord>> watch(String farmId, String kind) =>
      (_database.select(_database.driftFeatureRecords)..where(
            (t) =>
                t.farmId.equals(farmId) &
                t.kind.equals(kind) &
                t.deletedAt.isNull(),
          ))
          .watch()
          .map((rows) => rows.map(_fromRow).toList(growable: false));

  @override
  Future<FeatureRecord?> get(String farmId, String uuid) async {
    final row =
        await (_database.select(_database.driftFeatureRecords)
              ..where((t) => t.uuid.equals(uuid) & t.farmId.equals(farmId)))
            .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<List<FeatureRecord>> list(
    String farmId,
    String kind, {
    bool includeDeleted = false,
  }) async {
    final query = _database.select(_database.driftFeatureRecords)
      ..where((t) => t.farmId.equals(farmId) & t.kind.equals(kind));
    final rows = await query.get();
    return rows
        .where((row) => includeDeleted || row.deletedAt == null)
        .map(_fromRow)
        .toList(growable: false);
  }

  @override
  Future<List<FeatureRecord>> listAll({bool includeDeleted = false}) async {
    final rows = await _database.select(_database.driftFeatureRecords).get();
    return rows
        .where((row) => includeDeleted || row.deletedAt == null)
        .map(_fromRow)
        .toList(growable: false);
  }

  @override
  Future<void> put(
    FeatureRecord record, {
    List<FeatureRecord> alsoPut = const [],
  }) async {
    for (final row in [record, ...alsoPut]) {
      requireFiniteNumbers(row.payload);
    }
    await runTransaction((store) async {
      for (final item in [record, ...alsoPut]) {
        final old = await (_database.select(
          _database.driftFeatureRecords,
        )..where((t) => t.uuid.equals(item.uuid))).getSingleOrNull();
        if (old != null &&
            (old.farmId != item.farmId || old.kind != item.kind)) {
          throw ArgumentError('El UUID pertenece a otra finca o tipo.');
        }
        await _database
            .into(_database.driftFeatureRecords)
            .insertOnConflictUpdate(_companion(item));
      }
    });
  }

  @override
  Future<void> softDelete({
    required String farmId,
    required String uuid,
    required String kind,
  }) async {
    final current = await get(farmId, uuid);
    if (current == null || current.kind != kind) return;
    final now = DateTime.now().toUtc();
    await put(
      current.copyWith(
        deletedAt: now,
        updatedAt: now,
        revision: current.revision + 1,
        synced: false,
      ),
    );
  }

  @override
  Future<void> markSynced(String farmId, String uuid, int revision) async {
    final current = await get(farmId, uuid);
    if (current != null) {
      await put(current.copyWith(revision: revision, synced: true));
    }
  }

  FeatureRecord _fromRow(DriftFeatureRecord row) => FeatureRecord(
    uuid: row.uuid,
    farmId: row.farmId,
    kind: row.kind,
    payload: Map<String, dynamic>.from(jsonDecode(row.payloadJson) as Map),
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
    revision: row.revision,
    synced: row.synced,
  );

  DriftFeatureRecordsCompanion _companion(FeatureRecord record) =>
      DriftFeatureRecordsCompanion.insert(
        uuid: record.uuid,
        farmId: record.farmId,
        kind: record.kind,
        payloadJson: jsonEncode(record.payload),
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: Value(record.deletedAt),
        revision: Value(record.revision),
        synced: Value(record.synced),
      );
}
