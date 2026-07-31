/// End-to-end proof that the reproductive cycle is wired together.
///
/// Each step used to be reachable only in isolation: the service stored a row
/// without touching the cow, nothing could mark a pregnancy as confirmed, and
/// so the calving step could never activate. This walks the real chain
/// service -> diagnosis -> calving -> offspring against a real Isar instance,
/// asserting the animal's own state after every step.
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/services/reproductive_kpi_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/reproduction_record_repository_isar.dart';

bool _canRunIsarNative() {
  try {
    Isar.initializeIsarCore();
    return true;
  } catch (_) {
    return false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;
  late IsarDatabase db;
  late ReproductionRecordRepositoryIsar repo;

  const cowUuid = 'vaca-ciclo';
  const calfUuid = 'cria-ciclo';
  final serviceDate = DateTime(2026, 1, 10);

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('libretapp_cycle_test_');
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
    final isar = await db.initialize();
    repo = ReproductionRecordRepositoryIsar(db);

    await isar.writeTxn(() async {
      await isar.isarAnimals.clear();
      await isar.isarReproductionRecords.clear();
      await isar.isarAnimals.put(
        IsarAnimal()
          ..uuid = cowUuid
          ..earTagNumber = '0001'
          ..species = 'cattle'
          ..category = 'cow'
          ..lifeStage = 'cow'
          ..sex = 'female'
          ..breed = 'Brahman'
          ..birthDate = DateTime(2022, 1, 1)
          ..ageMonths = 48
          ..status = 'active'
          ..healthStatus = 'good'
          ..vaccinated = false
          ..dewormed = false
          ..hasVitamins = false
          ..hasChronicIssues = false
          ..reproductiveStatus = 'virgin'
          ..underObservation = false
          ..requiresAttention = false
          ..riskLevel = 'none'
          ..synced = true
          ..creationDate = DateTime(2022, 1, 1)
          ..lastUpdateDate = DateTime(2022, 1, 1),
      );
    });
  });

  Future<IsarAnimal> cow() async {
    final isar = await db.initialize();
    final animal = await isar.isarAnimals
        .where()
        .uuidEqualTo(cowUuid)
        .findFirst();
    return animal!;
  }

  test('service -> diagnosis -> calving -> offspring stays connected', () async {
    // ── 1. Monta ──────────────────────────────────────────────────────────
    await repo.addReproductionRecord(
      cowUuid,
      ReproductionRecord(
        serviceDate: serviceDate,
        serviceType: ServiceType.naturalService,
        maleSireUuid: 'toro-1',
      ),
    );

    var animal = await cow();
    expect(
      animal.reproductiveStatus,
      'active',
      reason: 'registering a service must move her out of virgin',
    );
    expect(animal.lastServiceDate, serviceDate);
    expect(animal.firstServiceDate, serviceDate);
    expect(
      animal.expectedCalvingDate,
      serviceDate.add(const Duration(days: 283)),
      reason: 'the calving date should be projected, not left to the user',
    );

    var records = await repo.getReproductionRecords(cowUuid);
    expect(records, hasLength(1));
    expect(
      ReproductiveKpiService.pendingDiagnosisOf(records),
      isNotNull,
      reason: 'a service with no result is what the diagnosis step looks for',
    );
    expect(ReproductiveKpiService.openCycleOf(records), isNull);

    // ── 2. Diagnóstico positivo, sobre el mismo registro ──────────────────
    final pending = ReproductiveKpiService.pendingDiagnosisOf(records)!;
    await repo.addReproductionRecord(
      cowUuid,
      pending.copyWith(
        pregnancyCheckDate: DateTime(2026, 2, 20),
        pregnancyResult: PregnancyCheckResult.positive,
      ),
    );

    animal = await cow();
    expect(animal.reproductiveStatus, 'pregnant');

    records = await repo.getReproductionRecords(cowUuid);
    expect(
      records,
      hasLength(1),
      reason: 'the diagnosis updates the service, it does not open a new cycle',
    );

    final openCycle = ReproductiveKpiService.openCycleOf(records);
    expect(openCycle, isNotNull, reason: 'the calving step needs this cycle');
    expect(ReproductiveKpiService.pendingDiagnosisOf(records), isNull);

    const kpiService = ReproductiveKpiService();
    final midCycle = kpiService.forAnimal(
      records: records,
      now: DateTime(2026, 4, 20),
    );
    expect(midCycle.isPregnant, isTrue);
    expect(midCycle.currentGestationDays, 100);

    // ── 3. Parto, también sobre el mismo registro ─────────────────────────
    final calvingDate = DateTime(2026, 10, 20);
    await repo.addReproductionRecord(
      cowUuid,
      openCycle!.copyWith(
        actualCalvingDate: calvingDate,
        calvingOutcome: CalvingOutcome.liveBirth,
        calvingEase: 1,
      ),
    );

    animal = await cow();
    expect(animal.reproductiveStatus, 'lactating');
    expect(animal.expectedCalvingDate, isNull);

    records = await repo.getReproductionRecords(cowUuid);
    expect(records, hasLength(1));
    expect(
      ReproductiveKpiService.openCycleOf(records),
      isNull,
      reason: 'a calved cycle is closed',
    );

    // ── 4. Enlazar la cría ────────────────────────────────────────────────
    await repo.addReproductionRecord(
      cowUuid,
      records.single.copyWith(offspringUuids: const [calfUuid]),
    );

    records = await repo.getReproductionRecords(cowUuid);
    final closed = records.single;
    expect(closed.offspringUuids, [calfUuid]);
    expect(
      closed.calvingOutcome,
      CalvingOutcome.liveBirth,
      reason: 'linking the calf must not wipe the calving details',
    );
    expect(closed.gestationDays, calvingDate.difference(serviceDate).inDays);

    final finalKpis = kpiService.forAnimal(
      records: records,
      birthDate: DateTime(2022, 1, 1),
      now: DateTime(2026, 11, 1),
    );
    expect(finalKpis.calvingCount, 1);
    expect(finalKpis.isPregnant, isFalse);
    expect(finalKpis.ageAtFirstCalvingMonths, 57);
  }, skip: !_canRunIsarNative());
}
