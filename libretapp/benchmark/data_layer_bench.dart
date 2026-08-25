/// benchmark › data_layer_bench — timings for the directory's hot data paths.
///
/// Run with:
///   flutter test benchmark/data_layer_bench.dart --dart-define=BENCH_OUT=<file>
///
/// Every case here is something the app does while a breeder waits: opening the
/// directory, opening one animal, saving a record, deleting one. The suite is a
/// `flutter test` file only because that is what gives it a Flutter binding and
/// the native Isar library — the assertions are on timing, not behaviour.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_activity_tracker.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_remote_data_source.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/health_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/movement_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_health_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/weight_record_repository_isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/bench_db.dart';
import 'support/bench_runner.dart';

class _NoRemote implements AnimalRemoteDataSource {
  @override
  Future<RemoteAnimalPayload> fetchAnimals() async => RemoteAnimalPayload(
    animals: const [],
    hash: 'bench',
    lastUpdated: DateTime(2024),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const shape = HerdShape();
  const outPath = String.fromEnvironment(
    'BENCH_OUT',
    defaultValue: 'benchmark/results/latest.json',
  );

  late BenchDb bench;
  late Isar isar;
  late AnimalRepositoryIsar animals;
  late HealthRecordRepositoryIsar healthRepo;
  late WeightRecordRepositoryIsar weightRepo;
  late MovementRecordRepositoryIsar movementRepo;
  final suite = BenchSuite(shape.label);

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      // Skip the one-time activity backfill: it is a migration, not a hot
      // path, and letting it run would rewrite the seeded timestamps.
      'animals.activityBackfill.v1.done': true,
    });
    bench = await BenchDb.open(shape);
    isar = bench.isar;

    final db = IsarDatabase();
    final prefs = SharedPrefsService(await SharedPreferences.getInstance());
    animals = AnimalRepositoryIsar(db, prefs, _NoRemote());
    healthRepo = HealthRecordRepositoryIsar(db);
    weightRepo = WeightRecordRepositoryIsar(db);
    movementRepo = MovementRecordRepositoryIsar(db);
  });

  tearDownAll(() async {
    suite.writeJson(outPath);
    await bench.close();
  });

  test('data layer benchmarks', () async {
    stdout.writeln('\n=== LibretApp data layer — ${shape.label} ===\n');

    // ── Directory screen ────────────────────────────────────────────────
    await suite.measure(
      'AnimalRepository.getAll (directory open)',
      scale: shape.label,
      body: () => animals.getAll().then((_) {}),
      iterations: 10,
    );

    await suite.measure(
      'AnimalRepository.getActiveTaxonomyCounts (filter chips)',
      scale: shape.label,
      body: () => animals.getActiveTaxonomyCounts().then((_) {}),
      iterations: 10,
    );

    // ── Single-animal lookups ───────────────────────────────────────────
    // Sampled across the key space so no single run can sit on a lucky row.
    await suite.measure(
      'AnimalRepository.getByUuid x50',
      scale: shape.label,
      body: () async {
        for (var i = 0; i < 50; i++) {
          await animals.getByUuid(animalUuidAt(i * 37 % shape.animals));
        }
      },
      iterations: 10,
    );

    await suite.measure(
      'HealthRepository.getRecordsFor x50 (animal detail)',
      scale: shape.label,
      body: () async {
        for (var i = 0; i < 50; i++) {
          await healthRepo.getHealthRecords(
            animalUuidAt(i * 37 % shape.animals),
          );
        }
      },
      iterations: 10,
    );

    await suite.measure(
      'WeightRepository.getRecordsFor x50 (animal detail)',
      scale: shape.label,
      body: () async {
        for (var i = 0; i < 50; i++) {
          await weightRepo.getWeightRecords(
            animalUuidAt(i * 37 % shape.animals),
          );
        }
      },
      iterations: 10,
    );

    // ── Card indicators for one page of the list ────────────────────────
    final pageUuids = {for (var i = 0; i < 30; i++) animalUuidAt(i)};
    await suite.measure(
      'Batch indicators for a 30-card page',
      scale: shape.label,
      body: () async {
        await weightRepo.getWeightRecordsForAnimals(pageUuids);
        await healthRepo.getActiveWithdrawals(pageUuids);
      },
      iterations: 10,
    );

    // ── Reportes "recent activity" ──────────────────────────────────────
    // The screen shows five movements and five health records. It used to ask
    // every animal in the herd for both, then keep five of each.
    await suite.measure(
      'Reportes recent activity — per-animal loop (old)',
      scale: shape.label,
      body: () async {
        final all = await animals.getAll();
        final movements = <MovementRecord>[];
        final health = <HealthRecord>[];
        for (final animal in all) {
          movements.addAll(await movementRepo.getMovementRecords(animal.uuid));
          health.addAll(await healthRepo.getHealthRecords(animal.uuid));
        }
        movements.sort((a, b) => b.date.compareTo(a.date));
        health.sort((a, b) => b.date.compareTo(a.date));
        movements.take(5).toList();
        health.take(5).toList();
      },
      iterations: 3,
      warmup: 1,
    );

    await suite.measure(
      'Reportes recent activity — two batch queries (new)',
      scale: shape.label,
      body: () async {
        await movementRepo.getRecentMovementRecords(limit: 5);
        await healthRepo.getRecentHealthRecords(limit: 5);
      },
      iterations: 3,
      warmup: 1,
    );

    // ── Writes ──────────────────────────────────────────────────────────
    await suite.measure(
      'AnimalActivityTracker.touch x25 (every record save)',
      scale: shape.label,
      body: () async {
        await isar.writeTxn(() async {
          for (var i = 0; i < 25; i++) {
            await AnimalActivityTracker.touch(
              isar,
              animalUuidAt(i * 37 % shape.animals),
              DateTime(2024, 6, 1),
            );
          }
        });
      },
      iterations: 10,
    );

    await suite.measure(
      'AnimalActivityTracker.recalculate x5 (record delete)',
      scale: shape.label,
      body: () async {
        await isar.writeTxn(() async {
          for (var i = 0; i < 5; i++) {
            await AnimalActivityTracker.recalculate(
              isar,
              animalUuidAt(i * 37 % shape.animals),
            );
          }
        });
      },
      iterations: 10,
    );

    var saveCounter = 0;
    await suite.measure(
      'HealthRepository.addHealthRecord (save a treatment)',
      scale: shape.label,
      body: () async {
        saveCounter++;
        await healthRepo.addHealthRecord(
          animalUuidAt(saveCounter * 37 % shape.animals),
          HealthRecord(
            id: '0',
            date: DateTime(2024, 6, 1),
            type: HealthRecordType.vaccine,
            product: 'Bench $saveCounter',
            recordUuid: 'bench-save-$saveCounter',
          ),
        );
      },
      iterations: 10,
      warmup: 2,
    );

    // Undo the benchmark's own writes so the seeded shape is what the next
    // case measures against.
    await isar.writeTxn(() async {
      await isar.isarHealthRecords
          .filter()
          .productStartsWith('Bench ')
          .deleteAll();
    });

    stdout.writeln('');
  }, timeout: const Timeout(Duration(minutes: 30)));
}
