import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/demo/demo_scenario_service.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/export_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('libretapp_full_export_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          pathProviderChannel,
          (_) async => tempDir.path,
        );
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await locator.reset();
    await setupLocator();
  });

  tearDown(() async {
    if (locator.isRegistered<IsarDatabase>()) {
      await locator<IsarDatabase>().close();
    }
    await locator.reset();
  });

  test('exports the twelve registered sheets with demo rows', () async {
    await locator<DemoScenarioService>().install(
      referenceDate: DateTime(2026, 8, 25),
      reset: false,
    );
    final service = locator<ExportService>();

    expect(service.sheets.keys, {
      'animals',
      'locations',
      'events',
      'weights',
      'weanings',
      'health',
      'reproduction',
      'movements',
      'costs',
      'commercial',
      'production',
      'milking',
      'finances',
    });

    final file = await service.exportToExcel(service.sheets.keys.toSet());
    final workbook = Excel.decodeBytes(await file.readAsBytes());
    const expectedNames = {
      'Animales',
      'Ubicaciones',
      'Eventos',
      'Pesos',
      'Destetes',
      'Salud',
      'Reproducción',
      'Movimientos',
      'Costos',
      'Comercial',
      'Producción',
      'Ordeñas',
      'Finanzas',
    };

    expect(workbook.tables.keys.toSet(), expectedNames);
    for (final name in expectedNames) {
      expect(
        workbook.tables[name]!.maxRows,
        name == 'Destetes' ? greaterThanOrEqualTo(1) : greaterThan(1),
        reason: '$name should include a header and at least one demo row',
      );
    }

    expect(_headers(workbook, 'Animales'), contains('UUID Animal'));
    expect(
      _headers(workbook, 'Pesos'),
      containsAll(['UUID Registro', 'Caravana']),
    );
    expect(
      _headers(workbook, 'Finanzas'),
      containsAll(['Dirección', 'Categoría', 'Monto', 'Moneda']),
    );
  });
}

List<String> _headers(Excel workbook, String name) => workbook
    .tables[name]!
    .rows
    .first
    .map((cell) => cell?.value?.toString() ?? '')
    .toList(growable: false);
