import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/registro/view/bulk_health_registro_page.dart';
import 'package:libretapp/features/registro/view/registro_comercial_page.dart';
import 'package:libretapp/features/registro/view/registro_costo_page.dart';
import 'package:libretapp/features/registro/view/registro_movimiento_page.dart';
import 'package:libretapp/features/registro/view/registro_peso_page.dart';
import 'package:libretapp/features/registro/view/registro_produccion_page.dart';
import 'package:libretapp/features/registro/view/registro_reproduccion_page.dart';
import 'package:libretapp/features/registro/view/registro_sanitario_page.dart';
import 'package:libretapp/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAnimalRepository animalRepo;

  setUp(() {
    animalRepo = _FakeAnimalRepository(
      animals: [
        _animal(
          uuid: 'ani-reg-1',
          earTag: 'TAG-REG-1',
          customName: 'Animal Reg 1',
        ),
      ],
    );

    locator
      ..registerSingleton<AnimalRepository>(animalRepo)
      ..registerSingleton<LotesRepository>(_FakeLotesRepository())
      ..registerSingleton<WeightRecordRepository>(_FakeWeightRecordRepository())
      ..registerSingleton<HealthRecordRepository>(_FakeHealthRecordRepository())
      ..registerSingleton<ProductionRecordRepository>(
        _FakeProductionRecordRepository(),
      )
      ..registerSingleton<ReproductionRecordRepository>(
        _FakeReproductionRecordRepository(),
      )
      ..registerSingleton<CommercialRecordRepository>(
        _FakeCommercialRecordRepository(),
      )
      ..registerSingleton<MovementRecordRepository>(
        _FakeMovementRecordRepository(),
      )
      ..registerSingleton<CostRecordRepository>(_FakeCostRecordRepository());
  });

  tearDown(() async {
    await locator.reset();
  });

  group('Registro pages validations', () {
    testWidgets('registro peso blocks non-positive values', (tester) async {
      await tester.pumpWidget(_testApp(const RegistroPesoPage()));
      await tester.pumpAndSettle();

      await _selectAnimal(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Peso (kg)'), '0');

      await _tapSave(tester);

      expect(find.textContaining('mayor que cero'), findsOneWidget);
    });

    testWidgets('registro produccion requires value for weighing', (
      tester,
    ) async {
      await tester.pumpWidget(_testApp(const RegistroProduccionPage()));
      await tester.pumpAndSettle();

      await _selectAnimal(tester);
      await _tapSave(tester);

      expect(
        find.text('Ingresa un valor para este tipo de registro'),
        findsOneWidget,
      );
    });

    testWidgets('registro movimiento blocks same from/to locations', (
      tester,
    ) async {
      await tester.pumpWidget(_testApp(const RegistroMovimientoPage()));
      await tester.pumpAndSettle();

      await _selectAnimal(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Desde (opcional)'),
        'Potrero 1',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Hacia'),
        'Potrero 1',
      );

      await _tapSave(tester);

      expect(find.textContaining('origen y destino'), findsOneWidget);
    });

    testWidgets('registro comercial requires amount for purchase type', (
      tester,
    ) async {
      await tester.pumpWidget(_testApp(const RegistroComercialPage()));
      await tester.pumpAndSettle();

      await _selectAnimal(tester);
      await _tapSave(tester);

      expect(
        find.text('Monto requerido para este tipo de registro'),
        findsOneWidget,
      );
    });

    testWidgets('registro costo blocks non-positive amount', (tester) async {
      await tester.pumpWidget(_testApp(const RegistroCostoPage()));
      await tester.pumpAndSettle();

      await _selectAnimal(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Monto'), '0');

      await _tapSave(tester);

      expect(find.textContaining('mayor que cero'), findsOneWidget);
    });

    testWidgets('registro sanitario requires product', (tester) async {
      await tester.pumpWidget(_testApp(const RegistroSanitarioPage()));
      await tester.pumpAndSettle();

      await _selectAnimal(tester);

      await _tapSave(tester);

      expect(find.text('Producto requerido'), findsOneWidget);
    });

    testWidgets('registro reproduccion requires animal selection', (
      tester,
    ) async {
      await tester.pumpWidget(_testApp(const RegistroReproduccionPage()));
      await tester.pumpAndSettle();

      await _tapSave(tester);

      expect(find.text('Selecciona un animal primero'), findsOneWidget);
    });

    testWidgets(
      'registro sanitario: cancelling the "next date" picker preserves the already-picked date',
      (tester) async {
        await tester.pumpWidget(_testApp(const RegistroSanitarioPage()));
        await tester.pumpAndSettle();

        await _pickThenCancelNextDate(tester, placeholder: 'Próximo (opcional)');
      },
    );

    testWidgets(
      'bulk health registro: cancelling the "next date" picker preserves the already-picked date',
      (tester) async {
        await tester.pumpWidget(_testApp(const BulkHealthRegistroPage()));
        await tester.pumpAndSettle();

        await tester.tap(find.textContaining('TAG-REG-1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continuar (1)'));
        await tester.pumpAndSettle();

        await _pickThenCancelNextDate(tester, placeholder: 'Próximo (opcional)');
      },
    );
  });
}

/// Opens the optional "next date" picker (marked by the Icons.event_available
/// button, distinct from the required date's Icons.today button), picks a
/// date, then reopens it and cancels — the previously picked date must
/// remain visible instead of being silently wiped back to [placeholder].
Future<void> _pickThenCancelNextDate(
  WidgetTester tester, {
  required String placeholder,
}) async {
  final nextDateButtonFinder = find.ancestor(
    of: find.byIcon(Icons.event_available),
    matching: find.byType(OutlinedButton),
  );
  expect(nextDateButtonFinder, findsOneWidget);

  final labelFinder = find.descendant(
    of: nextDateButtonFinder,
    matching: find.byType(Text),
  );
  expect(tester.widget<Text>(labelFinder).data, placeholder);

  await tester.ensureVisible(nextDateButtonFinder);
  await tester.tap(nextDateButtonFinder);
  await tester.pumpAndSettle();

  final materialLocalizations = MaterialLocalizations.of(
    tester.element(nextDateButtonFinder),
  );
  await tester.tap(find.text(materialLocalizations.okButtonLabel));
  await tester.pumpAndSettle();

  final pickedDateLabel = tester.widget<Text>(labelFinder).data;
  expect(
    pickedDateLabel,
    isNot(placeholder),
    reason: 'the date should have been picked and the placeholder replaced',
  );

  await tester.tap(nextDateButtonFinder);
  await tester.pumpAndSettle();
  await tester.tap(find.text(materialLocalizations.cancelButtonLabel));
  await tester.pumpAndSettle();

  expect(
    tester.widget<Text>(labelFinder).data,
    pickedDateLabel,
    reason:
        'cancelling the picker must not wipe out a date the user already chose',
  );
}

Future<void> _tapSave(WidgetTester tester) async {
  final saveButton = find.text('Guardar');
  await tester.ensureVisible(saveButton);
  await tester.tap(saveButton, warnIfMissed: false);
  await tester.pumpAndSettle();
}

Future<void> _selectAnimal(WidgetTester tester) async {
  await tester.tap(find.text('Seleccionar animal'));
  await tester.pumpAndSettle();

  await tester.tap(find.textContaining('TAG-REG-1').last);
  await tester.pumpAndSettle();
}

Widget _testApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    home: child,
  );
}

AnimalEntity _animal({
  required String uuid,
  required String earTag,
  required String customName,
}) {
  final now = DateTime(2025, 1, 1);
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: earTag,
    customName: customName,
    visualId: 'VIS-$uuid',
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: 'Cebu',
    birthDate: DateTime(2020, 1, 1),
    ageMonths: 60,
    healthStatus: HealthStatus.good,
    vaccinated: true,
    dewormed: true,
    hasVitamins: true,
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

class _FakeAnimalRepository implements AnimalRepository {
  _FakeAnimalRepository({required List<AnimalEntity> animals})
    : _animals = List<AnimalEntity>.from(animals);

  final List<AnimalEntity> _animals;

  @override
  Future<List<AnimalEntity>> getAll() async =>
      List<AnimalEntity>.unmodifiable(_animals);

  @override
  Stream<List<AnimalEntity>> watchAll() async* {
    yield List<AnimalEntity>.unmodifiable(_animals);
  }

  @override
  Future<bool> refreshFromRemote({bool force = false}) async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLotesRepository implements LotesRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWeightRecordRepository implements WeightRecordRepository {
  @override
  Future<List<WeightRecord>> getWeightRecords(String animalUuid) async =>
      const [];
  @override
  Future<Map<String, List<WeightRecord>>> getWeightRecordsForAnimals(
    Set<String> animalUuids,
  ) async => const {};
  @override
  Future<WeightRecord> addWeightRecord(
    String animalUuid,
    WeightRecord record,
  ) async => record;
  @override
  Future<void> deleteWeightRecord(String recordId) async {}
}

class _FakeHealthRecordRepository implements HealthRecordRepository {
  @override
  Future<List<HealthRecord>> getHealthRecords(String animalUuid) async =>
      const [];
  @override
  Future<Map<String, DateTime>> getActiveWithdrawals(
    Set<String> animalUuids, {
    DateTime? asOf,
  }) async => const {};
  @override
  Future<HealthRecord> addHealthRecord(
    String animalUuid,
    HealthRecord record,
  ) async => record;
  @override
  Future<void> addHealthRecordToMultiple(
    List<String> animalUuids,
    HealthRecord record,
  ) async {}
  @override
  Future<void> deleteHealthRecord(String recordId) async {}
}

class _FakeProductionRecordRepository implements ProductionRecordRepository {
  @override
  Future<List<ProductionRecord>> getProductionRecords(
    String animalUuid,
  ) async => const [];
  @override
  Future<ProductionRecord> addProductionRecord(
    String animalUuid,
    ProductionRecord record,
  ) async => record;
  @override
  Future<void> deleteProductionRecord(String recordId) async {}
}

class _FakeReproductionRecordRepository
    implements ReproductionRecordRepository {
  @override
  Future<List<ReproductionRecord>> getReproductionRecords(
    String animalUuid,
  ) async => const [];
  @override
  Future<Map<String, List<ReproductionRecord>>>
  getReproductionRecordsForAnimals(Set<String> animalUuids) async => const {};
  @override
  Future<List<ReproductionRecord>> getRecordsBySire(String sireUuid) async =>
      const [];
  @override
  Future<ReproductionRecord> addReproductionRecord(
    String animalUuid,
    ReproductionRecord record,
  ) async => record;
  @override
  Future<void> deleteReproductionRecord(String recordId) async {}
  @override
  Future<List<({String animalUuid, DateTime expectedCalvingDate})>>
  getUpcomingCalvings(DateTime from, DateTime to) async => const [];
}

class _FakeCommercialRecordRepository implements CommercialRecordRepository {
  @override
  Future<List<CommercialRecord>> getCommercialRecords(
    String animalUuid,
  ) async => const [];
  @override
  Future<CommercialRecord> addCommercialRecord(
    String animalUuid,
    CommercialRecord record,
  ) async => record;
  @override
  Future<void> deleteCommercialRecord(String recordId) async {}
}

class _FakeMovementRecordRepository implements MovementRecordRepository {
  @override
  Future<List<MovementRecord>> getMovementRecords(String animalUuid) async =>
      const [];
  @override
  Future<MovementRecord> addMovementRecord(
    String animalUuid,
    MovementRecord record,
  ) async => record;
  @override
  Future<void> deleteMovementRecord(String recordId) async {}
}

class _FakeCostRecordRepository implements CostRecordRepository {
  @override
  Future<List<CostRecord>> getCostRecords(String animalUuid) async => const [];
  @override
  Future<CostRecord> addCostRecord(
    String animalUuid,
    CostRecord record,
  ) async => record;
  @override
  Future<void> deleteCostRecord(String recordId) async {}
}
