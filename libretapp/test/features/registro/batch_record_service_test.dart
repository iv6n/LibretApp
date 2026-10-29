import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/tenancy/tenancy.dart';
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/core/persistence/isar_feature_record_store.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/health_record_repository_isar.dart';
import 'package:libretapp/features/registro/lotes/batch_record_service.dart';

import '../../support/phase_one_fixture.dart';
import '../directorio/animales/advisor/rules/rule_test_fixtures.dart';

class _FailingHealth extends HealthRecordRepositoryIsar {
  _FailingHealth(PhaseOneFixture fixture) : super(fixture.database);
  @override
  Future<HealthRecord> addHealthRecord(
    String animalUuid,
    HealthRecord record,
  ) async {
    if (animalUuid == 'b') throw StateError('simulated storage failure');
    return super.addHealthRecord(animalUuid, record);
  }
}

class _FailingReceiptStore extends IsarFeatureRecordStore {
  _FailingReceiptStore(PhaseOneFixture fixture) : super(fixture.database);
  @override
  Future<void> put(
    FeatureRecord record, {
    List<FeatureRecord> alsoPut = const [],
  }) {
    if (record.kind == 'record.batch_session' &&
        record.payload['completedAt'] != null)
      throw StateError('simulated receipt failure');
    return super.put(record, alsoPut: alsoPut);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PhaseOneFixture fixture;
  setUp(() async {
    fixture = PhaseOneFixture();
    await fixture.initialize();
    await fixture.seedLot();
  });
  tearDown(() => fixture.dispose());

  test(
    'draft survives a database close/reopen with raw invalid inputs and its original participants',
    () async {
      final service = fixture.batch();
      var session = await service.start(
        lotUuid: 'lot-1',
        kind: BatchRecordKind.weight,
      );
      session = await service.saveDraft(
        session.copyWith(
          weights: {'a': '320,5', 'b': 'pendiente'},
          responsible: 'Ana',
          notes: 'Jornada sin señal',
        ),
        expectedVersion: 0,
      );
      await fixture.database.close();
      await fixture.reopen();
      final reopened = await fixture.batch().open(session.uuid);
      expect(reopened.weights, {'a': '320,5', 'b': 'pendiente'});
      expect(reopened.participants.map((p) => p.uuid), ['a', 'b']);
      expect(reopened.responsible, 'Ana');
      expect(await fixture.weights.getWeightRecords('a'), isEmpty);
      final backup = await fixture.backup.capture();
      expect(
        backup.collections['featureRecords']!.any(
          (r) => r['uuid'] == session.uuid,
        ),
        isTrue,
      );
    },
  );

  test(
    'a completion receipt failure rolls back the animal records as well',
    () async {
      final service = fixture.batch(
        sessionStore: _FailingReceiptStore(fixture),
      );
      var session = await service.start(
        lotUuid: 'lot-1',
        kind: BatchRecordKind.weight,
      );
      session = await service.saveDraft(
        session.copyWith(weights: {'a': '300', 'b': '310'}),
        expectedVersion: 0,
      );
      await expectLater(
        service.complete(session.uuid, expectedVersion: session.version),
        throwsStateError,
      );
      expect(await fixture.weights.getWeightRecords('a'), isEmpty);
      expect(await fixture.weights.getWeightRecords('b'), isEmpty);
      expect((await service.open(session.uuid)).isCompleted, isFalse);
      final result = await fixture.batch().complete(
        session.uuid,
        expectedVersion: session.version,
      );
      expect(result.savedCount, 2);
    },
  );

  test(
    'a draft is restored from a full backup with its original identity and raw values',
    () async {
      final service = fixture.batch();
      var session = await service.start(
        lotUuid: 'lot-1',
        kind: BatchRecordKind.health,
      );
      session = await service.saveDraft(
        session.copyWith(product: 'Vacuna pendiente', dose: 'por revisar'),
        expectedVersion: 0,
      );
      final snapshot = await fixture.backup.capture();
      await fixture.database.clearAllCollections();
      await fixture.backup.restore(snapshot, mode: BackupImportMode.replaceAll);
      final restored = await fixture.batch().open(session.uuid);
      expect(restored.product, 'Vacuna pendiente');
      expect(restored.dose, 'por revisar');
      expect(restored.participants.map((p) => p.uuid), ['a', 'b']);
      expect(restored.isCompleted, isFalse);
    },
  );

  test(
    'weights confirm atomically, blank or skipped animals are omitted and retries create no duplicates',
    () async {
      final service = fixture.batch();
      var session = await service.start(
        lotUuid: 'lot-1',
        kind: BatchRecordKind.weight,
      );
      session = await service.saveDraft(
        session.copyWith(weights: {'a': '320,5'}),
        expectedVersion: 0,
      );
      final completed = await service.complete(
        session.uuid,
        expectedVersion: session.version,
      );
      expect(completed.savedCount, 1);
      expect(completed.isCompleted, isTrue);
      expect(
        (await fixture.weights.getWeightRecords('a')).single.weight,
        320.5,
      );
      expect(
        (await fixture.weights.getWeightRecords('a')).single.lotUuid,
        'lot-1',
      );
      expect(await fixture.weights.getWeightRecords('b'), isEmpty);
      await service.complete(session.uuid, expectedVersion: session.version);
      expect(await fixture.weights.getWeightRecords('a'), hasLength(1));
      await expectLater(
        service.saveDraft(session, expectedVersion: session.version),
        throwsStateError,
      );
    },
  );

  test(
    'one invalid weight prevents all writes and leaves the draft editable',
    () async {
      final service = fixture.batch();
      var session = await service.start(
        lotUuid: 'lot-1',
        kind: BatchRecordKind.weight,
      );
      session = await service.saveDraft(
        session.copyWith(weights: {'a': '300', 'b': '-2'}),
        expectedVersion: 0,
      );
      await expectLater(
        service.complete(session.uuid, expectedVersion: session.version),
        throwsStateError,
      );
      expect(await fixture.weights.getWeightRecords('a'), isEmpty);
      expect((await service.open(session.uuid)).isCompleted, isFalse);
      session = await service.saveDraft(
        session.copyWith(skipped: {'b'}),
        expectedVersion: session.version,
      );
      expect(
        (await service.complete(
          session.uuid,
          expectedVersion: session.version,
        )).savedCount,
        1,
      );
    },
  );

  test(
    'treatment failure rolls back every animal and a retry creates one record per original member',
    () async {
      final failing = fixture.batch(healthRepository: _FailingHealth(fixture));
      var session = await failing.start(
        lotUuid: 'lot-1',
        kind: BatchRecordKind.health,
      );
      session = await failing.saveDraft(
        session.copyWith(
          product: 'Vacuna',
          dose: '2 ml',
          medicineBatch: 'M-01',
          withdrawalDays: '7',
          responsible: 'MVZ Ana',
        ),
        expectedVersion: 0,
      );
      await expectLater(
        failing.complete(session.uuid, expectedVersion: session.version),
        throwsStateError,
      );
      expect(await fixture.health.getHealthRecords('a'), isEmpty);
      expect((await failing.open(session.uuid)).isCompleted, isFalse);
      final service = fixture.batch();
      await service.complete(session.uuid, expectedVersion: session.version);
      final record = (await fixture.health.getHealthRecords('a')).single;
      expect(record.medicineBatch, 'M-01');
      expect(record.withdrawalDays, 7);
      expect(record.appliedBy, 'MVZ Ana');
      expect(await fixture.health.getHealthRecords('b'), hasLength(1));
      await service.complete(session.uuid, expectedVersion: session.version);
      expect(await fixture.health.getHealthRecords('a'), hasLength(1));
    },
  );

  test('new lot members do not receive an earlier session treatment', () async {
    final service = fixture.batch();
    var session = await service.start(
      lotUuid: 'lot-1',
      kind: BatchRecordKind.health,
    );
    await fixture.lots.removeAnimalFromLote(loteUuid: 'lot-1', animalUuid: 'b');
    await fixture.animals.save(
      buildAnimal(uuid: 'c').copyWith(earTagNumber: '0003', batchUuid: 'lot-1'),
    );
    session = await service.saveDraft(
      session.copyWith(product: 'Vacuna'),
      expectedVersion: 0,
    );
    await service.complete(session.uuid, expectedVersion: session.version);
    expect(await fixture.health.getHealthRecords('b'), hasLength(1));
    expect(await fixture.health.getHealthRecords('c'), isEmpty);
    expect((await service.open(session.uuid)).participants.map((p) => p.uuid), [
      'a',
      'b',
    ]);
  });

  test(
    'movement updates animal and lot positions and retains individual history exactly once',
    () async {
      final service = fixture.batch();
      var session = await service.start(
        lotUuid: 'lot-1',
        kind: BatchRecordKind.movement,
      );
      session = await service.saveDraft(
        session.copyWith(destinationId: 'south', responsible: 'Ana'),
        expectedVersion: 0,
      );
      await service.complete(session.uuid, expectedVersion: session.version);
      expect(
        (await fixture.animals.getByUuid('a'))!.currentLocationId,
        'south',
      );
      expect(
        (await fixture.lots.getByUuid('lot-1'))!.currentLocationId,
        'south',
      );
      expect(
        (await fixture.movements.getMovementRecords('a')).single.fromLocation,
        'north',
      );
      await service.complete(session.uuid, expectedVersion: session.version);
      expect(await fixture.movements.getMovementRecords('a'), hasLength(1));
    },
  );

  test(
    'stale movement, concurrent draft edits and a switched farm cannot be silently applied',
    () async {
      final service = fixture.batch();
      final original = await service.start(
        lotUuid: 'lot-1',
        kind: BatchRecordKind.movement,
      );
      final session = await service.saveDraft(
        original.copyWith(destinationId: 'south'),
        expectedVersion: 0,
      );
      await expectLater(
        service.saveDraft(
          original.copyWith(notes: 'stale'),
          expectedVersion: 0,
        ),
        throwsStateError,
      );
      final a = (await fixture.animals.getByUuid('a'))!;
      await fixture.animals.update(a.copyWith(currentLocationId: 'elsewhere'));
      await expectLater(
        service.complete(session.uuid, expectedVersion: session.version),
        throwsStateError,
      );
      expect(await fixture.movements.getMovementRecords('b'), isEmpty);
      await fixture.context.saveFarm(
        const Farm(uuid: 'farm-2', name: 'Otra finca'),
      );
      await fixture.context.saveMembership(
        const FarmMembership(
          uuid: 'owner-2',
          farmId: 'farm-2',
          userId: 'local-user',
          role: FarmRole.owner,
        ),
      );
      await fixture.context.select('farm-2', 'local-user');
      await expectLater(service.open(session.uuid), throwsStateError);
      await expectLater(
        service.saveDraft(session, expectedVersion: session.version),
        throwsStateError,
      );
    },
  );

  test('a new movement follows existing movements from the same day', () async {
    final earlier = DateTime.now().subtract(const Duration(milliseconds: 1));
    for (final animal in ['a', 'b']) {
      await fixture.movements.addMovementRecord(
        animal,
        MovementRecord(
          fromLocation: 'north',
          toLocation: 'south',
          date: earlier,
          reason: MovementReason.relocation,
        ),
      );
    }
    final service = fixture.batch();
    var session = await service.start(
      lotUuid: 'lot-1',
      kind: BatchRecordKind.movement,
    );
    session = await service.saveDraft(
      session.copyWith(destinationId: 'north'),
      expectedVersion: 0,
    );
    await service.complete(session.uuid, expectedVersion: session.version);
    expect((await fixture.animals.getByUuid('a'))!.currentLocationId, 'north');
    expect((await fixture.lots.getByUuid('lot-1'))!.currentLocationId, 'north');
  });

  test(
    'a backdated movement preserves a newer animal and lot location',
    () async {
      final now = DateTime.now();
      for (final animal in ['a', 'b']) {
        await fixture.movements.addMovementRecord(
          animal,
          MovementRecord(
            fromLocation: 'north',
            toLocation: 'south',
            date: now,
            reason: MovementReason.relocation,
          ),
        );
      }
      final lot = (await fixture.lots.getByUuid('lot-1'))!;
      await fixture.lots.upsert(lot.copyWith(currentLocationId: 'south'));
      final service = fixture.batch();
      var session = await service.start(
        lotUuid: 'lot-1',
        kind: BatchRecordKind.movement,
      );
      session = await service.saveDraft(
        session.copyWith(
          destinationId: 'north',
          date: now.subtract(const Duration(days: 1)),
        ),
        expectedVersion: 0,
      );
      await service.complete(session.uuid, expectedVersion: session.version);
      expect(
        (await fixture.animals.getByUuid('a'))!.currentLocationId,
        'south',
      );
      expect(
        (await fixture.lots.getByUuid('lot-1'))!.currentLocationId,
        'south',
      );
      expect(await fixture.movements.getMovementRecords('a'), hasLength(2));
    },
  );
}
