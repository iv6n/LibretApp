/// Browser acceptance app for tool/verify_web_batches.cjs. Uses the production
/// worker and storage factory, then resumes a draft after a full offline reload.
import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:libretapp/core/di/injection_web_repositories.dart';
import 'package:libretapp/core/di/web/farm_record_access.dart';
import 'package:libretapp/core/persistence/drift_feature_record_store.dart';
import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/core/tenancy/tenancy.dart';
import 'package:libretapp/features/registro/lotes/batch_record_service.dart';
import '../support/web_batch_fixture.dart';

@JS('window.libretappBatchSmoke')
external set smokeResult(JSString value);

class _BrowserFixture extends WebBatchFixture {
  @override
  Future<void> open() async {
    store = await DriftFeatureRecordStore.open(
      databaseName: 'libretapp_batch_browser_smoke',
    );
    context = IsarFarmContextRepository(store);
    await FarmMigrationService(context, store).ensureDefaultFarm();
    access = FarmRecordAccess(store, context);
    animals = WebAnimalRepository(store, context);
    lots = WebLotesRepository(access, animals);
    locations = WebLocationRepository(access);
    weights = WebWeightRecordRepository(access, animals);
    health = WebHealthRecordRepository(access, animals);
    movements = WebMovementRecordRepository(access, animals, locations, lots);
  }

  @override
  Future<void> reopen() async {
    await store.close();
    await open();
  }
}

class _FailingReceipt implements FeatureRecordStore {
  _FailingReceipt(this.store);
  final FeatureRecordStore store;
  @override
  Future<FeatureRecord?> get(String f, String u) => store.get(f, u);
  @override
  Future<List<FeatureRecord>> list(
    String f,
    String k, {
    bool includeDeleted = false,
  }) => store.list(f, k, includeDeleted: includeDeleted);
  @override
  Future<List<FeatureRecord>> listAll({bool includeDeleted = false}) =>
      store.listAll(includeDeleted: includeDeleted);
  @override
  Future<void> put(FeatureRecord r, {List<FeatureRecord> alsoPut = const []}) {
    if (r.kind == 'record.batch_session' && r.payload['completedAt'] != null)
      throw StateError('Receipt write failure');
    return store.put(r, alsoPut: alsoPut);
  }

  @override
  Future<void> softDelete({
    required String farmId,
    required String uuid,
    required String kind,
  }) => store.softDelete(farmId: farmId, uuid: uuid, kind: kind);
  @override
  Future<void> markSynced(String f, String u, int r) =>
      store.markSynced(f, u, r);
}

void check(bool condition, String description) {
  if (!condition) throw StateError(description);
}

void report(Map<String, dynamic> result) {
  smokeResult = jsonEncode(result).toJS;
  runApp(
    MaterialApp(
      home: Scaffold(body: Center(child: Text(jsonEncode(result)))),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final f = _BrowserFixture();
    await f.open();
    final farm = (await f.context.current())!.farmId;
    final phase = await f.store.get(farm, 'browser-smoke-phase');
    if (phase == null) {
      await f.seed();
      var s = await f.batch().start(
        lotUuid: f.lotUuid,
        kind: BatchRecordKind.weight,
      );
      s = await f.batch().saveDraft(
        s.copyWith(
          weights: {'a': '320,5', 'b': 'por revisar'},
          notes: 'Borrador previo a desconexión',
        ),
        expectedVersion: 0,
      );
      final now = DateTime.now();
      await f.store.put(
        FeatureRecord(
          uuid: 'browser-smoke-phase',
          farmId: farm,
          kind: 'test.browser_phase',
          payload: {'sessionUuid': s.uuid, 'lotUuid': f.lotUuid},
          createdAt: now,
          updatedAt: now,
        ),
      );
      report({'phase': 'draft_saved', 'sessionUuid': s.uuid});
      return;
    }
    f.lotUuid = phase.payload['lotUuid'] as String;
    var s = await f.batch().open(phase.payload['sessionUuid'] as String);
    check(
      s.weights['b'] == 'por revisar' && s.weights['a'] == '320,5',
      'Raw draft lost after offline page reload',
    );
    check(s.notes == 'Borrador previo a desconexión', 'Draft notes lost');
    s = await f.batch().saveDraft(
      s.copyWith(weights: {'a': '320,5', 'b': '310'}),
      expectedVersion: s.version,
    );
    final completions = await Future.wait([
      f.batch().complete(s.uuid, expectedVersion: s.version),
      f.batch().complete(s.uuid, expectedVersion: s.version),
    ]);
    check(
      completions.every((r) => r.savedCount == 2),
      'Concurrent confirmation failed',
    );
    await f.reopen();
    final receipt = await f.batch().complete(s.uuid, expectedVersion: 0);
    check(receipt.savedCount == 2, 'Receipt lost after database reopening');
    check(
      (await f.weights.getWeightRecords('a')).length == 1 &&
          (await f.weights.getWeightRecords('b')).length == 1,
      'Duplicate weights',
    );
    check(
      (await f.animals.getByUuid('a'))!.weight == 320.5,
      'Weight projection lost',
    );

    var health = await f.batch().start(
      lotUuid: f.lotUuid,
      kind: BatchRecordKind.health,
    );
    health = await f.batch().saveDraft(
      health.copyWith(
        product: 'Vacuna',
        dose: '2 ml',
        medicineBatch: 'B-01',
        withdrawalDays: '7',
      ),
      expectedVersion: 0,
    );
    await f.batch().complete(health.uuid, expectedVersion: health.version);
    await f.reopen();
    await f.batch().complete(health.uuid, expectedVersion: 0);
    check(
      (await f.health.getHealthRecords('a')).length == 1 &&
          (await f.health.getHealthRecords('b')).length == 1,
      'Duplicate health events',
    );
    check(
      (await f.health.getActiveWithdrawals({'a', 'b'})).length == 2,
      'Withdrawal persistence failed',
    );

    var movement = await f.batch().start(
      lotUuid: f.lotUuid,
      kind: BatchRecordKind.movement,
    );
    movement = await f.batch().saveDraft(
      movement.copyWith(destinationId: 'south'),
      expectedVersion: 0,
    );
    var failed = false;
    try {
      await f
          .batch(sessionStore: _FailingReceipt(f.store))
          .complete(movement.uuid, expectedVersion: movement.version);
    } catch (_) {
      failed = true;
    }
    check(failed, 'Injected receipt failure was ignored');
    check(
      (await f.movements.getMovementRecords('a')).isEmpty,
      'Movement history was not rolled back',
    );
    check(
      (await f.animals.getByUuid('a'))!.currentLocationId == 'north',
      'Animal location was not rolled back',
    );
    check(
      (await f.lots.getByUuid(f.lotUuid))!.currentLocationId == 'north',
      'Lot location was not rolled back',
    );
    await f.reopen();
    check(
      !(await f.batch().open(movement.uuid)).isCompleted,
      'Failed session was marked completed',
    );
    await f.batch().complete(movement.uuid, expectedVersion: movement.version);
    await f.reopen();
    await f.batch().complete(movement.uuid, expectedVersion: 0);
    check(
      (await f.movements.getMovementRecords('a')).length == 1 &&
          (await f.movements.getMovementRecords('b')).length == 1,
      'Duplicate movements',
    );
    check(
      (await f.lots.getByUuid(f.lotUuid))!.currentLocationId == 'south',
      'Lot location not persisted',
    );
    report({
      'phase': 'passed',
      'offlineReload': true,
      'resumedRawDraft': true,
      'concurrentConfirmation': true,
      'weightRecords': 2,
      'healthRecords': 2,
      'movementRecords': 2,
      'receiptRollback': true,
      'duplicates': 0,
    });
  } catch (error, stack) {
    report({'phase': 'failed', 'error': '$error', 'stack': '$stack'});
  }
}
