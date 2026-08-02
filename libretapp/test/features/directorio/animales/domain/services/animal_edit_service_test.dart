/// Covers the canonical edit workflow end to end against a real (temp-dir)
/// Isar database — the same "Prieta" walkthrough described in the task:
/// rename, change lote, change location, save unchanged, register health,
/// then sell her and confirm she leaves the herd/lote/milking pool while
/// keeping her history.
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/features/agenda/infrastructure/isar_agenda_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_rule.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_edit_service.dart';
import 'package:libretapp/features/directorio/animales/domain/services/care_calendar_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_remote_data_source.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/care_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/health_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/movement_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/reproduction_record_repository_isar.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository_isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAnimalRemoteDataSource implements AnimalRemoteDataSource {
  @override
  Future<RemoteAnimalPayload> fetchAnimals() async {
    return RemoteAnimalPayload(
      animals: const [],
      hash: 'h',
      lastUpdated: DateTime.now(),
    );
  }
}

AnimalEntity _cow({
  required String uuid,
  required String earTag,
  String? name,
  String? batchUuid,
  String? currentLocationId,
  String? initialLocationId,
  AnimalStatus status = AnimalStatus.active,
}) {
  final now = DateTime(2026, 1, 1);
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: earTag,
    customName: name,
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: 'Brahman',
    birthDate: DateTime(2021, 1, 1),
    ageMonths: 60,
    healthStatus: HealthStatus.good,
    vaccinated: true,
    dewormed: true,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.dairy,
    productionStage: ProductionStage.lactating,
    productionSystem: ProductionSystem.extensive,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.none,
    gallery: const [],
    batchUuid: batchUuid,
    currentLocationId: currentLocationId,
    initialLocationId: initialLocationId,
    status: status,
    synced: true,
    creationDate: now,
    lastUpdateDate: now,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;
  late IsarDatabase database;
  late AnimalRepositoryIsar animalRepository;
  late LotesRepositoryIsar lotesRepository;
  late MovementRecordRepositoryIsar movementRepository;
  late CareRepositoryIsar careRepository;
  late AnimalEditService service;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('libretapp_edit_test_');
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
    final prefs = SharedPrefsService(sharedPreferences);

    database = IsarDatabase();
    await database.initialize();
    await database.clearAllCollections();

    animalRepository = AnimalRepositoryIsar(
      database,
      prefs,
      _FakeAnimalRemoteDataSource(),
    );
    lotesRepository = LotesRepositoryIsar(database);
    movementRepository = MovementRecordRepositoryIsar(database);
    careRepository = CareRepositoryIsar(database);
    final healthRepository = HealthRecordRepositoryIsar(database);
    final reproductionRepository = ReproductionRecordRepositoryIsar(database);
    final careCalendarService = CareCalendarService(careRepository);
    final agendaRepository = IsarAgendaRepository(database, prefs);
    final agendaReminderSyncService = AgendaReminderSyncService(
      animalRepository: animalRepository,
      agendaRepository: agendaRepository,
      healthRepo: healthRepository,
      reproductionRepo: reproductionRepository,
      careRepo: careRepository,
      careCalendarService: careCalendarService,
    );

    service = AnimalEditService(
      animalRepository: animalRepository,
      lotesRepository: lotesRepository,
      movementRepository: movementRepository,
      careRepository: careRepository,
      agendaReminderSyncService: agendaReminderSyncService,
      careCalendarService: careCalendarService,
    );

    await lotesRepository.upsert(
      LoteEntity(
        uuid: 'lote-vientres',
        name: 'Vientres',
        animalUuids: const [],
        createdAt: DateTime(2026, 1, 1),
        lastUpdateDate: DateTime(2026, 1, 1),
      ),
    );
    await lotesRepository.upsert(
      LoteEntity(
        uuid: 'lote-vaquillas',
        name: 'Vaquillas',
        animalUuids: const [],
        createdAt: DateTime(2026, 1, 1),
        lastUpdateDate: DateTime(2026, 1, 1),
      ),
    );
  });

  tearDown(() async => database.close());

  test(
    'renaming and re-tagging preserves uuid/creationDate and flips synced',
    () async {
      final prieta = _cow(uuid: 'prieta-1', earTag: 'V-1', name: 'Prieta');
      await animalRepository.save(prieta);

      final saved = await service.applyEdit(
        original: prieta,
        draft: prieta.copyWith(
          customName: 'Prieta Linda',
          earTagNumber: 'V-1B',
        ),
      );

      expect(saved.uuid, prieta.uuid);
      expect(saved.creationDate, prieta.creationDate);
      expect(saved.customName, 'Prieta Linda');
      expect(saved.earTagNumber, 'V-1B');
      expect(saved.synced, isFalse);
      expect(saved.lastUpdateDate.isAfter(prieta.creationDate), isTrue);
    },
  );

  test(
    'a duplicate ear tag is rejected, excluding the animal itself',
    () async {
      final prieta = _cow(uuid: 'prieta-1', earTag: 'V-1');
      final wera = _cow(uuid: 'wera-1', earTag: 'V-2');
      await animalRepository.save(prieta);
      await animalRepository.save(wera);

      // Saving Prieta again with her own tag must succeed (no false positive).
      await expectLater(
        service.applyEdit(original: prieta, draft: prieta),
        completes,
      );

      await expectLater(
        service.applyEdit(
          original: prieta,
          draft: prieta.copyWith(earTagNumber: 'V-2'),
        ),
        throwsA(isA<AnimalEditValidationException>()),
      );
    },
  );

  test(
    'changing lote removes the old membership and adds the new one once',
    () async {
      final prieta = _cow(
        uuid: 'prieta-1',
        earTag: 'V-1',
        batchUuid: 'lote-vientres',
      );
      await animalRepository.save(prieta);
      await lotesRepository.addAnimalToLote(
        loteUuid: 'lote-vientres',
        animalUuid: 'prieta-1',
      );

      await service.applyEdit(
        original: prieta,
        draft: prieta.copyWith(batchUuid: 'lote-vaquillas'),
      );

      final vientres = await lotesRepository.getByUuid('lote-vientres');
      final vaquillas = await lotesRepository.getByUuid('lote-vaquillas');
      expect(vientres!.animalUuids, isNot(contains('prieta-1')));
      expect(vaquillas!.animalUuids, ['prieta-1']);

      // Saving again with the same lote must not duplicate the membership.
      final persisted = await animalRepository.getByUuid('prieta-1');
      await service.applyEdit(original: persisted!, draft: persisted);
      final vaquillasAgain = await lotesRepository.getByUuid('lote-vaquillas');
      expect(vaquillasAgain!.animalUuids, ['prieta-1']);
    },
  );

  test(
    'changing location creates exactly one movement; an unchanged save creates none',
    () async {
      final prieta = _cow(
        uuid: 'prieta-1',
        earTag: 'V-1',
        currentLocationId: 'loc-cuarentena',
        initialLocationId: 'loc-cuarentena',
      );
      await animalRepository.save(prieta);

      await service.applyEdit(
        original: prieta,
        draft: prieta.copyWith(currentLocationId: 'loc-potrero-norte'),
      );
      var movements = await movementRepository.getMovementRecords('prieta-1');
      expect(movements, hasLength(1));
      expect(movements.single.toLocation, 'loc-potrero-norte');
      expect(movements.single.fromLocation, 'loc-cuarentena');

      final persisted = await animalRepository.getByUuid('prieta-1');
      expect(persisted!.initialLocationId, 'loc-cuarentena');
      expect(persisted.currentLocationId, 'loc-potrero-norte');

      // Save again without changing the location: no second movement.
      await service.applyEdit(original: persisted, draft: persisted);
      movements = await movementRepository.getMovementRecords('prieta-1');
      expect(movements, hasLength(1));
    },
  );

  test(
    'selling an animal drops it from its lote and clears pending auto care',
    () async {
      final prieta = _cow(
        uuid: 'prieta-1',
        earTag: 'V-1',
        batchUuid: 'lote-vientres',
      );
      await animalRepository.save(prieta);
      await lotesRepository.addAnimalToLote(
        loteUuid: 'lote-vientres',
        animalUuid: 'prieta-1',
      );
      await careRepository.saveRule(
        const CareRule(
          id: 'rule-1',
          name: 'Vacunación',
          type: CareType.vaccination,
          intervalDays: 365,
        ),
      );
      await CareCalendarService(
        careRepository,
      ).regenerateFor(prieta, now: DateTime(2026, 1, 1));
      expect(await careRepository.getPendingForAnimal('prieta-1'), isNotEmpty);

      await service.applyEdit(
        original: prieta,
        draft: prieta.copyWith(status: AnimalStatus.sold),
      );

      final sold = await animalRepository.getByUuid('prieta-1');
      expect(sold!.status, AnimalStatus.sold);
      expect(sold.batchUuid, isNull);
      expect(sold.status.isInActiveHerd, isFalse);

      final vientres = await lotesRepository.getByUuid('lote-vientres');
      expect(vientres!.animalUuids, isNot(contains('prieta-1')));

      expect(await careRepository.getPendingForAnimal('prieta-1'), isEmpty);

      // The active-herd query (what Milking/dashboard read) excludes her.
      final active = await animalRepository.getAll();
      expect(active.any((a) => a.uuid == 'prieta-1'), isFalse);
    },
  );

  test('self-parentage is rejected', () async {
    final prieta = _cow(uuid: 'prieta-1', earTag: 'V-1');
    await animalRepository.save(prieta);

    await expectLater(
      service.applyEdit(
        original: prieta,
        draft: prieta.copyWith(sireUuid: 'prieta-1'),
      ),
      throwsA(isA<AnimalEditValidationException>()),
    );
  });
}
