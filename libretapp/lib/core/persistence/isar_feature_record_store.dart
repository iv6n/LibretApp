/// Isar implementation of the shared feature-record store.
library;

import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/core/persistence/isar_feature_record.dart';

class IsarFeatureRecordStore implements FeatureRecordStore {
  IsarFeatureRecordStore(this._database);

  final IsarDatabase _database;

  @override
  Future<FeatureRecord?> get(String farmId, String uuid) async {
    final row = await _database.isar.isarFeatureRecords
        .filter()
        .farmIdEqualTo(farmId)
        .uuidEqualTo(uuid)
        .findFirst();
    return row == null ? null : _fromIsar(row);
  }

  @override
  Future<List<FeatureRecord>> list(String farmId, String kind, {bool includeDeleted = false}) async {
    final rows = await (_database.isar.isarFeatureRecords
          .filter()
          .farmIdEqualTo(farmId)
          .kindEqualTo(kind)
          .sortByUpdatedAt())
        .findAll();
    return rows.where((row) => includeDeleted || row.deletedAt == null).map(_fromIsar).toList(growable: false);
  }

  @override
  Future<List<FeatureRecord>> listAll({bool includeDeleted = false}) async {
    final rows = await _database.isar.isarFeatureRecords.where().findAll();
    return rows.where((row) => includeDeleted || row.deletedAt == null).map(_fromIsar).toList(growable: false);
  }

  @override
  Future<void> put(FeatureRecord record, {List<FeatureRecord> alsoPut = const []}) async {
    await _database.isar.writeTxn(() async {
      await _database.isar.isarFeatureRecords.putAll([record, ...alsoPut].map(_toIsar).toList(growable: false));
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

  FeatureRecord _fromIsar(IsarFeatureRecord row) => FeatureRecord(
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

  IsarFeatureRecord _toIsar(FeatureRecord record) => IsarFeatureRecord()
    ..uuid = record.uuid
    ..farmId = record.farmId
    ..kind = record.kind
    ..payloadJson = jsonEncode(record.payload)
    ..createdAt = record.createdAt
    ..updatedAt = record.updatedAt
    ..deletedAt = record.deletedAt
    ..revision = record.revision
    ..synced = record.synced;
}
