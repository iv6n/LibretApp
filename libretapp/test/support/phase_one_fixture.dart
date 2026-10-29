import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/backup/isar_backup_store.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/database/isar_write_transaction.dart';
import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/core/persistence/isar_feature_record_store.dart';
import 'package:libretapp/core/services/herd_import_service.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/tenancy/tenancy.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_remote_data_source.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/health_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/movement_record_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/weight_record_repository_isar.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository_isar.dart';
import 'package:libretapp/features/perfil/data/perfil_isar_repository.dart';
import 'package:libretapp/features/registro/lotes/batch_record_service.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/repositories/isar_location_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/directorio/animales/advisor/rules/rule_test_fixtures.dart';

class OfflineAnimalSource implements AnimalRemoteDataSource {
  @override
  Future<RemoteAnimalPayload> fetchAnimals() =>
      throw StateError('The offline flow must never request the network.');
}

class PhaseOneFixture {
  late Directory directory;
  late IsarDatabase database;
  late SharedPrefsService prefs;
  late AnimalRepositoryIsar animals;
  late LotesRepositoryIsar lots;
  late IsarLocationRepository locations;
  late HealthRecordRepositoryIsar health;
  late WeightRecordRepositoryIsar weights;
  late MovementRecordRepositoryIsar movements;
  late IsarFeatureRecordStore store;
  late IsarFarmContextRepository context;
  late IsarWriteTransactionRunner transactions;
  static const channel = MethodChannel('plugins.flutter.io/path_provider');

  Future<void> initialize() async {
    directory = await Directory.systemTemp.createTemp('libret_phase_one_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => directory.path);
    SharedPreferences.setMockInitialValues({});
    prefs = SharedPrefsService(await SharedPreferences.getInstance());
    database = IsarDatabase.workspace(directory.path, name: 'phase_one');
    await reopen();
    await context.saveFarm(
      const Farm(uuid: 'farm-1', name: 'Rancho de prueba'),
    );
    await context.saveMembership(
      const FarmMembership(
        uuid: 'owner-1',
        farmId: 'farm-1',
        userId: 'local-user',
        role: FarmRole.owner,
      ),
    );
    await context.select('farm-1', 'local-user');
  }

  Future<void> reopen() async {
    await database.initialize();
    animals = AnimalRepositoryIsar(database, prefs, OfflineAnimalSource());
    lots = LotesRepositoryIsar(database);
    locations = IsarLocationRepository(database);
    health = HealthRecordRepositoryIsar(database);
    weights = WeightRecordRepositoryIsar(database);
    movements = MovementRecordRepositoryIsar(database);
    store = IsarFeatureRecordStore(database);
    context = IsarFarmContextRepository(store);
    transactions = IsarWriteTransactionRunner(database);
  }

  HerdImportService importer({AnimalRepository? repository}) =>
      HerdImportService(
        animals: repository ?? animals,
        transactions: transactions,
        context: context,
      );

  BatchRecordService batch({
    HealthRecordRepository? healthRepository,
    FeatureRecordStore? sessionStore,
  }) => BatchRecordService(
    store: sessionStore ?? store,
    transactions: transactions,
    context: context,
    animals: animals,
    lots: lots,
    health: healthRepository ?? health,
    weights: weights,
    movements: movements,
    locations: locations,
  );

  IsarBackupStore get backup => IsarBackupStore(
    database: database,
    perfilRepository: PerfilIsarRepository(database, prefs),
  );

  Future<void> seedLot() async {
    final now = DateTime.now();
    for (final entry in const {'a': '0001', 'b': '0002'}.entries) {
      await animals.save(
        buildAnimal(uuid: entry.key, sex: Sex.female).copyWith(
          earTagNumber: entry.value,
          batchUuid: 'lot-1',
          currentLocationId: 'north',
        ),
      );
    }
    await lots.upsert(
      LoteEntity(
        uuid: 'lot-1',
        name: 'Lote de cría',
        animalUuids: const ['a', 'b'],
        createdAt: now,
        lastUpdateDate: now,
        currentLocationId: 'north',
      ),
    );
    for (final entry in const {
      'north': 'Potrero norte',
      'south': 'Potrero sur',
    }.entries) {
      await locations.upsert(
        LocationEntity(
          uuid: entry.key,
          name: entry.value,
          type: LocationType.pasture,
          surfaceArea: 2,
          capacity: 10,
          waterSource: '',
          terrainType: '',
        ),
      );
    }
  }

  Future<void> dispose() async {
    await database.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    final target = directory.absolute.path;
    final tempRoot = Directory.systemTemp.absolute.path;
    if (!target.startsWith('$tempRoot${Platform.pathSeparator}') ||
        !directory.uri.pathSegments.any(
          (p) => p.startsWith('libret_phase_one_'),
        ))
      throw StateError('Unexpected test directory.');
    await directory.delete(recursive: true);
  }
}
