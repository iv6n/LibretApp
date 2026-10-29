import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/inventory_item.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/water_type.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/view/ubicaciones_page.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_card.dart';

class _FakeLocationRepository implements LocationRepository {
  _FakeLocationRepository(this._data);

  final List<LocationEntity> _data;

  @override
  Stream<List<LocationEntity>> watchAll() => Stream.value(_data);

  @override
  Future<List<LocationEntity>> getAll() async => _data;

  @override
  Future<LocationEntity?> getByUuid(String uuid) async {
    for (final location in _data) {
      if (location.uuid == uuid) {
        return location;
      }
    }
    return null;
  }

  @override
  Future<void> upsert(LocationEntity location) async {}

  @override
  Future<void> deleteByUuid(String uuid) async {}

  @override
  Future<void> addVisit(String uuid, VisitRecord record) async {}

  @override
  Future<void> addWater(String uuid, WaterRecord record) async {}

  @override
  Future<void> addSalt(String uuid, SaltRecord record) async {}

  @override
  Future<void> addShade(String uuid, ShadeRecord record) async {}

  @override
  Future<void> addPasture(String uuid, PastureRecord record) async {}

  @override
  Future<void> addSeeding(String uuid, SeedingRecord record) async {}

  @override
  Future<void> addIrrigation(String uuid, IrrigationRecord record) async {}

  @override
  Future<void> addRain(String uuid, RainRecord record) async {}

  @override
  Future<void> addMaintenance(String uuid, MaintenanceRecord record) async {}

  @override
  Future<void> addCost(String uuid, LocationCostRecord record) async {}

  @override
  Future<void> addCrop(String locationUuid, CropRecord crop) async {}

  @override
  Future<void> updateCrop(String locationUuid, CropRecord crop) async {}

  @override
  Future<void> deleteCrop(String locationUuid, String cropUuid) async {}

  @override
  Future<void> addHarvest(
    String locationUuid,
    String cropUuid,
    HarvestRecord record,
  ) async {}

  @override
  Future<void> addCropWatering(
    String locationUuid,
    String cropUuid,
    CropWateringRecord record,
  ) async {}

  @override
  Future<void> addCropHealth(
    String locationUuid,
    String cropUuid,
    CropHealthRecord record,
  ) async {}

  @override
  Future<void> addCropTask(
    String locationUuid,
    String cropUuid,
    CropTask task,
  ) async {}

  @override
  Future<void> completeCropTask(
    String locationUuid,
    String cropUuid,
    String taskUuid,
  ) async {}

  @override
  Future<void> addInventoryItem(
    String locationUuid,
    InventoryItem item,
  ) async {}

  @override
  Future<void> updateInventoryItem(
    String locationUuid,
    InventoryItem item,
  ) async {}

  @override
  Future<void> removeInventoryItem(
    String locationUuid,
    String itemUuid,
  ) async {}
}

class _FakeCultivationRepository implements CultivationRepository {
  _FakeCultivationRepository(this._data);

  final List<CultivationEntity> _data;

  @override
  Stream<List<CultivationEntity>> watchAll({bool includeArchived = false}) =>
      Stream.value(_data);

  @override
  Future<List<CultivationEntity>> getAll({
    bool includeArchived = false,
  }) async => _data;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UbicacionesPage', () {
    late List<LocationEntity> fakeLocations;
    late _FakeLocationRepository repository;

    setUp(() {
      fakeLocations = [
        LocationEntity(
          uuid: 'uuid-1',
          name: 'Potrero A',
          type: LocationType.pasture,
          surfaceArea: 12.5,
          capacity: 40,
          waterSource: 'Pozo',
          terrainType: 'Plano',
          status: LocationStatus.available,
          waters: [
            WaterRecord(
              date: DateTime(2024, 1, 1),
              level: 70,
              type: WaterType.well,
            ),
          ],
        ),
        const LocationEntity(
          uuid: 'uuid-2',
          name: 'Corral Central',
          type: LocationType.corral,
          surfaceArea: 3.2,
          capacity: 25,
          waterSource: 'Pila',
          terrainType: 'Firm',
          status: LocationStatus.available,
        ),
      ];
      repository = _FakeLocationRepository(fakeLocations);
    });

    testWidgets('muestra listado de ubicaciones', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: UbicacionesPage(repository: repository)),
      );

      // Espera a que cargue el bloc y reconstruya.
      await tester.pumpAndSettle();

      expect(find.text('Ubicaciones'), findsOneWidget);
      expect(find.text('Potrero A'), findsWidgets);
      expect(find.text('Corral Central'), findsWidgets);
    });

    testWidgets('muestra datos al cargar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: UbicacionesPage(repository: repository)),
      );

      await tester.pumpAndSettle();
      expect(find.text('Potrero A'), findsWidgets);
    });

    testWidgets('muestra el selector solo cuando hay varias raíces', (
      tester,
    ) async {
      const rootWithChildren = LocationEntity(
        uuid: 'root-a',
        name: 'Rancho A',
        type: LocationType.ranch,
        surfaceArea: 10,
        capacity: 20,
        waterSource: 'Pozo',
        terrainType: 'Plano',
        status: LocationStatus.available,
      );
      const child = LocationEntity(
        uuid: 'child-a',
        name: 'Corral A',
        parentUuid: 'root-a',
        type: LocationType.corral,
        surfaceArea: 2,
        capacity: 10,
        waterSource: 'Pila',
        terrainType: 'Firme',
        status: LocationStatus.available,
      );
      const secondRoot = LocationEntity(
        uuid: 'root-b',
        name: 'Finca B',
        type: LocationType.farm,
        surfaceArea: 12,
        capacity: 30,
        waterSource: 'Pozo',
        terrainType: 'Plano',
        status: LocationStatus.available,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: UbicacionesPage(
            repository: _FakeLocationRepository([
              rootWithChildren,
              child,
              secondRoot,
            ]),
            showHeader: false,
            shellInteractionsEnabled: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('ubicaciones-root-filter-row')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('ubicaciones-root-filter-root-a')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('ubicaciones-root-filter-root-b')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('ubicaciones-root-filter-child-a')),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const ValueKey('ubicaciones-root-filter-root-a')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('ubicaciones-root-filter-row')),
        findsOneWidget,
      );
      expect(find.byType(TabBar), findsNothing);
      expect(find.text('Rancho A'), findsWidgets);
      expect(find.text('Corral A'), findsOneWidget);
      expect(find.text('Finca B'), findsWidgets);
    });

    testWidgets('oculta el selector cuando existe una sola raíz', (
      tester,
    ) async {
      const root = LocationEntity(
        uuid: 'single-root',
        name: 'Rancho único',
        type: LocationType.ranch,
        surfaceArea: 10,
        capacity: 20,
        waterSource: 'Pozo',
        terrainType: 'Plano',
        status: LocationStatus.available,
      );
      const child = LocationEntity(
        uuid: 'single-child',
        name: 'Sub ubicación',
        parentUuid: 'single-root',
        type: LocationType.pasture,
        surfaceArea: 2,
        capacity: 10,
        waterSource: 'Pila',
        terrainType: 'Firme',
        status: LocationStatus.available,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: UbicacionesPage(
            repository: _FakeLocationRepository([root, child]),
            showHeader: false,
            shellInteractionsEnabled: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('ubicaciones-root-filter-row')),
        findsNothing,
      );
      expect(find.byTooltip('Filtrar categorías'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('ubicaciones-category-filter-row')),
        findsNothing,
      );

      await tester.tap(find.byTooltip('Filtrar categorías'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('ubicaciones-category-filter-row')),
        findsOneWidget,
      );
    });

    testWidgets('resume los cultivos activos vinculados y calcula En uso', (
      tester,
    ) async {
      final cultivations = [
        CultivationEntity(
          uuid: 'crop-1',
          name: 'Maíz blanco',
          scale: CultivationScale.area,
          locationUuid: 'uuid-1',
          plantingDate: DateTime(2024, 6, 1),
          areaSquareMeters: 42000,
          preferredAreaUnit: CultivationAreaUnit.hectares,
        ),
        CultivationEntity(
          uuid: 'crop-2',
          name: 'Frijol intercalado',
          scale: CultivationScale.area,
          locationUuid: 'uuid-1',
          plantingDate: DateTime(2024, 6, 1),
          areaSquareMeters: 10000,
        ),
        CultivationEntity(
          uuid: 'crop-finished',
          name: 'Sorgo anterior',
          scale: CultivationScale.area,
          locationUuid: 'uuid-1',
          plantingDate: DateTime(2023, 6, 1),
          status: CropStatus.harvested,
          areaSquareMeters: 50000,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: UbicacionesPage(
            repository: repository,
            cultivationRepository: _FakeCultivationRepository(cultivations),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('En uso por Maíz blanco +1'), findsOneWidget);
      expect(find.text('In Use'), findsOneWidget);
      expect(find.textContaining('Sorgo anterior'), findsNothing);
    });

    testWidgets('un cultivo no sobrescribe un estado manual cerrado', (
      tester,
    ) async {
      const closed = LocationEntity(
        uuid: 'closed-location',
        name: 'Parcela cerrada',
        type: LocationType.field,
        surfaceArea: 2,
        capacity: 0,
        waterSource: '',
        terrainType: '',
        status: LocationStatus.closed,
      );
      final cultivation = CultivationEntity(
        uuid: 'crop-closed',
        name: 'Cobertura temporal',
        locationUuid: closed.uuid,
        plantingDate: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: UbicacionesPage(
            repository: _FakeLocationRepository([closed]),
            cultivationRepository: _FakeCultivationRepository([cultivation]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('En uso por Cobertura temporal'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
      expect(find.text('In Use'), findsNothing);
    });

    testWidgets('una ubicación disponible con animales aparece En uso', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationCard(
              location: fakeLocations.first,
              animalCount: 1,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('In Use'), findsOneWidget);
      expect(find.text('Available'), findsNothing);
    });
  });
}
