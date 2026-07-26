import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';
import 'package:libretapp/features/milking/infrastructure/milking_repository_isar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('libretapp_milking_test_');

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
    'getOpenDraft ignores a draft abandoned on a previous day',
    () async {
      final repository = MilkingRepositoryIsar(IsarDatabase());

      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final staleDraft = MilkingSession(
        uuid: 'stale-draft',
        occurredAt: threeDaysAgo,
        shift: MilkingShift.fromTime(threeDaysAgo),
        status: MilkingStatus.draft,
        createdAt: threeDaysAgo,
        updatedAt: threeDaysAgo,
      );
      await repository.upsertSession(staleDraft);

      final resumed = await repository.getOpenDraft();

      expect(
        resumed,
        isNull,
        reason:
            'a draft abandoned days ago must not be silently resumed and '
            'absorb "today"\'s readings under the old date',
      );
    },
    skip: !_canRunIsarNative(),
  );

  test(
    "getOpenDraft resumes today's draft",
    () async {
      final repository = MilkingRepositoryIsar(IsarDatabase());

      final now = DateTime.now();
      final todayDraft = MilkingSession(
        uuid: 'today-draft',
        occurredAt: now,
        shift: MilkingShift.fromTime(now),
        status: MilkingStatus.draft,
        createdAt: now,
        updatedAt: now,
      );
      await repository.upsertSession(todayDraft);

      final resumed = await repository.getOpenDraft();

      expect(resumed?.uuid, 'today-draft');
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
