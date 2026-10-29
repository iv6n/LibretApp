import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/core/tenancy/tenancy.dart';

/// Web repositories share the same local database and its transaction scope.
class FarmRecordAccess {
  FarmRecordAccess(this.store, this.context);

  final FeatureRecordStore store;
  final FarmContextRepository context;

  Future<String> get farmId async {
    final current = await context.current();
    if (current == null) throw StateError('Abre una finca para continuar.');
    return current.farmId;
  }

  Future<void> requireWrite({bool health = false}) async {
    final current = await context.current();
    if (current == null ||
        !current.membership.role.canOperate ||
        (health && !current.membership.role.canManageHealth)) {
      throw StateError('Tu acceso no permite registrar esta actividad.');
    }
  }

  Future<T> transaction<T>(Future<T> Function() action) {
    final transactional = store;
    if (transactional is! TransactionalFeatureRecordStore) {
      throw StateError('El almacenamiento no admite una operación atómica.');
    }
    return (transactional as TransactionalFeatureRecordStore).runTransaction(
      (_) => action(),
    );
  }

  Future<List<FeatureRecord>> list(String kind) async =>
      store.list(await farmId, kind);

  Future<FeatureRecord?> get(String kind, String uuid) async {
    final row = await store.get(await farmId, uuid);
    return row == null || row.kind != kind || row.deletedAt != null
        ? null
        : row;
  }

  Stream<List<FeatureRecord>> watch(String kind) async* {
    final id = await farmId;
    final observable = store;
    if (observable is WatchableFeatureRecordStore) {
      yield* (observable as WatchableFeatureRecordStore).watch(id, kind);
    } else {
      yield await store.list(id, kind);
    }
  }

  Future<FeatureRecord> put(
    String kind,
    String uuid,
    Map<String, dynamic> payload, {
    DateTime? createdAt,
  }) async {
    final id = await farmId;
    final previous = await store.get(id, uuid);
    final now = DateTime.now().toUtc();
    final row = FeatureRecord(
      uuid: uuid,
      farmId: id,
      kind: kind,
      payload: payload,
      createdAt: previous?.createdAt ?? createdAt ?? now,
      updatedAt: now,
      revision: (previous?.revision ?? 0) + 1,
    );
    await store.put(row);
    return row;
  }

  Future<void> delete(String kind, String uuid) async =>
      store.softDelete(farmId: await farmId, uuid: uuid, kind: kind);
}
