import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/view/quick_register_animal_page.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _testApp({double textScale = 1, double keyboardInset = 0}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          viewInsets: EdgeInsets.only(bottom: keyboardInset),
        ),
        child: child!,
      ),
      home: const QuickRegisterAnimalPage(),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAnimalRepository repository;

  setUp(() {
    repository = _FakeAnimalRepository();
    locator.registerSingleton<AnimalRepository>(repository);
  });

  tearDown(() async {
    await locator.reset();
  });

  for (final width in <double>[320, 360, 412]) {
    testWidgets('muestra identificación y Guardar a ${width.toInt()} dp', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_testApp());
      await tester.pumpAndSettle();
      final identification = find.byKey(
        const ValueKey('animal-quick-identification'),
      );
      expect(tester.getTopLeft(identification).dy, lessThan(580));
      expect(find.byKey(const ValueKey('animal-quick-save')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in <double>[320, 360, 412]) {
    testWidgets(
      'mantiene Guardar sobre el teclado a ${width.toInt()} dp con texto ampliado',
      (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(_testApp(textScale: 1.4, keyboardInset: 300));
        await tester.pumpAndSettle();

        final save = find.byKey(const ValueKey('animal-quick-save'));
        expect(tester.getBottomLeft(save).dy, lessThanOrEqualTo(500));
        expect(
          find.byKey(const ValueKey('animal-quick-identification')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final width in <double>[320, 412]) {
    testWidgets('alta rápida sin desbordes a ${width.toInt()} dp y 200 %', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_testApp(textScale: 2));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('animal-quick-save')), findsOneWidget);
      await tester.enterText(
        _fieldByLabel('Nombre o alias — opcional'),
        'Luna',
      );
      await tester.ensureVisible(find.text('Hembra'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hembra'));
      expect(tester.takeException(), isNull, reason: 'sexo');
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar animal'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'diálogo de arete');
      await tester.tap(find.text('Guardar como pendiente'));
      await tester.pumpAndSettle();
      expect(find.text('Registrar monta'), findsOneWidget);
      final layoutError = tester.takeException();
      expect(
        layoutError,
        isNull,
        reason: layoutError is FlutterError ? layoutError.toStringDeep() : null,
      );
    });
  }

  testWidgets('uses compact sex controls and a two-wheel age picker', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    final sexChips = find.byType(ChoiceChip).evaluate().where((element) {
      final chip = element.widget as ChoiceChip;
      final label = chip.label;
      return label is Text && {'Hembra', 'Macho'}.contains(label.data);
    });
    expect(sexChips.length, 2);
    for (final element in sexChips) {
      expect(tester.getSize(find.byWidget(element.widget)).height, 48);
    }

    await tester.tap(find.text('Edad'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('No lo sé').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('No lo sé').last);
    await tester.pumpAndSettle();

    expect(find.byType(ListWheelScrollView), findsNWidgets(2));
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Aplicar'), findsOneWidget);
  });

  testWidgets('persists optional name and confirms a pending cattle tag', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.enterText(_fieldByLabel('Nombre o alias — opcional'), 'Luna');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar animal'));
    await tester.pumpAndSettle();

    expect(find.text('Dejar arete pendiente'), findsOneWidget);
    await tester.tap(find.text('Guardar como pendiente'));
    await tester.pumpAndSettle();

    expect(repository.savedAnimals, hasLength(1));
    expect(repository.savedAnimals.single.customName, 'Luna');
    expect(repository.savedAnimals.single.breed, 'Desconocido');
    expect(repository.savedAnimals.single.earTagNumber, isEmpty);
    expect(find.text('Registrar otro'), findsOneWidget);
    expect(find.text('Registrar monta'), findsNothing);
    expect(find.text('Completar ficha'), findsOneWidget);
    expect(find.text('Volver al directorio'), findsOneWidget);
  });

  testWidgets('offers Registrar monta only after saving an eligible female', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.enterText(_fieldByLabel('Nombre o alias — opcional'), 'Luna');
    await tester.tap(find.text('Hembra'));
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar animal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar como pendiente'));
    await tester.pumpAndSettle();

    expect(repository.savedAnimals.single.sex, Sex.female);
    expect(find.text('Registrar monta'), findsOneWidget);
  });

  testWidgets(
    'cancellation returns to the saved animal and saving opens its ficha',
    (tester) async {
      final router = GoRouter(
        initialLocation: AppRoutes.animalNuevoRapido,
        routes: [
          GoRoute(
            path: AppRoutes.animalNuevoRapido,
            builder: (_, _) => const QuickRegisterAnimalPage(),
          ),
          GoRoute(
            path: AppRoutes.animalRegistroReproduccion,
            name: AppRoutes.nameAnimalRegistroReproduccion,
            builder: (context, state) => Scaffold(
              body: Column(
                children: [
                  Text(
                    'Monta ${state.pathParameters['uuid']} ${state.uri.queryParameters['step']}',
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancelar monta'),
                  ),
                  TextButton(
                    onPressed: () => context.pop(true),
                    child: const Text('Guardar monta'),
                  ),
                ],
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.animalDetalle,
            builder: (_, state) =>
                Scaffold(body: Text('Ficha ${state.pathParameters['uuid']}')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        _fieldByLabel('Nombre o alias — opcional'),
        'Luna',
      );
      await tester.tap(find.text('Hembra'));
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar animal'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar como pendiente'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Registrar monta'));
      await tester.pumpAndSettle();
      expect(find.textContaining('service'), findsOneWidget);
      await tester.tap(find.text('Cancelar monta'));
      await tester.pumpAndSettle();
      expect(find.text('Registrar monta'), findsOneWidget);

      await tester.tap(find.text('Registrar monta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar monta'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Ficha ani-'), findsOneWidget);
    },
  );

  testWidgets('saves an exact birth date without estimating it', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.enterText(_fieldByLabel('Nombre o alias — opcional'), 'Luna');
    await tester.tap(find.text('Fecha'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Elegir fecha de nacimiento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elegir fecha de nacimiento'));
    await tester.pumpAndSettle();
    final picker = find.byType(DatePickerDialog);
    await tester.tap(
      find
          .descendant(of: picker, matching: find.text('${DateTime.now().day}'))
          .last,
    );
    await tester.tap(
      find.descendant(of: picker, matching: find.byType(TextButton)).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar animal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar como pendiente'));
    await tester.pumpAndSettle();

    expect(
      repository.savedAnimals.single.birthDatePrecision,
      BirthDatePrecision.exact,
    );
    expect(repository.savedAnimals.single.birthDate.day, DateTime.now().day);
  });

  testWidgets('offers a discreet backup link after the first animal', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    locator.registerSingleton<SharedPrefsService>(
      SharedPrefsService(await SharedPreferences.getInstance()),
    );
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.enterText(_fieldByLabel('Nombre o alias — opcional'), 'Luna');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar animal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar como pendiente'));
    await tester.pumpAndSettle();

    expect(find.text('Proteger mis datos · Ver respaldos'), findsOneWidget);
  });

  testWidgets('adapts identification and purposes for equines', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Équido'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Más datos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Más datos'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Deporte'));
    await tester.pumpAndSettle();

    expect(find.text('Microchip, pasaporte o identificación'), findsOneWidget);
    expect(find.text('Deporte'), findsOneWidget);
    expect(find.text('Guardia'), findsNothing);
  });

  testWidgets('meets Flutter tap-target and semantic-label guidelines', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });
}

Finder _fieldByLabel(String label) {
  final field = find.ancestor(
    of: find.text(label),
    matching: find.byType(TextField),
  );
  return find.descendant(of: field, matching: find.byType(EditableText));
}

class _FakeAnimalRepository implements AnimalRepository {
  final List<AnimalEntity> savedAnimals = [];

  @override
  Future<List<AnimalEntity>> getAll() async => List.unmodifiable(savedAnimals);

  @override
  Future<AnimalEntity> save(AnimalEntity animal) async {
    savedAnimals.add(animal);
    return animal;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
