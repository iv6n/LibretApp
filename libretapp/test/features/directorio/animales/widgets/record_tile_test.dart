import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/widgets/records_tab.dart';
import 'package:libretapp/l10n/app_localizations.dart';

Widget _testApp(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('es'),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('tapping an actionable record opens correction', (tester) async {
    var edits = 0;
    await tester.pumpWidget(
      _testApp(
        RecordTile(
          title: 'Registro con identidad',
          onEdit: () => edits++,
          onDelete: () {},
        ),
      ),
    );

    await tester.tap(find.text('Registro con identidad'));

    expect(edits, 1);
  });

  testWidgets('accessible menu exposes correction and deletion', (
    tester,
  ) async {
    var edits = 0;
    var deletes = 0;
    await tester.pumpWidget(
      _testApp(
        RecordTile(
          title: 'Registro',
          onEdit: () => edits++,
          onDelete: () => deletes++,
        ),
      ),
    );

    final menu = find.byWidgetPredicate((widget) => widget is PopupMenuButton);
    await tester.tap(menu);
    await tester.pumpAndSettle();
    expect(find.text('Corregir'), findsOneWidget);
    expect(find.text('Eliminar'), findsOneWidget);

    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    expect(deletes, 1);
    expect(edits, 0);
  });

  testWidgets('a record without identity remains read-only', (tester) async {
    await tester.pumpWidget(
      _testApp(const RecordTile(title: 'Registro importado')),
    );

    expect(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
      findsNothing,
    );
  });
}
