import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/core/experience/care_profile.dart';
import 'package:libretapp/core/experience/registration_preferences.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libretapp/core/platform/release_features.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/registro/view/registro_page.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await locator.reset();
    locator.registerSingleton<LocationRepository>(_FakeLocationRepository());
  });

  tearDown(() async {
    await locator.reset();
  });

  testWidgets(
    'espacio vacío prioriza mascota y tarea sin ocultar herramientas',
    (tester) async {
      locator.registerSingleton<AnimalRepository>(
        _FakeAnimalRepository(const []),
      );
      SharedPreferences.setMockInitialValues({});
      final controller = AppExperienceController(
        SharedPrefsService(await SharedPreferences.getInstance()),
      );
      await controller.setPreferences(
        RegistrationPreferences(
          preferredSpecies: const {Species.canine, Species.feline},
          includePlants: false,
          careProfile: CareProfile.pets,
        ),
      );
      await tester.pumpWidget(
        AppExperienceScope(
          controller: controller,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const RegistroPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Animal'), findsOneWidget);
      expect(find.text('Añadir mascota'), findsOneWidget);
      expect(find.text('Programar tarea'), findsOneWidget);
      expect(find.text('Plantas'), findsOneWidget);
      expect(find.text('Ubicaciones'), findsOneWidget);
      expect(find.byType(TabBar), findsNothing);
      expect(find.byType(TabBarView), findsNothing);
      expect(find.text('Registro por lotes'), findsNothing);
      await tester.tap(find.text('Ver todas las funciones'));
      await tester.pumpAndSettle();
      expect(find.text('Registro por lotes'), findsOneWidget);
    },
  );

  testWidgets('ganado prioriza acciones de lote según animales existentes', (
    tester,
  ) async {
    locator.registerSingleton<AnimalRepository>(
      _FakeAnimalRepository([_animal(Species.cattle)]),
    );
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const RegistroPage()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tratar lote'), findsOneWidget);
    expect(find.text('Lote'), findsOneWidget);
  });

  testWidgets('mascotas y espacio mixto priorizan acciones pertinentes', (
    tester,
  ) async {
    locator.registerSingleton<AnimalRepository>(
      _FakeAnimalRepository([_animal(Species.canine)]),
    );
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const RegistroPage()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Añadir mascota'), findsOneWidget);
    expect(find.text('Sanitario'), findsOneWidget);
    expect(find.text('Tratar lote'), findsNothing);

    await locator.unregister<AnimalRepository>();
    locator.registerSingleton<AnimalRepository>(
      _FakeAnimalRepository([_animal(Species.canine), _animal(Species.cattle)]),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const RegistroPage()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Añadir animal'), findsOneWidget);
    expect(find.text('Lote'), findsOneWidget);
    expect(find.text('Sanitario'), findsOneWidget);
    await tester.tap(find.text('Ver todas las funciones'));
    await tester.pumpAndSettle();
    expect(find.text('Lote'), findsOneWidget);
    expect(find.text('Sanitario'), findsOneWidget);
    expect(find.text('Peso'), findsOneWidget);
    expect(find.text('Animal'), findsOneWidget);
    expect(find.text('Registro por lotes'), findsOneWidget);
  });

  testWidgets('secciones visibles en orden y desplazables sin pestañas', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const RegistroPage()),
    );
    await tester.pumpAndSettle();

    final animal = tester.getTopLeft(find.text('Animal')).dy;
    final plants = tester.getTopLeft(find.text('Plantas')).dy;
    final locations = tester.getTopLeft(find.text('Ubicaciones')).dy;
    expect(animal, lessThan(plants));
    expect(plants, lessThan(locations));
    for (final label in [
      'Añadir planta o cultivo',
      'Cosecha',
      'Riego',
      'Salud de cultivo',
      'Tarea',
    ]) {
      expect(find.text(label), findsOneWidget);
      expect(tester.getTopLeft(find.text(label)).dy, greaterThan(plants));
      expect(tester.getTopLeft(find.text(label)).dy, lessThan(locations));
    }
    expect(find.byType(TabBar), findsNothing);
    expect(find.byType(TabBarView), findsNothing);

    await tester.ensureVisible(find.text('Nueva ubicación'));
    await tester.pumpAndSettle();
    expect(find.text('Nueva ubicación'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('alta de planta y ubicación conservan sus rutas', (tester) async {
    locator.registerSingleton<CultivationRepository>(
      _FakeCultivationRepository(),
    );
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const RegistroPage()),
        GoRoute(
          path: '/plantas/nueva',
          name: AppRoutes.nameCultivoNuevo,
          builder: (context, state) => Scaffold(
            body: Text(
              'Alta de planta sin ubicación: '
              '${state.uri.queryParameters.isEmpty}',
            ),
          ),
        ),
        GoRoute(
          path: '/ubicaciones/nueva',
          name: AppRoutes.nameUbicacionNueva,
          builder: (context, state) =>
              const Scaffold(body: Text('Alta de ubicación')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Añadir planta o cultivo'));
    await tester.tap(find.text('Añadir planta o cultivo'));
    await tester.pumpAndSettle();
    expect(find.text('Alta de planta sin ubicación: true'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Nueva ubicación'));
    await tester.tap(find.text('Nueva ubicación'));
    await tester.pumpAndSettle();
    expect(find.text('Alta de ubicación'), findsOneWidget);
  });

  testWidgets('las acciones principales y el catálogo usan el mismo tamaño', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const RegistroPage()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Programar tarea'), findsOneWidget);
    await tester.tap(find.text('Ver todas las funciones'));
    await tester.pumpAndSettle();

    final mainIconContainers = _decoratedContainers(tester).where((container) {
      final decoration = container.decoration! as BoxDecoration;
      return decoration.shape == BoxShape.rectangle &&
          decoration.borderRadius != null;
    }).toList();
    final chevronContainers = _decoratedContainers(tester).where((container) {
      final decoration = container.decoration! as BoxDecoration;
      return decoration.shape == BoxShape.circle;
    }).toList();

    final cardCount =
        (ReleaseFeatures.hardwareIntegrationsEnabled ? 15 : 14) +
        (ReleaseFeatures.demoMode ? 0 : 1);
    expect(find.text('Registro por lotes'), findsOneWidget);
    if (!ReleaseFeatures.demoMode) {
      expect(find.text('Importar hato'), findsOneWidget);
    }
    expect(mainIconContainers.length, greaterThan(cardCount));
    expect(
      mainIconContainers.where(
        (container) => _sizeOf(tester, container).width == 44,
      ),
      hasLength(mainIconContainers.length),
    );
    expect(chevronContainers, hasLength(mainIconContainers.length));

    expect(find.text('Añadir planta o cultivo'), findsOneWidget);
    expect(find.text('Nueva ubicación'), findsOneWidget);
  });

  for (final width in <double>[360, 390, 604, 1280]) {
    for (final dark in <bool>[false, true]) {
      testWidgets(
        'menú sin desbordes a ${width.toInt()} px en tema ${dark ? 'oscuro' : 'claro'}',
        (tester) async {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: dark ? ThemeMode.dark : ThemeMode.light,
              home: const RegistroPage(),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Programar tarea'), findsOneWidget);
          expect(find.text('Ver todas las funciones'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

List<Container> _decoratedContainers(WidgetTester tester) => tester
    .widgetList<Container>(find.byType(Container))
    .where((container) => container.decoration is BoxDecoration)
    .toList();

Size _sizeOf(WidgetTester tester, Container container) =>
    tester.getSize(find.byWidget(container));

class _FakeLocationRepository implements LocationRepository {
  @override
  Future<List<LocationEntity>> getAll() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCultivationRepository implements CultivationRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAnimalRepository implements AnimalRepository {
  _FakeAnimalRepository(this.animals);
  final List<AnimalEntity> animals;

  @override
  Future<List<AnimalEntity>> getAll() async => animals;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AnimalEntity _animal(Species species) => AnimalEntity(
  uuid: 'animal-1',
  earTagNumber: 'A1',
  species: species,
  category: Category.cow,
  lifeStage: LifeStage.cow,
  sex: Sex.female,
  breed: 'Criollo',
  birthDate: DateTime(2022, 1, 1),
  ageMonths: 48,
  healthStatus: HealthStatus.good,
  vaccinated: false,
  dewormed: false,
  hasVitamins: false,
  hasChronicIssues: false,
  reproductiveStatus: ReproductiveStatus.unknown,
  productionPurpose: ProductionPurpose.dairy,
  productionStage: ProductionStage.unknown,
  productionSystem: ProductionSystem.intensive,
  underObservation: false,
  requiresAttention: false,
  riskLevel: RiskLevel.none,
  gallery: const [],
  status: AnimalStatus.active,
  synced: false,
  creationDate: DateTime(2026),
  lastUpdateDate: DateTime(2026),
);
