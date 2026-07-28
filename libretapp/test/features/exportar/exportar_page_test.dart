import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/export_service.dart';
import 'package:libretapp/core/services/exportable_sheet.dart';
import 'package:libretapp/features/exportar/view/exportar_page.dart';

class _NoopExportableSheet implements ExportableSheet {
  @override
  Future<void> writeTo(Excel excel) async {}
}

void main() {
  setUp(() {
    if (locator.isRegistered<ExportService>()) {
      locator.unregister<ExportService>();
    }
    locator.registerSingleton<ExportService>(
      ExportService(
        animalsSheet: _NoopExportableSheet(),
        ubicacionesSheet: _NoopExportableSheet(),
        eventosSheet: _NoopExportableSheet(),
      ),
    );
  });

  tearDown(() {
    if (locator.isRegistered<ExportService>()) {
      locator.unregister<ExportService>();
    }
  });

  Checkbox selectAllCheckbox(WidgetTester tester) {
    final tile = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Seleccionar todo'),
    );
    return Checkbox(value: tile.value, tristate: tile.tristate, onChanged: (_) {});
  }

  testWidgets('"Seleccionar todo" starts checked when every section defaults to selected', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ExportarPage()));
    await tester.pumpAndSettle();

    expect(selectAllCheckbox(tester).value, isTrue);
  });

  testWidgets('"Seleccionar todo" shows the indeterminate state when the selection is mixed', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ExportarPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(CheckboxListTile, 'Animales'));
    await tester.pumpAndSettle();

    expect(
      selectAllCheckbox(tester).value,
      isNull,
      reason: 'mixed selection must render the tristate dash, not look unchecked',
    );
  });

  testWidgets('"Seleccionar todo" is unchecked once every section is deselected', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExportarPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(CheckboxListTile, 'Animales'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Ubicaciones'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Agenda'));
    await tester.pumpAndSettle();

    expect(selectAllCheckbox(tester).value, isFalse);
  });
}
