import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/agenda/bloc/agenda_bloc.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/category.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/health_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/life_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_purpose.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/reproductive_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/risk_level.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/sex.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/dynamic_attribute.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/view/location_detail_page.dart';

class _FakeAgendaRepository implements AgendaRepository {
  @override
  Future<List<AgendaEntry>> fetchEntries() async => const [];

  @override
  Future<AgendaEntry> getEntry(String id) async {
    throw StateError('not found');
  }

  @override
  Future<void> saveEntry(AgendaEntry entry) async {}

  @override
  Future<void> deleteEntry(String id) async {}

  @override
  Future<void> updateEntry(AgendaEntry entry) async {}

  @override
  Future<void> replaceAll(List<AgendaEntry> entries) async {}

  @override
  Future<void> clearAll() async {}
}

class _FakeLocationRepository implements LocationRepository {
  _FakeLocationRepository(List<LocationEntity> seed)
    : _locations = List<LocationEntity>.from(seed),
      _controller = StreamController<List<LocationEntity>>.broadcast();

  final List<LocationEntity> _locations;
  final StreamController<List<LocationEntity>> _controller;

  @override
  Stream<List<LocationEntity>> watchAll() {
    Future<void>.microtask(() {
      if (!_controller.isClosed) {
        _controller.add(List<LocationEntity>.unmodifiable(_locations));
      }
    });
    return _controller.stream;
  }

  @override
  Future<List<LocationEntity>> getAll() async =>
      List<LocationEntity>.unmodifiable(_locations);

  @override
  Future<LocationEntity?> getByUuid(String uuid) async {
    for (final item in _locations) {
      if (item.uuid == uuid) return item;
    }
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  Future<void> dispose() async {
    await _controller.close();
  }
}

class _FakeAnimalRepository implements AnimalRepository {
  _FakeAnimalRepository({required List<AnimalEntity> animals})
    : _animals = List<AnimalEntity>.from(animals);

  final List<AnimalEntity> _animals;

  @override
  Future<List<AnimalEntity>> getAll() async =>
      List<AnimalEntity>.unmodifiable(_animals);

  @override
  Stream<List<AnimalEntity>> watchAll() async* {
    yield List<AnimalEntity>.unmodifiable(_animals);
  }

  @override
  Future<bool> refreshFromRemote({bool force = false}) async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMovementRecordRepository implements MovementRecordRepository {
  @override
  Future<List<MovementRecord>> getMovementRecords(String animalUuid) async =>
      const [];

  @override
  Future<MovementRecord> addMovementRecord(
    String animalUuid,
    MovementRecord record,
  ) async => record;

  @override
  Future<void> deleteMovementRecord(String recordId) async {}
}

AnimalEntity _animal({required String uuid, required String locationId}) {
  final now = DateTime(2026, 1, 1);
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: 'A-$uuid',
    customName: 'Animal $uuid',
    visualId: 'VIS-$uuid',
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: 'Cebu',
    birthDate: DateTime(2020, 1, 1),
    ageMonths: 72,
    healthStatus: HealthStatus.good,
    vaccinated: true,
    dewormed: true,
    hasVitamins: true,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.undefined,
    productionStage: ProductionStage.unknown,
    productionSystem: ProductionSystem.unknown,
    currentLocationId: locationId,
    initialLocationId: locationId,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.low,
    gallery: const [],
    synced: false,
    creationDate: now,
    lastUpdateDate: now,
  );
}

LocationEntity _locationWithAdaptiveProps() {
  return LocationEntity(
    uuid: 'loc-1',
    name: 'Milpa Corral A',
    type: LocationType.pasture,
    surfaceArea: 10,
    capacity: 30,
    waterSource: 'Pozo',
    terrainType: 'Plano',
    status: LocationStatus.available,
    geometry: '{"type":"Point","coordinates":[-99.1,19.3]}',
    isShared: true,
    attributes: [
      DynamicAttribute.text(
        key: 'registryCode',
        label: 'Registry code',
        value: 'RCH-001',
      ),
    ],
  );
}

Widget _testHost({
  required LocationRepository locationRepository,
  required AnimalRepository animalRepository,
}) {
  final agendaBloc = AgendaBloc(_FakeAgendaRepository());

  return BlocProvider.value(
    value: agendaBloc,
    child: MaterialApp(
      home: LocationDetailPage(
        locationUuid: 'loc-1',
        locationRepository: locationRepository,
        animalRepository: animalRepository,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationDetailPage adaptive properties', () {
    late _FakeLocationRepository locationRepository;
    late _FakeAnimalRepository animalRepository;

    setUp(() {
      if (locator.isRegistered<MovementRecordRepository>()) {
        locator.unregister<MovementRecordRepository>();
      }
      locator.registerSingleton<MovementRecordRepository>(
        _FakeMovementRecordRepository(),
      );

      locationRepository = _FakeLocationRepository([
        _locationWithAdaptiveProps(),
      ]);
      animalRepository = _FakeAnimalRepository(
        animals: [_animal(uuid: '1', locationId: 'loc-1')],
      );
    });

    tearDown(() async {
      await locationRepository.dispose();
      if (locator.isRegistered<MovementRecordRepository>()) {
        locator.unregister<MovementRecordRepository>();
      }
    });

    testWidgets('renders adaptive properties card with expected values', (
      tester,
    ) async {
      await tester.pumpWidget(
        _testHost(
          locationRepository: locationRepository,
          animalRepository: animalRepository,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Propiedades específicas'), findsOneWidget);
      expect(find.text('RCH-001'), findsOneWidget);
      expect(
        find.text('{"type":"Point","coordinates":[-99.1,19.3]}'),
        findsOneWidget,
      );

      final yesOrSi = find.byWidgetPredicate((widget) {
        if (widget is! Text) return false;
        final value = widget.data;
        return value == 'Yes' || value == 'Sí';
      });
      expect(yesOrSi, findsWidgets);
    });
  });
}
