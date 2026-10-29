import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:libretapp/core/database/isar_write_transaction.dart';
import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/core/persistence/isar_feature_record_store.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/health_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/movement_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/isar_backup_store.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/maintenance/data_maintenance.dart';
import 'package:libretapp/core/maintenance/isar_data_maintenance.dart';
import 'package:libretapp/core/services/backup_service.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/agenda/infrastructure/isar_agenda_repository.dart';
import 'package:libretapp/features/agenda/infrastructure/isar_workforce_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_dto.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_remote_data_source.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/weight_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_weight_record.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository_isar.dart';
import 'package:libretapp/features/finanzas/infrastructure/isar/isar_income_record.dart';
import 'package:libretapp/features/finanzas/infrastructure/isar_finanzas_repository.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';
import 'package:libretapp/features/milking/infrastructure/milking_repository_isar.dart';
import 'package:libretapp/features/perfil/data/perfil_isar_repository.dart';
import 'package:libretapp/features/rfid/domain/rfid_models.dart';
import 'package:libretapp/features/rfid/infrastructure/rfid_repository_isar.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/infrastructure/cultivation_repository_isar.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import '../features/directorio/animales/advisor/rules/rule_test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory root;
  late IsarDatabase database;
  late SharedPrefsService prefs;
  late PerfilIsarRepository profile;
  late AnimalRepositoryIsar animals;
  late IsarBackupStore store;
  late BackupService backup;
  late IsarDataMaintenance maintenance;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('libret_native_recovery_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => root.path);
    SharedPreferences.setMockInitialValues({
      'perfil_v1':
          '{"nombre":"Original","region_state":"sonora","production_setting":"rangeland"}',
    });
    prefs = SharedPrefsService(await SharedPreferences.getInstance());
    database = IsarDatabase.workspace(root.path, name: 'regression');
    await database.initialize();
    profile = PerfilIsarRepository(database, prefs);
    await profile.migrate();
    animals = AnimalRepositoryIsar(database, prefs, AnimalApiMock());
    await animals.save(buildAnimal(uuid: 'a').copyWith(earTagNumber: 'A'));
    await animals.save(buildAnimal(uuid: 'b').copyWith(earTagNumber: 'B'));
    store = IsarBackupStore(database: database, perfilRepository: profile);
    backup = BackupService(
      animalRepository: animals,
      lotesRepository: LotesRepositoryIsar(database),
      agendaRepository: IsarAgendaRepository(database, prefs),
      workforceRepository: IsarWorkforceRepository(database),
      milkingRepository: MilkingRepositoryIsar(database),
      backupStore: store,
      statusPrefs: prefs,
      storageDirectory: () async => root,
    );
    maintenance = IsarDataMaintenance(
      database: database,
      store: store,
      backup: backup,
      directory: () async => root,
    );
  });
  tearDown(() async {
    await database.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await root.delete(recursive: true);
  });

  test(
    'lot economics reject every non-finite field without changing stored data',
    () async {
      final lots = LotesRepositoryIsar(database);
      final original = await lots.createLote(
        nombre: 'Valid lot',
        feedPricePerKg: 12,
        dailyFeedKgPerHead: 2,
        liveWeightPricePerKg: 40,
      );
      for (final invalid in [
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        for (final values in [
          [invalid, 2.0, 40.0],
          [12.0, invalid, 40.0],
          [12.0, 2.0, invalid],
        ]) {
          await expectLater(
            lots.createLote(
              nombre: 'Invalid',
              feedPricePerKg: values[0],
              dailyFeedKgPerHead: values[1],
              liveWeightPricePerKg: values[2],
            ),
            throwsArgumentError,
          );
          final draft = original.copyWith(
            feedPricePerKg: values[0],
            dailyFeedKgPerHead: values[1],
            liveWeightPricePerKg: values[2],
          );
          await expectLater(lots.upsert(draft), throwsArgumentError);
          await expectLater(lots.updateLote(draft), throwsArgumentError);
        }
      }
      expect(await lots.getAll(), [original]);
    },
  );

  test('scan coordinates reject non-finite values before any write', () async {
    final scans = RfidRepositoryIsar(database);
    for (final invalid in [
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      for (final coords in [
        [invalid, 10.0, 1.0],
        [20.0, invalid, 1.0],
        [20.0, 10.0, invalid],
      ]) {
        await expectLater(
          scans.saveScanSession(
            RfidScanSession(
              uuid: 'invalid-scan',
              startedAt: DateTime(2026),
              deviceId: 'qa',
              source: RfidBindingSource.reader,
              tagCount: 1,
              uniqueTagCount: 1,
              latitude: coords[0],
              longitude: coords[1],
              accuracyMeters: coords[2],
            ),
          ),
          throwsArgumentError,
        );
      }
    }
    expect(await scans.listScanSessions(), isEmpty);
  });

  test('cultivation area and embedded harvest numbers are validated before writing', () async {
    final crops=CultivationRepositoryIsar(database);
    final crop=CultivationEntity(uuid:'finite-crop',name:'QA crop',plantingDate:DateTime(2026),areaSquareMeters:10);
    await crops.upsert(crop);
    for(final invalid in [double.nan,double.infinity,double.negativeInfinity]) {
      await expectLater(crops.upsert(crop.copyWith(areaSquareMeters:invalid)),throwsArgumentError);
      await expectLater(crops.addHarvest(crop.uuid,HarvestRecord(uuid:'invalid-harvest',date:DateTime(2026),yieldKg:invalid)),throwsArgumentError);
    }
    final stored=(await crops.getByUuid(crop.uuid))!;
    expect(stored.areaSquareMeters,10);
    expect(stored.harvests,isEmpty);
  });

  test(
    'profile migration retains source and never overwrites later edits',
    () async {
      expect((await profile.fetchPerfil()).nombre, 'Original');
      final old = await profile.fetchPerfil();
      await profile.savePerfil(old.copyWith(nombre: 'Editado'));
      await prefs.setString('perfil_v1', '{"nombre":"Antiguo"}');
      await profile.migrate();
      expect((await profile.fetchPerfil()).nombre, 'Editado');
      expect(prefs.getString('perfil_v1'), isNotNull);
    },
  );

  test(
    'batch failure rolls back first weight and projection, retry is idempotent',
    () async {
      final weights = WeightRecordRepositoryIsar(database);
      WeightBatchEntry entry(String animal, double weight, String uuid) =>
          WeightBatchEntry(
            animalUuid: animal,
            record: WeightRecord(
              date: DateTime(2026, 10, 1),
              weight: weight,
              method: WeightMethod.scale,
              recordUuid: uuid,
            ),
          );
      final before = (await animals.getByUuid('a'))!.weight;
      await expectLater(
        weights.addWeightRecordsAtomically([
          entry('a', 150, 'wa'),
          entry('missing', 170, 'wb'),
        ]),
        throwsStateError,
      );
      expect(await database.isar.isarWeightRecords.count(), 0);
      expect((await animals.getByUuid('a'))!.weight, before);
      final entries = [entry('a', 150, 'wa'), entry('b', 170, 'wb')];
      final saved = await weights.addWeightRecordsAtomically(entries);
      final retry = await weights.addWeightRecordsAtomically(entries);
      expect(retry.map((e) => e.id), saved.map((e) => e.id));
      expect(await database.isar.isarWeightRecords.count(), 2);
      await expectLater(
        weights.addWeightRecordsAtomically([entry('a', 200, 'wa')]),
        throwsArgumentError,
      );
      expect((await weights.getWeightRecords('a')).single.weight, 150);
    },
  );

  test(
    'failed replace after writes rolls back profile and every collection',
    () async {
      final snapshot = await store.capture();
      final rows =
          jsonDecode(jsonEncode(snapshot.collections)) as Map<String, dynamic>;
      rows['weightRecords'] = [
        {
          'id': 1,
          'recordUuid': 'bad',
          'animalUuid': 'a',
          'weight': 100,
          'date': 'wrong',
          'method': 'scale',
        },
      ];
      final invalid = BackupEnvelope(
        schemaVersion: 11,
        appVersion: '0.1.3+6',
        exportedAt: DateTime.now(),
        profile: {'nombre': 'No debe guardarse'},
        collections: rows.map(
          (key, value) => MapEntry(
            key,
            (value as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList(),
          ),
        ),
      );
      await expectLater(
        store.restore(invalid, mode: BackupImportMode.replaceAll),
        throwsA(anything),
      );
      expect((await profile.fetchPerfil()).nombre, 'Original');
      expect((await animals.getAll()).map((a) => a.uuid).toSet(), {'a', 'b'});
      expect(await database.isar.isarWeightRecords.count(), 0);
    },
  );

  test(
    'legacy replace is atomic, clears old records and preserves profile',
    () async {
      await WeightRecordRepositoryIsar(database).addWeightRecord(
        'a',
        WeightRecord(
          date: DateTime(2026, 10, 1),
          weight: 120,
          method: WeightMethod.scale,
        ),
      );
      final incoming = buildAnimal(uuid: 'c').copyWith(earTagNumber: 'C');
      final json = jsonEncode({
        'schemaVersion': 3,
        'appVersion': '0.1.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'data': {
          'animals': [AnimalDto.fromEntity(incoming).toJson()],
          'lotes': [],
        },
      });
      await backup.importFromJsonString(
        json,
        mode: BackupImportMode.replaceAll,
      );
      expect((await animals.getAll()).single.uuid, 'c');
      expect(await database.isar.isarWeightRecords.count(), 0);
      expect((await profile.fetchPerfil()).nombre, 'Original');
    },
  );

  test(
    'cleanup is readonly until selected, stale review fails, native copy restores NaN',
    () async {
      final invalid = IsarIncomeRecord()
        ..recordUuid = 'invalid'
        ..date = DateTime(2026)
        ..type = 'other'
        ..amount = double.nan;
      await database.isar.writeTxn(
        () => database.isar.isarIncomeRecords.put(invalid),
      );
      final review = await maintenance.scan();
      final issue = review.issues.singleWhere(
        (i) => i.kind == MaintenanceIssueKind.invalidNumber,
      );
      expect(
        (await database.isar.isarIncomeRecords.get(invalid.id))!.amount.isNaN,
        true,
      );
      expect(await maintenance.snapshots(), isEmpty);
      final id = await maintenance.apply(review, [
        MaintenanceChange(issue.id, number: 55),
      ]);
      expect(
        (await database.isar.isarIncomeRecords.get(invalid.id))!.amount,
        55,
      );
      expect(await maintenance.exportSnapshot(id), isNotEmpty);
      await expectLater(
        maintenance.apply(review, [MaintenanceChange(issue.id, number: 80)]),
        throwsStateError,
      );
      await maintenance.restoreSnapshot(
        id,
        reopen: (action) async {
          await database.close();
          await action();
          await database.initialize();
        },
      );
      expect(
        (await database.isar.isarIncomeRecords.get(invalid.id))!.amount.isNaN,
        true,
      );
      expect((await profile.fetchPerfil()).nombre, 'Original');
    },
  );

  test(
    'invalid second cleanup selection rolls back first correction',
    () async {
      final rows = [
        for (final id in ['n1', 'n2'])
          IsarIncomeRecord()
            ..recordUuid = id
            ..date = DateTime(2026)
            ..type = 'other'
            ..amount = double.nan,
      ];
      await database.isar.writeTxn(
        () => database.isar.isarIncomeRecords.putAll(rows),
      );
      final review = await maintenance.scan();
      final issues = review.issues
          .where((i) => i.kind == MaintenanceIssueKind.invalidNumber)
          .toList();
      await expectLater(
        maintenance.apply(review, [
          MaintenanceChange(issues[0].id, number: 50),
          MaintenanceChange(issues[1].id, number: double.infinity),
        ]),
        throwsArgumentError,
      );
      expect(
        (await database.isar.isarIncomeRecords.where().findAll()).every(
          (e) => e.amount.isNaN,
        ),
        true,
      );
      expect(await maintenance.snapshots(), hasLength(1));
    },
  );

  test(
    'income edit keeps identity and merge preserves newer local corrections',
    () async {
      final repo = IsarFinanzasRepository(database);
      final first = await repo.addIncome(
        IncomeRecord(
          date: DateTime(2026, 10, 1),
          type: IncomeType.other,
          amount: 50,
        ),
      );
      final old = await store.capture();
      final corrected = await repo.updateIncome(first.copyWith(amount: 75));
      expect(corrected.id, first.id);
      expect(corrected.recordUuid, first.recordUuid);
      await store.restore(old, mode: BackupImportMode.merge);
      expect((await repo.getAllIncomes()).single.amount, 75);
    },
  );

  test(
    'media hash, path and profile failures retain all previous data and files',
    () async {
      final photo = File('${root.path}/original.jpg');
      await photo.writeAsBytes([1, 2, 3, 4], flush: true);
      await animals.update(
        (await animals.getByUuid('a'))!.copyWith(profilePhoto: photo.path),
      );
      final valid = await backup.createArchiveBytes();
      Uint8List corrupt({
        bool hash = false,
        bool path = false,
        bool profile = false,
        bool future = false,
      }) {
        final original = ZipDecoder().decodeBytes(valid);
        final archive = Archive();
        for (final file in original.files) {
          var bytes = List<int>.from(file.content as List);
          if (file.name == 'manifest.json') {
            final manifest =
                jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
            if (profile) manifest['profile']['nombre'] = 42;
            if (future) manifest['schemaVersion'] = 99;
            if (path)
              (manifest['collections']['animals'] as List)
                      .first['profilePhoto'] =
                  'media://../escape.jpg';
            bytes = utf8.encode(jsonEncode(manifest));
          } else if (hash) {
            bytes = [9, 9, 9];
          }
          archive.addFile(ArchiveFile(file.name, bytes.length, bytes));
        }
        return Uint8List.fromList(ZipEncoder().encode(archive)!);
      }

      for (final invalid in [
        corrupt(hash: true),
        corrupt(path: true),
        corrupt(profile: true),
        corrupt(future: true),
      ]) {
        await expectLater(
          backup.importArchiveBytes(invalid, mode: BackupImportMode.replaceAll),
          throwsA(anything),
        );
        expect((await animals.getByUuid('a'))!.profilePhoto, photo.path);
        expect(await photo.readAsBytes(), [1, 2, 3, 4]);
        expect((await profile.fetchPerfil()).nombre, 'Original');
        expect(await animals.getAll(), hasLength(2));
      }
      final media = Directory('${root.path}/backup_media');
      if (await media.exists()) expect(await media.list().toList(), isEmpty);
      await backup.importArchiveBytes(valid, mode: BackupImportMode.replaceAll);
      final firstPath = (await animals.getByUuid('a'))!.profilePhoto!;
      await backup.importArchiveBytes(valid, mode: BackupImportMode.replaceAll);
      final secondPath = (await animals.getByUuid('a'))!.profilePhoto!;
      expect(firstPath, isNot(secondPath));
      expect(await File(firstPath).readAsBytes(), [1, 2, 3, 4]);
      expect(await File(secondPath).readAsBytes(), [1, 2, 3, 4]);
      expect(await photo.readAsBytes(), [1, 2, 3, 4]);
    },
  );

  test(
    'legacy merge validates resulting normalized identities inside the transaction',
    () async {
      final incoming = buildAnimal(uuid: 'c').copyWith(earTagNumber: ' a ');
      final source = jsonEncode({
        'schemaVersion': 3,
        'appVersion': '0.1.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'data': {
          'animals': [AnimalDto.fromEntity(incoming).toJson()],
          'lotes': [],
        },
      });
      await expectLater(
        backup.importFromJsonString(source, mode: BackupImportMode.merge),
        throwsA(isA<FormatException>()),
      );
      expect((await animals.getAll()).map((a) => a.uuid).toSet(), {'a', 'b'});
    },
  );

  test(
    'old omitted profile fields and missing profile remain intact',
    () async {
      final snapshot = await store.capture();
      BackupEnvelope withProfile(Map<String, dynamic> value) => BackupEnvelope(
        schemaVersion: 10,
        appVersion: '0.1.2+5',
        exportedAt: snapshot.exportedAt,
        collections: snapshot.collections,
        profile: value,
      );
      await store.restore(
        withProfile({'nombre': 'Antiguo'}),
        mode: BackupImportMode.replaceAll,
      );
      expect((await profile.fetchPerfil()).regionState, 'sonora');
      expect((await profile.fetchPerfil()).productionSetting, 'rangeland');
      await store.restore(withProfile({}), mode: BackupImportMode.replaceAll);
      expect((await profile.fetchPerfil()).nombre, 'Antiguo');
    },
  );

  test(
    'manual preventive health survives unrelated recalculation and deletion',
    () async {
      final current = (await animals.getByUuid('a'))!;
      await animals.update(
        current.copyWith(vaccinated: true, dewormed: true, hasVitamins: true),
      );
      final health = HealthRecordRepositoryIsar(database);
      final vaccine = await health.addHealthRecord(
        'a',
        HealthRecord(
          date: DateTime(2026, 10, 1),
          type: HealthRecordType.vaccine,
          product: 'Manual plus record',
        ),
      );
      await health.deleteHealthRecord(vaccine.id!);
      await WeightRecordRepositoryIsar(database).addWeightRecord(
        'a',
        WeightRecord(
          date: DateTime(2026, 10, 1),
          weight: 180,
          method: WeightMethod.scale,
        ),
      );
      final result = (await animals.getByUuid('a'))!;
      expect(result.vaccinated, true);
      expect(result.dewormed, true);
      expect(result.hasVitamins, true);
      final withoutManualVaccine = (await animals.getByUuid('b'))!;
      await animals.update(
        withoutManualVaccine.copyWith(
          vaccinated: false,
          manualVaccinated: false,
        ),
      );
      final derived = await health.addHealthRecord(
        'b',
        HealthRecord(
          date: DateTime(2026, 10, 1),
          type: HealthRecordType.vaccine,
          product: 'Derived only',
        ),
      );
      await health.deleteHealthRecord(derived.id!);
      expect((await animals.getByUuid('b'))!.vaccinated, false);
    },
  );

  test('unknown old health flags are retained until explicit review', () async {
    final old = await database.isar.isarAnimals
        .where()
        .uuidEqualTo('a')
        .findFirst();
    old!
      ..manualVaccinated = null
      ..manualDewormed = null
      ..manualHasVitamins = null
      ..vaccinated = true
      ..dewormed = true
      ..hasVitamins = true;
    await database.isar.writeTxn(() => database.isar.isarAnimals.put(old));
    await WeightRecordRepositoryIsar(database).addWeightRecord(
      'a',
      WeightRecord(
        date: DateTime(2026, 10, 1),
        weight: 150,
        method: WeightMethod.scale,
      ),
    );
    expect((await animals.getByUuid('a'))!.vaccinated, true);
    final review = await maintenance.scan();
    final issue = review.issues.singleWhere(
      (i) => i.kind == MaintenanceIssueKind.monitoring,
    );
    await maintenance.apply(review, [
      MaintenanceChange(
        issue.id,
        manualObservation: false,
        manualAttention: false,
        manualVaccinated: false,
        manualDewormed: false,
        manualHasVitamins: false,
      ),
    ]);
    final result = (await animals.getByUuid('a'))!;
    expect(result.vaccinated, false);
    expect(result.dewormed, false);
    expect(result.hasVitamins, false);
  });

  test(
    'linked duplicate records cannot be selected for bulk deletion',
    () async {
      final weights = WeightRecordRepositoryIsar(database);
      for (final uuid in ['w1', 'w2']) {
        await weights.addWeightRecord(
          'a',
          WeightRecord(
            date: DateTime(2026, 10, 1),
            weight: 150,
            method: WeightMethod.scale,
            recordUuid: uuid,
          ),
        );
        await IsarFeatureRecordStore(database).put(
          FeatureRecord(
            uuid: 'ref-$uuid',
            farmId: 'farm',
            kind: 'audit',
            payload: {'weightRecordUuid': uuid},
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );
      }
      final review = await maintenance.scan();
      final duplicate = review.issues.singleWhere(
        (i) => i.kind == MaintenanceIssueKind.duplicate,
      );
      expect(duplicate.canDelete, false);
      await expectLater(
        maintenance.apply(review, [
          MaintenanceChange(duplicate.id, delete: true),
        ]),
        throwsStateError,
      );
      expect(await weights.getWeightRecords('a'), hasLength(2));
    },
  );

  test(
    'shared write scope rolls back animal, movement and batch projections together',
    () async {
      final runner = IsarWriteTransactionRunner(database);
      final movements = MovementRecordRepositoryIsar(database);
      final weights = WeightRecordRepositoryIsar(database);
      await expectLater(
        runner.run(() async {
          await animals.save(
            buildAnimal(uuid: 'c').copyWith(earTagNumber: 'C'),
          );
          await movements.addMovementRecord(
            'a',
            MovementRecord(
              date: DateTime(2026, 10, 1),
              toLocation: 'B',
              reason: MovementReason.relocation,
            ),
          );
          await weights.addWeightRecordsAtomically([
            WeightBatchEntry(
              animalUuid: 'b',
              record: WeightRecord(
                date: DateTime(2026, 10, 1),
                weight: 140,
                method: WeightMethod.scale,
                recordUuid: 'wb',
              ),
            ),
            WeightBatchEntry(
              animalUuid: 'missing',
              record: WeightRecord(
                date: DateTime(2026, 10, 1),
                weight: 150,
                method: WeightMethod.scale,
                recordUuid: 'wc',
              ),
            ),
          ]);
        }),
        throwsStateError,
      );
      expect(await animals.getByUuid('c'), isNull);
      expect(await movements.getMovementRecords('a'), isEmpty);
      expect(await weights.getWeightRecords('b'), isEmpty);
    },
  );
}
