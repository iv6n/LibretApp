import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/water_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/view/ubicaciones_page.dart';

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
  Future<void> addPasture(String uuid, PastureRecord record) async {}

  @override
  Future<void> addSeeding(String uuid, SeedingRecord record) async {}

  @override
  Future<void> addIrrigation(String uuid, IrrigationRecord record) async {}

  @override
  Future<void> addRain(String uuid, RainRecord record) async {}

  @override
  Future<void> addCost(String uuid, CostRecord record) async {}
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
          type: LocationType.potrero,
          surfaceArea: 12.5,
          capacity: 40,
          waterSource: 'Pozo',
          terrainType: 'Plano',
          status: 'activo',
          waters: [
            WaterRecord(
              date: DateTime(2024, 1, 1),
              level: 70,
              type: WaterType.pozo,
            ),
          ],
        ),
        LocationEntity(
          uuid: 'uuid-2',
          name: 'Corral Central',
          type: LocationType.corral,
          surfaceArea: 3.2,
          capacity: 25,
          waterSource: 'Pila',
          terrainType: 'Firm',
          status: 'activo',
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
      expect(find.text('Potrero A'), findsOneWidget);
      expect(find.text('Corral Central'), findsOneWidget);
    });

    testWidgets('muestra datos al cargar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: UbicacionesPage(repository: repository)),
      );

      await tester.pumpAndSettle();
      expect(find.text('Potrero A'), findsOneWidget);
    });
  });
}
