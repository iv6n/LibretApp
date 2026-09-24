library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:libretapp/core/persistence/drift_feature_database.dart';
import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/core/persistence/web_feature_database.dart';

/// Drift implementation used by the web/WASM composition root.
class DriftFeatureRecordStore implements FeatureRecordStore {
  DriftFeatureRecordStore(this._database);

  static Future<DriftFeatureRecordStore> open() async {
    final database = await openWebFeatureDatabase(
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return DriftFeatureRecordStore(database);
  }

  final DriftFeatureDatabase _database;

  @override
  Future<FeatureRecord?> get(String farmId, String uuid) async {
    final row = await (_database.select(_database.driftFeatureRecords)
          ..where((t) => t.uuid.equals(uuid) & t.farmId.equals(farmId)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<List<FeatureRecord>> list(String farmId, String kind, {bool includeDeleted = false}) async {
    final query = _database.select(_database.driftFeatureRecords)
      ..where((t) => t.farmId.equals(farmId) & t.kind.equals(kind));
    final rows = await query.get();
    return rows.where((row) => includeDeleted || row.deletedAt == null).map(_fromRow).toList(growable: false);
  }

  @override
  Future<List<FeatureRecord>> listAll({bool includeDeleted = false}) async {
    final rows = await _database.select(_database.driftFeatureRecords).get();
    return rows.where((row) => includeDeleted || row.deletedAt == null).map(_fromRow).toList(growable: false);
  }

  @override
  Future<void> put(FeatureRecord record, {List<FeatureRecord> alsoPut = const []}) async {
    await _database.transaction(() async {
      for (final item in [record, ...alsoPut]) {
        await _database.into(_database.driftFeatureRecords).insertOnConflictUpdate(
          _companion(item),
        );
      }
    });
  }

  @override
  Future<void> softDelete({required String farmId, required String uuid, required String kind}) async {
    final current = await get(farmId, uuid);
    if (current == null || current.kind != kind) return;
    final now = DateTime.now().toUtc();
    await put(current.copyWith(deletedAt: now, updatedAt: now, revision: current.revision + 1, synced: false));
  }

  @override
  Future<void> markSynced(String farmId, String uuid, int revision) async {
    final current = await get(farmId, uuid);
    if (current != null) await put(current.copyWith(revision: revision, synced: true));
  }

  FeatureRecord _fromRow(DriftFeatureRecord row) => FeatureRecord(
    uuid: row.uuid, farmId: row.farmId, kind: row.kind,
    payload: Map<String, dynamic>.from(jsonDecode(row.payloadJson) as Map),
    createdAt: row.createdAt, updatedAt: row.updatedAt, deletedAt: row.deletedAt,
    revision: row.revision, synced: row.synced,
  );

  DriftFeatureRecordsCompanion _companion(FeatureRecord record) => DriftFeatureRecordsCompanion.insert(
    uuid: record.uuid, farmId: record.farmId, kind: record.kind,
    payloadJson: jsonEncode(record.payload), createdAt: record.createdAt,
    updatedAt: record.updatedAt, deletedAt: Value(record.deletedAt),
    revision: Value(record.revision), synced: Value(record.synced),
  );
}
