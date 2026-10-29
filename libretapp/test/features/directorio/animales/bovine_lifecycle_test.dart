import 'package:shared_preferences/shared_preferences.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/perfil/data/perfil_isar_repository.dart';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/isar_backup_store.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_indicator_snapshot.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/health_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_weaning_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/reproduction_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/weaning_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/weight_record_repository_isar.dart';
import 'advisor/rules/rule_test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory directory;
  late IsarDatabase database;
  late Isar isar;
  late ReproductionRecordRepositoryIsar reproduction;
  late WeaningRecordRepositoryIsar weaning;
  late WeightRecordRepositoryIsar weights;
  late IsarBackupStore backup;
  final birth = DateTime(2024, 1, 1);
  final weanDate = DateTime(2024, 7, 1);

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('libret_bovine_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => directory.path);
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    database = IsarDatabase();
    isar = await database.initialize();
    await database.clearAllCollections();
    reproduction = ReproductionRecordRepositoryIsar(database);
    weaning = WeaningRecordRepositoryIsar(database);
    weights = WeightRecordRepositoryIsar(database);
    backup = IsarBackupStore(
      database: database,
      perfilRepository: PerfilIsarRepository(
        database,
        SharedPrefsService(await SharedPreferences.getInstance()),
      ),
    );
    await isar.writeTxn(() async {
      for (final entity in [
        buildAnimal(uuid: 'dam', sex: Sex.female),
        buildAnimal(uuid: 'sire', category: Category.bull),
        buildAnimal(uuid: 'other-sire', category: Category.bull),
        buildAnimal(
          uuid: 'calf',
          category: Category.calf,
          lifeStage: LifeStage.calf,
          ageMonths: 6,
          weight: null,
        ),
      ]) {
        final animal = entity.copyWith(earTagNumber: entity.uuid).toIsar();
        if (animal.uuid == 'calf') animal.birthDate = birth;
        await isar.isarAnimals.put(animal);
      }
    });
  });
  tearDown(() => database.close());
  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await directory.delete(recursive: true);
  });

  Future<IsarAnimal> animal(String uuid) async =>
      (await isar.isarAnimals.where().uuidEqualTo(uuid).findFirst())!;
  Future<ReproductionRecord> standalone() => reproduction.addReproductionRecord(
    'dam',
    ReproductionRecord(
      kind: ReproductionRecordKind.calving,
      actualCalvingDate: birth,
      calvingOutcome: CalvingOutcome.liveBirth,
      maleSireUuid: 'sire',
    ),
  );

  test(
    'standalone calving, deferred calf, weaning, measured gain and backup restore',
    () async {
      final calving = await standalone();
      expect(calving.serviceDate, isNull);
      expect(calving.serviceType, isNull);
      expect(calving.offspringUuids, isEmpty);
      await reproduction.linkOffspring('dam', calving.id!, 'calf');
      await reproduction.linkOffspring('dam', calving.id!, 'calf');
      final linked = (await reproduction.getReproductionRecords('dam')).single;
      expect(linked.offspringUuids, ['calf']);
      expect((await animal('calf')).damUuid, 'dam');
      expect((await animal('calf')).sireUuid, 'sire');
      expect((await animal('calf')).birthDatePrecision, 'exact');
      final sireKpi = const ReproductiveKpiService().forSire(
        records: await reproduction.getRecordsBySire('sire'),
      );
      expect(sireKpi.serviceCount, 0);
      expect(sireKpi.offspringCount, 1);
      final first = await weaning.save(
        WeaningRecord(
          animalUuid: 'calf',
          date: weanDate,
          weightKg: 180,
          performedBy: 'Ana',
        ),
      );
      final changed = await weaning.updateRecord(
        'calf',
        WeaningRecord(
          id: first.id,
          recordUuid: first.recordUuid,
          animalUuid: 'calf',
          date: weanDate,
          weightKg: 200,
        ),
      );
      expect(await weights.getWeightRecords('calf'), hasLength(1));
      expect(changed.weightRecordUuid, first.weightRecordUuid);
      await weights.addWeightRecord(
        'calf',
        WeightRecord(
          date: weanDate.add(const Duration(days: 30)),
          weight: 230,
          method: WeightMethod.scale,
        ),
      );
      final snapshot = buildAnimalIndicatorSnapshot(
        animal: (await animal('calf')).toEntity(),
        weights: await weights.getWeightRecords('calf'),
      );
      expect(snapshot.averageDailyGainKg, 1);
      final archive = await backup.capture();
      expect(archive.schemaVersion, 11);
      await database.clearAllCollections();
      await backup.restore(archive, mode: BackupImportMode.replaceAll);
      expect(
        (await weaning.getWeaningRecords('calf')).single.weightRecordUuid,
        first.weightRecordUuid,
      );
      expect(
        (await reproduction.getReproductionRecords(
          'dam',
        )).single.offspringUuids,
        ['calf'],
      );
      expect((await animal('calf')).sireUuid, 'sire');
      expect(await weights.getWeightRecords('calf'), hasLength(2));
      await backup.restore(archive, mode: BackupImportMode.merge);
      expect(await weaning.getWeaningRecords('calf'), hasLength(1));
      expect(await weights.getWeightRecords('calf'), hasLength(2));
    },
  );

  test(
    'weaning deletion and undo restore category, linked weight and identity',
    () async {
      final first = await weaning.save(
        WeaningRecord(animalUuid: 'calf', date: weanDate, weightKg: 190),
      );
      expect((await animal('calf')).category, 'weaned');
      await weaning.deleteWeaningRecord(first.id!);
      expect((await animal('calf')).weight, isNull);
      expect((await animal('calf')).category, 'calf');
      expect(await weights.getWeightRecords('calf'), isEmpty);
      final restored = await weaning.save(first);
      expect(restored.recordUuid, first.recordUuid);
      expect(restored.weightRecordUuid, first.weightRecordUuid);
      expect(await weights.getWeightRecords('calf'), hasLength(1));
      expect((await animal('calf')).weight, 190);
    },
  );

  test(
    'removing optional weaning weight does not duplicate or leave stale weight',
    () async {
      final first = await weaning.save(
        WeaningRecord(animalUuid: 'calf', date: weanDate, weightKg: 190),
      );
      await weaning.updateRecord(
        'calf',
        WeaningRecord(id: first.id, animalUuid: 'calf', date: weanDate),
      );
      expect(await weights.getWeightRecords('calf'), isEmpty);
      expect((await animal('calf')).weight, isNull);
      expect(await weaning.getWeaningRecords('calf'), hasLength(1));
    },
  );

  test(
    'direct correction, deletion and undo of linked weighing remain consistent',
    () async {
      await weaning.save(
        WeaningRecord(animalUuid: 'calf', date: weanDate, weightKg: 190),
      );
      final weight = (await weights.getWeightRecords('calf')).single;
      final edited = await weights.updateRecord(
        'calf',
        weight.copyWith(weight: 205),
      );
      expect((await weaning.getWeaningRecords('calf')).single.weightKg, 205);
      await weights.deleteWeightRecord(edited.id!);
      expect((await weaning.getWeaningRecords('calf')).single.weightKg, isNull);
      await weights.addWeightRecord('calf', edited);
      expect((await weaning.getWeaningRecords('calf')).single.weightKg, 205);
    },
  );

  test(
    'last ordinary weighing removed clears projection and undo restores it',
    () async {
      final weight = await weights.addWeightRecord(
        'calf',
        WeightRecord(date: weanDate, weight: 200, method: WeightMethod.scale),
      );
      await weights.deleteWeightRecord(weight.id!);
      expect((await animal('calf')).weight, isNull);
      await weights.addWeightRecord('calf', weight);
      expect((await animal('calf')).weight, 200);
    },
  );

  test(
    'sire and calving correction update linked calf and both bull projections',
    () async {
      var cycle = await reproduction.addReproductionRecord(
        'dam',
        ReproductionRecord(
          serviceDate: DateTime(2023, 3, 1),
          serviceType: ServiceType.naturalService,
          maleSireUuid: 'sire',
          actualCalvingDate: birth,
          calvingOutcome: CalvingOutcome.liveBirth,
        ),
      );
      await reproduction.linkOffspring('dam', cycle.id!, 'calf');
      cycle = (await reproduction.getReproductionRecords('dam')).single;
      final edited = await reproduction.updateRecord(
        'dam',
        cycle.copyWith(
          maleSireUuid: 'other-sire',
          actualCalvingDate: birth.add(const Duration(days: 1)),
        ),
      );
      expect((await animal('sire')).lastServiceDate, isNull);
      expect((await animal('other-sire')).lastServiceDate, cycle.serviceDate);
      expect((await animal('calf')).sireUuid, 'other-sire');
      expect((await animal('calf')).birthDate, edited.actualCalvingDate);
      await reproduction.deleteReproductionRecord(edited.id!);
      expect((await animal('other-sire')).lastServiceDate, isNull);
      await reproduction.addReproductionRecord('dam', edited);
      expect((await animal('other-sire')).lastServiceDate, cycle.serviceDate);
    },
  );

  test(
    'latest negative or uncertain diagnosis supersedes old pregnancy',
    () async {
      await reproduction.addReproductionRecord(
        'dam',
        ReproductionRecord(
          serviceDate: DateTime(2023, 1, 1),
          serviceType: ServiceType.naturalService,
          pregnancyResult: PregnancyCheckResult.positive,
          expectedCalvingDate: birth,
        ),
      );
      final latest = await reproduction.addReproductionRecord(
        'dam',
        ReproductionRecord(
          serviceDate: DateTime(2024, 2, 1),
          serviceType: ServiceType.naturalService,
          pregnancyResult: PregnancyCheckResult.negative,
        ),
      );
      expect(
        ReproductiveKpiService.openCycleOf(
          await reproduction.getReproductionRecords('dam'),
        ),
        isNull,
      );
      expect(
        await reproduction.getUpcomingCalvings(DateTime(2023), DateTime(2025)),
        isEmpty,
      );
      await reproduction.updateRecord(
        'dam',
        latest.copyWith(pregnancyResult: PregnancyCheckResult.uncertain),
      );
      expect(
        ReproductiveKpiService.openCycleOf(
          await reproduction.getReproductionRecords('dam'),
        ),
        isNull,
      );
      expect(
        ReproductiveKpiService.pendingDiagnosisOf(
          await reproduction.getReproductionRecords('dam'),
        )!.id,
        latest.id,
      );
    },
  );

  test(
    'incompatible dates, duplicate weaning and incompatible offspring leave records intact',
    () async {
      final calving = await standalone();
      final calf = await animal('calf');
      await isar.writeTxn(() async {
        calf.birthDatePrecision = 'exact';
        calf.birthDate = birth.add(const Duration(days: 1));
        await isar.isarAnimals.put(calf);
      });
      await expectLater(
        reproduction.linkOffspring('dam', calving.id!, 'calf'),
        throwsArgumentError,
      );
      expect(
        (await reproduction.getReproductionRecords(
          'dam',
        )).single.offspringUuids,
        isEmpty,
      );
      await expectLater(
        weaning.save(WeaningRecord(animalUuid: 'calf', date: birth)),
        throwsArgumentError,
      );
      await weaning.save(WeaningRecord(animalUuid: 'calf', date: weanDate));
      await expectLater(
        weaning.save(WeaningRecord(animalUuid: 'calf', date: weanDate)),
        throwsStateError,
      );
      await expectLater(
        reproduction.addReproductionRecord(
          'dam',
          ReproductionRecord(
            serviceDate: birth,
            serviceType: ServiceType.naturalService,
            actualCalvingDate: birth.subtract(const Duration(days: 1)),
          ),
        ),
        throwsArgumentError,
      );
      expect(await weaning.getWeaningRecords('calf'), hasLength(1));
    },
  );

  test('abortion and stillbirth cannot link a live calf', () async {
    for (final outcome in [
      CalvingOutcome.abortion,
      CalvingOutcome.stillbirth,
    ]) {
      final calving = await reproduction.addReproductionRecord(
        'dam',
        ReproductionRecord(
          kind: ReproductionRecordKind.calving,
          actualCalvingDate: birth,
          calvingOutcome: outcome,
        ),
      );
      await expectLater(
        reproduction.linkOffspring('dam', calving.id!, 'calf'),
        throwsArgumentError,
      );
      expect((await animal('dam')).reproductiveStatus, 'active');
    }
  });

  test(
    'sold animals permit historical corrections and undo but no new weaning',
    () async {
      final event = await weaning.save(
        WeaningRecord(animalUuid: 'calf', date: weanDate),
      );
      final calf = await animal('calf');
      await isar.writeTxn(() async {
        calf.status = 'sold';
        await isar.isarAnimals.put(calf);
      });
      await weaning.updateRecord(
        'calf',
        WeaningRecord(
          id: event.id,
          animalUuid: 'calf',
          date: weanDate,
          weightKg: 180,
        ),
      );
      await weaning.deleteWeaningRecord(event.id!);
      // A persisted sale normally owns the status. Set it to simulate its projection.
      final sold = await animal('calf');
      await isar.writeTxn(() async {
        sold.status = 'sold';
        await isar.isarAnimals.put(sold);
      });
      await expectLater(
        weaning.save(WeaningRecord(animalUuid: 'calf', date: weanDate)),
        throwsStateError,
      );
      await weaning.save(event);
    },
  );

  test(
    'disease or death needs no fictitious product, treatment still requires it',
    () async {
      final health = HealthRecordRepositoryIsar(database);
      await health.addHealthRecord(
        'calf',
        HealthRecord(
          date: weanDate,
          type: HealthRecordType.disease,
          product: '',
        ),
      );
      await expectLater(
        health.addHealthRecord(
          'calf',
          HealthRecord(
            date: weanDate,
            type: HealthRecordType.treatment,
            product: '',
          ),
        ),
        throwsArgumentError,
      );
      final record = await health.addHealthRecord(
        'calf',
        HealthRecord(
          date: weanDate,
          type: HealthRecordType.treatment,
          product: 'Producto',
          medicineBatch: 'L-1',
          withdrawalDays: 7,
          withdrawalEndDate: weanDate.add(const Duration(days: 7)),
        ),
      );
      expect(record.medicineBatch, 'L-1');
      expect(record.withdrawalDays, 7);
    },
  );

  test(
    'schema 9 import defaults birth precision and service kind without changing UUID',
    () async {
      await reproduction.addReproductionRecord(
        'dam',
        ReproductionRecord(
          serviceDate: DateTime(2023, 1, 1),
          serviceType: ServiceType.naturalService,
        ),
      );
      final archive = await backup.capture();
      final collections = Map<String, List<Map<String, dynamic>>>.from(
        archive.collections,
      )..remove('weaningRecords');
      for (final row in collections['animals']!) {
        row.remove('birthDatePrecision');
      }
      for (final row in collections['reproductionRecords']!) {
        row.remove('kind');
      }
      final legacy = BackupEnvelope(
        schemaVersion: 9,
        appVersion: '0.1.1+4',
        exportedAt: archive.exportedAt,
        collections: collections,
        profile: archive.profile,
      );
      await backup.restore(legacy, mode: BackupImportMode.replaceAll);
      final record = (await reproduction.getReproductionRecords('dam')).single;
      expect(record.kind, ReproductionRecordKind.service);
      expect(
        record.recordUuid,
        archive.collections['reproductionRecords']!.single['recordUuid'],
      );
      expect(
        (await animal('calf')).toEntity().birthDatePrecision,
        BirthDatePrecision.unknown,
      );
      expect(await isar.isarWeaningRecords.count(), 0);
    },
  );

  test(
    'weaning cannot overwrite another animal weighing and rolls back',
    () async {
      final foreign = await weights.addWeightRecord(
        'sire',
        WeightRecord(date: weanDate, weight: 600, method: WeightMethod.scale),
      );
      await expectLater(
        weaning.save(
          WeaningRecord(
            animalUuid: 'calf',
            date: weanDate,
            weightKg: 180,
            weightRecordUuid: foreign.recordUuid,
          ),
        ),
        throwsArgumentError,
      );
      expect((await weights.getWeightRecords('sire')).single.weight, 600);
      expect(await weaning.getWeaningRecords('calf'), isEmpty);
      expect(await weights.getWeightRecords('calf'), isEmpty);
      expect((await animal('calf')).category, 'calf');
    },
  );

  test('linking an ancestor as calf cannot create a genealogy cycle', () async {
    final calving = await standalone();
    final dam = await animal('dam');
    await isar.writeTxn(() async {
      dam.damUuid = 'calf';
      await isar.isarAnimals.put(dam);
    });
    await expectLater(
      reproduction.linkOffspring('dam', calving.id!, 'calf'),
      throwsArgumentError,
    );
    expect(
      (await reproduction.getReproductionRecords('dam')).single.offspringUuids,
      isEmpty,
    );
  });

  test(
    'estimated readings and same day readings cannot fabricate daily gain',
    () async {
      final calf = (await animal('calf')).toEntity();
      final measured = WeightRecord(
        date: weanDate,
        weight: 200,
        method: WeightMethod.scale,
      );
      final sameDay = WeightRecord(
        date: weanDate.add(const Duration(hours: 3)),
        weight: 205,
        method: WeightMethod.scale,
      );
      final estimated = WeightRecord(
        date: weanDate.add(const Duration(days: 30)),
        weight: 230,
        method: WeightMethod.estimated,
      );
      expect(
        buildAnimalIndicatorSnapshot(
          animal: calf,
          weights: [measured, sameDay, estimated],
        ).averageDailyGainKg,
        isNull,
      );
      final earlier = WeightRecord(
        date: weanDate.subtract(const Duration(days: 10)),
        weight: 195,
        method: WeightMethod.scale,
      );
      expect(
        buildAnimalIndicatorSnapshot(
          animal: calf,
          weights: [earlier, measured, sameDay, estimated],
        ).averageDailyGainKg,
        1,
      );
      expect(
        buildAnimalIndicatorSnapshot(
          animal: calf,
          weights: [estimated],
        ).lastWeightMethod,
        WeightMethod.estimated,
      );
    },
  );
}
