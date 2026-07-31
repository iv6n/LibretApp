import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/view/quick_register_animal_page.dart';

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

  testWidgets('uses compact sex controls and a two-wheel age picker', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: QuickRegisterAnimalPage()));
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

    await tester.ensureVisible(find.text('1 año'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1 año'));
    await tester.pumpAndSettle();

    expect(find.byType(ListWheelScrollView), findsNWidgets(2));
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Aplicar'), findsOneWidget);
  });

  testWidgets('persists optional name and confirms a pending cattle tag', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: QuickRegisterAnimalPage()));
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

  testWidgets('adapts identification and purposes for equines', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: QuickRegisterAnimalPage()));
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

    await tester.pumpWidget(const MaterialApp(home: QuickRegisterAnimalPage()));
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
