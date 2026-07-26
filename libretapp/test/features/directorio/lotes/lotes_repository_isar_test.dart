import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository_isar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('libretapp_lotes_test_');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          switch (call.method) {
            case 'getApplicationSupportDirectory':
            case 'getApplicationDocumentsDirectory':
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
    await IsarDatabase().close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  tearDown(() async {
    await IsarDatabase().close();
  });

  test(
    'a fresh install has no lotes — no demo data is seeded',
    () async {
      final repository = LotesRepositoryIsar(IsarDatabase());

      final lotes = await repository.getAll();

      expect(
        lotes,
        isEmpty,
        reason:
            'production installs must not be seeded with fake demo lotes '
            'referencing non-existent animals',
      );
    },
    skip: !_canRunIsarNative(),
  );
}

bool _canRunIsarNative() {
  if (!Platform.isWindows) return true;
  final candidates = <File>[
    File('isar.dll'),
    File('${Directory.current.path}\\isar.dll'),
  ];
  return candidates.any((file) => file.existsSync());
}
