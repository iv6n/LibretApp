import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/database/write_transaction.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/application/animal_batch_registration.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/models/animal_batch_draft.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/view/animal_batch_register_page.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Animals animals;
  late _Lots lots;
  late AnimalBatchRegistration registration;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    animals = _Animals();
    lots = _Lots();
    registration = AnimalBatchRegistration(
      preferences: SharedPrefsService(
        await SharedPreferences.getInstance(),
        prefix: 'workspace-a.',
      ),
      animals: animals,
      lots: lots,
      health: _Health(),
      movements: _Movements(),
      reproduction: _Reproduction(),
      transactions: _Transaction(animals, lots),
    );
  });

  tearDown(() async => locator.reset());

  test('persists and restores animals and the chosen lot', () async {
    final session = AnimalBatchSession(
      animals: [
        AnimalBatchDraft(
          animal: _animal('a', 'A1'),
          fullForm: const {'step': 4, 'notes': 'Revisión'},
          healthRecords: const [
            {'type': 'vaccine', 'product': 'Vacuna', 'date': 1},
          ],
        ),
      ],
      lotChoice: BatchLotChoice.create,
      newLotName: 'Engorda',
      newLotDescription: 'Lote de prueba',
    );
    await registration.persist(session);
    final restored = registration.load();
    expect(restored.animals.single.animal.earTagNumber, 'A1');
    expect(restored.animals.single.fullForm?['notes'], 'Revisión');
    expect(restored.animals.single.healthRecords.single['product'], 'Vacuna');
    expect(restored.lotChoice, BatchLotChoice.create);
    expect(restored.newLotName, 'Engorda');
    await registration.discard();
    expect(registration.load().animals, isEmpty);
  });

  test('saves the whole list without a lot', () async {
    final session = AnimalBatchSession(
      animals: [
        AnimalBatchDraft(animal: _animal('a', 'A1')),
        AnimalBatchDraft(animal: _animal('b', 'B1')),
      ],
    );
    await registration.persist(session);
    expect(await registration.commit(session), isNull);
    expect(animals.rows.keys, containsAll(['a', 'b']));
    expect(registration.load().animals, isEmpty);
  });

  test('assigns every animal to an existing lot', () async {
    lots.rows['existing'] = _lot('existing', 'Existente');
    final session = AnimalBatchSession(
      animals: [
        AnimalBatchDraft(animal: _animal('a', 'A1')),
        AnimalBatchDraft(animal: _animal('b', 'B1')),
      ],
      lotChoice: BatchLotChoice.existing,
      lotUuid: 'existing',
    );
    expect(await registration.commit(session), 'existing');
    expect(lots.rows['existing']!.animalUuids, containsAll(['a', 'b']));
    expect(animals.rows['a']!.batchUuid, 'existing');
    expect(animals.rows['b']!.batchUuid, 'existing');
  });

  test('creates one lot and rolls everything back on a failed write', () async {
    final session = AnimalBatchSession(
      animals: [
        AnimalBatchDraft(animal: _animal('a', 'A1')),
        AnimalBatchDraft(animal: _animal('b', 'B1')),
      ],
      lotChoice: BatchLotChoice.create,
      newLotName: 'Nuevas',
    );
    await registration.persist(session);
    animals.failOnUuid = 'b';
    await expectLater(registration.commit(session), throwsStateError);
    expect(animals.rows, isEmpty);
    expect(lots.rows, isEmpty);
    expect(registration.load().animals, hasLength(2));
    animals.failOnUuid = null;
    final lotUuid = await registration.commit(session);
    expect(lotUuid, isNotNull);
    expect(lots.rows[lotUuid]!.animalUuids, containsAll(['a', 'b']));
  });

  test('rejects duplicate tags and a closed lot before writing', () async {
    final duplicates = AnimalBatchSession(
      animals: [
        AnimalBatchDraft(animal: _animal('a', 'A1')),
        AnimalBatchDraft(animal: _animal('b', 'a1')),
      ],
    );
    await expectLater(registration.commit(duplicates), throwsStateError);
    lots.rows['closed'] = _lot('closed', 'Cerrado').copyWith(active: false);
    final closed = AnimalBatchSession(
      animals: [AnimalBatchDraft(animal: _animal('a', 'A1'))],
      lotChoice: BatchLotChoice.existing,
      lotUuid: 'closed',
    );
    await expectLater(registration.commit(closed), throwsStateError);
    expect(animals.rows, isEmpty);
  });

  test(
    'checks tags against existing animals and allows unknown tags',
    () async {
      animals.rows['old'] = _animal('old', 'A1');
      final duplicate = AnimalBatchSession(
        animals: [AnimalBatchDraft(animal: _animal('new', 'a1'))],
      );
      await expectLater(registration.commit(duplicate), throwsStateError);
      final unknown = AnimalBatchSession(
        animals: [
          AnimalBatchDraft(animal: _animal('a', '')),
          AnimalBatchDraft(animal: _animal('b', '')),
        ],
      );
      await registration.commit(unknown);
      expect(animals.rows.keys, containsAll(['old', 'a', 'b']));
    },
  );

  test('clears a stale draft after an already completed write', () async {
    final session = AnimalBatchSession(
      animals: [AnimalBatchDraft(animal: _animal('a', 'A1'))],
    );
    await registration.persist(session);
    animals.rows['a'] = _animal('a', 'A1');
    await registration.commit(session);
    expect(animals.rows, hasLength(1));
    expect(registration.load().animals, isEmpty);
  });

  testWidgets('restores a list, shows row actions and fits narrow large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await registration.persist(
      AnimalBatchSession(
        animals: [AnimalBatchDraft(animal: _animal('a', 'A1'))],
        lotChoice: BatchLotChoice.create,
        newLotName: 'Nuevas',
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: AnimalBatchRegisterPage(registration: registration),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 animales en la lista'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('A1'), 160);
    expect(find.textContaining('A1'), findsWidgets);
    expect(find.text('Completar ficha'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Nuevas'), 160);
    expect(find.text('Nuevas'), findsOneWidget);
    final layoutError = tester.takeException();
    expect(
      layoutError,
      isNull,
      reason: layoutError is FlutterError ? layoutError.toStringDeep() : null,
    );
    await tester.scrollUntilVisible(
      find.text('Eliminar').first,
      -160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Eliminar').first);
    await tester.pumpAndSettle();
    expect(registration.load().animals, isEmpty);
  });

  testWidgets('quick entry adds a recoverable row without saving it', (
    tester,
  ) async {
    locator.registerSingleton<AnimalRepository>(animals);
    await tester.pumpWidget(
      MaterialApp(home: AnimalBatchRegisterPage(registration: registration)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agregar animal rápido'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('animal-quick-identification')),
      'A-101',
    );
    await tester.tap(find.text('Agregar a la lista').last);
    await tester.pumpAndSettle();
    expect(registration.load().animals.single.animal.earTagNumber, 'A-101');
    expect(animals.rows, isEmpty);
  });

  testWidgets('leaving can keep or discard the entire draft', (tester) async {
    await registration.persist(
      AnimalBatchSession(
        animals: [AnimalBatchDraft(animal: _animal('a', 'A1'))],
      ),
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/batch'),
              child: const Text('Abrir lista'),
            ),
          ),
        ),
        GoRoute(
          path: '/batch',
          builder: (_, _) =>
              AnimalBatchRegisterPage(registration: registration),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Abrir lista'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Conservar borrador'));
    await tester.pumpAndSettle();
    expect(registration.load().animals, hasLength(1));
    await tester.tap(find.text('Abrir lista'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar lista'));
    await tester.pumpAndSettle();
    expect(registration.load().animals, isEmpty);
  });
}

AnimalEntity _animal(String uuid, String tag) {
  final now = DateTime(2026, 11, 8);
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: tag,
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: 'Desconocido',
    birthDate: now,
    ageMonths: -1,
    healthStatus: HealthStatus.good,
    vaccinated: false,
    dewormed: false,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.undefined,
    productionStage: ProductionStage.unknown,
    productionSystem: ProductionSystem.unknown,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.low,
    gallery: const [],
    synced: false,
    creationDate: now,
    lastUpdateDate: now,
  );
}

LoteEntity _lot(String uuid, String name) => LoteEntity(
  uuid: uuid,
  name: name,
  createdAt: DateTime(2026, 11, 8),
  lastUpdateDate: DateTime(2026, 11, 8),
);

class _Animals implements AnimalRepository {
  final rows = <String, AnimalEntity>{};
  String? failOnUuid;
  @override
  Future<AnimalEntity?> getByUuid(String uuid) async => rows[uuid];
  @override
  Future<List<AnimalEntity>> getAllIncludingInactive() async =>
      rows.values.toList();
  @override
  Future<List<AnimalEntity>> getAll() async => rows.values.toList();
  @override
  Future<AnimalEntity> save(AnimalEntity animal) async {
    if (animal.uuid == failOnUuid) throw StateError('write failed');
    rows[animal.uuid] = animal;
    return animal;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Lots implements LotesRepository {
  final rows = <String, LoteEntity>{};
  @override
  Future<List<LoteEntity>> getActiveLotes() async =>
      rows.values.where((lot) => lot.active).toList();
  @override
  Future<LoteEntity?> getByUuid(String uuid) async => rows[uuid];
  @override
  Future<LoteEntity> createLote({
    required String nombre,
    String? descripcion,
    String? notas,
    double? feedPricePerKg,
    double? dailyFeedKgPerHead,
    double? liveWeightPricePerKg,
  }) async {
    final lot = _lot('new-lot', nombre).copyWith(description: descripcion);
    rows[lot.uuid] = lot;
    return lot;
  }

  @override
  Future<void> addAnimalsToLote({
    required String loteUuid,
    required List<String> animalUuids,
  }) async {
    rows[loteUuid] = rows[loteUuid]!.copyWith(animalUuids: animalUuids);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transaction implements WriteTransactionRunner {
  _Transaction(this.animals, this.lots);
  final _Animals animals;
  final _Lots lots;
  @override
  Future<T> run<T>(Future<T> Function() action) async {
    final originalAnimals = Map<String, AnimalEntity>.from(animals.rows);
    final originalLots = Map<String, LoteEntity>.from(lots.rows);
    try {
      return await action();
    } catch (_) {
      animals.rows
        ..clear()
        ..addAll(originalAnimals);
      lots.rows
        ..clear()
        ..addAll(originalLots);
      rethrow;
    }
  }
}

class _Health implements HealthRecordRepository {
  @override
  Future<HealthRecord> addHealthRecord(
    String uuid,
    HealthRecord record,
  ) async => record;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Movements implements MovementRecordRepository {
  @override
  Future<MovementRecord> addMovementRecord(
    String uuid,
    MovementRecord record,
  ) async => record;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Reproduction implements ReproductionRecordRepository {
  @override
  Future<ReproductionRecord> addReproductionRecord(
    String uuid,
    ReproductionRecord record,
  ) async => record;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
