library;

import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/core/tenancy/farm_context_service.dart';
import 'package:libretapp/core/tenancy/farm_models.dart';

/// Idempotent migration boundary for the pre-multi-farm database.
///
/// Existing Isar collections remain readable and are logically assigned to
/// this farm until their physical schemas receive `farmId`; all new records
/// are physically scoped from the first write. Re-running this service never
/// creates a second farm or changes UUIDs.
class FarmMigrationService {
  FarmMigrationService(this._contexts, this._store);
  final FarmContextRepository _contexts;
  final FeatureRecordStore _store;

  static const migrationUuid = 'farm-context-migration-v1';

  Future<FarmContext> ensureDefaultFarm({String? name, String? upp}) async {
    final marker = await _store.get('__context__', migrationUuid);
    if (marker != null) {
      final current = await _contexts.current();
      if (current != null) return current;
    }
    final farms = await _contexts.listFarms();
    final farm = farms.isEmpty ? await _contexts.saveFarm(IsarFarmContextRepository.create(name ?? 'Mi finca', upp: upp)) : farms.first;
    final memberships = await _contexts.listMemberships(farm.uuid);
    final membership = memberships.where((m) => m.userId == 'local-user' && m.active).firstOrNull ?? await _contexts.saveMembership(FarmMembership(uuid: 'membership-${farm.uuid}-local-user', farmId: farm.uuid, userId: 'local-user', role: FarmRole.owner));
    final selected = await _contexts.select(farm.uuid, 'local-user');
    final now = DateTime.now().toUtc();
    await _store.put(FeatureRecord(uuid: migrationUuid, farmId: '__context__', kind: 'core.migration', payload: {'version': 1, 'farmId': farm.uuid, 'legacyRowsInheritFarm': true}, createdAt: now, updatedAt: now, synced: true));
    return FarmContext(farm: selected.farm, membership: membership);
  }
}
