import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/lite/lite_pages.dart';
import 'package:libretapp/features/lite/lite_pet_service.dart';
import 'package:libretapp/features/lite/lite_task_form_page.dart';
import 'package:libretapp/theme/app_theme.dart';

class _Animals extends AnimalRepository {
  final list = <AnimalEntity>[];
  @override
  Future<AnimalEntity> save(AnimalEntity animal) async {
    list.add(animal);
    return animal;
  }

  @override
  Future<List<AnimalEntity>> getAllIncludingInactive() async => list;

  @override
  Future<List<AnimalEntity>> getAll() async => list;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Plants extends CultivationRepository {
  _Plants(this.list);

  final List<CultivationEntity> list;

  @override
  Future<List<CultivationEntity>> getAll({
    bool includeArchived = false,
  }) async => list;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppExperienceController controller;
  setUp(() async {
    await initializeDateFormatting('es');
    SharedPreferences.setMockInitialValues({});
    final prefs = SharedPrefsService(await SharedPreferences.getInstance());
    controller = AppExperienceController(prefs);
    final animals = _Animals();
    final cat = await LitePetService(
      animals,
    ).create(const LitePetInput(name: 'Mora', species: Species.feline));
    animals.list.add(cat.copyWith(uuid: 'cow', species: Species.cattle));
    locator.registerSingleton<AnimalRepository>(animals);
    locator.registerSingleton<CultivationRepository>(
      _Plants([
        CultivationEntity(name: 'Albahaca', plantingDate: DateTime(2026)),
      ]),
    );
  });
  tearDown(() async {
    controller.dispose();
    await locator.reset();
  });

  testWidgets('una cita guarda fecha singular y varias tomas usan plural', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppExperienceScope(
        controller: controller,
        child: const MaterialApp(home: LiteTaskFormPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Guardar fecha'), findsOneWidget);
    await tester.tap(find.text('Cita').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Medicamento').last);
    await tester.pumpAndSettle();
    final doses = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Número de tomas',
    );
    await tester.enterText(doses, '3');
    await tester.pump();
    expect(find.text('Guardar fechas'), findsOneWidget);
  });

  for (final width in [320.0, 412.0]) {
    for (final dark in [false, true]) {
      testWidgets(
        'formulario de mascota a ${width}dp y texto 200 %, oscuro $dark',
        (tester) async {
          tester.view.physicalSize = Size(width, 760);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            AppExperienceScope(
              controller: controller,
              child: MaterialApp(
                theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(2)),
                  child: child!,
                ),
                home: const LitePetFormPage(),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Más detalles'));
          await tester.pumpAndSettle();
          final chipField = find.byWidgetPredicate(
            (widget) =>
                widget is TextField &&
                widget.decoration?.labelText == 'Microchip o placa (opcional)',
          );
          final sexField = find.byWidgetPredicate(
            (widget) =>
                widget is DropdownButtonFormField &&
                widget.decoration.labelText == 'Sexo (opcional)',
          );
          expect(
            tester.getRect(sexField).top,
            greaterThanOrEqualTo(tester.getRect(chipField).bottom + 12),
          );
          await tester.drag(
            find.byType(ListView).first,
            const Offset(0, -1800),
          );
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('Guardar'));
          expect(find.text('Guardar').hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
