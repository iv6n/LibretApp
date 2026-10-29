import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/detail_helpers.dart';
import 'package:libretapp/features/directorio/animales/widgets/movement_location_names.dart';
import 'package:libretapp/features/directorio/animales/widgets/records_tab.dart';
import 'package:libretapp/l10n/app_localizations.dart';

import '../../../support/web_batch_fixture.dart';
import 'advisor/rules/rule_test_fixtures.dart';

Future<void> _showHistory(
  WidgetTester tester,
  List<MovementRecord> movements, {
  Map<String, String> names = const {},
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: RecordsTab(
          data: DetailData(
            animal: buildAnimal(),
            weights: const [],
            reproductions: const [],
            productions: const [],
            health: const [],
            commercial: const [],
            movements: movements,
            movementLocationNames: names,
            costs: const [],
            milkingRecords: const [],
          ),
          onChanged: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows persisted origin and destination names after reopening, '
      'including archived locations', (tester) async {
    final history = (await tester.runAsync(() async {
      final fixture = WebBatchFixture();
      try {
        await fixture.open();
        await fixture.seed();
        await fixture.locations.upsert(
          (await fixture.locations.getByUuid(
            'north',
          ))!.copyWith(name: 'Potrero norte'),
        );
        await fixture.locations.upsert(
          (await fixture.locations.getByUuid(
            'south',
          ))!.copyWith(name: 'Potrero destino'),
        );
        await fixture.movements.addMovementRecord(
          'a',
          MovementRecord(
            date: DateTime(2026, 10, 25),
            fromLocation: 'north',
            toLocation: 'south',
            reason: MovementReason.relocation,
            notes: 'Traslado de prueba',
          ),
        );
        await fixture.locations.deleteByUuid('north');
        await fixture.locations.deleteByUuid('south');
        await fixture.reopen();

        final movements = await fixture.movements.getMovementRecords('a');
        final names = await loadMovementLocationNames(
          movements,
          fixture.locations,
        );
        return (movements, names);
      } finally {
        await fixture.dispose();
      }
    }))!;
    await _showHistory(tester, history.$1, names: history.$2);

    expect(
      find.text('De Potrero norte · A Potrero destino · Traslado de prueba'),
      findsOneWidget,
    );
    expect(find.textContaining('north'), findsNothing);
    expect(find.textContaining('south'), findsNothing);
    expect(history.$1.single.fromLocation, 'north');
    expect(history.$1.single.toLocation, 'south');
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps legacy names and labels a cleared location', (
    tester,
  ) async {
    const reference = 'c4675f92-8228-4ca5-accc-ac9c1cb8fdb8';
    await _showHistory(
      tester,
      [
        MovementRecord(
          date: DateTime(2026, 10, 25),
          fromLocation: 'Corral antiguo',
          toLocation: 'Potrero antiguo',
          reason: MovementReason.relocation,
        ),
        MovementRecord(
          date: DateTime(2026, 10, 24),
          fromLocation: reference,
          toLocation: '',
          clearsLocation: true,
          reason: MovementReason.relocation,
        ),
      ],
      names: {reference: 'Potrero de salida'},
    );

    expect(find.text('De Corral antiguo · A Potrero antiguo'), findsOneWidget);
    expect(find.text('De Potrero de salida · A Sin ubicación'), findsOneWidget);
    expect(find.textContaining(reference), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not expose an unresolved UUID in the history', (
    tester,
  ) async {
    const reference = 'c4675f92-8228-4ca5-accc-ac9c1cb8fdb8';
    await _showHistory(tester, [
      MovementRecord(
        date: DateTime(2026, 10, 25),
        toLocation: reference,
        reason: MovementReason.relocation,
      ),
    ]);

    expect(find.text('A Sin dato'), findsOneWidget);
    expect(find.textContaining(reference), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
