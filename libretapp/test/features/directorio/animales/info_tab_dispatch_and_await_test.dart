import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/animal_bloc.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/info_tab.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';

void main() {
  late _FakeAnimalRepository animalRepository;
  late _FakeLotesRepository lotesRepository;

  setUp(() {
    animalRepository = _FakeAnimalRepository();
    lotesRepository = _FakeLotesRepository();

    locator.registerSingleton<LocationRepository>(
      _FakeLocationRepository([
        _location('loc-a', 'Potrero A'),
        _location('loc-b', 'Potrero B'),
      ]),
    );
  });

  tearDown(() async {
    await locator.reset();
  });

  testWidgets(
    'changing location does not report success when the update fails',
    (tester) async {
      animalRepository.throwOnUpdate = true;
      final animal = _animal(uuid: 'ani-1', currentLocationId: 'loc-a');

      final bloc = AnimalBloc(
        animalRepository: animalRepository,
        lotesRepository: lotesRepository,
        weightRepo: _FakeWeightRecordRepository(),
        healthRepo: _FakeHealthRecordRepository(),
        productionRepo: _FakeProductionRecordRepository(),
        reproductionRepo: _FakeReproductionRecordRepository(),
        commercialRepo: _FakeCommercialRecordRepository(),
        movementRepo: _FakeMovementRecordRepository(),
        costRepo: _FakeCostRecordRepository(),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: BlocProvider<AnimalBloc>.value(
            value: bloc,
            child: Scaffold(
              body: InfoTab(animal: animal, lotesRepository: lotesRepository),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final changeLocationButton = find.text('Cambiar ubicación');
      await tester.ensureVisible(changeLocationButton);
      await tester.tap(changeLocationButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Potrero A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Potrero B').last);
      await tester.pumpAndSettle();

      final saveButton = find.text('Guardar');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(animalRepository.updateCallCount, 1);
      expect(
        find.text('Ubicación y lote actualizados'),
        findsNothing,
        reason:
            'dispatchAndAwait must reflect the real UpdateAnimal failure '
            'instead of always resolving to success',
      );
      expect(
        find.text('Cambiar ubicación y lote'),
        findsOneWidget,
        reason: 'the sheet should stay open when the save actually failed',
      );
    },
  );
}

LocationEntity _location(String uuid, String name) {
  return LocationEntity(
    uuid: uuid,
    name: name,
    type: LocationType.pasture,
    surfaceArea: 10,
    capacity: 20,
    waterSource: 'Pozo',
    terrainType: 'Plano',
  );
}

AnimalEntity _animal({required String uuid, String? currentLocationId}) {
  final now = DateTime(2025, 1, 1);
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: 'TAG-$uuid',
    customName: 'Animal $uuid',
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: 'Cebu',
    birthDate: DateTime(2020, 1, 1),
    ageMonths: 60,
    healthStatus: HealthStatus.good,
    vaccinated: true,
    dewormed: true,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.undefined,
    productionStage: ProductionStage.unknown,
    productionSystem: ProductionSystem.unknown,
    currentLocationId: currentLocationId,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.low,
    gallery: const [],
    synced: false,
    creationDate: now,
    lastUpdateDate: now,
  );
}

class _FakeLocationRepository implements LocationRepository {
  _FakeLocationRepository(this._locations);
  final List<LocationEntity> _locations;

  @override
  Stream<List<LocationEntity>> watchAll() async* {
    yield _locations;
  }

  @override
  Future<List<LocationEntity>> getAll() async => _locations;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLotesRepository implements LotesRepository {
  @override
  Future<List<LoteEntity>> getActiveLotes() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAnimalRepository implements AnimalRepository {
  bool throwOnUpdate = false;
  int updateCallCount = 0;

  @override
  Future<AnimalEntity?> getByUuid(String uuid) async => null;

  @override
  Future<List<AnimalEntity>> getAll() async => const [];

  @override
  Future<AnimalEntity> update(AnimalEntity animal) async {
    updateCallCount += 1;
    if (throwOnUpdate) {
      throw Exception('update failed');
    }
    return animal;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWeightRecordRepository implements WeightRecordRepository {
  @override
  Future<List<WeightRecord>> getWeightRecords(String animalUuid) async =>
      const [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHealthRecordRepository implements HealthRecordRepository {
  @override
  Future<List<HealthRecord>> getHealthRecords(String animalUuid) async =>
      const [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProductionRecordRepository implements ProductionRecordRepository {
  @override
  Future<List<ProductionRecord>> getProductionRecords(
    String animalUuid,
  ) async => const [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeReproductionRecordRepository
    implements ReproductionRecordRepository {
  @override
  Future<List<ReproductionRecord>> getReproductionRecords(
    String animalUuid,
  ) async => const [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCommercialRecordRepository implements CommercialRecordRepository {
  @override
  Future<List<CommercialRecord>> getCommercialRecords(
    String animalUuid,
  ) async => const [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMovementRecordRepository implements MovementRecordRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCostRecordRepository implements CostRecordRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
