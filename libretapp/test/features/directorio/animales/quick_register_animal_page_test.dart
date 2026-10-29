import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/di/injection.dart';
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

    await tester.ensureVisible(find.text('No lo sé'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No lo sé'));
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
    expect(find.text('Completar ficha'), findsOneWidget);
    expect(find.text('Volver al directorio'), findsOneWidget);
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
