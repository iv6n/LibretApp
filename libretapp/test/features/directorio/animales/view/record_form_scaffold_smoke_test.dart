import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/view/animal_weight_form_page.dart';
import 'package:libretapp/features/directorio/animales/view/bulk_health_form_page.dart';
import 'package:libretapp/l10n/app_localizations.dart';

/// Smoke-tests two of the 8 record form pages that were migrated onto the
/// shared `RecordFormScaffold` (one plain page, one that uses the
/// `formKey`-driven `Form`/`TextFormField` validation path) to catch any
/// rendering/wiring regression from the extraction — these pages had zero
/// widget test coverage before.
class _FakeWeightRecordRepository implements WeightRecordRepository {
  bool addCalled = false;

  @override
  Future<List<WeightRecord>> getWeightRecords(String animalUuid) async => [];

  @override
  Future<Map<String, List<WeightRecord>>> getWeightRecordsForAnimals(
    Set<String> animalUuids,
  ) async => const {};

  @override
  Future<WeightRecord> addWeightRecord(
    String animalUuid,
    WeightRecord record,
  ) async {
    addCalled = true;
    return record;
  }

  @override
  Future<void> deleteWeightRecord(String recordId) async {}
}

Widget _testApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    home: child,
  );
}

void main() {
  group('AnimalWeightFormPage', () {
    late _FakeWeightRecordRepository repo;

    setUp(() {
      repo = _FakeWeightRecordRepository();
      locator.registerSingleton<WeightRecordRepository>(repo);
    });

    tearDown(() async => locator.reset());

    testWidgets('renders the title and save button', (tester) async {
      await tester.pumpWidget(
        _testApp(const AnimalWeightFormPage(animalUuid: 'a1')),
      );

      expect(find.text('Registrar peso'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Guardar'), findsOneWidget);
    });

    testWidgets(
      'blocks save and shows a validation error when weight is empty',
      (tester) async {
        await tester.pumpWidget(
          _testApp(const AnimalWeightFormPage(animalUuid: 'a1')),
        );

        await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
        await tester.pump();

        expect(find.text('Ingresa un peso válido'), findsOneWidget);
        expect(repo.addCalled, isFalse);
      },
    );
  });

  group('BulkHealthFormPage', () {
    testWidgets('renders the title with the selected count', (tester) async {
      await tester.pumpWidget(
        _testApp(
          BulkHealthFormPage(
            selectedCount: 3,
            onSubmit: (record) async => true,
          ),
        ),
      );

      expect(find.textContaining('3'), findsWidgets);
      expect(find.widgetWithText(FilledButton, 'Guardar'), findsOneWidget);
    });

    testWidgets(
      'blocks submit and shows a validation error when product is empty',
      (tester) async {
        var submitted = false;
        await tester.pumpWidget(
          _testApp(
            BulkHealthFormPage(
              selectedCount: 2,
              onSubmit: (record) async {
                submitted = true;
                return true;
              },
            ),
          ),
        );

        await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
        await tester.pump();

        expect(find.text('Producto requerido'), findsOneWidget);
        expect(submitted, isFalse);
      },
    );
  });
}
