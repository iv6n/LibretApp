library;

import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/core/tenancy/farm_models.dart';
import 'package:uuid/uuid.dart';

abstract interface class FarmContextRepository {
  Future<List<Farm>> listFarms();
  Future<Farm> saveFarm(Farm farm);
  Future<List<FarmMembership>> listMemberships(String farmId);
  Future<FarmMembership> saveMembership(FarmMembership membership);
  Future<FarmContext?> current();
  Future<FarmContext> select(String farmId, String userId);
}

class IsarFarmContextRepository implements FarmContextRepository {
  IsarFarmContextRepository(this._store, {String? userId}) : _userId = userId ?? 'local-user';

  static const _farmKind = 'core.farm';
  static const _membershipKind = 'core.farm_membership';
  static const _contextKind = 'core.farm_context';
  final FeatureRecordStore _store;
  final String _userId;

  @override
  Future<List<Farm>> listFarms() async => (await _store.list(_farmScope, _farmKind)).map((r) => Farm.fromJson(r.payload)).toList();

  @override
  Future<Farm> saveFarm(Farm farm) async {
    final now = DateTime.now().toUtc();
    await _store.put(FeatureRecord(
      uuid: farm.uuid, farmId: _farmScope, kind: _farmKind, payload: farm.toJson(),
      createdAt: farm.createdAt ?? now, updatedAt: now,
    ));
    return farm;
  }

  @override
  Future<List<FarmMembership>> listMemberships(String farmId) async =>
      (await _store.list(farmId, _membershipKind)).map((r) => FarmMembership.fromJson(r.payload)).toList();

  @override
  Future<FarmMembership> saveMembership(FarmMembership membership) async {
    final now = DateTime.now().toUtc();
    await _store.put(FeatureRecord(
      uuid: membership.uuid, farmId: membership.farmId, kind: _membershipKind,
      payload: membership.toJson(), createdAt: now, updatedAt: now,
    ));
    return membership;
  }

  @override
  Future<FarmContext?> current() async {
    final rows = await _store.list(_scope, _contextKind);
    if (rows.isEmpty) return null;
    final payload = rows.first.payload;
    final farm = await _store.get(_farmScope, payload['farmId'] as String);
    if (farm == null || farm.kind != _farmKind) return null;
    final memberships = await listMemberships(payload['farmId'] as String);
    final membership = memberships.where((m) => m.userId == _userId && m.active).firstOrNull;
    return membership == null ? null : FarmContext(farm: Farm.fromJson(farm.payload), membership: membership);
  }

  @override
  Future<FarmContext> select(String farmId, String userId) async {
    final farmRow = await _store.get(_farmScope, farmId);
    if (farmRow == null || farmRow.kind != _farmKind) throw StateError('Finca no encontrada: $farmId');
    final membership = (await listMemberships(farmId)).where((m) => m.userId == userId && m.active).firstOrNull;
    if (membership == null) throw StateError('El usuario no tiene acceso a esta finca.');
    final farm = Farm.fromJson(farmRow.payload);
    final now = DateTime.now().toUtc();
    await _store.put(FeatureRecord(
      uuid: 'current-context-$_userId', farmId: _scope, kind: _contextKind,
      payload: {'farmId': farmId, 'userId': userId}, createdAt: now, updatedAt: now,
    ));
    return FarmContext(farm: farm, membership: membership);
  }

  String get _scope => '__context__';
  String get _farmScope => '__farms__';

  static Farm create(String name, {String? upp}) {
    final now = DateTime.now().toUtc();
    return Farm(uuid: const Uuid().v4(), name: name, upp: upp, createdAt: now, updatedAt: now);
  }
}
