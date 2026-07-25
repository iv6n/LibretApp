/// features › ubicaciones › view › ubicaciones_scoped_tab_view — tabbed sub-location view for a selected root.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_category.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/view/ubicaciones_tree_builder.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_card.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_labels.dart';

typedef _LocationAction = void Function(LocationEntity location);

/// Tabbed view showing all sub-locations of [rootLocation] grouped by category.
///
/// The header combines a rancho chip row (for switching ranchos) with a
/// [TabBar] for filtering by category — no separate title strip is needed
/// since the selected rancho chip already conveys context.
class UbicacionesScopedTabView extends StatefulWidget {
  const UbicacionesScopedTabView({
    super.key,
    required this.rootLocation,
    required this.state,
    required this.listBottomPadding,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final LocationEntity rootLocation;
  final UbicacionesLoaded state;
  final double listBottomPadding;
  final _LocationAction onTap;
  final _LocationAction onEdit;
  final _LocationAction onDelete;

  @override
  State<UbicacionesScopedTabView> createState() =>
      _UbicacionesScopedTabViewState();
}

class _UbicacionesScopedTabViewState extends State<UbicacionesScopedTabView>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<LocationCategory> _tabs = const [];
  Map<LocationCategory, List<LocationEntity>> _byCategory = const {};

  @override
  void initState() {
    super.initState();
    _rebuildTabs();
  }

  @override
  void didUpdateWidget(covariant UbicacionesScopedTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rootLocation.uuid != widget.rootLocation.uuid ||
        !identical(
          oldWidget.state.allUbicaciones,
          widget.state.allUbicaciones,
        )) {
      _rebuildTabs();
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _rebuildTabs() {
    // Always refresh byCategory so content stays current even when tab set is unchanged.
    _byCategory = UbicacionesTreeBuilder.descendantsByCategory(
      rootUuid: widget.rootLocation.uuid,
      allLocations: widget.state.allUbicaciones,
    );
    final newTabs = LocationCategory.values
        .where((c) => _byCategory.containsKey(c))
        .toList(growable: false);

    // Only recreate the controller when the tab set actually changes.
    if (_listsEqual(newTabs, _tabs) && _tabController != null) return;
    _tabController?.dispose();
    _tabs = newTabs;
    _tabController = _tabs.isEmpty
        ? null
        : TabController(length: _tabs.length, vsync: this);
  }

  bool _listsEqual(List<LocationCategory> a, List<LocationCategory> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _tabController;

    if (controller == null || _tabs.isEmpty) {
      return _buildEmptyState(context);
    }

    final useScrollable = _tabs.length > 3;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Unified Material header — rancho info + category tabs.
        _ScopedTabHeader(
          rootLocation: widget.rootLocation,
          state: widget.state,
          tabs: _tabs,
          controller: controller,
          useScrollable: useScrollable,
        ),
        // Category tab content.
        Expanded(
          child: ColoredBox(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.25,
            ),
            child: TabBarView(
              controller: controller,
              children: _tabs.map((cat) {
                final locations = _byCategory[cat] ?? const [];
                return _CategoryTabContent(
                  category: cat,
                  locations: locations,
                  state: widget.state,
                  listBottomPadding: widget.listBottomPadding,
                  onTap: widget.onTap,
                  onEdit: widget.onEdit,
                  onDelete: widget.onDelete,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_location_alt_outlined,
              size: 56,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin sub-ubicaciones',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega sub-ubicaciones a ${widget.rootLocation.name} usando el botón +.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Unified header: location identity + category tab bar ─────────────────────

class _ScopedTabHeader extends StatelessWidget {
  const _ScopedTabHeader({
    required this.rootLocation,
    required this.state,
    required this.tabs,
    required this.controller,
    required this.useScrollable,
  });

  final LocationEntity rootLocation;
  final UbicacionesLoaded state;
  final List<LocationCategory> tabs;
  final TabController controller;
  final bool useScrollable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final typeColor = locationTypeColor(rootLocation.type);
    final subtreeCount = state.subtreeAnimalCounts[rootLocation.uuid] ?? 0;
    final subCount = state.allUbicaciones
        .where((l) => l.parentUuid == rootLocation.uuid)
        .length;

    final parts = [
      if (subCount > 0) '$subCount sub-ubic.',
      if (subtreeCount > 0) '$subtreeCount animales',
    ];

    return Material(
      color: colorScheme.surface,
      elevation: 1,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Location identity row.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                // Back chevron.
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  tooltip: 'Todas las ubicaciones',
                  onPressed: () => context.read<UbicacionesBloc>().add(
                    const SelectParentFilter(null),
                  ),
                ),
                const SizedBox(width: 4),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: typeColor.withValues(alpha: 0.12),
                  child: LocationTypeAvatar(
                    type: rootLocation.type,
                    radius: 13,
                    backgroundColor: Colors.transparent,
                    fallbackColor: typeColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        rootLocation.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (parts.isNotEmpty)
                        Text(
                          parts.join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: rootLocation.status.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          // Category tab bar.
          TabBar(
            controller: controller,
            isScrollable: useScrollable,
            tabAlignment: useScrollable
                ? TabAlignment.start
                : TabAlignment.fill,
            dividerColor: Colors.transparent,
            tabs: tabs
                .map(
                  (cat) => Tab(
                    icon: Icon(iconForLocationCategory(cat), size: 18),
                    text: locationCategoryLabelByLanguage(
                      cat,
                      Localizations.localeOf(context).languageCode,
                    ),
                    iconMargin: const EdgeInsets.only(bottom: 2),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Category tab content ─────────────────────────────────────────────────────

class _CategoryTabContent extends StatelessWidget {
  const _CategoryTabContent({
    required this.category,
    required this.locations,
    required this.state,
    required this.listBottomPadding,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final LocationCategory category;
  final List<LocationEntity> locations;
  final UbicacionesLoaded state;
  final double listBottomPadding;
  final _LocationAction onTap;
  final _LocationAction onEdit;
  final _LocationAction onDelete;

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) {
      return Center(
        child: Text(
          'No hay ${locationCategoryLabelByLanguage(category, Localizations.localeOf(context).languageCode).toLowerCase()} en esta ubicación',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final allByUuid = {for (final l in state.allUbicaciones) l.uuid: l};

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(12, 10, 12, listBottomPadding),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        final animalCount = state.animalCounts[location.uuid] ?? 0;
        final subtreeCount = state.subtreeAnimalCounts[location.uuid] ?? 0;
        final parentName = location.parentUuid != null
            ? allByUuid[location.parentUuid]?.name
            : null;

        return Slidable(
          key: ValueKey(location.uuid),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.45,
            children: [
              SlidableAction(
                onPressed: (_) => onEdit(location),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                icon: Icons.edit_outlined,
                label: 'Editar',
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
              SlidableAction(
                onPressed: (_) => onDelete(location),
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                icon: Icons.delete_outline,
                label: 'Eliminar',
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(12),
                ),
              ),
            ],
          ),
          child: LocationCard(
            location: location,
            animalCount: animalCount,
            totalAnimalCount: subtreeCount != animalCount ? subtreeCount : null,
            parentName: parentName,
            isNested: true,
            hierarchyDepth: 1,
            onTap: () => onTap(location),
          ),
        );
      },
    );
  }
}
