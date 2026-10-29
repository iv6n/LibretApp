/// Care tasks must reach the Agenda the same way health/reproduction
/// reminders already do — otherwise the calendar built in
/// CareCalendarService/CareRepositoryIsar has nowhere the breeder actually
/// looks.
library;

import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/domain/operational_work.dart';
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
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_task_type.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

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

class _BlockedAnimalRepository implements AnimalRepository {
  final started = Completer<void>();
  final release = Completer<List<AnimalEntity>>();

  @override
  Future<List<AnimalEntity>> getAll() {
    if (!started.isCompleted) started.complete();
    return release.future;
  }

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

class _InMemoryAgendaRepository
    implements AgendaRepository, AtomicAgendaRepository {
  List<AgendaEntry> _entries = [];

  @override
  Future<List<AgendaEntry>> fetchEntries() async => List.of(_entries);

  @override
  Future<void> replaceAll(List<AgendaEntry> entries) async {
    _entries = List.of(entries);
  }

  @override
  Future<void> saveEntry(AgendaEntry entry) async {
    final index = _entries.indexWhere((current) => current.id == entry.id);
    if (index < 0) {
      _entries.add(entry);
    } else {
      _entries[index] = entry;
    }
  }

  @override
  Future<void> updateEntry(AgendaEntry entry) => saveEntry(entry);

  @override
  Future<void> reconcileEntries(
    List<AgendaEntry> Function(List<AgendaEntry> current) update,
  ) async {
    _entries = update(List<AgendaEntry>.of(_entries));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeLocationRepository implements LocationRepository {
  _FakeLocationRepository(this.locations);

  final List<LocationEntity> locations;

  @override
  Future<List<LocationEntity>> getAll() async => locations;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeCultivationRepository implements CultivationRepository {
  _FakeCultivationRepository(this.cultivations);

  final List<CultivationEntity> cultivations;

  @override
  Future<List<CultivationEntity>> getAll({
    bool includeArchived = false,
  }) async =>
      cultivations.where((item) => includeArchived || item.isActive).toList();

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
      AnimalRepository? animalRepository,
      LocationRepository? locationRepository,
      CultivationRepository? cultivationRepository,
    }) {
      return AgendaReminderSyncService(
        animalRepository: animalRepository ?? _FakeAnimalRepository(animals),
        agendaRepository: agendaRepository,
        healthRepo: _EmptyHealthRepository(),
        reproductionRepo: _EmptyReproductionRepository(),
        careRepo: careRepo,
        careCalendarService: CareCalendarService(careRepo),
        locationRepository: locationRepository,
        cultivationRepository: cultivationRepository,
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
      expect(entries.single.tipo, 'Vacunación');
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

    test(
      'sync preserves manual lite and unknown entries, dropping only legacy auto',
      () async {
        AgendaEntry entry(String id, {String? sourceType}) => AgendaEntry(
          id: id,
          titulo: id,
          descripcion: '',
          fecha: DateTime(2026, 10, 1),
          tipo: 'Cuidado',
          animalIds: const [],
          loteIds: const [],
          ubicacion: '',
          estado: AgendaEstado.pendiente,
          completedAnimalIds: const [],
          notas: '',
          sourceType: sourceType,
        );

        final agenda = _InMemoryAgendaRepository();
        await agenda.replaceAll([
          entry('auto:care:manual', sourceType: 'manual'),
          entry('auto:care:lite', sourceType: 'lite'),
          entry('third-party-event', sourceType: 'externalIntegration'),
          entry('auto:care:legacy'),
        ]);

        await buildService(animals: const [], agendaRepository: agenda).sync();

        final ids = (await agenda.fetchEntries())
            .map((value) => value.id)
            .toSet();
        expect(
          ids,
          containsAll([
            'auto:care:manual',
            'auto:care:lite',
            'third-party-event',
          ]),
        );
        expect(ids, isNot(contains('auto:care:legacy')));
      },
    );

    test(
      'sync preserves an appointment created and completed while reminders build',
      () async {
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
        final now = DateTime(2026, 10, 1);
        await buildService(
          animals: [_cow()],
          agendaRepository: agenda,
        ).sync(now: now);
        final generated = (await agenda.fetchEntries()).single;

        final blockedAnimals = _BlockedAnimalRepository();
        final sync = buildService(
          animals: const [],
          animalRepository: blockedAnimals,
          agendaRepository: agenda,
        ).sync(now: now);
        await blockedAnimals.started.future;

        final created = AgendaEntry(
          id: 'manual-created-during-sync',
          titulo: 'Consulta nueva',
          descripcion: '',
          fecha: now,
          tipo: 'Cita',
          animalIds: const ['vaca-1'],
          loteIds: const [],
          ubicacion: '',
          estado: AgendaEstado.pendiente,
          completedAnimalIds: const [],
          notas: '',
          sourceType: 'manual',
        );
        await agenda.saveEntry(created);
        await agenda.saveEntry(
          generated.copyWith(
            estado: AgendaEstado.completado,
            notas: 'Aplicada durante la regeneración',
          ),
        );
        blockedAnimals.release.complete([_cow()]);
        await sync;

        final latest = await agenda.fetchEntries();
        final preservedAuto = latest.singleWhere(
          (entry) => entry.id == generated.id,
        );
        expect(latest.map((entry) => entry.id), contains(created.id));
        expect(preservedAuto.estado, AgendaEstado.completado);
        expect(preservedAuto.notas, 'Aplicada durante la regeneración');
      },
    );

    test('an independent crop without location creates Agenda work', () async {
      final agenda = _InMemoryAgendaRepository();
      final cultivation = CultivationEntity(
        uuid: 'rose-1',
        name: 'Rosa',
        plantingDate: DateTime(2026, 9, 1),
        expectedHarvestDate: DateTime(2026, 12, 1),
        tasks: [
          CropTask(
            uuid: 'prune-1',
            type: CropTaskType.prune,
            dueDate: DateTime(2026, 9, 10),
          ),
        ],
      );
      final service = buildService(
        animals: const [],
        agendaRepository: agenda,
        cultivationRepository: _FakeCultivationRepository([cultivation]),
      );

      await service.sync();
      final entries = await agenda.fetchEntries();

      expect(entries, hasLength(3));
      expect(entries.every((entry) => entry.cropUuid == 'rose-1'), isTrue);
      expect(
        entries.every((entry) => entry.ubicacion == 'Sin ubicación'),
        isTrue,
      );
      expect(entries.any((entry) => entry.titulo == 'Podar - Rosa'), isTrue);
      expect(entries.any((entry) => entry.titulo == 'Riego - Rosa'), isTrue);
      expect(
        entries.any((entry) => entry.titulo == 'Cosecha esperada - Rosa'),
        isTrue,
      );
    });

    test('a location maintenance due date reaches the Agenda', () async {
      final dueDate = DateTime(2026, 2, 15);
      final location = LocationEntity(
        uuid: 'corral-1',
        name: 'Corral principal',
        type: LocationType.corral,
        surfaceArea: 100,
        capacity: 20,
        waterSource: 'Pozo',
        terrainType: 'Plano',
        maintenances: [
          MaintenanceRecord(
            uuid: 'maintenance-1',
            date: DateTime(2026, 1, 15),
            assetName: 'Bomba de agua',
            maintenanceType: 'Preventivo',
            nextDueDate: dueDate,
          ),
        ],
      );
      final agenda = _InMemoryAgendaRepository();
      final service = buildService(
        animals: const [],
        agendaRepository: agenda,
        locationRepository: _FakeLocationRepository([location]),
      );

      final generated = await service.sync(now: DateTime(2026, 1, 20));

      expect(generated, 1);
      final entry = (await agenda.fetchEntries()).single;
      expect(
        entry.id,
        'auto:location-maintenance:corral-1:maintenance-1:20260215',
      );
      expect(entry.titulo, contains('Bomba de agua'));
      expect(entry.actionKind, WorkActionType.maintenance.name);
      expect(entry.locationUuid, 'corral-1');
    });
  }, skip: !_canRunIsarNative());
}
