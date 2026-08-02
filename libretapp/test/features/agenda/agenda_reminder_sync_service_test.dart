/// Care tasks must reach the Agenda the same way health/reproduction
/// reminders already do — otherwise the calendar built in
/// CareCalendarService/CareRepositoryIsar has nowhere the breeder actually
/// looks.
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_rule.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/services/care_calendar_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
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

AnimalEntity _cow() {
  final now = DateTime(2026, 1, 1);
  return AnimalEntity(
    uuid: 'vaca-1',
    earTagNumber: 'V-1',
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: 'Brahman',
    birthDate: DateTime(2023, 1, 1),
    ageMonths: 36,
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

class _FakeAnimalRepository implements AnimalRepository {
  _FakeAnimalRepository(this.animals);
  final List<AnimalEntity> animals;

  @override
  Future<List<AnimalEntity>> getAll() async => animals;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _EmptyHealthRepository implements HealthRecordRepository {
  @override
  Future<List<HealthRecord>> getHealthRecords(String animalUuid) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _EmptyReproductionRepository implements ReproductionRecordRepository {
  @override
  Future<List<ReproductionRecord>> getReproductionRecords(
    String animalUuid,
  ) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _InMemoryAgendaRepository implements AgendaRepository {
  List<AgendaEntry> _entries = [];

  @override
  Future<List<AgendaEntry>> fetchEntries() async => List.of(_entries);

  @override
  Future<void> replaceAll(List<AgendaEntry> entries) async {
    _entries = List.of(entries);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AgendaReminderSyncService · care tasks', () {
    const pathProviderChannel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    late Directory tempDir;
    late IsarDatabase db;
    late CareRepositoryIsar careRepo;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'libretapp_agenda_care_test_',
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
      if (tempDir.existsSync()) await tempDir.delete(recursive: true);
    });

    setUp(() async {
      db = IsarDatabase();
      final isar = await db.initialize();
      careRepo = CareRepositoryIsar(db);
      await isar.writeTxn(() async {
        await isar.isarCareRules.clear();
        await isar.isarCareRecords.clear();
        await isar.isarScheduledCares.clear();
      });
    });

    tearDown(() async => IsarDatabase().close());

    AgendaReminderSyncService buildService({
      required List<AnimalEntity> animals,
      required AgendaRepository agendaRepository,
    }) {
      return AgendaReminderSyncService(
        animalRepository: _FakeAnimalRepository(animals),
        agendaRepository: agendaRepository,
        healthRepo: _EmptyHealthRepository(),
        reproductionRepo: _EmptyReproductionRepository(),
        careRepo: careRepo,
        careCalendarService: CareCalendarService(careRepo),
      );
    }

    test('a due care rule reaches the Agenda as an auto:care entry', () async {
      await careRepo.saveRule(
        const CareRule(
          id: 'r1',
          name: 'Vacunación anual',
          type: CareType.vaccination,
          intervalDays: 365,
          species: Species.cattle,
        ),
      );

      final agenda = _InMemoryAgendaRepository();
      final service = buildService(animals: [_cow()], agendaRepository: agenda);

      final generated = await service.sync();
      expect(generated, 1);

      final entries = await agenda.fetchEntries();
      expect(entries, hasLength(1));
      expect(entries.single.id, startsWith('auto:care:vaca-1:r1:'));
      expect(entries.single.titulo, contains('Vacunación anual'));
      expect(entries.single.tipo, 'Cuidado sanitario');
    });

    test('recording the care pushes the reminder a year out', () async {
      await careRepo.saveRule(
        const CareRule(
          id: 'r1',
          name: 'Vacunación anual',
          type: CareType.vaccination,
          intervalDays: 365,
          species: Species.cattle,
        ),
      );

      final agenda = _InMemoryAgendaRepository();
      final service = buildService(animals: [_cow()], agendaRepository: agenda);

      await service.sync();
      final firstEntry = (await agenda.fetchEntries()).single;

      final performedAt = DateTime.now();
      await careRepo.saveRecord(
        CareRecord(
          id: 'c1',
          animalId: 'vaca-1',
          ruleId: 'r1',
          type: CareType.vaccination,
          performedAt: performedAt,
        ),
      );

      await service.sync();
      final entries = await agenda.fetchEntries();
      expect(entries, hasLength(1));
      expect(
        entries.single.id,
        isNot(firstEntry.id),
        reason: 'the due date moved, so the derived id must move with it',
      );
      expect(
        entries.single.fecha.difference(firstEntry.fecha).inDays,
        closeTo(365, 1),
      );
    });

    test('a rule outside the species is not scheduled', () async {
      await careRepo.saveRule(
        const CareRule(
          id: 'goat-only',
          name: 'Desparasitación caprina',
          type: CareType.deworming,
          intervalDays: 120,
          species: Species.goat,
        ),
      );

      final agenda = _InMemoryAgendaRepository();
      final service = buildService(animals: [_cow()], agendaRepository: agenda);

      await service.sync();
      expect(await agenda.fetchEntries(), isEmpty);
    });
  }, skip: !_canRunIsarNative());
}
