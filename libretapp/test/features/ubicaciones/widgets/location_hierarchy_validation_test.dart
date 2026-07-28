import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_hierarchy_validation.dart';

LocationEntity _location({
  required String uuid,
  required String name,
  String? parentUuid,
  LocationType type = LocationType.pasture,
  bool isCommunal = false,
}) {
  return LocationEntity(
    uuid: uuid,
    name: name,
    parentUuid: parentUuid,
    type: type,
    surfaceArea: 10,
    capacity: 25,
    waterSource: 'Pozo',
    terrainType: 'Plano',
    status: LocationStatus.available,
    isCommunal: isCommunal,
  );
}

void main() {
  group('validateLocationParent', () {
    test('allows a location with no parent (root)', () {
      final location = _location(uuid: 'root', name: 'Rancho', type: LocationType.ranch);

      expect(validateLocationParent(location, [location]), isNull);
    });

    test('rejects a location assigned as its own parent', () {
      final location = _location(uuid: 'a', name: 'A', parentUuid: 'a');

      expect(
        validateLocationParent(location, [location]),
        'Una ubicacion no puede asignarse como su propio padre',
      );
    });

    test('rejects a parent that does not exist', () {
      final location = _location(uuid: 'a', name: 'A', parentUuid: 'missing');

      expect(
        validateLocationParent(location, [location]),
        'La ubicacion padre seleccionada no existe o fue eliminada',
      );
    });

    test('rejects a parent that cannot accept the child type', () {
      final parent = _location(
        uuid: 'parent',
        name: 'Potrero',
        type: LocationType.pasture,
      );
      final child = _location(
        uuid: 'child',
        name: 'Ejido hijo',
        parentUuid: 'parent',
        type: LocationType.ejido,
      );

      expect(
        validateLocationParent(child, [parent, child]),
        'Derecho ejidal no puede estar dentro de Potrero',
      );
    });

    test('allows an ejido under a communal monte', () {
      final monte = _location(
        uuid: 'monte',
        name: 'Monte Ejidal Comunal',
        type: LocationType.monte,
        isCommunal: true,
      );
      final derecho = _location(
        uuid: 'derecho',
        name: 'Derecho Ejidal',
        parentUuid: 'monte',
        type: LocationType.ejido,
      );

      expect(validateLocationParent(derecho, [monte, derecho]), isNull);
    });

    test('rejects an ejido under a non-communal monte', () {
      final monte = _location(
        uuid: 'monte',
        name: 'Monte',
        type: LocationType.monte,
      );
      final derecho = _location(
        uuid: 'derecho',
        name: 'Derecho Ejidal',
        parentUuid: 'monte',
        type: LocationType.ejido,
      );

      expect(
        validateLocationParent(derecho, [monte, derecho]),
        isNotNull,
      );
    });

    test('allows a water resource nested under any parent type', () {
      final parent = _location(
        uuid: 'parent',
        name: 'Potrero',
        type: LocationType.pasture,
      );
      final water = _location(
        uuid: 'water',
        name: 'Bebedero',
        parentUuid: 'parent',
        type: LocationType.trough,
      );

      expect(validateLocationParent(water, [parent, water]), isNull);
    });
  });
}
