/// features › ubicaciones › widgets › ubicaciones_location_tree — hierarchical lazy list of locations.
library;

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_category.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/view/ubicaciones_tree_builder.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_card.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_labels.dart';
import 'package:libretapp/features/ubicaciones/widgets/ubicaciones_centered_section.dart';

typedef LocationTreeAction = void Function(LocationEntity location);

class UbicacionesLocationTree extends StatefulWidget {
  const UbicacionesLocationTree({
    super.key,
    required this.state,
    required this.listBottomPadding,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final UbicacionesLoaded state;
  final double listBottomPadding;
  final LocationTreeAction onTap;
  final LocationTreeAction onEdit;
  final LocationTreeAction onDelete;

  @override
  State<UbicacionesLocationTree> createState() =>
      _UbicacionesLocationTreeState();
}

class _UbicacionesLocationTreeState extends State<UbicacionesLocationTree> {
  late Set<String> _expandedUuids;
  String _treeKey = '';

  @override
  void initState() {
    super.initState();
    _expandedUuids = _computeDefaultExpanded();
  }

  @override
  void didUpdateWidget(covariant UbicacionesLocationTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newKey = _structureKey(widget.state);
    if (newKey != _treeKey) {
      _treeKey = newKey;
      _expandedUuids = _computeDefaultExpanded();
    }
  }

  String _structureKey(UbicacionesLoaded state) {
    return state.visibleUbicaciones.map((e) => e.uuid).join('|');
  }

  Set<String> _computeDefaultExpanded() {
    final state = widget.state;
    final snapshot = state.treeSnapshot;
    _treeKey = _structureKey(state);
    return UbicacionesTreeBuilder.defaultExpandedUuids(
      roots: snapshot.roots,
      childrenByParent: snapshot.childrenByParent,
      visibleIds: snapshot.visibleIds,
    );
  }

  List<UbicacionTreeRow> _buildRows() {
    final snapshot = widget.state.treeSnapshot;
    return UbicacionesTreeBuilder.flattenVisibleGrouped(
      roots: snapshot.roots,
      childrenByParent: snapshot.childrenByParent,
      visibleIds: snapshot.visibleIds,
      expandedUuids: _expandedUuids,
    );
  }

  void _toggleExpanded(String uuid) {
    setState(() {
      if (_expandedUuids.contains(uuid)) {
        _expandedUuids.remove(uuid);
      } else {
        _expandedUuids.add(uuid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rows = _buildRows();
    final allByUuid = widget.state.treeSnapshot.allByUuid;

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(4, 0, 4, widget.listBottomPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final row = rows[index];
          return switch (row) {
            LocationEntryRow(:final entry) => _buildLocationEntry(
              context,
              entry,
              allByUuid,
            ),
            GroupedChildrenRow(
              :final parent,
              :final depth,
              :final childrenByParent,
              :final visibleIds,
            ) =>
              UbicacionesCenteredSection(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _LocationGroupsPanel(
                  key: ValueKey('loc_groups_${parent.uuid}'),
                  parent: parent,
                  depth: depth,
                  childrenByParent: childrenByParent,
                  visibleIds: visibleIds,
                  state: widget.state,
                  onTap: widget.onTap,
                  onEdit: widget.onEdit,
                  onDelete: widget.onDelete,
                ),
              ),
          };
        }, childCount: rows.length),
      ),
    );
  }

  Widget _buildLocationEntry(
    BuildContext context,
    LocationTreeEntry entry,
    Map<String, LocationEntity> allByUuid,
  ) {
    final location = entry.location;
    final parentName = location.parentUuid == null
        ? null
        : allByUuid[location.parentUuid]?.name;
    final animalCount = widget.state.animalCounts[location.uuid] ?? 0;
    final totalAnimalCount = widget.state.subtreeAnimalCounts[location.uuid];
    final averageWeight = widget.state.averageWeights[location.uuid];
    final typeColor = locationTypeColor(location.type);

    int? ejidoCount;
    int? ejidoTotalCapacity;
    if (location.isCommunalMonteContainer) {
      final ejidoChildren = widget.state.allUbicaciones
          .where(
            (l) =>
                l.parentUuid == location.uuid && l.type == LocationType.ejido,
          )
          .toList(growable: false);
      ejidoCount = ejidoChildren.length;
      ejidoTotalCapacity = ejidoChildren.fold<int>(
        0,
        (sum, e) => sum + e.capacity,
      );
    }

    return UbicacionesCenteredSection(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Slidable(
        key: ValueKey('slide_${location.uuid}'),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.22,
          children: [
            SlidableAction(
              onPressed: (_) => widget.onEdit(location),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              icon: Icons.edit_outlined,
              label: 'Editar',
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(entry.depth > 0 ? 14 : 16),
              ),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.22,
          children: [
            SlidableAction(
              onPressed: (_) => widget.onDelete(location),
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
              label: 'Eliminar',
              borderRadius: BorderRadius.horizontal(
                right: Radius.circular(entry.depth > 0 ? 14 : 16),
              ),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.depth > 0)
              Padding(
                padding: EdgeInsets.only(left: (entry.depth - 1) * 12.0),
                child: _BranchRail(depth: entry.depth, color: typeColor),
              ),
            Expanded(
              child: LocationCard(
                key: ValueKey('loc_${location.uuid}'),
                location: location,
                animalCount: animalCount,
                totalAnimalCount: location.isCommunalMonteContainer
                    ? totalAnimalCount
                    : null,
                averageWeightKg: averageWeight,
                parentName: parentName,
                childCount: entry.directChildCount,
                isExpanded: _expandedUuids.contains(location.uuid),
                onToggleExpanded: entry.hasVisibleChildren
                    ? () => _toggleExpanded(location.uuid)
                    : null,
                isNested: entry.depth > 0,
                hierarchyDepth: entry.depth,
                ejidoCount: ejidoCount,
                ejidoTotalCapacity: ejidoTotalCapacity,
                onTap: () => widget.onTap(location),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Panel entry model ────────────────────────────────────────────────────────

/// One row inside a grouped children panel: either a single location card or
/// a synthetic category/type group (e.g. "Aguas", "Corrales").
sealed class _PanelEntry {}

class _BranchRail extends StatelessWidget {
  const _BranchRail({required this.depth, required this.color});

  final int depth;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final width = (14 + depth * 3).clamp(14, 24).toDouble();
    return SizedBox(
      width: width,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            bottom: 10,
            child: Container(
              width: (3 + depth * 0.5).clamp(3, 5).toDouble(),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.48),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            top: 26,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SingleEntry extends _PanelEntry {
  _SingleEntry(this.location);
  final LocationEntity location;
}

class _GroupEntry extends _PanelEntry {
  _GroupEntry({
    required this.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.members,
  });

  final String key;
  final String title;
  final IconData icon;
  final Color color;
  final List<LocationEntity> members;
}

// ── Shared helpers ───────────────────────────────────────────────────────────

List<LocationEntity> _visibleChildrenOf(
  LocationEntity parent,
  Map<String?, List<LocationEntity>> childrenByParent,
  Set<String> visibleIds,
) {
  final children = childrenByParent[parent.uuid] ?? const <LocationEntity>[];
  return children
      .where(
        (child) => UbicacionesTreeBuilder.hasVisibleDescendants(
          child,
          childrenByParent,
          visibleIds,
        ),
      )
      .toList(growable: false)
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}

int _categoryPriority(LocationCategory category) {
  return switch (category) {
    LocationCategory.macro => 0,
    LocationCategory.livestock => 1,
    LocationCategory.handling => 2,
    LocationCategory.agricultural => 3,
    LocationCategory.water => 4,
    LocationCategory.natural => 5,
    LocationCategory.infrastructure => 6,
  };
}

String _pluralizeEs(String word) {
  if (word.isEmpty) return word;
  const vowels = {'a', 'e', 'i', 'o', 'u', 'á', 'é', 'í', 'ó', 'ú'};
  final last = word[word.length - 1].toLowerCase();
  if (vowels.contains(last)) return '${word}s';
  if (last == 'z') return '${word.substring(0, word.length - 1)}ces';
  return '${word}es';
}

/// Builds the ordered entries (groups + single cards) for [parent]'s children.
///
/// Grouping only kicks in when [parent] has more than two visible children.
/// Container locations (those with their own visible children, e.g. an ejido)
/// always render as individual expandable cards. Leaf locations are bucketed by
/// type (or by the "water" category) and grouped when a bucket has 2+ members.
List<_PanelEntry> _buildPanelEntries(
  LocationEntity parent,
  Map<String?, List<LocationEntity>> childrenByParent,
  Set<String> visibleIds,
) {
  final children = _visibleChildrenOf(parent, childrenByParent, visibleIds);
  final entries = <_PanelEntry>[];

  if (children.length <= 2) {
    for (final child in children) {
      entries.add(_SingleEntry(child));
    }
  } else {
    final leavesByKey = <String, List<LocationEntity>>{};
    for (final child in children) {
      final isContainer = _visibleChildrenOf(
        child,
        childrenByParent,
        visibleIds,
      ).isNotEmpty;
      if (isContainer) {
        entries.add(_SingleEntry(child));
        continue;
      }
      final isWater = child.effectiveCategory == LocationCategory.water;
      final key = isWater ? 'water' : 'type_${child.type.name}';
      leavesByKey.putIfAbsent(key, () => []).add(child);
    }

    leavesByKey.forEach((key, members) {
      if (members.length >= 2) {
        entries.add(_groupEntryFor(key, members));
      } else {
        entries.add(_SingleEntry(members.first));
      }
    });
  }

  entries.sort((a, b) {
    final (pa, la) = _entryOrderKey(a);
    final (pb, lb) = _entryOrderKey(b);
    if (pa != pb) return pa.compareTo(pb);
    return la.compareTo(lb);
  });
  return entries;
}

(int, String) _entryOrderKey(_PanelEntry entry) {
  switch (entry) {
    case _SingleEntry(:final location):
      return (
        _categoryPriority(location.effectiveCategory),
        location.name.toLowerCase(),
      );
    case _GroupEntry(:final members, :final title):
      return (
        _categoryPriority(members.first.effectiveCategory),
        title.toLowerCase(),
      );
  }
}

_GroupEntry _groupEntryFor(String key, List<LocationEntity> members) {
  if (key == 'water') {
    return _GroupEntry(
      key: key,
      title: 'Aguas',
      icon: Icons.water_drop_outlined,
      color: locationTypeColor(LocationType.dam),
      members: members,
    );
  }
  final type = members.first.type;
  return _GroupEntry(
    key: key,
    title: _pluralizeEs(locationTypeLabelEs(type)),
    icon: iconForLocationType(type),
    color: locationTypeColor(type),
    members: members,
  );
}

// ── Children column (recursive) ──────────────────────────────────────────────

/// Renders the ordered entries for a parent's children: synthetic group cards
/// and single location cards, with an accent rail on the left.
class _LocationChildrenColumn extends StatelessWidget {
  const _LocationChildrenColumn({
    required this.parent,
    required this.depth,
    required this.childrenByParent,
    required this.visibleIds,
    required this.state,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final LocationEntity parent;
  final int depth;
  final Map<String?, List<LocationEntity>> childrenByParent;
  final Set<String> visibleIds;
  final UbicacionesLoaded state;
  final LocationTreeAction onTap;
  final LocationTreeAction onEdit;
  final LocationTreeAction onDelete;

  @override
  Widget build(BuildContext context) {
    final entries = _buildPanelEntries(parent, childrenByParent, visibleIds);
    if (entries.isEmpty) return const SizedBox.shrink();

    final accentColor = locationTypeColor(parent.type);

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BranchRail(depth: depth, color: accentColor),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final entry in entries)
                      switch (entry) {
                        _SingleEntry(:final location) => _GroupedLocationCard(
                          key: ValueKey('grp_node_${location.uuid}'),
                          location: location,
                          depth: depth,
                          childrenByParent: childrenByParent,
                          visibleIds: visibleIds,
                          state: state,
                          onTap: onTap,
                          onEdit: onEdit,
                          onDelete: onDelete,
                        ),
                        _GroupEntry group => _CategoryGroupCard(
                          key: ValueKey('grp_cat_${parent.uuid}_${group.key}'),
                          group: group,
                          depth: depth,
                          childrenByParent: childrenByParent,
                          visibleIds: visibleIds,
                          state: state,
                          onTap: onTap,
                          onEdit: onEdit,
                          onDelete: onDelete,
                        ),
                      },
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Top-level entry rendered by the tree when a root card is expanded.
class _LocationGroupsPanel extends StatelessWidget {
  const _LocationGroupsPanel({
    super.key,
    required this.parent,
    required this.depth,
    required this.childrenByParent,
    required this.visibleIds,
    required this.state,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final LocationEntity parent;
  final int depth;
  final Map<String?, List<LocationEntity>> childrenByParent;
  final Set<String> visibleIds;
  final UbicacionesLoaded state;
  final LocationTreeAction onTap;
  final LocationTreeAction onEdit;
  final LocationTreeAction onDelete;

  @override
  Widget build(BuildContext context) {
    final leftInset = depth > 0 ? (depth - 1) * 12.0 : 0.0;
    return Padding(
      padding: EdgeInsets.only(left: leftInset),
      child: _LocationChildrenColumn(
        parent: parent,
        depth: depth,
        childrenByParent: childrenByParent,
        visibleIds: visibleIds,
        state: state,
        onTap: onTap,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}

// ── Synthetic category group card ────────────────────────────────────────────

/// An expandable summary card bundling several leaf locations of the same
/// category/type (e.g. "Aguas", "Corrales"). Collapsed by default; expanding
/// lists each member as its own compact card.
class _CategoryGroupCard extends StatefulWidget {
  const _CategoryGroupCard({
    super.key,
    required this.group,
    required this.depth,
    required this.childrenByParent,
    required this.visibleIds,
    required this.state,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final _GroupEntry group;
  final int depth;
  final Map<String?, List<LocationEntity>> childrenByParent;
  final Set<String> visibleIds;
  final UbicacionesLoaded state;
  final LocationTreeAction onTap;
  final LocationTreeAction onEdit;
  final LocationTreeAction onDelete;

  @override
  State<_CategoryGroupCard> createState() => _CategoryGroupCardState();
}

class _CategoryGroupCardState extends State<_CategoryGroupCard> {
  bool _expanded = false;

  /// Aggregate metric shown in the footer: average water level for water
  /// groups, total animals for livestock/handling, otherwise just the count.
  (IconData, String) _summaryMetric() {
    final members = widget.group.members;
    final category = members.first.effectiveCategory;

    if (category == LocationCategory.water) {
      final levels = <double>[];
      for (final m in members) {
        if (m.waters.isEmpty) continue;
        final latest = m.waters.reduce(
          (a, b) => a.date.isAfter(b.date) ? a : b,
        );
        levels.add(latest.level);
      }
      if (levels.isEmpty) {
        return (Icons.water_drop_outlined, 'Sin lecturas');
      }
      final avg = levels.reduce((a, b) => a + b) / levels.length;
      return (Icons.water_drop_outlined, 'Promedio ${avg.toStringAsFixed(0)}%');
    }

    if (category == LocationCategory.livestock ||
        category == LocationCategory.handling) {
      final total = members.fold<int>(
        0,
        (sum, m) => sum + (widget.state.subtreeAnimalCounts[m.uuid] ?? 0),
      );
      return (Icons.pets_outlined, '$total animales');
    }

    final count = members.length;
    return (widget.group.icon, '$count ubicaciones');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final color = widget.group.color;
    final count = widget.group.members.length;

    final headerColor = isDark
        ? Color.alphaBlend(color.withValues(alpha: 0.28), colorScheme.surface)
        : Color.alphaBlend(color.withValues(alpha: 0.15), colorScheme.surface);
    final footerColor = isDark
        ? Color.alphaBlend(
            Colors.white.withValues(alpha: 0.04),
            colorScheme.surface,
          )
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45);

    final (metricIcon, metricLabel) = _summaryMetric();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: color.withValues(alpha: 0.34),
                width: 1.2,
              ),
            ),
            elevation: 1.2,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: headerColor,
                    padding: const EdgeInsets.fromLTRB(12, 10, 10, 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 23,
                          backgroundColor: color.withValues(alpha: 0.16),
                          child: LocationTypeAvatar(
                            type: widget.group.members.first.type,
                            radius: 18,
                            backgroundColor: Colors.transparent,
                            fallbackColor: color,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.group.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Agrupacion · $count ubicaciones',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _expanded ? Icons.expand_less : Icons.expand_more,
                          size: 22,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: footerColor,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    child: Row(
                      children: [
                        Icon(
                          metricIcon,
                          size: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            metricLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(left: 14, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final member in widget.group.members)
                    _GroupedLocationCard(
                      key: ValueKey('grp_member_${member.uuid}'),
                      location: member,
                      depth: widget.depth + 1,
                      childrenByParent: widget.childrenByParent,
                      visibleIds: widget.visibleIds,
                      state: widget.state,
                      onTap: widget.onTap,
                      onEdit: widget.onEdit,
                      onDelete: widget.onDelete,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Single location card (expandable when it has children) ───────────────────

/// A compact summary card (same look as the parent card) for a single location.
/// When the location has its own visible children it becomes expandable and
/// renders them below as a nested children column.
class _GroupedLocationCard extends StatefulWidget {
  const _GroupedLocationCard({
    super.key,
    required this.location,
    required this.depth,
    required this.childrenByParent,
    required this.visibleIds,
    required this.state,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final LocationEntity location;
  final int depth;
  final Map<String?, List<LocationEntity>> childrenByParent;
  final Set<String> visibleIds;
  final UbicacionesLoaded state;
  final LocationTreeAction onTap;
  final LocationTreeAction onEdit;
  final LocationTreeAction onDelete;

  @override
  State<_GroupedLocationCard> createState() => _GroupedLocationCardState();
}

class _GroupedLocationCardState extends State<_GroupedLocationCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final location = widget.location;
    final state = widget.state;
    final animalCount = state.animalCounts[location.uuid] ?? 0;
    final averageWeight = state.averageWeights[location.uuid];
    final isCommunal = location.isCommunalMonteContainer;

    final visibleChildren = _visibleChildrenOf(
      location,
      widget.childrenByParent,
      widget.visibleIds,
    );
    final hasChildren = visibleChildren.isNotEmpty;
    final totalAnimalCount = (isCommunal || hasChildren)
        ? state.subtreeAnimalCounts[location.uuid]
        : null;

    int? ejidoCount;
    int? ejidoTotalCapacity;
    if (isCommunal) {
      final ejidoChildren = state.allUbicaciones
          .where(
            (l) =>
                l.parentUuid == location.uuid && l.type == LocationType.ejido,
          )
          .toList(growable: false);
      ejidoCount = ejidoChildren.length;
      ejidoTotalCapacity = ejidoChildren.fold<int>(
        0,
        (sum, e) => sum + e.capacity,
      );
    }

    final card = LocationCard(
      key: ValueKey('grp_loc_${location.uuid}'),
      location: location,
      animalCount: animalCount,
      totalAnimalCount: totalAnimalCount,
      averageWeightKg: averageWeight,
      isNested: true,
      childCount: visibleChildren.length,
      isExpanded: _expanded,
      onToggleExpanded: hasChildren
          ? () => setState(() => _expanded = !_expanded)
          : null,
      hierarchyDepth: widget.depth,
      ejidoCount: ejidoCount,
      ejidoTotalCapacity: ejidoTotalCapacity,
      onTap: () => widget.onTap(location),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Slidable(
          key: ValueKey('grp_slide_${location.uuid}'),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.22,
            children: [
              SlidableAction(
                onPressed: (_) => widget.onEdit(location),
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                icon: Icons.edit_outlined,
                label: 'Editar',
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.22,
            children: [
              SlidableAction(
                onPressed: (_) => widget.onDelete(location),
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                label: 'Eliminar',
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(14),
                ),
              ),
            ],
          ),
          child: card,
        ),
        if (_expanded && hasChildren)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: _LocationChildrenColumn(
              parent: location,
              depth: widget.depth + 1,
              childrenByParent: widget.childrenByParent,
              visibleIds: widget.visibleIds,
              state: state,
              onTap: widget.onTap,
              onEdit: widget.onEdit,
              onDelete: widget.onDelete,
            ),
          ),
      ],
    );
  }
}
