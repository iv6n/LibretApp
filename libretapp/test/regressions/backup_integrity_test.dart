import 'package:libretapp/features/perfil/data/perfil_isar_repository.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/isar_backup_store.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/backup_service.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/agenda/infrastructure/isar_agenda_repository.dart';
import 'package:libretapp/features/agenda/infrastructure/isar_workforce_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_dto.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_remote_data_source.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_weight_record.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository_isar.dart';
import 'package:libretapp/features/milking/infrastructure/milking_repository_isar.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/directorio/animales/advisor/rules/rule_test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  final stamp = DateTime.now().microsecondsSinceEpoch.toString();
  final root = Directory(
    '${Directory.systemTemp.path}/libret-backup-regression-$stamp',
  );
  late IsarDatabase database;
  late PerfilIsarRepository profiles;
  late IsarBackupStore store;
  late SharedPrefsService prefs;
  var index = 0;

  setUpAll(() async {
    await root.create(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => root.path);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => root.path);
    prefs = SharedPrefsService(await SharedPreferences.getInstance());
    database = IsarDatabase.workspace(
      root.path,
      name: 'audit_${stamp}_${index++}',
    );
    await database.initialize();
    profiles = PerfilIsarRepository(
      database,
      SharedPrefsService(await SharedPreferences.getInstance()),
    );
    await profiles.savePerfil(
      const Perfil(
        id: 'audit-profile',
        nombre: 'Auditoria',
        apellido: '',
        email: '',
        telefono: '',
        finca: 'Finca origen',
        direccion: '',
        regionState: 'sonora',
        productionSetting: 'rangeland',
      ),
    );
    store = IsarBackupStore(database: database, perfilRepository: profiles);
  });

  tearDown(() async => database.close());
  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await root.delete(recursive: true);
  });

  test('replace restores every profile field', () async {
    final envelope = await store.capture();
    expect(envelope.profile['region_state'], 'sonora');
    expect(envelope.profile['production_setting'], 'rangeland');

    await profiles.savePerfil(
      (await profiles.fetchPerfil()).copyWith(
        finca: 'Finca destino',
        regionState: 'jalisco',
        productionSetting: 'irrigated_valley',
      ),
    );
    await store.restore(envelope, mode: BackupImportMode.replaceAll);

    expect((await profiles.fetchPerfil()).finca, 'Finca origen');
    expect((await profiles.fetchPerfil()).regionState, 'sonora');
    expect((await profiles.fetchPerfil()).productionSetting, 'rangeland');
  });

  test(
    'invalid legacy restore preserves original animals and records',
    () async {
      final animals = AnimalRepositoryIsar(database, prefs, AnimalApiMock());
      final oldAnimal = buildAnimal(
        uuid: 'audit-old',
      ).copyWith(earTagNumber: 'LOCAL-OLD');
      await animals.save(oldAnimal);
      await database.isar.writeTxn(() async {
        await database.isar.isarWeightRecords.put(
          IsarWeightRecord()
            ..recordUuid = 'audit-old-weight'
            ..animalUuid = 'audit-old'
            ..date = DateTime.utc(2026, 10, 1)
            ..weight = 300
            ..method = 'scale',
        );
      });
      final service = BackupService(
        animalRepository: animals,
        lotesRepository: LotesRepositoryIsar(database),
        agendaRepository: IsarAgendaRepository(database, prefs),
        workforceRepository: IsarWorkforceRepository(database),
        milkingRepository: MilkingRepositoryIsar(database),
        backupStore: store,
        statusPrefs: prefs,
        storageDirectory: () async => root,
      );
      final first = buildAnimal(
        uuid: 'audit-import-first',
      ).copyWith(earTagNumber: 'DUPLICATE');
      final second = buildAnimal(
        uuid: 'audit-import-second',
      ).copyWith(earTagNumber: 'DUPLICATE');
      final legacy = jsonEncode({
        'schemaVersion': 3,
        'appVersion': '0.1.0',
        'exportedAt': DateTime.utc(2026, 10, 18).toIso8601String(),
        'data': {
          'animals': [
            AnimalDto.fromEntity(first).toJson(),
            AnimalDto.fromEntity(second).toJson(),
          ],
          'lotes': [],
        },
      });

      await expectLater(
        service.importFromJsonString(legacy, mode: BackupImportMode.replaceAll),
        throwsA(isA<FormatException>()),
      );

      final after = await database.isar.isarAnimals.where().findAll();
      expect(after.map((animal) => animal.uuid).toList(), ['audit-old']);
      final weights = await database.isar.isarWeightRecords.where().findAll();
      expect(weights, hasLength(1));
      expect(weights.single.animalUuid, 'audit-old');
      final bytes = await service.createArchiveBytes();
      expect(bytes, isNotEmpty);
    },
  );
}
