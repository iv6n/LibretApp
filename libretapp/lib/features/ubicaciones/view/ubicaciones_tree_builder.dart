/// features › ubicaciones › view › ubicaciones_tree_builder — pure tree logic for locations list.
library;

import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_category.dart';

/// A row in the flattened location tree (card or grouped communal-monte panel).
sealed class UbicacionTreeRow {}

class LocationEntryRow extends UbicacionTreeRow {
  LocationEntryRow(this.entry);

  final LocationTreeEntry entry;
}

/// A grouped panel that buckets the visible children of [parent] into
/// expandable category sections (Derecho Ejidal, Aguas, Corrales, …).
class GroupedChildrenRow extends UbicacionTreeRow {
  GroupedChildrenRow({
    required this.parent,
    required this.depth,
    required this.childrenByParent,
    required this.visibleIds,
  });

  final LocationEntity parent;
  final int depth;
  final Map<String?, List<LocationEntity>> childrenByParent;
  final Set<String> visibleIds;
}

/// A visible row in the flattened location tree.
class LocationTreeEntry {
  const LocationTreeEntry({
    required this.location,
    required this.depth,
    required this.directChildCount,
    required this.hasVisibleChildren,
  });

  final LocationEntity location;
  final int depth;
  final int directChildCount;
  final bool hasVisibleChildren;
}

class UbicacionesTreeBuilder {
  const UbicacionesTreeBuilder._();

  static Map<String?, List<LocationEntity>> childrenByParent(
    List<LocationEntity> locations,
  ) {
    final map = <String?, List<LocationEntity>>{};
    for (final location in locations) {
      map
          .putIfAbsent(location.parentUuid, () => <LocationEntity>[])
          .add(location);
    }
    return map;
  }

  static bool hasVisibleDescendants(
    LocationEntity location,
    Map<String?, List<LocationEntity>> childrenByParent,
    Set<String> visibleIds, {
    Set<String>? traversed,
  }) {
    final seen = traversed ?? <String>{};
    if (!seen.add(location.uuid)) return false;
    if (visibleIds.contains(location.uuid)) return true;
    final children =
        childrenByParent[location.uuid] ?? const <LocationEntity>[];
    for (final child in children) {
      if (hasVisibleDescendants(
        child,
        childrenByParent,
        visibleIds,
        traversed: seen,
      )) {
        return true;
      }
    }
    seen.remove(location.uuid);
    return false;
  }

  static List<LocationEntity> buildRoots({
    required List<LocationEntity> allLocations,
    required Map<String, LocationEntity> allByUuid,
    required Map<String?, List<LocationEntity>> childrenByParent,
    required Set<String> visibleIds,
  }) {
    return allLocations
        .where((location) {
          final parentUuid = location.parentUuid;
          if (parentUuid != null && allByUuid.containsKey(parentUuid)) {
            return false;
          }
          return hasVisibleDescendants(location, childrenByParent, visibleIds);
        })
        .toList(growable: false);
  }

  /// Default expanded UUIDs: roots with at most [maxAutoExpandChildren] children.
  /// Communal monte containers are always expanded regardless of child count.
  static Set<String> defaultExpandedUuids({
    required List<LocationEntity> roots,
    required Map<String?, List<LocationEntity>> childrenByParent,
    required Set<String> visibleIds,
    int maxAutoExpandChildren = 3,
  }) {
    final expanded = <String>{};
    for (final root in roots) {
      if (root.isCommunalMonteContainer) {
        expanded.add(root.uuid);
        continue;
      }
      final visibleChildren = _visibleChildren(
        root,
        childrenByParent,
        visibleIds,
      );
      if (visibleChildren.isNotEmpty &&
          visibleChildren.length <= maxAutoExpandChildren) {
        expanded.add(root.uuid);
      }
    }
    return expanded;
  }

  static List<LocationTreeEntry> flattenVisible({
    required List<LocationEntity> roots,
    required Map<String?, List<LocationEntity>> childrenByParent,
    required Set<String> visibleIds,
    required Set<String> expandedUuids,
  }) {
    final entries = <LocationTreeEntry>[];
    for (final root in roots) {
      _appendNode(
        location: root,
        depth: 0,
        childrenByParent: childrenByParent,
        visibleIds: visibleIds,
        expandedUuids: expandedUuids,
        entries: entries,
        ancestry: const {},
      );
    }
    return entries;
  }

  static List<UbicacionTreeRow> flattenVisibleGrouped({
    required List<LocationEntity> roots,
    required Map<String?, List<LocationEntity>> childrenByParent,
    required Set<String> visibleIds,
    required Set<String> expandedUuids,
  }) {
    final rows = <UbicacionTreeRow>[];
    for (final root in roots) {
      _appendNodeGrouped(
        location: root,
        depth: 0,
        childrenByParent: childrenByParent,
        visibleIds: visibleIds,
        expandedUuids: expandedUuids,
        rows: rows,
        ancestry: const {},
      );
    }
    return rows;
  }

  static List<LocationEntity> _visibleChildren(
    LocationEntity location,
    Map<String?, List<LocationEntity>> childrenByParent,
    Set<String> visibleIds,
  ) {
    final children =
        childrenByParent[location.uuid] ?? const <LocationEntity>[];
    return children
        .where(
          (child) => hasVisibleDescendants(child, childrenByParent, visibleIds),
        )
        .toList(growable: false);
  }

  static void _appendNode({
    required LocationEntity location,
    required int depth,
    required Map<String?, List<LocationEntity>> childrenByParent,
    required Set<String> visibleIds,
    required Set<String> expandedUuids,
    required List<LocationTreeEntry> entries,
    required Set<String> ancestry,
  }) {
    if (ancestry.contains(location.uuid)) return;
    final nextAncestry = {...ancestry, location.uuid};
    final visibleChildren = _visibleChildren(
      location,
      childrenByParent,
      visibleIds,
    );

    entries.add(
      LocationTreeEntry(
        location: location,
        depth: depth,
        directChildCount: visibleChildren.length,
        hasVisibleChildren: visibleChildren.isNotEmpty,
      ),
    );

    if (!expandedUuids.contains(location.uuid)) return;

    for (final child in visibleChildren) {
      _appendNode(
        location: child,
        depth: depth + 1,
        childrenByParent: childrenByParent,
        visibleIds: visibleIds,
        expandedUuids: expandedUuids,
        entries: entries,
        ancestry: nextAncestry,
      );
    }
  }

  static void _appendNodeGrouped({
    required LocationEntity location,
    required int depth,
    required Map<String?, List<LocationEntity>> childrenByParent,
    required Set<String> visibleIds,
    required Set<String> expandedUuids,
    required List<UbicacionTreeRow> rows,
    required Set<String> ancestry,
  }) {
    if (ancestry.contains(location.uuid)) return;
    final visibleChildren = _visibleChildren(
      location,
      childrenByParent,
      visibleIds,
    );

    rows.add(
      LocationEntryRow(
        LocationTreeEntry(
          location: location,
          depth: depth,
          directChildCount: visibleChildren.length,
          hasVisibleChildren: visibleChildren.isNotEmpty,
        ),
      ),
    );

    if (!expandedUuids.contains(location.uuid)) return;
    if (visibleChildren.isEmpty) return;

    // Any expanded parent shows its children inside a grouped panel that
    // buckets them by category (Derecho Ejidal, Aguas, Corrales, …).
    rows.add(
      GroupedChildrenRow(
        parent: location,
        depth: depth + 1,
        childrenByParent: childrenByParent,
        visibleIds: visibleIds,
      ),
    );
  }

  /// Returns all descendant UUIDs (non-inclusive of [rootUuid]) for a root.
  static Set<String> allDescendantUuids({
    required String rootUuid,
    required List<LocationEntity> allLocations,
  }) {
    final byParent = childrenByParent(allLocations);
    final result = <String>{};
    final queue = <String>[rootUuid];
    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      for (final child in byParent[current] ?? const <LocationEntity>[]) {
        if (result.add(child.uuid)) {
          queue.add(child.uuid);
        }
      }
    }
    return result;
  }

  /// Groups all descendants of [rootUuid] (exclusive) by [LocationCategory].
  ///
  /// Only non-empty categories are included in the result.
  static Map<LocationCategory, List<LocationEntity>> descendantsByCategory({
    required String rootUuid,
    required List<LocationEntity> allLocations,
  }) {
    final descendants = allDescendantUuids(
      rootUuid: rootUuid,
      allLocations: allLocations,
    );
    final map = <LocationCategory, List<LocationEntity>>{};
    for (final loc in allLocations) {
      if (descendants.contains(loc.uuid)) {
        map.putIfAbsent(loc.effectiveCategory, () => []).add(loc);
      }
    }
    return map;
  }

  /// Sums [directCounts] for each location including all descendants.
  ///
  /// Guards against cyclic parent chains (e.g. a corrupted `parentUuid`
  /// pointing back into its own subtree): a node already being computed on
  /// the current path contributes 0 instead of recursing forever.
  static Map<String, int> computeSubtreeAnimalCounts({
    required List<LocationEntity> locations,
    required Map<String, int> directCounts,
  }) {
    final byParent = childrenByParent(locations);
    final memo = <String, int>{};
    final inProgress = <String>{};

    int totalFor(String uuid) {
      final cached = memo[uuid];
      if (cached != null) return cached;
      if (!inProgress.add(uuid)) return 0;

      var total = directCounts[uuid] ?? 0;
      for (final child in byParent[uuid] ?? const <LocationEntity>[]) {
        total += totalFor(child.uuid);
      }

      inProgress.remove(uuid);
      memo[uuid] = total;
      return total;
    }

    return {
      for (final location in locations) location.uuid: totalFor(location.uuid),
    };
  }
}
