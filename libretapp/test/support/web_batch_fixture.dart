import 'package:libretapp/core/database/feature_store_transaction_runner.dart';
import 'package:libretapp/core/di/injection_web_repositories.dart';
import 'package:libretapp/core/di/web/farm_record_access.dart';
import 'package:libretapp/core/persistence/drift_feature_record_store.dart';
import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/core/tenancy/tenancy.dart';
import 'package:libretapp/features/registro/lotes/batch_record_service.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';

import '../features/directorio/animales/advisor/rules/rule_test_fixtures.dart';
import 'batch_test_database.dart';

class WebBatchFixture {
  final database = BatchTestDatabase();
  late DriftFeatureRecordStore store;
  late IsarFarmContextRepository context;
  late FarmRecordAccess access;
  late WebAnimalRepository animals;
  late WebLotesRepository lots;
  late WebLocationRepository locations;
  late WebWeightRecordRepository weights;
  late WebHealthRecordRepository health;
  late WebMovementRecordRepository movements;
  late String lotUuid;

  Future<void> open() async {
    store = await database.open();
    context = IsarFarmContextRepository(store);
    await FarmMigrationService(context, store).ensureDefaultFarm();
    access = FarmRecordAccess(store, context);
    animals = WebAnimalRepository(store, context);
    lots = WebLotesRepository(access, animals);
    locations = WebLocationRepository(access);
    weights = WebWeightRecordRepository(access, animals);
    health = WebHealthRecordRepository(access, animals);
    movements = WebMovementRecordRepository(access, animals, locations, lots);
  }

  Future<void> seed() async {
    for (final uuid in ['north', 'south', 'east']) {
      await locations.upsert(
        LocationEntity(
          uuid: uuid,
          name: uuid,
          type: LocationType.pasture,
          surfaceArea: 10,
          capacity: 20,
          waterSource: 'Pozo',
          terrainType: 'Plano',
        ),
      );
    }
    final lot = await lots.createLote(nombre: 'Destete');
    lotUuid = lot.uuid;
    for (final uuid in ['a', 'b']) {
      await animals.save(
        buildAnimal(
          uuid: uuid,
          vaccinated: false,
          dewormed: false,
          hasVitamins: false,
          currentLocationId: 'north',
          weight: 200,
        ).copyWith(earTagNumber: uuid == 'a' ? '0001' : '0002'),
      );
    }
    await lots.addAnimalsToLote(loteUuid: lotUuid, animalUuids: ['a', 'b']);
    await lots.upsert(
      (await lots.getByUuid(lotUuid))!.copyWith(currentLocationId: 'north'),
    );
  }

  BatchRecordService batch({
    FeatureRecordStore? sessionStore,
    HealthRecordRepository? healthRepository,
  }) => BatchRecordService(
    store: sessionStore ?? store,
    transactions: FeatureStoreTransactionRunner(store),
    context: context,
    animals: animals,
    lots: lots,
    health: healthRepository ?? health,
    weights: weights,
    movements: movements,
    locations: locations,
  );

  Future<void> reopen() async {
    await database.close();
    await open();
  }

  Future<void> dispose() => database.dispose();
}
