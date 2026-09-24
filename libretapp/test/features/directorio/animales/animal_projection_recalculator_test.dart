/// The animal fields derived from its records must follow the records —
/// including when a record is removed.
///
/// Before [AnimalProjectionRecalculator] each repository projected onto the
/// animal on save and nothing undid it. Deleting the latest weighing left its
/// value on the animal; deleting a death record left the animal dead and out
/// of the inventory for good. Nothing caught it because no screen called
/// delete, which is exactly the state the edit work changes.
library;

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
import 'package:libretapp/features/directorio/animales/infrastructure/health_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/weight_record_repository_isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/reproduction_record_repository_isar.dart';

const _uuid = 'projection-subject';
const _sireUuid = 'projection-sire';

Future<AnimalEntity> _read(String uuid) async {
  final repo = AnimalRepositoryIsar(
    IsarDatabase(),
    SharedPrefsService(await SharedPreferences.getInstance()),
    _NoRemote(),
  );
  final animal = await repo.getByUuid(uuid);
  expect(animal, isNotNull, reason: 'expected $uuid to exist');
  return animal!;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('libretapp_projection_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          pathProviderChannel,
          (call) async => tempDir.path,
        );
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    await IsarDatabase().close();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final db = IsarDatabase();
    await db.initialize();
    await db.clearAllCollections();
    await _seedAnimal();
  });

  tearDown(() async => IsarDatabase().close());

  Future<AnimalEntity> subject() async {
    final repo = AnimalRepositoryIsar(
      IsarDatabase(),
      SharedPrefsService(await SharedPreferences.getInstance()),
      _NoRemote(),
    );
    final animal = await repo.getByUuid(_uuid);
    expect(animal, isNotNull, reason: 'the seeded animal should still exist');
    return animal!;
  }

  group('weight', () {
    test(
      'follows the newest weighing, and falls back when one is removed',
      () async {
        final repo = WeightRecordRepositoryIsar(IsarDatabase());

        await repo.addWeightRecord(
          _uuid,
          WeightRecord(
            date: DateTime(2025, 1, 10),
            weight: 300,
            method: WeightMethod.scale,
          ),
        );
        final newer = await repo.addWeightRecord(
          _uuid,
          WeightRecord(
            date: DateTime(2025, 6, 10),
            weight: 380,
            method: WeightMethod.scale,
          ),
        );

        expect((await subject()).weight, 380);

        await repo.deleteWeightRecord(newer.id!);

        expect(
          (await subject()).weight,
          300,
          reason:
              'with the June weighing gone the January one is the latest; the '
              'animal used to keep 380 forever',
        );
      },
    );

    test('an older weighing does not overwrite a newer one', () async {
      final repo = WeightRecordRepositoryIsar(IsarDatabase());
      await repo.addWeightRecord(
        _uuid,
        WeightRecord(
          date: DateTime(2025, 6, 10),
          weight: 380,
          method: WeightMethod.scale,
        ),
      );
      await repo.addWeightRecord(
        _uuid,
        WeightRecord(
          date: DateTime(2024, 1, 10),
          weight: 210,
          method: WeightMethod.scale,
        ),
      );

      expect(
        (await subject()).weight,
        380,
        reason: 'backfilling an old weighing is not a weight change',
      );
    });
  });

  group('herd status', () {
    test(
      'a death record removes the animal, deleting it brings it back',
      () async {
        final repo = HealthRecordRepositoryIsar(IsarDatabase());

        final death = await repo.addHealthRecord(
          _uuid,
          HealthRecord(
            date: DateTime(2025, 3, 1),
            type: HealthRecordType.death,
            product: 'Muerte',
          ),
        );
        expect((await subject()).status, AnimalStatus.dead);

        await repo.deleteHealthRecord(death.id!);

        expect(
          (await subject()).status,
          AnimalStatus.active,
          reason:
              'a death recorded on the wrong animal was previously impossible '
              'to take back',
        );
      },
    );
  });

  group('health flags', () {
    test('a flag clears when its last record is removed', () async {
      final repo = HealthRecordRepositoryIsar(IsarDatabase());

      final vaccine = await repo.addHealthRecord(
        _uuid,
        HealthRecord(
          date: DateTime(2025, 2, 1),
          type: HealthRecordType.vaccine,
          product: 'Aftosa',
        ),
      );
      expect((await subject()).vaccinated, isTrue);

      await repo.deleteHealthRecord(vaccine.id!);

      expect(
        (await subject()).vaccinated,
        isFalse,
        reason: 'the flag used to latch on and never clear',
      );
    });
  });
  group('reproduction', () {
    test(
      'the newest record decides the cycle, not the last one saved',
      () async {
        final repo = ReproductionRecordRepositoryIsar(IsarDatabase());

        await repo.addReproductionRecord(
          _uuid,
          ReproductionRecord(
            serviceDate: DateTime(2025, 5, 1),
            serviceType: ServiceType.naturalService,
            pregnancyResult: PregnancyCheckResult.positive,
          ),
        );
        expect(
          (await subject()).reproductiveStatus,
          ReproductiveStatus.pregnant,
        );

        // Backfilling an older, negative service must not undo the newer
        // positive diagnosis.
        await repo.addReproductionRecord(
          _uuid,
          ReproductionRecord(
            serviceDate: DateTime(2024, 9, 1),
            serviceType: ServiceType.naturalService,
            pregnancyResult: PregnancyCheckResult.negative,
          ),
        );

        final after = await subject();
        expect(after.reproductiveStatus, ReproductiveStatus.pregnant);
        expect(after.firstServiceDate, DateTime(2024, 9, 1));
        expect(after.lastServiceDate, DateTime(2025, 5, 1));
      },
    );

    test(
      'the sire keeps his own service dates, and loses them on delete',
      () async {
        final repo = ReproductionRecordRepositoryIsar(IsarDatabase());
        await _seedAnimal(uuid: _sireUuid, sex: Sex.male);

        final service = await repo.addReproductionRecord(
          _uuid,
          ReproductionRecord(
            serviceDate: DateTime(2025, 4, 20),
            serviceType: ServiceType.naturalService,
            maleSireUuid: _sireUuid,
          ),
        );

        final sire = await _read(_sireUuid);
        expect(sire.lastServiceDate, DateTime(2025, 4, 20));

        await repo.deleteReproductionRecord(service.id!);

        expect(
          (await _read(_sireUuid)).lastServiceDate,
          isNull,
          reason: 'the deleted service was his only one',
        );
      },
    );
  });
  group('editing a record', () {
    test('replaces the row in place instead of adding a second one', () async {
      final repo = WeightRecordRepositoryIsar(IsarDatabase());

      final saved = await repo.addWeightRecord(
        _uuid,
        WeightRecord(
          date: DateTime(2025, 6, 10),
          weight: 380,
          method: WeightMethod.scale,
        ),
      );

      // The breeder meant 350, not 380.
      final corrected = await repo.updateRecord(
        _uuid,
        saved.copyWith(weight: 350),
      );

      final records = await repo.getWeightRecords(_uuid);
      expect(records, hasLength(1), reason: 'a correction is not a new record');
      expect(records.single.weight, 350);
      expect(corrected.id, saved.id, reason: 'the id has to survive');
      expect(
        records.single.recordUuid,
        saved.recordUuid,
        reason: 'agenda registrations and care cycles resolve records by uuid',
      );
      expect((await subject()).weight, 350);
    });

    test('refuses a record that is not already stored', () async {
      final repo = WeightRecordRepositoryIsar(IsarDatabase());

      expect(
        () => repo.updateRecord(
          _uuid,
          WeightRecord(
            date: DateTime(2025, 6, 10),
            weight: 350,
            method: WeightMethod.scale,
          ),
        ),
        throwsArgumentError,
        reason: 'silently inserting would leave two rows where one was fixed',
      );
    });

    test('correcting a death record to a checkup returns the animal', () async {
      final repo = HealthRecordRepositoryIsar(IsarDatabase());

      final death = await repo.addHealthRecord(
        _uuid,
        HealthRecord(
          date: DateTime(2025, 3, 1),
          type: HealthRecordType.death,
          product: 'Muerte',
        ),
      );
      expect((await subject()).status, AnimalStatus.dead);

      await repo.updateRecord(
        _uuid,
        death.copyWith(type: HealthRecordType.checkup, product: 'Revision'),
      );

      expect(
        (await subject()).status,
        AnimalStatus.active,
        reason: 'the status latch used to be one-way',
      );
    });
  });
}

Future<void> _seedAnimal({String uuid = _uuid, Sex sex = Sex.female}) async {
  final repo = AnimalRepositoryIsar(
    IsarDatabase(),
    SharedPrefsService(await SharedPreferences.getInstance()),
    _NoRemote(),
  );
  final now = DateTime(2025, 1, 1);
  await repo.save(
    AnimalEntity(
      uuid: uuid,
      earTagNumber: 'TAG-$uuid',
      species: Species.cattle,
      category: sex == Sex.female ? Category.cow : Category.bull,
      lifeStage: sex == Sex.female ? LifeStage.cow : LifeStage.bull,
      sex: sex,
      breed: 'Cebu',
      birthDate: DateTime(2021, 1, 1),
      ageMonths: 48,
      healthStatus: HealthStatus.good,
      vaccinated: false,
      dewormed: false,
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
    ),
  );
}

class _NoRemote implements AnimalRemoteDataSource {
  @override
  Future<RemoteAnimalPayload> fetchAnimals() async => RemoteAnimalPayload(
    animals: const [],
    hash: 'test',
    lastUpdated: DateTime(2025),
  );
}
