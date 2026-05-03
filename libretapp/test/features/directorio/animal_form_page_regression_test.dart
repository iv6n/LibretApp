import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/view/register_animal_page.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    locator.registerSingleton<SharedPrefsService>(SharedPrefsService(prefs));
  });

  tearDown(() async {
    await locator.reset();
  });

  group('RegisterAnimalPage regressions', () {
    testWidgets('builds create form without duplicate key errors', (
      tester,
    ) async {
      final now = DateTime(2025, 1, 1);
      final animalRepo = _FakeAnimalRepository(
        allAnimals: [
          _animal(uuid: 'a-1', sex: Sex.female, updatedAt: now),
          _animal(uuid: 'a-2', sex: Sex.male, updatedAt: now),
        ],
      );
      final lotesRepo = _FakeLotesRepository(
        activeLotes: [
          _lote(uuid: 'l-1', nombre: 'Lote A', now: now),
          _lote(uuid: 'l-1', nombre: 'Lote A duplicado', now: now),
        ],
      );
      final locationRepo = _FakeLocationRepository(
        allLocations: [
          _location(uuid: 'u-1', name: 'Potrero 1'),
          _location(uuid: 'u-1', name: 'Potrero 1 duplicado'),
        ],
      );

      locator
        ..registerSingleton<AnimalRepository>(animalRepo)
        ..registerSingleton<LotesRepository>(lotesRepo)
        ..registerSingleton<LocationRepository>(locationRepo);

      await tester.pumpWidget(_testApp(const RegisterAnimalPage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Registrar nuevo animal'), findsOneWidget);
      expect(find.text('Siguiente'), findsOneWidget);
    });

    testWidgets('sanitizes stale selected values in edit mode', (tester) async {
      final now = DateTime(2025, 1, 1);
      final editingAnimal = _animal(
        uuid: 'edit-1',
        sex: Sex.female,
        updatedAt: now,
        currentPaddockId: 'missing-location',
        batchUuid: 'missing-batch',
      );

      final animalRepo = _FakeAnimalRepository(
        allAnimals: [editingAnimal],
        byUuid: {'edit-1': editingAnimal},
      );
      final lotesRepo = _FakeLotesRepository(
        activeLotes: [_lote(uuid: 'l-1', nombre: 'Lote A', now: now)],
      );
      final locationRepo = _FakeLocationRepository(
        allLocations: [_location(uuid: 'u-1', name: 'Potrero 1')],
      );

      locator
        ..registerSingleton<AnimalRepository>(animalRepo)
        ..registerSingleton<LotesRepository>(lotesRepo)
        ..registerSingleton<LocationRepository>(locationRepo);

      await tester.pumpWidget(const _TestEditAnimalForm());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Editar animal'), findsOneWidget);
    });

    testWidgets('auto-adjusts species and category with feedback messages', (
      tester,
    ) async {
      final now = DateTime(2025, 1, 1);
      final animalRepo = _FakeAnimalRepository(
        allAnimals: [
          _animal(uuid: 'a-1', sex: Sex.female, updatedAt: now),
          _animal(uuid: 'a-2', sex: Sex.male, updatedAt: now),
        ],
      );
      final lotesRepo = _FakeLotesRepository(activeLotes: const []);
      final locationRepo = _FakeLocationRepository(allLocations: const []);

      locator
        ..registerSingleton<AnimalRepository>(animalRepo)
        ..registerSingleton<LotesRepository>(lotesRepo)
        ..registerSingleton<LocationRepository>(locationRepo);

      await tester.pumpWidget(_testApp(const RegisterAnimalPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<Species>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Équido').last);
      await tester.pumpAndSettle();

      final categoryField = tester.widget<DropdownButtonFormField<Category>>(
        find.byType(DropdownButtonFormField<Category>),
      );
      expect(categoryField.initialValue, Category.other);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows no-ear-tag warning and stays on form when canceled', (
      tester,
    ) async {
      final now = DateTime(2025, 1, 1);
      final animalRepo = _FakeAnimalRepository(
        allAnimals: [_animal(uuid: 'a-1', sex: Sex.female, updatedAt: now)],
      );
      final lotesRepo = _FakeLotesRepository(activeLotes: const []);
      final locationRepo = _FakeLocationRepository(allLocations: const []);

      locator
        ..registerSingleton<AnimalRepository>(animalRepo)
        ..registerSingleton<LotesRepository>(lotesRepo)
        ..registerSingleton<LocationRepository>(locationRepo);

      await tester.pumpWidget(_testApp(const RegisterAnimalPage()));
      await tester.pumpAndSettle();

      await _tapFilledButtonByLabel(tester, 'Siguiente');

      expect(find.text('Siguiente'), findsOneWidget);
      expect(find.text('Anterior'), findsNothing);
      expect(find.text('Registrar nuevo animal'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('advances to step 2 when ear tag is valid', (tester) async {
      final now = DateTime(2025, 1, 1);
      final animalRepo = _FakeAnimalRepository(
        allAnimals: [_animal(uuid: 'a-1', sex: Sex.female, updatedAt: now)],
      );
      final lotesRepo = _FakeLotesRepository(activeLotes: const []);
      final locationRepo = _FakeLocationRepository(allLocations: const []);

      locator
        ..registerSingleton<AnimalRepository>(animalRepo)
        ..registerSingleton<LotesRepository>(lotesRepo)
        ..registerSingleton<LocationRepository>(locationRepo);

      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_testApp(const RegisterAnimalPage()));
      await tester.pumpAndSettle();

      await _fillStep1RequiredFields(tester, earTag: '1001');
      await _tapFilledButtonByLabel(tester, 'Siguiente');

      expect(find.text('Anterior'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('persists animal directly when AnimalesBloc is absent', (
      tester,
    ) async {
      final now = DateTime(2025, 1, 1);
      final animalRepo = _FakeAnimalRepository(
        allAnimals: [_animal(uuid: 'a-1', sex: Sex.female, updatedAt: now)],
      );
      final lotesRepo = _FakeLotesRepository(activeLotes: const []);
      final locationRepo = _FakeLocationRepository(allLocations: const []);

      locator
        ..registerSingleton<AnimalRepository>(animalRepo)
        ..registerSingleton<LotesRepository>(lotesRepo)
        ..registerSingleton<LocationRepository>(locationRepo);

      await tester.pumpWidget(_testApp(const RegisterAnimalPage()));
      await tester.pumpAndSettle();

      await _fillStep1RequiredFields(tester, earTag: '2001');

      await _navigateToLastStep(tester);
      await _tapFilledButtonByLabel(tester, 'Terminar');

      expect(animalRepo.saveCallCount, 1);
      expect(
        animalRepo.savedAnimals.any((animal) => animal.earTagNumber == '2001'),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'stays on create form when direct save fails without AnimalesBloc',
      (tester) async {
        final now = DateTime(2025, 1, 1);
        final animalRepo = _FakeAnimalRepository(
          allAnimals: [_animal(uuid: 'a-1', sex: Sex.female, updatedAt: now)],
          throwOnSave: true,
        );
        final lotesRepo = _FakeLotesRepository(activeLotes: const []);
        final locationRepo = _FakeLocationRepository(allLocations: const []);

        locator
          ..registerSingleton<AnimalRepository>(animalRepo)
          ..registerSingleton<LotesRepository>(lotesRepo)
          ..registerSingleton<LocationRepository>(locationRepo);

        await tester.pumpWidget(_testApp(const RegisterAnimalPage()));
        await tester.pumpAndSettle();

        await _fillStep1RequiredFields(tester, earTag: '2002');

        await _navigateToLastStep(tester);
        await _tapFilledButtonByLabel(tester, 'Terminar');

        expect(animalRepo.saveCallCount, 1);
        expect(
          find.textContaining('No se pudo guardar el animal'),
          findsOneWidget,
        );
        expect(find.text('Registrar nuevo animal'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'updates animal directly in edit mode when AnimalesBloc is absent',
      (tester) async {
        final now = DateTime(2025, 1, 1);
        final editingAnimal = _animal(
          uuid: 'edit-1',
          sex: Sex.female,
          updatedAt: now,
        );

        final animalRepo = _FakeAnimalRepository(
          allAnimals: [editingAnimal],
          byUuid: {'edit-1': editingAnimal},
        );
        final lotesRepo = _FakeLotesRepository(activeLotes: const []);
        final locationRepo = _FakeLocationRepository(allLocations: const []);

        locator
          ..registerSingleton<AnimalRepository>(animalRepo)
          ..registerSingleton<LotesRepository>(lotesRepo)
          ..registerSingleton<LocationRepository>(locationRepo);

        await tester.pumpWidget(const _TestEditAnimalForm());
        await tester.pumpAndSettle();

        await _fillStep1RequiredFields(tester, earTag: '3002');

        await _navigateToLastStep(tester);
        await _tapFilledButtonByLabel(tester, 'Terminar');

        expect(animalRepo.updateCallCount, 1);
        expect(
          animalRepo.updatedAnimals.any(
            (animal) =>
                animal.uuid == 'edit-1' && animal.earTagNumber == '3002',
          ),
          isTrue,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'stays on edit form when direct update fails without AnimalesBloc',
      (tester) async {
        final now = DateTime(2025, 1, 1);
        final editingAnimal = _animal(
          uuid: 'edit-1',
          sex: Sex.female,
          updatedAt: now,
        );

        final animalRepo = _FakeAnimalRepository(
          allAnimals: [editingAnimal],
          byUuid: {'edit-1': editingAnimal},
          throwOnUpdate: true,
        );
        final lotesRepo = _FakeLotesRepository(activeLotes: const []);
        final locationRepo = _FakeLocationRepository(allLocations: const []);

        locator
          ..registerSingleton<AnimalRepository>(animalRepo)
          ..registerSingleton<LotesRepository>(lotesRepo)
          ..registerSingleton<LocationRepository>(locationRepo);

        await tester.pumpWidget(const _TestEditAnimalForm());
        await tester.pumpAndSettle();

        await _fillStep1RequiredFields(tester, earTag: '3003');

        await _navigateToLastStep(tester);
        await _tapFilledButtonByLabel(tester, 'Terminar');

        expect(animalRepo.updateCallCount, 1);
        expect(
          find.textContaining('No se pudo guardar el animal'),
          findsOneWidget,
        );
        expect(find.text('Editar animal'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('blocks step advance when ear tag is duplicated', (
      tester,
    ) async {
      final now = DateTime(2025, 1, 1);
      final animalRepo = _FakeAnimalRepository(
        allAnimals: [
          _animal(
            uuid: 'existing-1',
            sex: Sex.female,
            updatedAt: now,
          ).copyWith(earTagNumber: '9001'),
        ],
      );
      final lotesRepo = _FakeLotesRepository(activeLotes: const []);
      final locationRepo = _FakeLocationRepository(allLocations: const []);

      locator
        ..registerSingleton<AnimalRepository>(animalRepo)
        ..registerSingleton<LotesRepository>(lotesRepo)
        ..registerSingleton<LocationRepository>(locationRepo);

      await tester.pumpWidget(_testApp(const RegisterAnimalPage()));
      await tester.pumpAndSettle();

      await _fillStep1RequiredFields(tester, earTag: '9001');

      await _tapFilledButtonByLabel(tester, 'Siguiente');

      expect(find.text('Anterior'), findsNothing);
      expect(find.text('El arete ya existe en otro registro.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('persists provided breed on save flow', (tester) async {
      final now = DateTime(2025, 1, 1);
      final animalRepo = _FakeAnimalRepository(
        allAnimals: [_animal(uuid: 'a-1', sex: Sex.female, updatedAt: now)],
      );
      final lotesRepo = _FakeLotesRepository(activeLotes: const []);
      final locationRepo = _FakeLocationRepository(allLocations: const []);

      locator
        ..registerSingleton<AnimalRepository>(animalRepo)
        ..registerSingleton<LotesRepository>(lotesRepo)
        ..registerSingleton<LocationRepository>(locationRepo);

      await tester.pumpWidget(_testApp(const RegisterAnimalPage()));
      await tester.pumpAndSettle();

      await _fillStep1RequiredFields(tester, earTag: '4001');

      await _navigateToLastStep(tester);
      await _tapFilledButtonByLabel(tester, 'Terminar');

      expect(animalRepo.saveCallCount, 1);
      expect(animalRepo.savedAnimals.last.breed, 'Criolla');
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows breed required error when breed field is empty', (
      tester,
    ) async {
      final now = DateTime(2025, 1, 1);
      final animalRepo = _FakeAnimalRepository(
        allAnimals: [_animal(uuid: 'a-1', sex: Sex.female, updatedAt: now)],
      );
      final lotesRepo = _FakeLotesRepository(activeLotes: const []);
      final locationRepo = _FakeLocationRepository(allLocations: const []);

      locator
        ..registerSingleton<AnimalRepository>(animalRepo)
        ..registerSingleton<LotesRepository>(lotesRepo)
        ..registerSingleton<LocationRepository>(locationRepo);

      await tester.pumpWidget(_testApp(const RegisterAnimalPage()));
      await tester.pumpAndSettle();

      // Fill only ear tag — leave breed empty
      await tester.enterText(_earTagFieldFinder(), '5001');
      await tester.pump();

      await _tapFilledButtonByLabel(tester, 'Siguiente');

      // Validation error should appear and form stays on step 0 (no 'Anterior' button)
      expect(find.text('Ingresa la raza'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Anterior'), findsNothing);
      expect(animalRepo.saveCallCount, 0);
      expect(tester.takeException(), isNull);
    });
  });
}

/// Navigates from step 1 to the last step by tapping 'Siguiente' 4 times.
/// Uses a large viewport to avoid RenderFlex overflow on the Madre/Padre dropdowns.
Future<void> _navigateToLastStep(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pump();
  for (int i = 0; i < 4; i++) {
    await _tapFilledButtonByLabel(tester, 'Siguiente');
  }
}

Future<void> _tapFilledButtonByLabel(WidgetTester tester, String label) async {
  final finder = find.widgetWithText(FilledButton, label);
  expect(finder, findsOneWidget);
  final button = tester.widget<FilledButton>(finder);
  final onPressed = button.onPressed;
  expect(onPressed, isNotNull);
  onPressed!.call();
  await tester.pumpAndSettle();
}

Future<void> _fillStep1RequiredFields(
  WidgetTester tester, {
  required String earTag,
}) async {
  await tester.enterText(_earTagFieldFinder(), earTag);
  await tester.enterText(_breedFieldFinder(), 'Criolla');
  await tester.pump();
}

Finder _earTagFieldFinder() {
  final label = find.text('Arete / Identificacion');
  final textFormField = find.ancestor(
    of: label,
    matching: find.byType(TextFormField),
  );
  return find.descendant(
    of: textFormField,
    matching: find.byType(EditableText),
  );
}

Finder _breedFieldFinder() {
  final label = find.text('Raza 1');
  final textFormField = find.ancestor(
    of: label,
    matching: find.byType(TextFormField),
  );
  return find.descendant(
    of: textFormField,
    matching: find.byType(EditableText),
  );
}

class _TestEditAnimalForm extends StatelessWidget {
  const _TestEditAnimalForm();

  @override
  Widget build(BuildContext context) {
    return _testApp(const RegisterAnimalPage(animalUuid: 'edit-1'));
  }
}

Widget _testApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    home: child,
  );
}

LocationEntity _location({required String uuid, required String name}) {
  return LocationEntity(
    uuid: uuid,
    name: name,
    type: LocationType.potrero,
    surfaceArea: 1,
    capacity: 10,
    waterSource: 'pozo',
    terrainType: 'plano',
    status: 'activo',
  );
}

LoteEntity _lote({
  required String uuid,
  required String nombre,
  required DateTime now,
}) {
  return LoteEntity(
    uuid: uuid,
    nombre: nombre,
    fechaCreacion: now,
    lastUpdateDate: now,
  );
}

AnimalEntity _animal({
  required String uuid,
  required Sex sex,
  required DateTime updatedAt,
  String? currentPaddockId,
  String? batchUuid,
}) {
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: 'TAG-$uuid',
    customName: 'Animal $uuid',
    visualId: 'VIS-$uuid',
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: sex,
    breed: 'Cebú',
    birthDate: DateTime(2020, 1, 1),
    ageMonths: 60,
    weight: 420,
    healthStatus: HealthStatus.good,
    vaccinated: true,
    dewormed: true,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.undefined,
    productionStage: ProductionStage.unknown,
    productionSystem: ProductionSystem.unknown,
    currentPaddockId: currentPaddockId,
    initialLocationId: currentPaddockId,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.low,
    gallery: const [],
    batchUuid: batchUuid,
    synced: false,
    creationDate: updatedAt,
    lastUpdateDate: updatedAt,
  );
}

class _FakeAnimalRepository implements AnimalRepository {
  _FakeAnimalRepository({
    required List<AnimalEntity> allAnimals,
    Map<String, AnimalEntity>? byUuid,
    this.throwOnSave = false,
    this.throwOnUpdate = false,
  }) : _allAnimals = allAnimals,
       _byUuid = byUuid ?? <String, AnimalEntity>{};

  final List<AnimalEntity> _allAnimals;
  final Map<String, AnimalEntity> _byUuid;
  final _streamController = StreamController<List<AnimalEntity>>.broadcast();
  final bool throwOnSave;
  final bool throwOnUpdate;
  int saveCallCount = 0;
  int updateCallCount = 0;
  final List<AnimalEntity> savedAnimals = <AnimalEntity>[];
  final List<AnimalEntity> updatedAnimals = <AnimalEntity>[];

  @override
  Stream<List<AnimalEntity>> watchAll() async* {
    yield List<AnimalEntity>.unmodifiable(_allAnimals);
    yield* _streamController.stream;
  }

  @override
  Future<bool> refreshFromRemote({bool force = false}) async => true;

  @override
  Future<List<AnimalEntity>> getAll() async => _allAnimals;

  @override
  Future<AnimalEntity?> getByUuid(String uuid) async => _byUuid[uuid];

  @override
  Future<AnimalEntity> save(AnimalEntity animal) async {
    saveCallCount += 1;
    if (throwOnSave) {
      throw Exception('save failed');
    }
    savedAnimals.add(animal);
    _allAnimals.add(animal);
    _byUuid[animal.uuid] = animal;
    _streamController.add(List<AnimalEntity>.unmodifiable(_allAnimals));
    return animal;
  }

  @override
  Future<AnimalEntity> update(AnimalEntity animal) async {
    updateCallCount += 1;
    if (throwOnUpdate) {
      throw Exception('update failed');
    }
    updatedAnimals.add(animal);
    _byUuid[animal.uuid] = animal;
    final index = _allAnimals.indexWhere((item) => item.uuid == animal.uuid);
    if (index >= 0) {
      _allAnimals[index] = animal;
    } else {
      _allAnimals.add(animal);
    }
    _streamController.add(List<AnimalEntity>.unmodifiable(_allAnimals));
    return animal;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #dispose) {
      _streamController.close();
      return null;
    }
    return super.noSuchMethod(invocation);
  }
}

class _FakeLotesRepository implements LotesRepository {
  _FakeLotesRepository({required List<LoteEntity> activeLotes})
    : _activeLotes = activeLotes;

  final List<LoteEntity> _activeLotes;

  @override
  Future<List<LoteEntity>> getActiveLotes() async => _activeLotes;

  @override
  Future<List<LoteEntity>> getAll() async => _activeLotes;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLocationRepository implements LocationRepository {
  _FakeLocationRepository({required List<LocationEntity> allLocations})
    : _allLocations = allLocations;

  final List<LocationEntity> _allLocations;

  @override
  Future<List<LocationEntity>> getAll() async => _allLocations;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
