import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/directorio/cultivos/infrastructure/cultivation_migration_service.dart';
import 'package:libretapp/features/directorio/cultivos/infrastructure/cultivation_repository_isar.dart';
import 'package:libretapp/features/directorio/cultivos/infrastructure/isar_cultivation.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_task_type.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/isar/isar_location.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'libretapp_cultivation_test_',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => tempDir.path);
  });

  setUp(() async {
    final isar = await IsarDatabase().initialize();
    await isar.writeTxn(() async {
      await isar.isarCultivations.clear();
      await isar.isarLocations.clear();
    });
  });

  tearDown(() => IsarDatabase().close());

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await IsarDatabase().close();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  test(
    'migration is idempotent and preserves embedded crop history',
    () async {
      final database = IsarDatabase();
      final isar = await database.initialize();
      final crop = CropRecord(
        uuid: 'legacy-crop',
        cropName: 'Maíz blanco',
        variety: 'Criollo',
        plantingDate: DateTime(2026, 2, 1),
        surface: 4.2,
        harvests: [
          HarvestRecord(
            uuid: 'harvest-1',
            date: DateTime(2026, 7, 1),
            yieldKg: 900,
          ),
        ],
        waterings: [CropWateringRecord(date: DateTime(2026, 2, 4))],
        healthRecords: [
          CropHealthRecord(date: DateTime(2026, 3, 1), issue: 'Hongo'),
        ],
        tasks: [
          CropTask(
            uuid: 'task-1',
            type: CropTaskType.harvest,
            dueDate: DateTime(2026, 7, 1),
          ),
        ],
      );
      final location = LocationEntity(
        uuid: 'location-1',
        name: 'Lote Norte',
        type: LocationType.field,
        surfaceArea: 10,
        capacity: 0,
        waterSource: '',
        terrainType: '',
        updatedAt: DateTime(2026, 4, 1),
        crops: [crop],
      );
      await isar.writeTxn(() => isar.isarLocations.put(location.toIsar()));

      expect(await migrateLegacyCultivations(isar), 1);
      expect(await migrateLegacyCultivations(isar), 0);

      final repository = CultivationRepositoryIsar(database);
      final migrated = await repository.getByUuid('legacy-crop');
      expect(migrated, isNotNull);
      expect(migrated!.locationUuid, 'location-1');
      expect(migrated.areaSquareMeters, 42000);
      expect(migrated.harvests.single.uuid, 'harvest-1');
      expect(migrated.waterings, hasLength(1));
      expect(migrated.healthRecords, hasLength(1));
      expect(migrated.tasks.single.uuid, 'task-1');
      expect((await isar.isarLocations.where().findFirst())!.crops, isEmpty);
      expect(await isar.isarCultivations.count(), 1);
    },
    skip: !_canRunIsarNative(),
  );

  test(
    'repository tracks an unlocated plant through activities and archive',
    () async {
      final repository = CultivationRepositoryIsar(IsarDatabase());
      await repository.upsert(
        CultivationEntity(
          uuid: 'rose-1',
          name: 'Rosa',
          plantingDate: DateTime(2026, 9, 1),
        ),
      );
      await repository.addWatering(
        'rose-1',
        CropWateringRecord(date: DateTime(2026, 9, 2), amountLiters: 2),
      );
      await repository.addHealth(
        'rose-1',
        CropHealthRecord(date: DateTime(2026, 9, 2), issue: 'Mancha'),
      );
      await repository.addTask(
        'rose-1',
        CropTask(
          uuid: 'prune-1',
          type: CropTaskType.prune,
          dueDate: DateTime(2026, 9, 10),
        ),
      );
      await repository.completeTask('rose-1', 'prune-1');

      final tracked = await repository.getByUuid('rose-1');
      expect(tracked!.locationUuid, isNull);
      expect(tracked.waterings, hasLength(1));
      expect(tracked.healthRecords, hasLength(1));
      expect(tracked.tasks.single.completed, isTrue);

      await repository.archive('rose-1');
      expect(
        (await repository.getByUuid('rose-1'))!.status,
        CropStatus.archived,
      );
      expect(await repository.getAll(), isEmpty);
      expect(await repository.getAll(includeArchived: true), hasLength(1));
    },
    skip: !_canRunIsarNative(),
  );

  test(
    'cultivation rows survive closing and reopening Isar',
    () async {
      final database = IsarDatabase();
      final repository = CultivationRepositoryIsar(database);
      await repository.upsert(
        CultivationEntity(
          uuid: 'persistent-crop',
          name: 'Cultivo persistente',
          plantingDate: DateTime(2026, 9, 1),
        ),
      );
      expect(await repository.getAll(), hasLength(1));

      await database.close();
      await database.initialize();

      final reopened = CultivationRepositoryIsar(database);
      final rows = await reopened.getAll();
      expect(rows, hasLength(1));
      expect(rows.single.uuid, 'persistent-crop');
      expect(rows.single.name, 'Cultivo persistente');
    },
    skip: !_canRunIsarNative(),
  );
}

bool _canRunIsarNative() {
  if (!Platform.isWindows) return true;
  return File('isar.dll').existsSync() ||
      File('${Directory.current.path}\\isar.dll').existsSync();
}
