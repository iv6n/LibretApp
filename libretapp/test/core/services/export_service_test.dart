import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/services/export_service.dart';
import 'package:libretapp/core/services/exportable_sheet.dart';

class _SpySheet implements ExportableSheet {
  _SpySheet(this.key);

  bool wasCalled = false;

  @override
  final String key;

  @override
  String get title => key;

  @override
  String get description => 'Test $key';

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
    animalsSheet = _SpySheet('animals');
    ubicacionesSheet = _SpySheet('locations');
    eventosSheet = _SpySheet('events');
    service = ExportService([animalsSheet, ubicacionesSheet, eventosSheet]);
  });

  test('writes every selected registry sheet', () async {
    final file = await service.exportToExcel({
      'animals',
      'locations',
      'events',
    });

    expect(animalsSheet.wasCalled, isTrue);
    expect(ubicacionesSheet.wasCalled, isTrue);
    expect(eventosSheet.wasCalled, isTrue);
    expect(file.existsSync(), isTrue);
    expect(file.path, contains('libretapp_export_'));
    expect(file.path, endsWith('.xlsx'));
    final workbook = Excel.decodeBytes(await file.readAsBytes());
    expect(workbook.tables, isNot(contains('Sheet1')));
  });

  test('only writes selected keys', () async {
    await service.exportToExcel({'animals'});

    expect(animalsSheet.wasCalled, isTrue);
    expect(ubicacionesSheet.wasCalled, isFalse);
    expect(eventosSheet.wasCalled, isFalse);
  });

  test('rejects an empty selection', () async {
    await expectLater(service.exportToExcel({}), throwsArgumentError);
  });

  test('rejects unknown keys', () async {
    await expectLater(
      service.exportToExcel({'animals', 'unknown'}),
      throwsArgumentError,
    );
  });

  test('rejects duplicate registry keys', () {
    expect(
      () => ExportService([_SpySheet('same'), _SpySheet('same')]),
      throwsArgumentError,
    );
  });
}
