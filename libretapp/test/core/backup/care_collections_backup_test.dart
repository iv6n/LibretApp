/// Round-trips the care-calendar Isar collections (`careRules`,
/// `careRecords`, `scheduledCares`) through [IsarBackupStore] and
/// [BackupService], guarding against the collections silently being dropped
/// from capture/restore/merge/clear/validate again.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/isar_backup_store.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/backup_service.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/data/workforce_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_rule.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/scheduled_care.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_remote_data_source.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/care_repository_isar.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryPerfilRepository implements PerfilRepository {
  Perfil perfil = const Perfil(
    id: 'profile-1',
    nombre: 'Ana',
    apellido: 'Piloto',
    email: '',
    telefono: '',
    finca: 'Finca piloto',
    direccion: '',
  );

  @override
  Future<Perfil> fetchPerfil() async => perfil;

  @override
  Future<void> savePerfil(Perfil perfil) async => this.perfil = perfil;

  @override
  Future<void> updatePerfil(Perfil perfil) => savePerfil(perfil);
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

// The repositories below are only present to satisfy BackupService's
// constructor: every test in this file routes through the injected
// [IsarBackupStore], so BackupService never falls back to these.
class _NoopAnimalRepository implements AnimalRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoopLotesRepository implements LotesRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoopAgendaRepository implements AgendaRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoopWorkforceRepository implements WorkforceRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoopMilkingRepository implements MilkingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

AnimalEntity _buildAnimal({required String uuid, required String earTag}) {
  final now = DateTime.utc(2026, 7, 1);
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: earTag,
    customName: 'Animal $uuid',
    visualId: 'VIS-$uuid',
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: 'Cebu',
    birthDate: DateTime.utc(2021, 1, 1),
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDirectory;
  late IsarDatabase database;
  late CareRepositoryIsar careRepository;
  late AnimalRepositoryIsar animalRepository;
  late _MemoryPerfilRepository profiles;
  late IsarBackupStore store;

  const ruleVaccinationId = 'rule-vaccination';
  const ruleDewormingId = 'rule-deworming';
  const scheduleId = 'schedule-1';
  const recordId = 'record-1';

  const ruleVaccination = CareRule(
    id: ruleVaccinationId,
    name: 'Vacuna anual',
    type: CareType.vaccination,
    intervalDays: 365,
    leadTimeDays: 14,
    mandatory: true,
  );
  const ruleDeworming = CareRule(
    id: ruleDewormingId,
    name: 'Desparasitación',
    type: CareType.deworming,
    intervalDays: 90,
    mandatory: false,
  );
  final schedule = ScheduledCare(
    id: scheduleId,
    animalId: 'animal-1',
    ruleId: ruleVaccinationId,
    type: CareType.vaccination,
    dueAt: DateTime.utc(2026, 8, 15),
    remindAt: DateTime.utc(2026, 8, 10),
    done: false,
    autoGenerated: true,
  );
  final record = CareRecord(
    id: recordId,
    animalId: 'animal-2',
    ruleId: ruleDewormingId,
    type: CareType.deworming,
    performedAt: DateTime.utc(2026, 7, 1),
    notes: 'Aplicado en campo',
    performedBy: 'Juan',
  );

  setUpAll(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'libretapp_care_backup_',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          pathProviderChannel,
          (_) async => tempDirectory.path,
        );
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (tempDirectory.existsSync()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final sharedPrefs = await SharedPreferences.getInstance();

    database = IsarDatabase();
    await database.initialize();
    await database.clearAllCollections();

    careRepository = CareRepositoryIsar(database);
    animalRepository = AnimalRepositoryIsar(
      database,
      SharedPrefsService(sharedPrefs),
      _FakeAnimalRemoteDataSource(),
    );
    profiles = _MemoryPerfilRepository();
    store = IsarBackupStore(database: database, perfilRepository: profiles);

    await animalRepository.save(
      _buildAnimal(uuid: 'animal-1', earTag: 'TAG-1'),
    );
    await animalRepository.save(
      _buildAnimal(uuid: 'animal-2', earTag: 'TAG-2'),
    );
    await careRepository.saveRule(ruleVaccination);
    await careRepository.saveRule(ruleDeworming);
    await careRepository.saveSchedules([schedule]);
    await careRepository.saveRecord(record);
  });

  tearDown(() async => database.close());

  BackupService buildService() => BackupService(
    animalRepository: _NoopAnimalRepository(),
    lotesRepository: _NoopLotesRepository(),
    agendaRepository: _NoopAgendaRepository(),
    workforceRepository: _NoopWorkforceRepository(),
    milkingRepository: _NoopMilkingRepository(),
    backupStore: store,
  );

  test('capture includes the three care-calendar collections', () async {
    final envelope = await store.capture();

    final rules = envelope.collections['careRules'];
    final records = envelope.collections['careRecords'];
    final schedules = envelope.collections['scheduledCares'];

    expect(rules, isNotNull);
    expect(records, isNotNull);
    expect(schedules, isNotNull);

    expect(
      rules!.map((row) => row['recordUuid']),
      containsAll(<String>[ruleVaccinationId, ruleDewormingId]),
    );
    final vaccinationRow = rules.singleWhere(
      (row) => row['recordUuid'] == ruleVaccinationId,
    );
    expect(vaccinationRow['name'], 'Vacuna anual');
    expect(vaccinationRow['type'], 'vaccination');
    expect(vaccinationRow['intervalDays'], 365);

    expect(records, hasLength(1));
    expect(records!.single['recordUuid'], recordId);
    expect(records.single['animalUuid'], 'animal-2');
    expect(records.single['ruleId'], ruleDewormingId);
    expect(records.single['notes'], 'Aplicado en campo');

    expect(schedules, hasLength(1));
    expect(schedules!.single['recordUuid'], scheduleId);
    expect(schedules.single['animalUuid'], 'animal-1');
    expect(schedules.single['ruleId'], ruleVaccinationId);
    expect(schedules.single['done'], false);
  });

  test(
    'clearAllCollections empties the care calendar, and restore brings it back',
    () async {
      final envelope = await store.capture();

      await database.clearAllCollections();

      expect(await careRepository.getRules(), isEmpty);
      expect(await careRepository.getAllRuleIds(), isEmpty);
      expect(await careRepository.getPending(), isEmpty);
      expect(await careRepository.getRecordsForAnimal('animal-2'), isEmpty);

      final result = await store.restore(
        envelope,
        mode: BackupImportMode.replaceAll,
      );

      expect(result.count('careRules'), 2);
      expect(result.count('careRecords'), 1);
      expect(result.count('scheduledCares'), 1);

      final restoredRuleIds = await careRepository.getAllRuleIds();
      expect(restoredRuleIds, {ruleVaccinationId, ruleDewormingId});

      final restoredRecords = await careRepository.getRecordsForAnimal(
        'animal-2',
      );
      expect(restoredRecords, hasLength(1));
      final restoredRecord = restoredRecords.single;
      // Isar round-trips DateTime as a local-clock value with the same
      // instant, not as UTC, so a plain Equatable `==` against [record]
      // (built with DateTime.utc) would spuriously fail even though the
      // data is intact — compare the instant instead.
      expect(restoredRecord.id, record.id);
      expect(restoredRecord.animalId, record.animalId);
      expect(restoredRecord.ruleId, record.ruleId);
      expect(restoredRecord.type, record.type);
      expect(
        restoredRecord.performedAt.isAtSameMomentAs(record.performedAt),
        isTrue,
      );
      expect(restoredRecord.notes, record.notes);
      expect(restoredRecord.performedBy, record.performedBy);

      final restoredSchedules = await careRepository.getPendingForAnimal(
        'animal-1',
      );
      expect(restoredSchedules, hasLength(1));
      final restoredSchedule = restoredSchedules.single;
      expect(restoredSchedule.id, schedule.id);
      expect(restoredSchedule.animalId, schedule.animalId);
      expect(restoredSchedule.ruleId, schedule.ruleId);
      expect(restoredSchedule.type, schedule.type);
      expect(restoredSchedule.dueAt.isAtSameMomentAs(schedule.dueAt), isTrue);
      expect(
        restoredSchedule.remindAt?.isAtSameMomentAs(schedule.remindAt!),
        isTrue,
      );
      expect(restoredSchedule.done, schedule.done);
      expect(restoredSchedule.autoGenerated, schedule.autoGenerated);
    },
  );

  test('BackupService validation accepts an envelope with the care collections '
      'and rejects one missing careRules', () async {
    final service = buildService();

    final json = await service.exportToJsonString();
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    expect(decoded['schemaVersion'], BackupEnvelope.currentSchemaVersion);
    final collections = decoded['collections'] as Map<String, dynamic>;
    expect(collections.containsKey('careRules'), isTrue);
    expect(collections.containsKey('careRecords'), isTrue);
    expect(collections.containsKey('scheduledCares'), isTrue);
    expect((collections['careRules'] as List), hasLength(2));

    // A valid envelope (with the care collections present) must be
    // accepted by validation on the way back in.
    await expectLater(
      service.importFromJsonString(json, mode: BackupImportMode.merge),
      completes,
    );

    // Stripping careRules must be rejected: requiredCollections was wired
    // to demand it, now that capture() always produces it.
    final withoutCareRules = Map<String, dynamic>.from(decoded);
    final collectionsWithoutCareRules = Map<String, dynamic>.from(collections)
      ..remove('careRules');
    withoutCareRules['collections'] = collectionsWithoutCareRules;

    await expectLater(
      () => service.importFromJsonString(
        jsonEncode(withoutCareRules),
        mode: BackupImportMode.merge,
      ),
      throwsA(isA<FormatException>()),
    );
  });
}
