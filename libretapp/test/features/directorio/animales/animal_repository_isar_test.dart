import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_remote_data_source.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository_isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('libretapp_isar_test_');

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
    'save persists animal in Isar and can be fetched by uuid',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final sharedPrefs = await SharedPreferences.getInstance();

      final repository = AnimalRepositoryIsar(
        IsarDatabase(),
        SharedPrefsService(sharedPrefs),
        _FakeAnimalRemoteDataSource(),
      );

      await repository.clearAll();

      final now = DateTime.now();
      final animal = AnimalEntity(
        uuid: 'isar-test-1',
        earTagNumber: 'TAG-ISAR-001',
        customName: 'Isar Animal',
        visualId: 'VIS-ISAR-001',
        species: Species.cattle,
        category: Category.cow,
        lifeStage: LifeStage.cow,
        sex: Sex.female,
        breed: 'Cebu',
        birthDate: DateTime(2021, 1, 1),
        ageMonths: 60,
        healthStatus: HealthStatus.good,
        vaccinated: true,
        dewormed: true,
        hasVitamins: false,
        hasChronicIssues: false,
        reproductiveStatus: ReproductiveStatus.unknown,
        productionPurpose: ProductionPurpose.undefined,
        productionStage: ProductionStage.unknown,
        productionSystem: ProductionSystem.unknown,
        underObservation: false,
        requiresAttention: false,
        riskLevel: RiskLevel.low,
        gallery: const <String>[],
        synced: true,
        creationDate: now,
        lastUpdateDate: now,
      );

      final saved = await repository.save(animal);
      final fetched = await repository.getByUuid('isar-test-1');
      final total = await repository.count();

      expect(saved.uuid, 'isar-test-1');
      expect(saved.synced, isFalse);
      expect(fetched, isNotNull);
      expect(fetched!.earTagNumber, 'TAG-ISAR-001');
      expect(fetched.synced, isFalse);
      expect(total, 1);
    },
    skip: !_canRunIsarNative(),
  );

  test(
    'watchAll reflects save update and delete operations',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final sharedPrefs = await SharedPreferences.getInstance();

      final repository = AnimalRepositoryIsar(
        IsarDatabase(),
        SharedPrefsService(sharedPrefs),
        _FakeAnimalRemoteDataSource(),
      );

      await repository.clearAll();

      for (var i = 0; i < 6; i++) {
        await repository.save(
          _buildAnimal(
            uuid: 'stream-base-$i',
            earTag: 'TAG-BASE-$i',
            breed: 'Cebu',
          ),
        );
      }

      final stream = repository.watchAll();
      final initial = await stream
          .firstWhere((items) => items.length >= 6)
          .timeout(const Duration(seconds: 3));
      expect(initial.length, greaterThanOrEqualTo(6));

      final created = _buildAnimal(
        uuid: 'stream-new',
        earTag: 'TAG-NEW',
        breed: 'Brahman',
      );
      await repository.save(created);

      final afterSave = await stream
          .firstWhere((items) => items.any((item) => item.uuid == 'stream-new'))
          .timeout(const Duration(seconds: 3));
      expect(afterSave.any((item) => item.uuid == 'stream-new'), isTrue);

      final updated = created.copyWith(earTagNumber: 'TAG-UPDATED');
      await repository.update(updated);

      final afterUpdate = await stream
          .firstWhere(
            (items) => items.any(
              (item) =>
                  item.uuid == 'stream-new' &&
                  item.earTagNumber == 'TAG-UPDATED',
            ),
          )
          .timeout(const Duration(seconds: 3));
      final updatedEntity = afterUpdate.firstWhere(
        (item) => item.uuid == 'stream-new',
      );
      expect(updatedEntity.earTagNumber, 'TAG-UPDATED');

      await repository.delete('stream-new');

      final afterDelete = await stream
          .firstWhere(
            (items) => items.every((item) => item.uuid != 'stream-new'),
          )
          .timeout(const Duration(seconds: 3));
      expect(afterDelete.any((item) => item.uuid == 'stream-new'), isFalse);
    },
    skip: !_canRunIsarNative(),
  );

  test(
    'persists and reads all supported animal record types',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final sharedPrefs = await SharedPreferences.getInstance();

      final repository = AnimalRepositoryIsar(
        IsarDatabase(),
        SharedPrefsService(sharedPrefs),
        _FakeAnimalRemoteDataSource(),
      );

      await repository.clearAll();

      final animal = _buildAnimal(
        uuid: 'records-isar-1',
        earTag: 'TAG-REC-001',
        breed: 'Cebu',
      );
      await repository.save(animal);

      final now = DateTime(2025, 6, 1);

      await repository.addWeightRecord(
        animal.uuid,
        WeightRecord(
          date: DateTime(2025, 6, 1),
          weight: 412.5,
          method: WeightMethod.scale,
          notes: 'Pesaje inicial',
        ),
      );

      await repository.addHealthRecord(
        animal.uuid,
        HealthRecord(
          date: DateTime(2025, 6, 1),
          type: HealthRecordType.vaccine,
          product: 'Vacuna A',
          notes: 'Dosis completa',
        ),
      );

      await repository.addProductionRecord(
        animal.uuid,
        ProductionRecord(
          date: DateTime(2025, 6, 1),
          type: ProductionRecordType.production,
          value: 12.3,
          unit: 'L',
        ),
      );

      await repository.addReproductionRecord(
        animal.uuid,
        ReproductionRecord(
          serviceDate: now,
          serviceType: ServiceType.naturalService,
          maleSireIdentifier: 'TORO-01',
        ),
      );

      await repository.addMovementRecord(
        animal.uuid,
        MovementRecord(
          fromLocation: 'Potrero 1',
          toLocation: 'Potrero 2',
          date: DateTime(2025, 6, 1),
          reason: MovementReason.relocation,
        ),
      );

      await repository.addCommercialRecord(
        animal.uuid,
        CommercialRecord(
          date: DateTime(2025, 6, 1),
          type: CommercialRecordType.purchase,
          amount: 1500,
          currency: 'USD',
        ),
      );

      await repository.addCostRecord(
        animal.uuid,
        CostRecord(
          date: DateTime(2025, 6, 1),
          type: CostType.feeding,
          amount: 280,
          currency: 'USD',
        ),
      );

      final weights = await repository.getWeightRecords(animal.uuid);
      final health = await repository.getHealthRecords(animal.uuid);
      final production = await repository.getProductionRecords(animal.uuid);
      final reproduction = await repository.getReproductionRecords(animal.uuid);
      final movements = await repository.getMovementRecords(animal.uuid);
      final commercial = await repository.getCommercialRecords(animal.uuid);
      final costs = await repository.getCostRecords(animal.uuid);

      expect(weights, hasLength(1));
      expect(weights.first.weight, 412.5);

      expect(health, hasLength(1));
      expect(health.first.product, 'Vacuna A');

      expect(production, hasLength(1));
      expect(production.first.value, 12.3);

      expect(reproduction, hasLength(1));
      expect(reproduction.first.maleSireIdentifier, 'TORO-01');

      expect(movements, hasLength(1));
      expect(movements.first.toLocation, 'Potrero 2');

      expect(commercial, hasLength(1));
      expect(commercial.first.amount, 1500);

      expect(costs, hasLength(1));
      expect(costs.first.amount, 280);
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

class _FakeAnimalRemoteDataSource implements AnimalRemoteDataSource {
  @override
  Future<RemoteAnimalPayload> fetchAnimals() async {
    return RemoteAnimalPayload(
      animals: const [],
      hash: 'test-hash',
      lastUpdated: DateTime.now(),
    );
  }
}

AnimalEntity _buildAnimal({
  required String uuid,
  required String earTag,
  required String breed,
}) {
  final now = DateTime.now();
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: earTag,
    customName: 'Animal $uuid',
    visualId: 'VIS-$uuid',
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: breed,
    birthDate: DateTime(2021, 1, 1),
    ageMonths: 60,
    healthStatus: HealthStatus.good,
    vaccinated: true,
    dewormed: true,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.undefined,
    productionStage: ProductionStage.unknown,
    productionSystem: ProductionSystem.unknown,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.low,
    gallery: const <String>[],
    synced: true,
    creationDate: now,
    lastUpdateDate: now,
  );
}
