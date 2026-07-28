import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/services/export_service.dart';
import 'package:libretapp/core/services/exportable_sheet.dart';

class _SpySheet implements ExportableSheet {
  bool wasCalled = false;

  @override
  Future<void> writeTo(Excel excel) async {
    wasCalled = true;
    final sheet = excel['Spy'];
    writeExcelRow(sheet, 0, ['called']);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('libretapp_export_test_');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          switch (call.method) {
            case 'getTemporaryDirectory':
              return tempDir.path;
            default:
              return tempDir.path;
          }
        });
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    await tempDir.delete(recursive: true);
  });

  late _SpySheet animalsSheet;
  late _SpySheet ubicacionesSheet;
  late _SpySheet eventosSheet;
  late ExportService service;

  setUp(() {
    animalsSheet = _SpySheet();
    ubicacionesSheet = _SpySheet();
    eventosSheet = _SpySheet();
    service = ExportService(
      animalsSheet: animalsSheet,
      ubicacionesSheet: ubicacionesSheet,
      eventosSheet: eventosSheet,
    );
  });

  test('writes every sheet when all flags default to true', () async {
    final file = await service.exportToExcel();

    expect(animalsSheet.wasCalled, isTrue);
    expect(ubicacionesSheet.wasCalled, isTrue);
    expect(eventosSheet.wasCalled, isTrue);
    expect(file.existsSync(), isTrue);
    expect(file.path, contains('libretapp_export_'));
    expect(file.path, endsWith('.xlsx'));
  });

  test('only writes the animals sheet when the other flags are off', () async {
    await service.exportToExcel(ubicaciones: false, eventos: false);

    expect(animalsSheet.wasCalled, isTrue);
    expect(ubicacionesSheet.wasCalled, isFalse);
    expect(eventosSheet.wasCalled, isFalse);
  });

  test('only writes the ubicaciones sheet when the other flags are off', () async {
    await service.exportToExcel(animals: false, eventos: false);

    expect(animalsSheet.wasCalled, isFalse);
    expect(ubicacionesSheet.wasCalled, isTrue);
    expect(eventosSheet.wasCalled, isFalse);
  });

  test('only writes the eventos sheet when the other flags are off', () async {
    await service.exportToExcel(animals: false, ubicaciones: false);

    expect(animalsSheet.wasCalled, isFalse);
    expect(ubicacionesSheet.wasCalled, isFalse);
    expect(eventosSheet.wasCalled, isTrue);
  });

  test('writes no sheets when every flag is off, but still produces a file', () async {
    final file = await service.exportToExcel(
      animals: false,
      ubicaciones: false,
      eventos: false,
    );

    expect(animalsSheet.wasCalled, isFalse);
    expect(ubicacionesSheet.wasCalled, isFalse);
    expect(eventosSheet.wasCalled, isFalse);
    expect(file.existsSync(), isTrue);
  });
}
