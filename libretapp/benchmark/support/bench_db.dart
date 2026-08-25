/// benchmark › support › bench_db — opens a throwaway Isar and seeds a herd.
///
/// Seeds Isar models directly rather than going through the repositories: the
/// point is to hold the *data* constant across runs so a before/after diff can
/// only reflect the query code under test.
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/agenda/infrastructure/isar/isar_agenda_registration.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_care.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_commercial_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_cost_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_health_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_movement_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_production_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_weight_record.dart';
import 'package:libretapp/features/milking/infrastructure/isar/isar_milking_entry.dart';
import 'package:libretapp/features/milking/infrastructure/isar/isar_milking_session.dart';

/// Shape of the seeded herd. Defaults model a mid-size operation that has been
/// running a few years — the scale at which the directory starts to drag.
class HerdShape {
  const HerdShape({
    this.animals = 2000,
    this.healthPerAnimal = 4,
    this.weightPerAnimal = 4,
    this.reproductionPerAnimal = 2,
    this.movementPerAnimal = 2,
    this.productionPerAnimal = 2,
    this.commercialPerAnimal = 1,
    this.costPerAnimal = 2,
    this.carePerAnimal = 2,
    this.agendaPerAnimal = 1,
    this.milkingPerAnimal = 3,
  });

  final int animals;
  final int healthPerAnimal;
  final int weightPerAnimal;
  final int reproductionPerAnimal;
  final int movementPerAnimal;
  final int productionPerAnimal;
  final int commercialPerAnimal;
  final int costPerAnimal;
  final int carePerAnimal;
  final int agendaPerAnimal;
  final int milkingPerAnimal;

  int get totalChildRecords =>
      animals *
      (healthPerAnimal +
          weightPerAnimal +
          reproductionPerAnimal +
          movementPerAnimal +
          productionPerAnimal +
          commercialPerAnimal +
          costPerAnimal +
          carePerAnimal +
          agendaPerAnimal +
          milkingPerAnimal);

  String get label => '${animals}a/${totalChildRecords}r';
}

/// Deterministic uuid for animal [i] — stable across runs so a benchmark can
/// look up "the same" animal before and after a change.
String animalUuidAt(int i) => 'bench-animal-${i.toString().padLeft(6, '0')}';

class BenchDb {
  BenchDb._(this.isar, this.shape, this._tempDir);

  final Isar isar;
  final HerdShape shape;
  final Directory _tempDir;

  static const _pathProviderChannel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );

  static Future<BenchDb> open(HerdShape shape) async {
    final tempDir = await Directory.systemTemp.createTemp('libretapp_bench_');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          _pathProviderChannel,
          (call) async => tempDir.path,
        );

    final db = IsarDatabase();
    final isar = await db.initialize();
    await db.clearAllCollections();

    final bench = BenchDb._(isar, shape, tempDir);
    await bench._seed();
    return bench;
  }

  Future<void> close() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, null);
    await IsarDatabase().close();
    if (_tempDir.existsSync()) {
      await _tempDir.delete(recursive: true);
    }
  }

  /// Fixed so seeded dates never drift between runs.
  static final DateTime _epoch = DateTime(2024, 1, 1);

  Future<void> _seed() async {
    final sw = Stopwatch()..start();

    final animals = <IsarAnimal>[];
    final health = <IsarHealthRecord>[];
    final weights = <IsarWeightRecord>[];
    final reproductions = <IsarReproductionRecord>[];
    final movements = <IsarMovementRecord>[];
    final productions = <IsarProductionRecord>[];
    final commercials = <IsarCommercialRecord>[];
    final costs = <IsarCostRecord>[];
    final cares = <IsarCareRecord>[];
    final agendas = <IsarAgendaRegistration>[];
    final entries = <IsarMilkingEntry>[];

    for (var i = 0; i < shape.animals; i++) {
      final uuid = animalUuidAt(i);
      final day = i % 700;
      animals.add(_animal(i, uuid));

      for (var j = 0; j < shape.healthPerAnimal; j++) {
        health.add(
          IsarHealthRecord()
            ..recordUuid = '$uuid-h$j'
            ..animalUuid = uuid
            ..date = _epoch.add(Duration(days: day + j))
            ..type = 'vaccine'
            ..product = 'Producto $j'
            ..withdrawalDays = 5
            ..withdrawalEndDate = _epoch.add(Duration(days: day + j + 5))
            ..updatedAt = _epoch.add(Duration(days: day + j)),
        );
      }
      for (var j = 0; j < shape.weightPerAnimal; j++) {
        weights.add(
          IsarWeightRecord()
            ..recordUuid = '$uuid-w$j'
            ..animalUuid = uuid
            ..date = _epoch.add(Duration(days: day + j * 30))
            ..weight = 180.0 + (i % 300) + j * 12
            ..method = 'scale'
            ..updatedAt = _epoch.add(Duration(days: day + j * 30)),
        );
      }
      for (var j = 0; j < shape.reproductionPerAnimal; j++) {
        reproductions.add(
          IsarReproductionRecord()
            ..recordUuid = '$uuid-r$j'
            ..animalUuid = uuid
            ..serviceDate = _epoch.add(Duration(days: day + j * 90))
            ..serviceType = 'naturalService'
            ..updatedAt = _epoch.add(Duration(days: day + j * 90)),
        );
      }
      for (var j = 0; j < shape.movementPerAnimal; j++) {
        movements.add(
          IsarMovementRecord()
            ..recordUuid = '$uuid-m$j'
            ..animalUuid = uuid
            ..toLocation = 'potrero-${i % 30}'
            ..date = _epoch.add(Duration(days: day + j * 45))
            ..reason = 'paddockRotation'
            ..updatedAt = _epoch.add(Duration(days: day + j * 45)),
        );
      }
      for (var j = 0; j < shape.productionPerAnimal; j++) {
        productions.add(
          IsarProductionRecord()
            ..recordUuid = '$uuid-p$j'
            ..animalUuid = uuid
            ..date = _epoch.add(Duration(days: day + j * 20))
            ..type = 'production'
            ..value = 12.0 + j,
        );
      }
      for (var j = 0; j < shape.commercialPerAnimal; j++) {
        commercials.add(
          IsarCommercialRecord()
            ..recordUuid = '$uuid-c$j'
            ..animalUuid = uuid
            ..date = _epoch.add(Duration(days: day + j * 60))
            ..type = 'purchase'
            ..amount = 8000.0 + i,
        );
      }
      for (var j = 0; j < shape.costPerAnimal; j++) {
        costs.add(
          IsarCostRecord()
            ..recordUuid = '$uuid-k$j'
            ..animalUuid = uuid
            ..date = _epoch.add(Duration(days: day + j * 15))
            ..type = 'feeding'
            ..amount = 120.0 + j,
        );
      }
      for (var j = 0; j < shape.carePerAnimal; j++) {
        cares.add(
          IsarCareRecord()
            ..recordUuid = '$uuid-cr$j'
            ..animalUuid = uuid
            ..ruleId = 'rule-${j % 4}'
            ..type = 'deworming'
            ..performedAt = _epoch.add(Duration(days: day + j * 120)),
        );
      }
      for (var j = 0; j < shape.agendaPerAnimal; j++) {
        agendas.add(
          IsarAgendaRegistration()
            ..uuid = '$uuid-ag$j'
            ..batchId = 'batch-${i % 50}'
            ..entryId = 'entry-${i % 200}'
            ..eventKey = 'event-${i % 200}'
            ..animalId = uuid
            ..kind = 'health'
            ..performedAt = _epoch.add(Duration(days: day))
            ..createdAt = _epoch.add(Duration(days: day))
            ..updatedAt = _epoch.add(Duration(days: day)),
        );
      }
      for (var j = 0; j < shape.milkingPerAnimal; j++) {
        entries.add(
          IsarMilkingEntry()
            ..uuid = '$uuid-me$j'
            ..sessionUuid = 'bench-session-${i % 400}-$j'
            ..animalUuid = uuid
            ..volumeMilliliters = 9000 + j * 500
            ..createdAt = _epoch.add(Duration(days: day))
            ..updatedAt = _epoch.add(Duration(days: day)),
        );
      }
    }

    // Sessions are shared across animals, so build them from the key space the
    // entries above referenced rather than one per animal.
    final sessions = <IsarMilkingSession>[];
    var sessionDay = 0;
    for (final sessionUuid in entries.map((e) => e.sessionUuid).toSet()) {
      sessionDay = (sessionDay + 1) % 700;
      sessions.add(
        IsarMilkingSession()
          ..uuid = sessionUuid
          ..occurredAt = _epoch.add(Duration(days: sessionDay))
          ..shift = 'morning'
          ..status = 'completed'
          ..createdAt = _epoch
          ..updatedAt = _epoch.add(Duration(days: sessionDay)),
      );
    }

    await isar.writeTxn(() async {
      await isar.isarAnimals.putAll(animals);
      await isar.isarHealthRecords.putAll(health);
      await isar.isarWeightRecords.putAll(weights);
      await isar.isarReproductionRecords.putAll(reproductions);
      await isar.isarMovementRecords.putAll(movements);
      await isar.isarProductionRecords.putAll(productions);
      await isar.isarCommercialRecords.putAll(commercials);
      await isar.isarCostRecords.putAll(costs);
      await isar.isarCareRecords.putAll(cares);
      await isar.isarAgendaRegistrations.putAll(agendas);
      await isar.isarMilkingSessions.putAll(sessions);
      await isar.isarMilkingEntrys.putAll(entries);
    });

    sw.stop();
    stdout.writeln(
      'Seeded ${animals.length} animals + ${shape.totalChildRecords} child '
      'records in ${sw.elapsedMilliseconds} ms',
    );
  }

  IsarAnimal _animal(int i, String uuid) {
    return IsarAnimal()
      ..uuid = uuid
      ..earTagNumber = 'A${(shape.animals - i).toString().padLeft(5, '0')}'
      ..species = 'cattle'
      ..category = i.isEven ? 'cow' : 'steer'
      ..lifeStage = i.isEven ? 'cow' : 'steer'
      ..sex = i.isEven ? 'female' : 'male'
      ..breed = 'Brahman'
      ..birthDate = _epoch.subtract(Duration(days: 400 + (i % 2200)))
      ..ageMonths = 24 + (i % 80)
      ..weight = 300.0 + (i % 250)
      // A tenth of the herd has left, so the active-only filters have
      // something to actually filter out.
      ..status = i % 10 == 0 ? 'sold' : 'active'
      ..healthStatus = i % 17 == 0 ? 'poor' : 'good'
      ..vaccinated = true
      ..dewormed = true
      ..hasVitamins = false
      ..hasChronicIssues = false
      ..reproductiveStatus = 'active'
      ..currentLocationId = 'potrero-${i % 30}'
      ..underObservation = i % 23 == 0
      ..requiresAttention = i % 19 == 0
      ..riskLevel = i % 31 == 0 ? 'high' : 'low'
      ..synced = true
      ..creationDate = _epoch.subtract(Duration(days: i % 900))
      ..lastUpdateDate = _epoch.add(Duration(days: i % 700));
  }
}
