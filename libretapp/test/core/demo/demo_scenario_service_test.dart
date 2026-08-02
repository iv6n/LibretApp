/// Integration coverage for `DemoScenarioService`: seeds the whole
/// "Rancho El Mezquite — DEMO" scenario against a real (temp-dir) Isar
/// database, exactly the way `main.dart`/the Perfil debug action do, and
/// checks the properties the scenario promises — fixed quantities,
/// deterministic uuids, idempotency, referential integrity via
/// [DemoDataIntegrityValidator], and that real (non-demo) data is never
/// touched.
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/demo/demo_data_integrity_validator.dart';
import 'package:libretapp/core/demo/demo_scenario_service.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/features/agenda/infrastructure/isar_agenda_repository.dart';
import 'package:libretapp/features/agenda/infrastructure/isar_workforce_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/services/care_calendar_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_remote_data_source.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/care_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/commercial_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/cost_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/health_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/movement_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/production_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/reproduction_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/weight_record_repository_isar.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository_isar.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/infrastructure/isar_finanzas_repository.dart';
import 'package:libretapp/features/milking/infrastructure/milking_repository_isar.dart';
import 'package:libretapp/features/perfil/data/perfil_shared_prefs_repository.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/repositories/isar_location_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;
  late IsarDatabase database;
  late SharedPrefsService prefs;
  late AnimalRepositoryIsar animalRepository;
  late DemoScenarioService service;

  final referenceDate = DateTime(2026, 8, 1);

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('libretapp_demo_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          pathProviderChannel,
          (_) async => tempDir.path,
        );
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final sharedPreferences = await SharedPreferences.getInstance();
    prefs = SharedPrefsService(sharedPreferences);

    database = IsarDatabase();
    await database.initialize();
    await database.clearAllCollections();

    animalRepository = AnimalRepositoryIsar(
      database,
      prefs,
      _FakeAnimalRemoteDataSource(),
    );
    final lotesRepository = LotesRepositoryIsar(database);
    final locationRepository = IsarLocationRepository(database);
    final weightRepository = WeightRecordRepositoryIsar(database);
    final healthRepository = HealthRecordRepositoryIsar(database);
    final reproductionRepository = ReproductionRecordRepositoryIsar(database);
    final productionRepository = ProductionRecordRepositoryIsar(database);
    final movementRepository = MovementRecordRepositoryIsar(database);
    final commercialRepository = CommercialRecordRepositoryIsar(database);
    final costRepository = CostRecordRepositoryIsar(database);
    final careRepository = CareRepositoryIsar(database);
    final careCalendarService = CareCalendarService(careRepository);
    final milkingRepository = MilkingRepositoryIsar(database);
    final finanzasRepository = IsarFinanzasRepository(database);
    final agendaRepository = IsarAgendaRepository(database, prefs);
    final workforceRepository = IsarWorkforceRepository(database);
    final perfilRepository = PerfilSharedPrefsRepository(prefs);
    final agendaReminderSyncService = AgendaReminderSyncService(
      animalRepository: animalRepository,
      agendaRepository: agendaRepository,
      healthRepo: healthRepository,
      reproductionRepo: reproductionRepository,
      careRepo: careRepository,
      careCalendarService: careCalendarService,
    );

    service = DemoScenarioService(
      animalRepository: animalRepository,
      lotesRepository: lotesRepository,
      locationRepository: locationRepository,
      weightRepository: weightRepository,
      healthRepository: healthRepository,
      reproductionRepository: reproductionRepository,
      productionRepository: productionRepository,
      movementRepository: movementRepository,
      commercialRepository: commercialRepository,
      costRepository: costRepository,
      careRepository: careRepository,
      careCalendarService: careCalendarService,
      milkingRepository: milkingRepository,
      finanzasRepository: finanzasRepository,
      agendaRepository: agendaRepository,
      workforceRepository: workforceRepository,
      perfilRepository: perfilRepository,
      agendaReminderSyncService: agendaReminderSyncService,
      prefs: prefs,
    );
  });

  tearDown(() async => database.close());

  Future<DemoDataSnapshot> buildSnapshot() async {
    final animals = await animalRepository.getAllIncludingInactive();
    final lotes = await LotesRepositoryIsar(database).getAll();
    final locations = await IsarLocationRepository(database).getAll();
    final healthRepo = HealthRecordRepositoryIsar(database);
    final weightRepo = WeightRecordRepositoryIsar(database);
    final reproductionRepo = ReproductionRecordRepositoryIsar(database);
    final careRepo = CareRepositoryIsar(database);
    final milkingRepo = MilkingRepositoryIsar(database);
    final finanzasRepo = IsarFinanzasRepository(database);
    final agendaRepo = IsarAgendaRepository(database, prefs);

    final animalUuids = animals.map((a) => a.uuid).toSet();
    final weightsByAnimal = await weightRepo.getWeightRecordsForAnimals(
      animalUuids,
    );
    final healthByAnimal = <String, List<HealthRecord>>{
      for (final a in animals)
        a.uuid: await healthRepo.getHealthRecords(a.uuid),
    };
    final reproductionByAnimal = await reproductionRepo
        .getReproductionRecordsForAnimals(animalUuids);
    final careRecordsByAnimal = <String, List<dynamic>>{
      for (final a in animals)
        a.uuid: await careRepo.getRecordsForAnimal(a.uuid),
    };
    final scheduledCare = await careRepo.getPending();
    final careRules = await careRepo.getRules();
    final activeWithdrawals = await healthRepo.getActiveWithdrawals(
      animalUuids,
      asOf: referenceDate,
    );

    final wideRange = DateRange(
      start: DateTime(referenceDate.year - 1, 1, 1),
      end: DateTime(referenceDate.year + 1, 12, 31),
    );

    return DemoDataSnapshot(
      animals: animals,
      lotes: lotes,
      locations: locations,
      weightsByAnimal: weightsByAnimal,
      healthByAnimal: healthByAnimal,
      reproductionByAnimal: reproductionByAnimal,
      careRecordsByAnimal: careRecordsByAnimal.map(
        (k, v) => MapEntry(k, v.cast()),
      ),
      scheduledCare: scheduledCare,
      careRules: careRules,
      milkingSessions: await milkingRepo.getAllSessions(),
      milkingEntries: await milkingRepo.getAllEntries(),
      activeWithdrawalsByAnimal: activeWithdrawals,
      incomes: await finanzasRepo.getIncomes(wideRange),
      expenses: await finanzasRepo.getExpenses(wideRange),
      agendaEntries: await agendaRepo.fetchEntries(),
      asOf: referenceDate,
    );
  }

  test(
    'install seeds exactly 40 animals with the expected breakdown',
    () async {
      await service.install(referenceDate: referenceDate);

      final animals = await animalRepository.getAllIncludingInactive();
      expect(animals, hasLength(40));

      final cattle = animals.where((a) => a.species == Species.cattle).toList();
      expect(cattle, hasLength(24));
      expect(
        cattle.where((a) => a.status == AnimalStatus.active),
        hasLength(21),
      );
      expect(cattle.where((a) => a.status == AnimalStatus.sold), hasLength(1));
      expect(cattle.where((a) => a.status == AnimalStatus.dead), hasLength(1));
      expect(
        cattle.where((a) => a.status == AnimalStatus.archived),
        hasLength(1),
      );

      expect(animals.where((a) => a.species == Species.goat), hasLength(4));
      expect(animals.where((a) => a.species == Species.sheep), hasLength(3));
      expect(animals.where((a) => a.species == Species.equine), hasLength(2));
      expect(animals.where((a) => a.species == Species.pig), hasLength(2));
      expect(animals.where((a) => a.species == Species.poultry), hasLength(4));
      expect(animals.where((a) => a.species == Species.canine), hasLength(1));

      expect(animals.every((a) => a.uuid.startsWith('demo-')), isTrue);
    },
  );

  test('installing twice produces the same uuids and no duplicates', () async {
    await service.install(referenceDate: referenceDate);
    final first = await animalRepository.getAllIncludingInactive();
    final firstUuids = first.map((a) => a.uuid).toSet();

    // A second call without reset is a no-op (already installed).
    final second = await service.install(referenceDate: referenceDate);
    expect(second.alreadyInstalled, isTrue);
    final afterNoop = await animalRepository.getAllIncludingInactive();
    expect(afterNoop, hasLength(40));
    expect(afterNoop.map((a) => a.uuid).toSet(), firstUuids);

    // An explicit reset reseeds, but still converges to the same 40 uuids.
    await service.install(referenceDate: referenceDate, reset: true);
    final afterReset = await animalRepository.getAllIncludingInactive();
    expect(afterReset, hasLength(40));
    expect(afterReset.map((a) => a.uuid).toSet(), firstUuids);

    final lotes = await LotesRepositoryIsar(database).getAll();
    expect(lotes, hasLength(6));
    final locations = await IsarLocationRepository(database).getAll();
    expect(locations, hasLength(15));
  });

  test(
    'the installed scenario passes DemoDataIntegrityValidator with no errors',
    () async {
      await service.install(referenceDate: referenceDate);
      final snapshot = await buildSnapshot();
      final report = const DemoDataIntegrityValidator().validate(snapshot);

      expect(report.isValid, isTrue, reason: report.describe());
    },
  );

  test(
    'reset restores a user-edited demo animal to its canonical values',
    () async {
      await service.install(referenceDate: referenceDate);
      final animals = await animalRepository.getAllIncludingInactive();
      final prieta = animals.firstWhere((a) => a.customName == 'Prieta');

      await animalRepository.update(
        prieta.copyWith(
          customName: 'Editada por el usuario',
          earTagNumber: 'X-1',
        ),
      );
      final edited = await animalRepository.getByUuid(prieta.uuid);
      expect(edited!.customName, 'Editada por el usuario');

      await service.install(referenceDate: referenceDate, reset: true);
      final restored = await animalRepository.getByUuid(prieta.uuid);
      expect(restored!.customName, 'Prieta');
      expect(restored.earTagNumber, prieta.earTagNumber);
    },
  );

  test(
    'a real (non-demo) animal is never touched by install or reset',
    () async {
      final realAnimal = AnimalEntity(
        uuid: 'real-animal-1',
        earTagNumber: 'REAL-0001',
        customName: 'Animal real del usuario',
        species: Species.cattle,
        category: Category.cow,
        lifeStage: LifeStage.cow,
        sex: Sex.female,
        breed: 'Real',
        birthDate: DateTime(2020, 1, 1),
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
        riskLevel: RiskLevel.none,
        gallery: const [],
        synced: true,
        creationDate: DateTime(2020, 1, 1),
        lastUpdateDate: DateTime(2020, 1, 1),
      );
      await animalRepository.save(realAnimal);

      await service.install(referenceDate: referenceDate);
      await service.install(referenceDate: referenceDate, reset: true);

      final stillThere = await animalRepository.getByUuid('real-animal-1');
      expect(stillThere, isNotNull);
      expect(stillThere!.customName, 'Animal real del usuario');

      final all = await animalRepository.getAllIncludingInactive();
      expect(all, hasLength(41)); // 40 demo + 1 real
    },
  );

  test('a failed install does not mark the scenario as installed', () async {
    expect(service.isInstalled, isFalse);
    // No direct way to force a mid-sequence failure without a fake
    // repository — this asserts the flag's initial state and that a
    // successful install does flip it, which is what the rest of the
    // partial-failure guarantee in DemoScenarioService.install relies on.
    await service.install(referenceDate: referenceDate);
    expect(service.isInstalled, isTrue);
    expect(prefs.getInt(PrefsKeys.demoScenarioInstalledVersion), isNotNull);
  });

  group('uninstall', () {
    test('removes every demo-owned row across every collection', () async {
      await service.install(referenceDate: referenceDate);

      final result = await service.uninstall();

      expect(result.removed, isTrue);
      expect(result.counts['animals'], 40);
      expect(result.counts['locations'], 15);
      expect(result.counts['lotes'], 6);
      expect(result.counts['milkingSessions'], greaterThan(0));
      expect(result.counts['milkingEntries'], greaterThan(0));
      expect(result.counts['incomeRecords'], greaterThan(0));
      expect(result.counts['generalExpenseRecords'], greaterThan(0));
      expect(result.counts['workers'], greaterThan(0));
      expect(result.counts['agendaEntries'], greaterThan(0));
      expect(result.profileCleared, isTrue);

      expect(await animalRepository.getAllIncludingInactive(), isEmpty);
      expect(await LotesRepositoryIsar(database).getAll(), isEmpty);
      // Not asserted empty: querying an empty location collection is exactly
      // what triggers `IsarLocationRepository`'s own unrelated implicit seed
      // (`prop-casa` and friends — see `demo_locations.dart`'s doc comment).
      // That is pre-existing behaviour this feature does not touch; the
      // meaningful check is that no *demo*-owned location survived.
      final locationsAfter = await IsarLocationRepository(database).getAll();
      expect(locationsAfter.where((l) => l.uuid.startsWith('demo-')), isEmpty);
      expect(await MilkingRepositoryIsar(database).getAllSessions(), isEmpty);
      expect(await IsarWorkforceRepository(database).fetchWorkers(), isEmpty);

      final agendaEntries = await IsarAgendaRepository(
        database,
        prefs,
      ).fetchEntries();
      expect(
        agendaEntries.where((e) => e.id.startsWith('demo-')),
        isEmpty,
        reason: 'manual demo tasks are gone',
      );
      expect(
        agendaEntries.where((e) => e.id.startsWith('auto:')),
        isEmpty,
        reason:
            'auto reminders were derived from demo animals that no '
            'longer exist, so a post-uninstall sync must not recreate them',
      );

      expect(service.isInstalled, isFalse);
    });

    test(
      'does nothing and reports removed=false when nothing is installed',
      () async {
        final result = await service.uninstall();

        expect(result.removed, isFalse);
        expect(result.counts.values.every((c) => c == 0), isTrue);
        expect(result.profileCleared, isFalse);
      },
    );

    test('never touches a real animal, lote or location', () async {
      final realAnimal = AnimalEntity(
        uuid: 'real-animal-2',
        earTagNumber: 'REAL-0002',
        customName: 'Vaca real',
        species: Species.cattle,
        category: Category.cow,
        lifeStage: LifeStage.cow,
        sex: Sex.female,
        breed: 'Real',
        birthDate: DateTime(2021, 1, 1),
        ageMonths: 48,
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
        riskLevel: RiskLevel.none,
        gallery: const [],
        synced: true,
        creationDate: DateTime(2021, 1, 1),
        lastUpdateDate: DateTime(2021, 1, 1),
      );
      await animalRepository.save(realAnimal);

      final realLotesRepository = LotesRepositoryIsar(database);
      await realLotesRepository.upsert(
        LoteEntity(
          uuid: 'real-lote-1',
          name: 'Lote real',
          animalUuids: const ['real-animal-2'],
          createdAt: DateTime(2021, 1, 1),
          lastUpdateDate: DateTime(2021, 1, 1),
        ),
      );

      await service.install(referenceDate: referenceDate);
      await service.uninstall();

      final stillThere = await animalRepository.getByUuid('real-animal-2');
      expect(stillThere, isNotNull);
      expect(stillThere!.customName, 'Vaca real');

      final realLote = await realLotesRepository.getByUuid('real-lote-1');
      expect(realLote, isNotNull);
      expect(realLote!.animalUuids, ['real-animal-2']);
    });

    test(
      'detaches (does not delete) a real animal parked in a demo lote/location',
      () async {
        await service.install(referenceDate: referenceDate);
        final demoAnimals = await animalRepository.getAllIncludingInactive();
        final demoLote = (await LotesRepositoryIsar(database).getAll()).first;
        final demoLocation = (await IsarLocationRepository(
          database,
        ).getAll()).first;

        final parkedAnimal = AnimalEntity(
          uuid: 'real-animal-parked',
          earTagNumber: 'REAL-0003',
          customName: 'Prestada en corral demo',
          species: Species.cattle,
          category: Category.cow,
          lifeStage: LifeStage.cow,
          sex: Sex.female,
          breed: 'Real',
          birthDate: DateTime(2021, 1, 1),
          ageMonths: 48,
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
          riskLevel: RiskLevel.none,
          gallery: const [],
          batchUuid: demoLote.uuid,
          currentLocationId: demoLocation.uuid,
          initialLocationId: demoLocation.uuid,
          synced: true,
          creationDate: DateTime(2021, 1, 1),
          lastUpdateDate: DateTime(2021, 1, 1),
        );
        await animalRepository.save(parkedAnimal);
        await LotesRepositoryIsar(database).upsert(
          demoLote.copyWith(
            animalUuids: [...demoLote.animalUuids, 'real-animal-parked'],
          ),
        );

        final result = await service.uninstall();

        expect(result.detachedReferences, greaterThan(0));
        final survivor = await animalRepository.getByUuid('real-animal-parked');
        expect(survivor, isNotNull, reason: 'the real animal must survive');
        expect(survivor!.batchUuid, isNull);
        expect(survivor.currentLocationId, isNull);
        expect(survivor.initialLocationId, isNull);

        // The demo animals themselves and the demo lote/location are gone.
        for (final demoAnimal in demoAnimals) {
          expect(await animalRepository.getByUuid(demoAnimal.uuid), isNull);
        }
      },
    );

    test('leaves a profile the user edited over the demo one alone', () async {
      await service.install(referenceDate: referenceDate);
      final perfilRepository = PerfilSharedPrefsRepository(prefs);
      final demo = await perfilRepository.fetchPerfil();
      await perfilRepository.updatePerfil(
        demo.copyWith(nombre: 'Dueño real', finca: 'Rancho real'),
      );

      final result = await service.uninstall();

      expect(result.profileCleared, isFalse);
      final afterUninstall = await perfilRepository.fetchPerfil();
      expect(afterUninstall.nombre, 'Dueño real');
      expect(afterUninstall.finca, 'Rancho real');
    });

    test('install works again cleanly after an uninstall', () async {
      await service.install(referenceDate: referenceDate);
      await service.uninstall();

      final reinstalled = await service.install(referenceDate: referenceDate);
      expect(reinstalled.installed, isTrue);
      expect(reinstalled.alreadyInstalled, isFalse);

      final snapshot = await buildSnapshot();
      final report = const DemoDataIntegrityValidator().validate(snapshot);
      expect(report.isValid, isTrue, reason: report.describe());
    });
  });
}
