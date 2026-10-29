import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weaning_record_repository.dart';
import 'package:libretapp/features/directorio/animales/view/animal_weaning_form_page.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/view/animal_weight_form_page.dart';
import 'package:libretapp/features/directorio/animales/view/animal_health_form_page.dart';
import 'package:libretapp/features/directorio/animales/view/animal_reproduction_form_page.dart';
import 'package:libretapp/features/directorio/animales/view/animal_production_form_page.dart';
import 'package:libretapp/features/directorio/animales/view/animal_movement_form_page.dart';
import 'package:libretapp/features/directorio/animales/view/animal_commercial_form_page.dart';
import 'package:libretapp/features/directorio/animales/view/animal_cost_form_page.dart';
import 'package:libretapp/features/directorio/animales/view/bulk_health_form_page.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/app_theme.dart';
import 'advisor/rules/rule_test_fixtures.dart';

class _Animals implements AnimalRepository {
  final animal = buildAnimal(sex: Sex.female);
  @override
  Future<AnimalEntity?> getByUuid(String uuid) async => animal;
  @override
  Future<List<AnimalEntity>> getAll() async => [animal];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Weights implements WeightRecordRepository {
  @override
  Future<List<WeightRecord>> getWeightRecords(String uuid) async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Health implements HealthRecordRepository {
  @override
  Future<List<HealthRecord>> getHealthRecords(String uuid) async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Reproduction implements ReproductionRecordRepository {
  @override
  Future<List<ReproductionRecord>> getReproductionRecords(String uuid) async =>
      [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Weaning implements WeaningRecordRepository {
  @override
  Future<List<WeaningRecord>> getWeaningRecords(String uuid) async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Locations implements LocationRepository {
  @override
  Future<List<LocationEntity>> getAll() async => [];
  @override
  Stream<List<LocationEntity>> watchAll() => Stream.value([]);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    locator.registerSingleton<AnimalRepository>(_Animals());
    locator.registerSingleton<WeightRecordRepository>(_Weights());
    locator.registerSingleton<HealthRecordRepository>(_Health());
    locator.registerSingleton<LocationRepository>(_Locations());
    locator.registerSingleton<ReproductionRecordRepository>(_Reproduction());
    locator.registerSingleton<WeaningRecordRepository>(_Weaning());
  });
  tearDown(() => locator.reset());
  final pages = <String, Widget Function()>{
    'peso': () => const AnimalWeightFormPage(animalUuid: 'a1'),
    'destete': () => const AnimalWeaningFormPage(animalUuid: 'a1'),
    'salud': () => const AnimalHealthFormPage(animalUuid: 'a1'),
    'reproducción': () => const AnimalReproductionFormPage(animalUuid: 'a1'),
    'producción': () => const AnimalProductionFormPage(animalUuid: 'a1'),
    'movimiento': () => const AnimalMovementFormPage(animalUuid: 'a1'),
    'comercial': () => const AnimalCommercialFormPage(animalUuid: 'a1'),
    'costo': () => const AnimalCostFormPage(animalUuid: 'a1'),
    'salud masiva': () =>
        BulkHealthFormPage(selectedCount: 12, onSubmit: (_) async => true),
  };
  for (final page in pages.entries) {
    for (final dark in [false, true]) {
      testWidgets('${page.key}, 320dp 2x keyboard, dark=$dark', (tester) async {
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('es'),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2),
                viewInsets: const EdgeInsets.only(bottom: 260),
              ),
              child: child!,
            ),
            home: page.value(),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final scroll = find.byType(Scrollable).first;
        for (var step = 0; step < 5; step++) {
          await tester.drag(scroll, const Offset(0, -300));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        await tester.ensureVisible(
          find.widgetWithText(FilledButton, 'Guardar'),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
