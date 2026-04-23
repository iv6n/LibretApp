import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
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
      ..registerSingleton<LotesRepository>(_FakeLotesRepository());
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
  });
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
