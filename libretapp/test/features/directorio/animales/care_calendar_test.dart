/// Care calendar: persistence and schedule generation.
///
/// CareRule, CareRecord and ScheduledCare existed as entities and
/// CareScheduler could already compute a due date, but nothing was stored:
/// every schedule vanished when the app closed.
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_rule.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/services/care_calendar_service.dart';
import 'package:libretapp/features/directorio/animales/domain/services/default_care_rules.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/care_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_care.dart';

bool _canRunIsarNative() {
  try {
    Isar.initializeIsarCore();
    return true;
  } catch (_) {
    return false;
  }
}

AnimalEntity _animal({
  String uuid = 'vaca',
  Species species = Species.cattle,
  Sex sex = Sex.female,
  int ageMonths = 36,
}) {
  final now = DateTime(2026, 1, 1);
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: uuid,
    species: species,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: sex,
    breed: 'Brahman',
    birthDate: DateTime(2023, 1, 1),
    ageMonths: ageMonths,
    healthStatus: HealthStatus.good,
    vaccinated: false,
    dewormed: false,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.breeding,
    productionStage: ProductionStage.reproductive,
    productionSystem: ProductionSystem.extensive,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.none,
    gallery: const [],
    status: AnimalStatus.active,
    synced: true,
    creationDate: now,
    lastUpdateDate: now,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('rulesFor', () {
    test('filters by species, sex and age', () {
      const rules = [
        CareRule(
          id: 'bovino',
          name: 'Bovino',
          type: CareType.vaccination,
          intervalDays: 365,
          species: Species.cattle,
        ),
        CareRule(
          id: 'caprino',
          name: 'Caprino',
          type: CareType.deworming,
          intervalDays: 120,
          species: Species.goat,
        ),
        CareRule(
          id: 'adulto',
          name: 'Solo adultos',
          type: CareType.hoofCare,
          intervalDays: 180,
          minAgeMonths: 24,
        ),
        // No species and no sex: applies to whatever the breeder keeps.
        CareRule(
          id: 'abierta',
          name: 'Vitaminas',
          type: CareType.supplement,
          intervalDays: 120,
        ),
      ];

      final forCow = CareCalendarService.rulesFor(_animal(), rules);
      expect(
        forCow.map((r) => r.id),
        containsAll(<String>['bovino', 'adulto', 'abierta']),
      );
      expect(forCow.map((r) => r.id), isNot(contains('caprino')));

      final forCalf = CareCalendarService.rulesFor(
        _animal(uuid: 'becerro', ageMonths: 6),
        rules,
      );
      expect(
        forCalf.map((r) => r.id),
        isNot(contains('adulto')),
        reason: 'a six-month-old is below the rule minimum age',
      );
    });
  });

  group('persistence', () {
    const pathProviderChannel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    late Directory tempDir;
    late IsarDatabase db;
    late CareRepositoryIsar repo;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('libretapp_care_test_');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathProviderChannel, (call) async {
            return tempDir.path;
          });
    });

    tearDownAll(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathProviderChannel, null);
      await IsarDatabase().close();
      if (tempDir.existsSync()) await tempDir.delete(recursive: true);
    });

    tearDown(() async => IsarDatabase().close());

    setUp(() async {
      db = IsarDatabase();
      final isar = await db.initialize();
      repo = CareRepositoryIsar(db);
      await isar.writeTxn(() async {
        await isar.isarCareRules.clear();
        await isar.isarCareRecords.clear();
        await isar.isarScheduledCares.clear();
      });
    });

    test('rules survive a round trip and update in place', () async {
      const rule = CareRule(
        id: 'r1',
        name: 'Vacunación',
        type: CareType.vaccination,
        intervalDays: 365,
        leadTimeDays: 15,
        species: Species.cattle,
      );

      await repo.saveRule(rule);
      await repo.saveRule(rule.copyWith(intervalDays: 180));

      final stored = await repo.getRules();
      expect(stored, hasLength(1), reason: 'the id is a replacing unique key');
      expect(stored.single.intervalDays, 180);
      expect(stored.single.species, Species.cattle);
    });

    test('a retired rule disappears but is not forgotten', () async {
      const rule = CareRule(
        id: 'r1',
        name: 'Baño',
        type: CareType.tickBath,
        intervalDays: 21,
      );
      await repo.saveRule(rule);
      await repo.retireRule('r1');

      expect(await repo.getRules(), isEmpty);
      expect(await repo.getAllRuleIds(), contains('r1'));
    });

    test('the default calendar preloads once and respects retirements',
        () async {
      final service = CareCalendarService(repo);

      await service.preloadDefaults(alreadyLoaded: false);
      final first = await repo.getRules();
      expect(first, isNotEmpty);
      expect(first.length, DefaultCareRules.all().length);

      // The breeder switches one off, then the app restarts.
      await repo.retireRule(first.first.id);
      await service.preloadDefaults(alreadyLoaded: false);

      final second = await repo.getRules();
      expect(
        second.map((r) => r.id),
        isNot(contains(first.first.id)),
        reason: 'a rule the breeder retired must not come back',
      );
      expect(second.length, first.length - 1);
    });

    test('latest record per rule is what the scheduler reads', () async {
      await repo.saveRecord(
        CareRecord(
          id: 'c1',
          animalId: 'vaca',
          ruleId: 'r1',
          type: CareType.deworming,
          performedAt: DateTime(2025, 6, 1),
        ),
      );
      await repo.saveRecord(
        CareRecord(
          id: 'c2',
          animalId: 'vaca',
          ruleId: 'r1',
          type: CareType.deworming,
          performedAt: DateTime(2026, 1, 15),
        ),
      );

      final latest = await repo.getLatestRecordsByRule('vaca');
      expect(latest['r1']!.id, 'c2');
    });

    test('regenerating replaces pending tasks instead of stacking them',
        () async {
      final service = CareCalendarService(repo);
      await repo.saveRule(
        const CareRule(
          id: 'r1',
          name: 'Desparasitación',
          type: CareType.deworming,
          intervalDays: 180,
          species: Species.cattle,
        ),
      );

      final animal = _animal();
      final now = DateTime(2026, 3, 1);

      await service.regenerateFor(animal, now: now);
      await service.regenerateFor(animal, now: now);

      final pending = await repo.getPendingForAnimal(animal.uuid);
      expect(pending, hasLength(1), reason: 'the second run must not duplicate');
      expect(pending.single.ruleId, 'r1');
    });

    test('a recorded care pushes the next due date out', () async {
      final service = CareCalendarService(repo);
      await repo.saveRule(
        const CareRule(
          id: 'r1',
          name: 'Desparasitación',
          type: CareType.deworming,
          intervalDays: 180,
          species: Species.cattle,
        ),
      );

      final animal = _animal();
      final now = DateTime(2026, 3, 1);

      // With no history the task is due immediately.
      var pending = await service.regenerateFor(animal, now: now);
      expect(pending.single.dueAt, now);

      await repo.saveRecord(
        CareRecord(
          id: 'c1',
          animalId: 'vaca',
          ruleId: 'r1',
          type: CareType.deworming,
          performedAt: now,
        ),
      );

      pending = await service.regenerateFor(animal, now: now);
      expect(pending.single.dueAt, now.add(const Duration(days: 180)));
    });

    test('marking a task done takes it out of pending', () async {
      final service = CareCalendarService(repo);
      await repo.saveRule(
        const CareRule(
          id: 'r1',
          name: 'Baño',
          type: CareType.tickBath,
          intervalDays: 21,
        ),
      );

      final generated = await service.regenerateFor(
        _animal(),
        now: DateTime(2026, 3, 1),
      );
      await repo.markDone(generated.single.id);

      expect(await repo.getPendingForAnimal('vaca'), isEmpty);
    });
  }, skip: !_canRunIsarNative());
}

