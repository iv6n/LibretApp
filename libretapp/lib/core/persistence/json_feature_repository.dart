library;

import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:uuid/uuid.dart';

typedef JsonDecoder<T> = T Function(Map<String, dynamic> json);
typedef JsonEncoder<T> = Map<String, dynamic> Function(T value);

/// Small repository shared by the new modules. It provides UUID identity,
/// farm scoping, soft deletion and the same write boundary used by sync.
class JsonFeatureRepository<T> {
  JsonFeatureRepository({required this.store, required this.kind, required this.decode, required this.encode});

  final FeatureRecordStore store;
  final String kind;
  final JsonDecoder<T> decode;
  final JsonEncoder<T> encode;

  Future<R> runTransaction<R>(Future<R> Function(JsonFeatureRepository<T> repository) action) {
    final transactional = store;
    if (transactional is! TransactionalFeatureRecordStore) {
      throw StateError('El almacenamiento no admite una operación atómica.');
    }
    return (transactional as TransactionalFeatureRecordStore).runTransaction((scoped) => action(JsonFeatureRepository<T>(
      store: scoped, kind: kind, decode: decode, encode: encode)));
  }

  Future<List<T>> list(String farmId) async => (await store.list(farmId, kind)).map((r) => decode(r.payload)).toList(growable: false);

  Future<T?> get(String farmId, String uuid) async {
    final record = await store.get(farmId, uuid);
    return record == null || record.kind != kind || record.deletedAt != null ? null : decode(record.payload);
  }

  Future<T> save({required String farmId, required T value, String? uuid, DateTime? createdAt}) async {
    final now = DateTime.now().toUtc();
    final id = uuid ?? _uuid.v4();
    final previous = await store.get(farmId, id);
    await store.put(FeatureRecord(
      uuid: id, farmId: farmId, kind: kind, payload: encode(value),
      createdAt: previous?.createdAt ?? createdAt ?? now, updatedAt: now,
      revision: (previous?.revision ?? 0) + 1, synced: false,
    ));
    return value;
  }

  Future<void> delete(String farmId, String uuid) => store.softDelete(farmId: farmId, uuid: uuid, kind: kind);

  static const _uuid = Uuid();
}
