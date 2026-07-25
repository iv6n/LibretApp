import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/view/ubicaciones_tree_builder.dart';

LocationEntity _location({
  required String uuid,
  required String name,
  String? parentUuid,
  LocationType type = LocationType.pasture,
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
  );
}

void main() {
  group('UbicacionesTreeBuilder', () {
    test('buildRoots returns top-level nodes with visible descendants', () {
      final locations = [
        _location(uuid: 'root', name: 'Rancho', type: LocationType.ranch),
        _location(
          uuid: 'child',
          name: 'Potrero',
          parentUuid: 'root',
          type: LocationType.pasture,
        ),
        _location(uuid: 'orphan', name: 'Suelto', type: LocationType.pasture),
      ];
      final allByUuid = {for (final l in locations) l.uuid: l};
      final childrenByParent = UbicacionesTreeBuilder.childrenByParent(
        locations,
      );
      final visibleIds = locations.map((e) => e.uuid).toSet();

      final roots = UbicacionesTreeBuilder.buildRoots(
        allLocations: locations,
        allByUuid: allByUuid,
        childrenByParent: childrenByParent,
        visibleIds: visibleIds,
      );

      expect(roots.map((e) => e.uuid), containsAll(['root', 'orphan']));
      expect(roots, hasLength(2));
    });

    test('flattenVisible respects expanded nodes', () {
      final locations = [
        _location(uuid: 'root', name: 'Rancho', type: LocationType.ranch),
        _location(
          uuid: 'child',
          name: 'Potrero',
          parentUuid: 'root',
          type: LocationType.pasture,
        ),
      ];
      final allByUuid = {for (final l in locations) l.uuid: l};
      final childrenByParent = UbicacionesTreeBuilder.childrenByParent(
        locations,
      );
      final visibleIds = locations.map((e) => e.uuid).toSet();
      final roots = UbicacionesTreeBuilder.buildRoots(
        allLocations: locations,
        allByUuid: allByUuid,
        childrenByParent: childrenByParent,
        visibleIds: visibleIds,
      );

      final collapsed = UbicacionesTreeBuilder.flattenVisible(
        roots: roots,
        childrenByParent: childrenByParent,
        visibleIds: visibleIds,
        expandedUuids: {},
      );
      expect(collapsed, hasLength(1));
      expect(collapsed.first.location.uuid, 'root');

      final expanded = UbicacionesTreeBuilder.flattenVisible(
        roots: roots,
        childrenByParent: childrenByParent,
        visibleIds: visibleIds,
        expandedUuids: {'root'},
      );
      expect(expanded, hasLength(2));
      expect(expanded.last.depth, 1);
    });

    test('defaultExpandedUuids expands roots with few children', () {
      final locations = [
        _location(uuid: 'root', name: 'Rancho', type: LocationType.ranch),
        _location(
          uuid: 'c1',
          name: 'P1',
          parentUuid: 'root',
          type: LocationType.pasture,
        ),
        _location(
          uuid: 'c2',
          name: 'P2',
          parentUuid: 'root',
          type: LocationType.pasture,
        ),
      ];
      final childrenByParent = UbicacionesTreeBuilder.childrenByParent(
        locations,
      );
      final visibleIds = locations.map((e) => e.uuid).toSet();
      final roots = [locations.first];

      final expanded = UbicacionesTreeBuilder.defaultExpandedUuids(
        roots: roots,
        childrenByParent: childrenByParent,
        visibleIds: visibleIds,
      );

      expect(expanded, contains('root'));
    });

    test('computeSubtreeAnimalCounts aggregates descendant animals', () {
      final locations = [
        _location(uuid: 'root', name: 'Monte', type: LocationType.monte),
        _location(
          uuid: 'child',
          name: 'Derecho',
          parentUuid: 'root',
          type: LocationType.ejido,
        ),
      ];
      final counts = {'root': 2, 'child': 5};
      final subtree = UbicacionesTreeBuilder.computeSubtreeAnimalCounts(
        locations: locations,
        directCounts: counts,
      );
      expect(subtree['root'], 7);
      expect(subtree['child'], 5);
    });

    test('flattenVisibleGrouped emits grouped panel for any expanded parent', () {
      final locations = [
        _location(
          uuid: 'monte',
          name: 'Monte Ejidal Comunal',
          type: LocationType.monte,
        ).copyWith(isCommunal: true),
        _location(
          uuid: 'ejido',
          name: 'Derecho Ejidal',
          parentUuid: 'monte',
          type: LocationType.ejido,
        ),
        _location(
          uuid: 'corral',
          name: 'Corral Privado',
          parentUuid: 'ejido',
          type: LocationType.corral,
        ),
        _location(
          uuid: 'presa',
          name: 'Presa 1',
          parentUuid: 'monte',
          type: LocationType.dam,
        ),
      ];
      final allByUuid = {for (final l in locations) l.uuid: l};
      final childrenByParent = UbicacionesTreeBuilder.childrenByParent(
        locations,
      );
      final visibleIds = locations.map((e) => e.uuid).toSet();
      final roots = UbicacionesTreeBuilder.buildRoots(
        allLocations: locations,
        allByUuid: allByUuid,
        childrenByParent: childrenByParent,
        visibleIds: visibleIds,
      );

      final collapsed = UbicacionesTreeBuilder.flattenVisibleGrouped(
        roots: roots,
        childrenByParent: childrenByParent,
        visibleIds: visibleIds,
        expandedUuids: {},
      );
      expect(collapsed, hasLength(1));
      expect(collapsed.first, isA<LocationEntryRow>());

      final expanded = UbicacionesTreeBuilder.flattenVisibleGrouped(
        roots: roots,
        childrenByParent: childrenByParent,
        visibleIds: visibleIds,
        expandedUuids: {'monte'},
      );
      expect(expanded, hasLength(2));
      expect(expanded.first, isA<LocationEntryRow>());
      expect(expanded.last, isA<GroupedChildrenRow>());
      final panel = expanded.last as GroupedChildrenRow;
      expect(panel.parent.uuid, 'monte');
      expect(panel.depth, 1);
    });

    test(
      'flattenVisibleGrouped groups children of a non-communal root parent',
      () {
        final locations = [
          _location(uuid: 'ranch', name: 'Rancho', type: LocationType.ranch),
          _location(
            uuid: 'presa1',
            name: 'Presa 1',
            parentUuid: 'ranch',
            type: LocationType.dam,
          ),
          _location(
            uuid: 'corral1',
            name: 'Corral 1',
            parentUuid: 'ranch',
            type: LocationType.corral,
          ),
        ];
        final allByUuid = {for (final l in locations) l.uuid: l};
        final childrenByParent = UbicacionesTreeBuilder.childrenByParent(
          locations,
        );
        final visibleIds = locations.map((e) => e.uuid).toSet();
        final roots = UbicacionesTreeBuilder.buildRoots(
          allLocations: locations,
          allByUuid: allByUuid,
          childrenByParent: childrenByParent,
          visibleIds: visibleIds,
        );

        final expanded = UbicacionesTreeBuilder.flattenVisibleGrouped(
          roots: roots,
          childrenByParent: childrenByParent,
          visibleIds: visibleIds,
          expandedUuids: {'ranch'},
        );

        // The ranch card plus a single grouped panel for its children — the
        // children are not emitted as individual rows.
        expect(expanded, hasLength(2));
        expect(expanded.first, isA<LocationEntryRow>());
        expect(expanded.last, isA<GroupedChildrenRow>());
        expect((expanded.last as GroupedChildrenRow).parent.uuid, 'ranch');
      },
    );

    test('defaultExpandedUuids always expands communal monte containers', () {
      final locations = [
        _location(
          uuid: 'monte',
          name: 'Monte Ejidal Comunal',
          type: LocationType.monte,
        ).copyWith(isCommunal: true),
        _location(
          uuid: 'e1',
          name: 'D1',
          parentUuid: 'monte',
          type: LocationType.ejido,
        ),
        _location(
          uuid: 'e2',
          name: 'D2',
          parentUuid: 'monte',
          type: LocationType.ejido,
        ),
        _location(
          uuid: 'e3',
          name: 'D3',
          parentUuid: 'monte',
          type: LocationType.ejido,
        ),
        _location(
          uuid: 'e4',
          name: 'D4',
          parentUuid: 'monte',
          type: LocationType.ejido,
        ),
      ];
      final childrenByParent = UbicacionesTreeBuilder.childrenByParent(
        locations,
      );
      final visibleIds = locations.map((e) => e.uuid).toSet();
      final roots = [locations.first];

      final expanded = UbicacionesTreeBuilder.defaultExpandedUuids(
        roots: roots,
        childrenByParent: childrenByParent,
        visibleIds: visibleIds,
      );

      // Must be expanded even though it has 4 children (> default maxAutoExpandChildren=3).
      expect(expanded, contains('monte'));
    });

    test(
      'defaultExpandedUuids does not expand non-monte root with many children',
      () {
        final locations = [
          _location(uuid: 'ranch', name: 'Rancho', type: LocationType.ranch),
          _location(
            uuid: 'c1',
            name: 'P1',
            parentUuid: 'ranch',
            type: LocationType.pasture,
          ),
          _location(
            uuid: 'c2',
            name: 'P2',
            parentUuid: 'ranch',
            type: LocationType.pasture,
          ),
          _location(
            uuid: 'c3',
            name: 'P3',
            parentUuid: 'ranch',
            type: LocationType.pasture,
          ),
          _location(
            uuid: 'c4',
            name: 'P4',
            parentUuid: 'ranch',
            type: LocationType.pasture,
          ),
        ];
        final childrenByParent = UbicacionesTreeBuilder.childrenByParent(
          locations,
        );
        final visibleIds = locations.map((e) => e.uuid).toSet();
        final roots = [locations.first];

        final expanded = UbicacionesTreeBuilder.defaultExpandedUuids(
          roots: roots,
          childrenByParent: childrenByParent,
          visibleIds: visibleIds,
        );

        // Must NOT be auto-expanded since it has 4 children and is not a communal monte.
        expect(expanded, isNot(contains('ranch')));
      },
    );
  });
}
