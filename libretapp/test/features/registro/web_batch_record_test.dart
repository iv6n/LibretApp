import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/web_backup_store.dart';
import 'package:libretapp/core/di/web/web_animal_record_repositories.dart';
import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/core/tenancy/tenancy.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/registro/lotes/batch_record_service.dart';

import '../../support/web_batch_fixture.dart';
import '../directorio/animales/advisor/rules/rule_test_fixtures.dart';

class _FailingReceipt implements FeatureRecordStore {
  _FailingReceipt(this.delegate);
  final FeatureRecordStore delegate;
  @override
  Future<FeatureRecord?> get(String farmId, String uuid) =>
      delegate.get(farmId, uuid);
  @override
  Future<List<FeatureRecord>> list(
    String farmId,
    String kind, {
    bool includeDeleted = false,
  }) => delegate.list(farmId, kind, includeDeleted: includeDeleted);
  @override
  Future<List<FeatureRecord>> listAll({bool includeDeleted = false}) =>
      delegate.listAll(includeDeleted: includeDeleted);
  @override
  Future<void> put(
    FeatureRecord record, {
    List<FeatureRecord> alsoPut = const [],
  }) {
    if (record.kind == 'record.batch_session' &&
        record.payload['completedAt'] != null) {
      throw StateError('No hay espacio para guardar la confirmación.');
    }
    return delegate.put(record, alsoPut: alsoPut);
  }

  @override
  Future<void> softDelete({
    required String farmId,
    required String uuid,
    required String kind,
  }) => delegate.softDelete(farmId: farmId, uuid: uuid, kind: kind);
  @override
  Future<void> markSynced(String farmId, String uuid, int revision) =>
      delegate.markSynced(farmId, uuid, revision);
}

class _FailingHealth extends WebHealthRecordRepository {
  _FailingHealth(WebBatchFixture f) : super(f.access, f.animals);
  @override
  Future<HealthRecord> addHealthRecord(
    String animalUuid,
    HealthRecord record,
  ) async {
    final saved = await super.addHealthRecord(animalUuid, record);
    if (animalUuid == 'b')
      throw StateError('Fallo al terminar el segundo animal.');
    return saved;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late WebBatchFixture f;
  setUp(() async {
    f = WebBatchFixture();
    await f.open();
    await f.seed();
  });
  tearDown(() => f.dispose());

  test(
    'web draft survives reopening with raw input, omissions and original membership',
    () async {
      var session = await f.batch().start(
        lotUuid: f.lotUuid,
        kind: BatchRecordKind.weight,
      );
      session = await f.batch().saveDraft(
        session.copyWith(
          weights: {'a': '320,5', 'b': 'por revisar'},
          skipped: {'b'},
          responsible: 'Ana',
          notes: 'Jornada sin señal',
        ),
        expectedVersion: 0,
      );
      await f.animals.save(
        buildAnimal(uuid: 'c').copyWith(earTagNumber: '0003'),
      );
      await f.lots.addAnimalToLote(loteUuid: f.lotUuid, animalUuid: 'c');
      await f.reopen();
      final resumed = await f.batch().open(session.uuid);
      expect(resumed.weights, {'a': '320,5', 'b': 'por revisar'});
      expect(resumed.skipped, {'b'});
      expect(resumed.responsible, 'Ana');
      expect(resumed.notes, 'Jornada sin señal');
      expect(resumed.participants.map((p) => p.uuid), ['a', 'b']);
      expect((await f.lots.getByUuid(f.lotUuid))!.animalUuids, contains('c'));
      expect(await f.weights.getWeightRecords('a'), isEmpty);
      final saved = await f.batch().complete(
        session.uuid,
        expectedVersion: resumed.version,
      );
      expect(saved.savedCount, 1);
      expect((await f.weights.getWeightRecords('a')).single.weight, 320.5);
      expect(await f.weights.getWeightRecords('c'), isEmpty);
    },
  );

  test(
    'concurrent confirmations and retries after reopening produce one weight per animal',
    () async {
      var session = await f.batch().start(
        lotUuid: f.lotUuid,
        kind: BatchRecordKind.weight,
      );
      session = await f.batch().saveDraft(
        session.copyWith(weights: {'a': '300', 'b': '310'}),
        expectedVersion: 0,
      );
      final results = await Future.wait([
        f.batch().complete(session.uuid, expectedVersion: session.version),
        f.batch().complete(session.uuid, expectedVersion: session.version),
      ]);
      expect(results.map((s) => s.savedCount), [2, 2]);
      expect(results[0].completedAt, results[1].completedAt);
      await f.reopen();
      final retried = await f.batch().complete(
        session.uuid,
        expectedVersion: 0,
      );
      expect(retried.completedAt, results.first.completedAt);
      expect(
        (await f.weights.getWeightRecords('a')).single.recordUuid,
        '${session.uuid}-a',
      );
      expect((await f.weights.getWeightRecords('b')).single.weight, 310);
      expect(await f.weights.getWeightRecordsForLot(f.lotUuid), hasLength(2));
      expect((await f.animals.getByUuid('a'))!.weight, 300);
      expect(await f.batch().list(), hasLength(1));
    },
  );

  test(
    'receipt failure rolls back weights and projections, then the same draft can be confirmed',
    () async {
      var session = await f.batch().start(
        lotUuid: f.lotUuid,
        kind: BatchRecordKind.weight,
      );
      session = await f.batch().saveDraft(
        session.copyWith(weights: {'a': '300', 'b': '310'}),
        expectedVersion: 0,
      );
      await expectLater(
        f
            .batch(sessionStore: _FailingReceipt(f.store))
            .complete(session.uuid, expectedVersion: session.version),
        throwsStateError,
      );
      expect(await f.weights.getWeightRecordsForLot(f.lotUuid), isEmpty);
      expect((await f.animals.getByUuid('a'))!.weight, 200);
      expect((await f.animals.getByUuid('b'))!.weight, 200);
      await f.reopen();
      expect((await f.batch().open(session.uuid)).isCompleted, isFalse);
      expect(
        (await f.batch().complete(
          session.uuid,
          expectedVersion: session.version,
        )).savedCount,
        2,
      );
      expect(await f.weights.getWeightRecordsForLot(f.lotUuid), hasLength(2));
    },
  );

  test(
    'invalid weight preserves the draft without any partial writes',
    () async {
      var session = await f.batch().start(
        lotUuid: f.lotUuid,
        kind: BatchRecordKind.weight,
      );
      session = await f.batch().saveDraft(
        session.copyWith(weights: {'a': '300', 'b': '-1'}),
        expectedVersion: 0,
      );
      await expectLater(
        f.batch().complete(session.uuid, expectedVersion: session.version),
        throwsStateError,
      );
      await f.reopen();
      final draft = await f.batch().open(session.uuid);
      expect(draft.weights['b'], '-1');
      expect(draft.isCompleted, isFalse);
      expect(await f.weights.getWeightRecordsForLot(f.lotUuid), isEmpty);
    },
  );

  test(
    'sanitary records, withdrawals and flags persist exactly once',
    () async {
      var session = await f.batch().start(
        lotUuid: f.lotUuid,
        kind: BatchRecordKind.health,
      );
      session = await f.batch().saveDraft(
        session.copyWith(
          product: 'Vacuna',
          dose: '2 ml',
          medicineBatch: 'MED-001',
          withdrawalDays: '7',
          responsible: 'Ana',
          nextDueDate: session.date.add(const Duration(days: 30)),
        ),
        expectedVersion: 0,
      );
      await f.batch().complete(session.uuid, expectedVersion: session.version);
      await f.reopen();
      await f.batch().complete(session.uuid, expectedVersion: 0);
      for (final id in ['a', 'b']) {
        final record = (await f.health.getHealthRecords(id)).single;
        expect(record.medicineBatch, 'MED-001');
        expect(record.dose, '2 ml');
        expect(record.appliedBy, 'Ana');
        expect(
          record.withdrawalEndDate,
          session.date.add(const Duration(days: 7)),
        );
        expect(record.nextDueDate, session.nextDueDate);
        expect((await f.animals.getByUuid(id))!.vaccinated, isTrue);
      }
      expect(await f.health.getActiveWithdrawals({'a', 'b'}), hasLength(2));
      expect(await f.health.getRecentHealthRecords(), hasLength(2));
    },
  );

  test(
    'failure after writing the second treatment rolls back both animals and can be retried',
    () async {
      var session = await f.batch().start(
        lotUuid: f.lotUuid,
        kind: BatchRecordKind.health,
      );
      session = await f.batch().saveDraft(
        session.copyWith(product: 'Vacuna'),
        expectedVersion: 0,
      );
      await expectLater(
        f
            .batch(healthRepository: _FailingHealth(f))
            .complete(session.uuid, expectedVersion: session.version),
        throwsStateError,
      );
      expect(await f.health.getHealthRecords('a'), isEmpty);
      expect(await f.health.getHealthRecords('b'), isEmpty);
      expect((await f.animals.getByUuid('a'))!.vaccinated, isFalse);
      expect((await f.batch().open(session.uuid)).isCompleted, isFalse);
      await f.reopen();
      await f.batch().complete(session.uuid, expectedVersion: session.version);
      expect(await f.health.getHealthRecords('a'), hasLength(1));
    },
  );

  test(
    'movement receipt failure rolls back histories, animals and lot location',
    () async {
      var session = await f.batch().start(
        lotUuid: f.lotUuid,
        kind: BatchRecordKind.movement,
      );
      session = await f.batch().saveDraft(
        session.copyWith(destinationId: 'south', responsible: 'Luis'),
        expectedVersion: 0,
      );
      await expectLater(
        f
            .batch(sessionStore: _FailingReceipt(f.store))
            .complete(session.uuid, expectedVersion: session.version),
        throwsStateError,
      );
      expect(await f.movements.getMovementRecords('a'), isEmpty);
      expect((await f.animals.getByUuid('a'))!.currentLocationId, 'north');
      expect((await f.lots.getByUuid(f.lotUuid))!.currentLocationId, 'north');
      await f.reopen();
      await f.batch().complete(session.uuid, expectedVersion: session.version);
      await f.reopen();
      await f.batch().complete(session.uuid, expectedVersion: 0);
      for (final id in ['a', 'b']) {
        final movement = (await f.movements.getMovementRecords(id)).single;
        expect(movement.fromLocation, 'north');
        expect(movement.toLocation, 'south');
        expect(movement.movedBy, 'Luis');
        expect((await f.animals.getByUuid(id))!.currentLocationId, 'south');
      }
      expect((await f.lots.getByUuid(f.lotUuid))!.currentLocationId, 'south');
      expect(await f.locations.getAll(), hasLength(3));
    },
  );

  test(
    'a backdated batch movement preserves the current animal and lot locations',
    () async {
      final now = DateTime.now();
      for (final id in ['a', 'b']) {
        await f.movements.addMovementRecord(
          id,
          MovementRecord(
            date: now.subtract(const Duration(days: 1)),
            fromLocation: 'north',
            toLocation: 'east',
            reason: MovementReason.transport,
          ),
        );
      }
      await f.lots.upsert(
        (await f.lots.getByUuid(
          f.lotUuid,
        ))!.copyWith(currentLocationId: 'east'),
      );
      var session = await f.batch().start(
        lotUuid: f.lotUuid,
        kind: BatchRecordKind.movement,
      );
      session = await f.batch().saveDraft(
        session.copyWith(
          destinationId: 'south',
          date: now.subtract(const Duration(days: 2)),
        ),
        expectedVersion: 0,
      );
      await f.batch().complete(session.uuid, expectedVersion: session.version);
      await f.reopen();
      expect((await f.animals.getByUuid('a'))!.currentLocationId, 'east');
      expect((await f.lots.getByUuid(f.lotUuid))!.currentLocationId, 'east');
      expect(await f.movements.getMovementRecords('a'), hasLength(2));
    },
  );

  test('a changed animal origin rejects the whole movement session', () async {
    var session = await f.batch().start(
      lotUuid: f.lotUuid,
      kind: BatchRecordKind.movement,
    );
    session = await f.batch().saveDraft(
      session.copyWith(destinationId: 'south'),
      expectedVersion: 0,
    );
    await f.movements.addMovementRecord(
      'b',
      MovementRecord(
        date: DateTime.now(),
        fromLocation: 'north',
        toLocation: 'east',
        reason: MovementReason.transport,
      ),
    );
    await expectLater(
      f.batch().complete(session.uuid, expectedVersion: session.version),
      throwsStateError,
    );
    expect(await f.movements.getMovementRecords('a'), isEmpty);
    expect((await f.animals.getByUuid('a'))!.currentLocationId, 'north');
    expect((await f.batch().open(session.uuid)).isCompleted, isFalse);
  });

  test(
    'stale drafts cannot replace newer saved data or confirm another tab version',
    () async {
      final original = await f.batch().start(
        lotUuid: f.lotUuid,
        kind: BatchRecordKind.weight,
      );
      final saved = await f.batch().saveDraft(
        original.copyWith(weights: {'a': '300'}),
        expectedVersion: 0,
      );
      await expectLater(
        f.batch().saveDraft(
          original.copyWith(weights: {'a': '900'}),
          expectedVersion: 0,
        ),
        throwsStateError,
      );
      await expectLater(
        f.batch().complete(original.uuid, expectedVersion: 0),
        throwsStateError,
      );
      expect((await f.batch().open(original.uuid)).weights, saved.weights);
      await f.batch().complete(original.uuid, expectedVersion: saved.version);
      await expectLater(
        f.batch().saveDraft(saved, expectedVersion: saved.version),
        throwsStateError,
      );
    },
  );

  test(
    'sessions, lots, locations and record histories stay within the active farm',
    () async {
      var session = await f.batch().start(
        lotUuid: f.lotUuid,
        kind: BatchRecordKind.weight,
      );
      session = await f.batch().saveDraft(
        session.copyWith(weights: {'a': '300'}),
        expectedVersion: 0,
      );
      await f.batch().complete(session.uuid, expectedVersion: session.version);
      final farm = IsarFarmContextRepository.create('Otra finca');
      await f.context.saveFarm(farm);
      await f.context.saveMembership(
        FarmMembership(
          uuid: 'other-membership',
          farmId: farm.uuid,
          userId: 'local-user',
          role: FarmRole.owner,
        ),
      );
      await f.context.select(farm.uuid, 'local-user');
      expect(await f.batch().list(), isEmpty);
      expect(await f.lots.getAll(), isEmpty);
      expect(await f.locations.getAll(), isEmpty);
      expect(await f.weights.getWeightRecords('a'), isEmpty);
      await expectLater(
        f.batch().complete(session.uuid, expectedVersion: 0),
        throwsStateError,
      );
    },
  );

  test(
    'discard persists and farm health permissions are checked again when resuming',
    () async {
      final session = await f.batch().start(
        lotUuid: f.lotUuid,
        kind: BatchRecordKind.health,
      );
      final current = (await f.context.current())!;
      await f.context.saveMembership(
        FarmMembership(
          uuid: current.membership.uuid,
          farmId: current.farmId,
          userId: 'local-user',
          role: FarmRole.worker,
        ),
      );
      await expectLater(f.batch().open(session.uuid), throwsStateError);
      await f.context.saveMembership(current.membership);
      await f.batch().discard(session.uuid);
      await f.reopen();
      expect(await f.batch().list(), isEmpty);
      await expectLater(f.batch().open(session.uuid), throwsStateError);
    },
  );

  test(
    'stable record identities reject a conflicting retry and deletion restores registration weight',
    () async {
      final record = WeightRecord(
        date: DateTime.now(),
        weight: 330,
        method: WeightMethod.scale,
        recordUuid: 'unique-weight',
      );
      final first = await f.weights.addWeightRecord('a', record);
      expect((await f.weights.addWeightRecord('a', record)).id, first.id);
      await expectLater(
        f.weights.addWeightRecord('a', record.copyWith(weight: 440)),
        throwsArgumentError,
      );
      await expectLater(
        f.weights.addWeightRecord('b', record),
        throwsArgumentError,
      );
      await f.weights.deleteWeightRecord(first.id!);
      expect((await f.animals.getByUuid('a'))!.weight, 200);
      await expectLater(
        f.weights.addWeightRecord('a', record),
        throwsArgumentError,
      );
    },
  );

  test(
    'restoring a web backup keeps drafts and completion receipts idempotent',
    () async {
      var completed = await f.batch().start(
        lotUuid: f.lotUuid,
        kind: BatchRecordKind.weight,
      );
      completed = await f.batch().saveDraft(
        completed.copyWith(weights: {'a': '321'}),
        expectedVersion: 0,
      );
      await f.batch().complete(
        completed.uuid,
        expectedVersion: completed.version,
      );
      var draft = await f.batch().start(
        lotUuid: f.lotUuid,
        kind: BatchRecordKind.health,
      );
      draft = await f.batch().saveDraft(
        draft.copyWith(product: 'Por revisar', dose: 'sin completar'),
        expectedVersion: 0,
      );
      final backup = await WebBackupStore(f.store).capture();
      await WebBackupStore(
        f.store,
      ).restore(backup, mode: BackupImportMode.replaceAll);
      await f.reopen();
      expect((await f.batch().open(draft.uuid)).dose, 'sin completar');
      await f.batch().complete(completed.uuid, expectedVersion: 0);
      expect(await f.weights.getWeightRecords('a'), hasLength(1));
    },
  );

  test(
    'directory streams publish complete committed snapshots and never rolled back weights',
    () async {
      var session = await f.batch().start(
        lotUuid: f.lotUuid,
        kind: BatchRecordKind.weight,
      );
      session = await f.batch().saveDraft(
        session.copyWith(weights: {'a': '300', 'b': '310'}),
        expectedVersion: 0,
      );
      final snapshots = <List<double?>>[];
      final initial = Completer<void>();
      final committed = Completer<void>();
      final subscription = f.animals.watchAll().listen((animals) {
        animals.sort((a, b) => a.uuid.compareTo(b.uuid));
        snapshots.add(animals.map((a) => a.weight).toList());
        if (!initial.isCompleted) initial.complete();
        if (animals.first.weight == 300 && !committed.isCompleted)
          committed.complete();
      });
      addTearDown(subscription.cancel);
      await initial.future.timeout(const Duration(seconds: 5));
      await expectLater(
        f
            .batch(sessionStore: _FailingReceipt(f.store))
            .complete(session.uuid, expectedVersion: session.version),
        throwsStateError,
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(
        snapshots.every((weights) => weights[0] == 200 && weights[1] == 200),
        isTrue,
      );
      await f.batch().complete(session.uuid, expectedVersion: session.version);
      await committed.future.timeout(const Duration(seconds: 5));
      expect(
        snapshots.every(
          (weights) =>
              (weights[0] == 200 && weights[1] == 200) ||
              (weights[0] == 300 && weights[1] == 310),
        ),
        isTrue,
      );
    },
  );
}
