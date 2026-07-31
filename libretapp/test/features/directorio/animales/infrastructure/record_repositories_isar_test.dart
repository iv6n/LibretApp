import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/production_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/commercial_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/cost_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/health_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/movement_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/production_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/reproduction_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/weight_record_repository_isar.dart';

/// Exercises the 7 record repositories (health/movement/weight/cost/
/// commercial/production/reproduction) against a real (temp-dir) Isar
/// instance, to verify the shared `IsarRecordRepositoryBase` skeleton they
/// were consolidated onto behaves identically to the original hand-written
/// per-repository implementations — including the animal-side-effect hooks
/// (health/movement/weight) and the one-off `getUpcomingCalvings` query.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;
  late IsarDatabase db;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'libretapp_animales_isar_test_',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          return tempDir.path;
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

  setUp(() async {
    db = IsarDatabase();
    await db.initialize();
  });

  Future<String> seedAnimal(String uuid) async {
    final isar = await db.initialize();
    await isar.writeTxn(() async {
      await isar.isarAnimals.put(
        IsarAnimal()
          ..uuid = uuid
          ..earTagNumber = 'TAG-$uuid'
          ..species = 'cattle'
          ..category = 'cow'
          ..lifeStage = 'adult'
          ..sex = 'female'
          ..breed = 'Holstein'
          ..birthDate = DateTime(2022, 1, 1)
          ..ageMonths = 30
          ..status = 'active'
          ..healthStatus = 'good'
          ..vaccinated = false
          ..dewormed = false
          ..hasVitamins = false
          ..hasChronicIssues = false
          ..reproductiveStatus = 'active'
          ..underObservation = false
          ..requiresAttention = false
          ..riskLevel = 'none'
          ..synced = true
          ..creationDate = DateTime(2022, 1, 1)
          ..lastUpdateDate = DateTime(2022, 1, 1),
      );
    });
    return uuid;
  }

  Future<IsarAnimal> reloadAnimal(String uuid) async {
    final isar = await db.initialize();
    final animal = await isar.isarAnimals.where().uuidEqualTo(uuid).findFirst();
    expect(animal, isNotNull, reason: 'seeded animal should still exist');
    return animal!;
  }

  group('HealthRecordRepositoryIsar', () {
    test('addHealthRecord persists the record and applies animal side effects', () async {
      final repo = HealthRecordRepositoryIsar(db);
      final animalUuid = await seedAnimal('health-animal-1');

      final saved = await repo.addHealthRecord(
        animalUuid,
        HealthRecord(
          date: DateTime(2026, 1, 10),
          type: HealthRecordType.vaccine,
          product: 'Aftosa',
        ),
      );

      expect(saved.id, isNotNull);
      expect(saved.product, 'Aftosa');

      final records = await repo.getHealthRecords(animalUuid);
      expect(records, hasLength(1));
      expect(records.single.type, HealthRecordType.vaccine);

      final animal = await reloadAnimal(animalUuid);
      expect(animal.vaccinated, isTrue);
      expect(animal.synced, isFalse);
    });

    test('addHealthRecordToMultiple applies the same side effects to every animal', () async {
      final repo = HealthRecordRepositoryIsar(db);
      final a = await seedAnimal('health-multi-a');
      final b = await seedAnimal('health-multi-b');

      await repo.addHealthRecordToMultiple(
        [a, b],
        HealthRecord(
          date: DateTime(2026, 1, 10),
          type: HealthRecordType.deworming,
          product: 'Ivermectina',
        ),
      );

      final animalA = await reloadAnimal(a);
      final animalB = await reloadAnimal(b);
      expect(animalA.dewormed, isTrue);
      expect(animalB.dewormed, isTrue);
      expect(await repo.getHealthRecords(a), hasLength(1));
      expect(await repo.getHealthRecords(b), hasLength(1));
    });

    test('deleteHealthRecord removes the record', () async {
      final repo = HealthRecordRepositoryIsar(db);
      final animalUuid = await seedAnimal('health-delete');
      final saved = await repo.addHealthRecord(
        animalUuid,
        HealthRecord(date: DateTime(2026, 1, 1), type: HealthRecordType.checkup, product: 'Chequeo'),
      );

      await repo.deleteHealthRecord(saved.id!);

      expect(await repo.getHealthRecords(animalUuid), isEmpty);
    });
  });

  group('MovementRecordRepositoryIsar', () {
    test('addMovementRecord persists the record and updates the animal', () async {
      final repo = MovementRecordRepositoryIsar(db);
      final animalUuid = await seedAnimal('movement-animal-1');

      final saved = await repo.addMovementRecord(
        animalUuid,
        MovementRecord(
          toLocation: 'potrero-inexistente',
          date: DateTime(2026, 1, 5),
          reason: MovementReason.paddockRotation,
        ),
      );

      expect(saved.id, isNotNull);
      expect(await repo.getMovementRecords(animalUuid), hasLength(1));

      final animal = await reloadAnimal(animalUuid);
      // No matching location exists in this test, so currentLocationId stays null,
      // but the rest of the side effect (date bookkeeping) still applies.
      expect(animal.currentLocationId, isNull);
      expect(animal.lastMovementDate, DateTime(2026, 1, 5));
      expect(animal.synced, isFalse);
    });

    test('deleteMovementRecord removes the record', () async {
      final repo = MovementRecordRepositoryIsar(db);
      final animalUuid = await seedAnimal('movement-delete');
      final saved = await repo.addMovementRecord(
        animalUuid,
        MovementRecord(
          toLocation: 'x',
          date: DateTime(2026, 1, 1),
          reason: MovementReason.other,
        ),
      );

      await repo.deleteMovementRecord(saved.id!);

      expect(await repo.getMovementRecords(animalUuid), isEmpty);
    });
  });

  group('WeightRecordRepositoryIsar', () {
    test('addWeightRecord persists the record and updates the animal weight', () async {
      final repo = WeightRecordRepositoryIsar(db);
      final animalUuid = await seedAnimal('weight-animal-1');

      final saved = await repo.addWeightRecord(
        animalUuid,
        WeightRecord(
          date: DateTime(2026, 2, 1),
          weight: 412.5,
          method: WeightMethod.scale,
        ),
      );

      expect(saved.id, isNotNull);
      expect(await repo.getWeightRecords(animalUuid), hasLength(1));

      final animal = await reloadAnimal(animalUuid);
      expect(animal.weight, 412.5);
      expect(animal.synced, isFalse);
    });

    test('deleteWeightRecord removes the record', () async {
      final repo = WeightRecordRepositoryIsar(db);
      final animalUuid = await seedAnimal('weight-delete');
      final saved = await repo.addWeightRecord(
        animalUuid,
        WeightRecord(date: DateTime(2026, 1, 1), weight: 100, method: WeightMethod.estimated),
      );

      await repo.deleteWeightRecord(saved.id!);

      expect(await repo.getWeightRecords(animalUuid), isEmpty);
    });
  });

  group('repositories without animal side effects', () {
    test('CostRecordRepositoryIsar add/get/delete', () async {
      final repo = CostRecordRepositoryIsar(db);
      const animalUuid = 'cost-animal-1';

      final saved = await repo.addCostRecord(
        animalUuid,
        CostRecord(date: DateTime(2026, 1, 1), type: CostType.feeding, amount: 55.0),
      );
      expect(await repo.getCostRecords(animalUuid), hasLength(1));

      await repo.deleteCostRecord(saved.id!);
      expect(await repo.getCostRecords(animalUuid), isEmpty);
    });

    test('CommercialRecordRepositoryIsar add/get/delete', () async {
      final repo = CommercialRecordRepositoryIsar(db);
      const animalUuid = 'commercial-animal-1';

      final saved = await repo.addCommercialRecord(
        animalUuid,
        CommercialRecord(date: DateTime(2026, 1, 1), type: CommercialRecordType.sale, amount: 900),
      );
      expect(await repo.getCommercialRecords(animalUuid), hasLength(1));

      await repo.deleteCommercialRecord(saved.id!);
      expect(await repo.getCommercialRecords(animalUuid), isEmpty);
    });

    test('ProductionRecordRepositoryIsar add/get/delete', () async {
      final repo = ProductionRecordRepositoryIsar(db);
      const animalUuid = 'production-animal-1';

      final saved = await repo.addProductionRecord(
        animalUuid,
        ProductionRecord(date: DateTime(2026, 1, 1), type: ProductionRecordType.weighing, value: 20),
      );
      expect(await repo.getProductionRecords(animalUuid), hasLength(1));

      await repo.deleteProductionRecord(saved.id!);
      expect(await repo.getProductionRecords(animalUuid), isEmpty);
    });
  });

  group('ReproductionRecordRepositoryIsar', () {
    test('add/get/delete and sorts by serviceDate desc', () async {
      final repo = ReproductionRecordRepositoryIsar(db);
      const animalUuid = 'reproduction-animal-1';

      await repo.addReproductionRecord(
        animalUuid,
        ReproductionRecord(
          serviceDate: DateTime(2026, 1, 1),
          serviceType: ServiceType.naturalService,
        ),
      );
      final second = await repo.addReproductionRecord(
        animalUuid,
        ReproductionRecord(
          serviceDate: DateTime(2026, 3, 1),
          serviceType: ServiceType.artificialInsemination,
        ),
      );

      final records = await repo.getReproductionRecords(animalUuid);
      expect(records, hasLength(2));
      expect(records.first.serviceDate, DateTime(2026, 3, 1));

      await repo.deleteReproductionRecord(second.id!);
      expect(await repo.getReproductionRecords(animalUuid), hasLength(1));
    });

    test('getUpcomingCalvings finds records within range with no actual calving yet', () async {
      final repo = ReproductionRecordRepositoryIsar(db);
      const animalUuid = 'reproduction-calving-1';

      await repo.addReproductionRecord(
        animalUuid,
        ReproductionRecord(
          serviceDate: DateTime(2025, 6, 1),
          serviceType: ServiceType.naturalService,
          expectedCalvingDate: DateTime(2026, 3, 15),
        ),
      );
      // Already calved — should be excluded even though the expected date is in range.
      await repo.addReproductionRecord(
        animalUuid,
        ReproductionRecord(
          serviceDate: DateTime(2025, 1, 1),
          serviceType: ServiceType.naturalService,
          expectedCalvingDate: DateTime(2026, 3, 20),
          actualCalvingDate: DateTime(2026, 3, 18),
        ),
      );

      final upcoming = await repo.getUpcomingCalvings(
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 31),
      );

      expect(upcoming, hasLength(1));
      expect(upcoming.single.animalUuid, animalUuid);
      expect(upcoming.single.expectedCalvingDate, DateTime(2026, 3, 15));
    });

    test('calving details survive a round trip through Isar', () async {
      final repo = ReproductionRecordRepositoryIsar(db);
      const animalUuid = 'reproduction-calving-detail';

      await repo.addReproductionRecord(
        animalUuid,
        ReproductionRecord(
          serviceDate: DateTime(2025, 6, 1),
          serviceType: ServiceType.artificialInsemination,
          actualCalvingDate: DateTime(2026, 3, 11),
          calvingOutcome: CalvingOutcome.liveBirth,
          calvingEase: 2,
          offspringUuids: const ['cria-a', 'cria-b'],
          calvingNotes: 'Mellizos, sin complicaciones.',
        ),
      );

      final stored = await repo.getReproductionRecords(animalUuid);

      expect(stored, hasLength(1));
      final record = stored.single;
      expect(record.calvingOutcome, CalvingOutcome.liveBirth);
      expect(record.calvingEase, 2);
      expect(record.offspringUuids, ['cria-a', 'cria-b']);
      expect(record.calvingNotes, 'Mellizos, sin complicaciones.');
      // Derived, never stored: 283 days between service and calving.
      expect(record.gestationDays, 283);
      expect(record.producedLiveOffspring, isTrue);
    });

    test('calvingNotes keeps the legacy physical column name', () {
      // `calvingNotes` is annotated @Name('calvingResult'). Isar keys columns
      // by that physical name, so dropping the annotation would register a new
      // empty column and silently discard every calving note captured before
      // CalvingOutcome existed. Guard the name itself, not a round trip —
      // a round trip passes either way.
      final properties = IsarReproductionRecordSchema.properties.keys;

      expect(properties, contains('calvingResult'));
      expect(properties, isNot(contains('calvingNotes')));
    });
  });
}
