import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
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
      await tester.tap(find.textContaining(RegExp(r'^Ver \d+ funciones más$')));
      await tester.pumpAndSettle();
      expect(find.text('Registro por lotes'), findsOneWidget);
    },
  );

  testWidgets(
    'ganado prioriza captura rápida y permite expandir todas las acciones',
    (tester) async {
      locator.registerSingleton<AnimalRepository>(
        _FakeAnimalRepository([_animal(Species.cattle)]),
      );
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const RegistroPage()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Peso'), findsOneWidget);
      expect(find.text('Tratar lote'), findsNothing);
      await tester.tap(find.textContaining(RegExp(r'^Ver \d+ funciones más$')));
      await tester.pumpAndSettle();
      expect(find.text('Tratar lote'), findsOneWidget);
      expect(find.text('Lote'), findsOneWidget);
    },
  );

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
    expect(find.text('Sanitario'), findsNothing);
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
    expect(find.text('Lote'), findsNothing);
    expect(find.text('Sanitario'), findsNothing);
    await tester.tap(find.textContaining(RegExp(r'^Ver \d+ funciones más$')));
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
      initialLocation: AppRoutes.registro,
      routes: [
        GoRoute(
          path: AppRoutes.registro,
          builder: (context, state) => const RegistroPage(),
          routes: [
            GoRoute(
              path: 'plantas/nueva',
              name: AppRoutes.nameRegistroMenuCultivoNuevo,
              builder: (context, state) => Scaffold(
                body: Text(
                  'Alta de planta sin ubicación: '
                  '${state.uri.queryParameters.isEmpty}',
                ),
              ),
            ),
            GoRoute(
              path: 'ubicaciones/nueva',
              name: AppRoutes.nameRegistroMenuUbicacionNueva,
              builder: (context, state) =>
                  const Scaffold(body: Text('Alta de ubicación')),
            ),
          ],
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
    await tester.tap(find.textContaining(RegExp(r'^Ver \d+ funciones más$')));
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
        (container) => _sizeOf(tester, container).width == 16,
      ),
      hasLength(mainIconContainers.length),
    );
    expect(chevronContainers, hasLength(mainIconContainers.length));

    expect(find.text('Añadir planta o cultivo'), findsOneWidget);
    expect(find.text('Nueva ubicación'), findsOneWidget);
  });

  testWidgets('las tarjetas explican su acción y exponen contexto accesible', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const RegistroPage()),
    );
    await tester.pumpAndSettle();

    final card = find.byKey(const ValueKey('registro-card-Programar tarea'));
    expect(find.text('Crear un recordatorio en Agenda'), findsOneWidget);
    expect(tester.getSize(card).height, greaterThanOrEqualTo(64));
    final data = tester.getSemantics(card).getSemanticsData();
    expect(data.label, 'Programar tarea. Crear un recordatorio en Agenda');
    expect(data.hint, 'Abrir formulario');
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    semanticsHandle.dispose();
  });

  testWidgets('cada acción visible del menú abre su ruta asignada', (
    tester,
  ) async {
    locator.registerSingleton<CultivationRepository>(
      _FakeCultivationRepository(),
    );

    ({String label, String routeName, String? preset}) target(
      String label,
      String routeName, {
      String? preset,
    }) => (label: label, routeName: routeName, preset: preset);

    final targets = [
      target('Programar tarea', AppRoutes.nameRegistroMenuAgendaNuevo),
      target('Añadir animal', AppRoutes.nameRegistroMenuAnimalNuevo),
      target(
        'Alta de varios animales',
        AppRoutes.nameRegistroMenuAnimalMultiple,
      ),
      target('Lote', AppRoutes.nameRegistroMenuLoteNuevo),
      target(
        'Parición',
        AppRoutes.nameRegistroReproduccion,
        preset: 'paricion',
      ),
      target('Tratar lote', AppRoutes.nameRegistroTratarLote),
      target('Destete', AppRoutes.nameRegistroDestete),
      target('Peso', AppRoutes.nameRegistroPeso),
      target('Sanitario', AppRoutes.nameRegistroSanitario),
      target('Costo', AppRoutes.nameRegistroCosto),
      target('Cambio de ubicación', AppRoutes.nameRegistroMovimiento),
      target('Producción', AppRoutes.nameRegistroProduccion),
      target('Ordeña', AppRoutes.nameRegistroOrdena),
      target('Reproducción', AppRoutes.nameRegistroReproduccion),
      target('Comercial', AppRoutes.nameRegistroComercial),
      target('Registro por lotes', AppRoutes.nameBatchRecords),
      target('Añadir planta o cultivo', AppRoutes.nameRegistroMenuCultivoNuevo),
      target('Nueva ubicación', AppRoutes.nameRegistroMenuUbicacionNueva),
      if (ReleaseFeatures.hardwareIntegrationsEnabled)
        target('RFID', AppRoutes.nameRfid),
      if (!ReleaseFeatures.demoMode)
        target('Importar hato', AppRoutes.nameHerdImport),
    ];
    final routeNames = targets.map((target) => target.routeName).toSet();
    final menuRouteNames = {
      AppRoutes.nameRegistroMenuAgendaNuevo,
      AppRoutes.nameRegistroMenuAnimalNuevo,
      AppRoutes.nameRegistroMenuAnimalMultiple,
      AppRoutes.nameRegistroMenuLoteNuevo,
      AppRoutes.nameRegistroMenuCultivoNuevo,
      AppRoutes.nameRegistroMenuUbicacionNueva,
    };
    Widget destination(String routeName, GoRouterState state) => Scaffold(
      body: Center(
        child: Text(
          'abrió $routeName'
          '${state.uri.queryParameters['preset'] == null ? '' : ' ${state.uri.queryParameters['preset']}'}',
        ),
      ),
    );
    final router = GoRouter(
      initialLocation: AppRoutes.registro,
      routes: [
        GoRoute(
          path: AppRoutes.registro,
          builder: (context, state) => const RegistroPage(),
          routes: [
            for (final routeName in menuRouteNames)
              GoRoute(
                path: routeName,
                name: routeName,
                builder: (context, state) => destination(routeName, state),
              ),
          ],
        ),
        for (final (index, routeName)
            in routeNames
                .where((name) => !menuRouteNames.contains(name))
                .indexed)
          GoRoute(
            path: '/test/$index',
            name: routeName,
            builder: (context, state) => destination(routeName, state),
          ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
    );
    await tester.pumpAndSettle();
    final showAll = find.textContaining(RegExp(r'^Ver \d+ funciones más$'));
    await tester.ensureVisible(showAll);
    await tester.pumpAndSettle();
    await tester.tap(showAll);
    await tester.pumpAndSettle();

    for (final target in targets) {
      final card = find.byKey(ValueKey('registro-card-${target.label}')).last;
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();

      final expected =
          'abrió ${target.routeName}'
          '${target.preset == null ? '' : ' ${target.preset}'}';
      expect(find.text(expected), findsOneWidget, reason: target.label);

      router.pop();
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('las acciones de cultivo explican si aún no hay cultivos', (
    tester,
  ) async {
    locator.registerSingleton<CultivationRepository>(
      _FakeCultivationRepository(),
    );
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const RegistroPage()),
    );
    await tester.pumpAndSettle();

    for (final label in ['Cosecha', 'Riego', 'Salud de cultivo', 'Tarea']) {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.text('No hay cultivos disponibles para registrar.'),
        findsOneWidget,
        reason: label,
      );
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .clearSnackBars();
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('todas las opciones siguen accesibles con texto al 200 %', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const RegistroPage(),
      ),
    );
    await tester.pumpAndSettle();
    final more = find.textContaining(RegExp(r'^Ver \d+ funciones más$'));
    await tester.ensureVisible(more);
    await tester.tap(more);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Comercial'));
    final card = find.byKey(const ValueKey('registro-card-Comercial'));
    expect(tester.getSize(card).height, greaterThanOrEqualTo(64));
    await tester.ensureVisible(find.text('Nueva ubicación'));
    expect(tester.takeException(), isNull);
  });

  for (final width in <double>[320, 390, 600, 1200]) {
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
          expect(
            find.textContaining(RegExp(r'^Ver \d+ funciones más$')),
            findsOneWidget,
          );
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
  Future<List<CultivationEntity>> getAll({
    bool includeArchived = false,
  }) async => const [];

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
