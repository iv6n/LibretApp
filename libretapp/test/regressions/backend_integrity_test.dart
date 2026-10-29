import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/persistence/isar_feature_record_store.dart';
import 'package:libretapp/core/persistence/json_feature_repository.dart';
import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_remote_data_source.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/health_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/movement_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/repositories/isar_location_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/almacen/inventory_service.dart';
import 'package:libretapp/features/ubicaciones/almacen/inventory_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';
import 'package:libretapp/features/finanzas/infrastructure/isar_finanzas_repository.dart';
import '../features/directorio/animales/advisor/rules/rule_test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final root = Directory(
    '${Directory.systemTemp.path}/libret-regression-$stamp',
  );
  var index = 0;
  late IsarDatabase database;
  late AnimalRepositoryIsar animals;
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  setUpAll(() async {
    await root.create(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (_) async => root.absolute.path);
  });
  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, null);
    await root.delete(recursive: true);
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (_) async => root.absolute.path);
    database = IsarDatabase.workspace(
      root.absolute.path,
      name: 'backend_${stamp}_${index++}',
    );
    await database.initialize();
    animals = AnimalRepositoryIsar(
      database,
      SharedPrefsService(await SharedPreferences.getInstance()),
      AnimalApiMock(),
    );
    await animals.save(
      buildAnimal(
        uuid: 'probe-animal',
        initialLocationId: 'A',
        currentLocationId: 'A',
      ),
    );
  });
  tearDown(() async => database.close());

  test(
    'deleting last movement restores registration location and date',
    () async {
      final locations = IsarLocationRepository(database);
      for (final id in ['A', 'B']) {
        await locations.upsert(
          LocationEntity(
            uuid: id,
            name: id,
            type: LocationType.pasture,
            surfaceArea: 1,
            capacity: 5,
            waterSource: '',
            terrainType: '',
          ),
        );
      }
      final movements = MovementRecordRepositoryIsar(database);
      final record = await movements.addMovementRecord(
        'probe-animal',
        MovementRecord(
          fromLocation: 'A',
          toLocation: 'B',
          date: DateTime(2026, 10, 1),
          reason: MovementReason.relocation,
        ),
      );
      expect((await animals.getByUuid('probe-animal'))!.currentLocationId, 'B');
      await movements.deleteMovementRecord(record.id!);
      expect(await movements.getMovementRecords('probe-animal'), isEmpty);
      final result = (await animals.getByUuid('probe-animal'))!;
      expect(result.initialLocationId, 'A');
      expect(result.currentLocationId, 'A');
      expect(result.lastMovementDate, isNull);
    },
  );

  test('deleting disease clears generated monitoring flags', () async {
    final health = HealthRecordRepositoryIsar(database);
    final record = await health.addHealthRecord(
      'probe-animal',
      HealthRecord(
        date: DateTime.now(),
        type: HealthRecordType.disease,
        product: 'Error de captura',
      ),
    );
    expect((await animals.getByUuid('probe-animal'))!.underObservation, true);
    await health.deleteHealthRecord(record.id!);
    expect(await health.getHealthRecords('probe-animal'), isEmpty);
    final result = (await animals.getByUuid('probe-animal'))!;
    expect(result.underObservation, false);
    expect(result.requiresAttention, false);
  });

  test('inventory transfer conserves stock at destination and farm', () async {
    final store = IsarFeatureRecordStore(database);
    final inventory = InventoryService(
      JsonFeatureRepository<InventoryTransaction>(
        store: store,
        kind: 'audit.inventory',
        decode: InventoryTransaction.fromJson,
        encode: (value) => value.toJson(),
      ),
    );
    await inventory.record(
      farmId: 'farm',
      productId: 'feed',
      type: InventoryTransactionType.entry,
      quantity: 100,
      unit: 'kg',
      locationId: 'A',
    );
    await inventory.record(
      farmId: 'farm',
      productId: 'feed',
      type: InventoryTransactionType.transfer,
      quantity: 40,
      unit: 'kg',
      locationId: 'A',
      destinationLocationId: 'B',
    );
    expect(
      (await inventory.balance('farm', 'feed', locationId: 'A')).quantity,
      60,
    );
    expect(
      (await inventory.balance('farm', 'feed', locationId: 'B')).quantity,
      40,
    );
    expect((await inventory.balance('farm', 'feed')).quantity, 100);
  });

  test('record UUID cannot move between farms', () async {
    final store = IsarFeatureRecordStore(database);
    FeatureRecord row(String farm) => FeatureRecord(
      uuid: 'same-uuid',
      farmId: farm,
      kind: 'audit',
      payload: {'farm': farm},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await store.put(row('farm-A'));
    await expectLater(store.put(row('farm-B')), throwsArgumentError);
    expect((await store.get('farm-A', 'same-uuid'))!.payload['farm'], 'farm-A');
    expect(await store.get('farm-B', 'same-uuid'), isNull);
  });

  test('non-finite income is rejected before persistence', () async {
    final finances = IsarFinanzasRepository(database);
    for (final amount in [
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      await expectLater(
        finances.addIncome(
          IncomeRecord(
            date: DateTime.now(),
            type: IncomeType.other,
            amount: amount,
          ),
        ),
        throwsArgumentError,
      );
    }
    expect(await finances.getAllIncomes(), isEmpty);
  });
}
