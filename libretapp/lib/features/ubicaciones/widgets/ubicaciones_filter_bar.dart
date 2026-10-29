/// features › ubicaciones › widgets › ubicaciones_filter_bar — rancho + category filter chips.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/widgets/app_directory_filter_chip.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_category.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_card.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_labels.dart';

class UbicacionesFilterBar extends StatefulWidget {
  const UbicacionesFilterBar({
    super.key,
    required this.state,
    this.showCategoryFilter = true,
  });

  final UbicacionesLoaded state;

  /// When false, only the rancho chip row is shown (used inside scoped tab view).
  final bool showCategoryFilter;

  @override
  State<UbicacionesFilterBar> createState() => _UbicacionesFilterBarState();
}

class _UbicacionesFilterBarState extends State<UbicacionesFilterBar> {
  bool _categoriesOpen = false;
  UbicacionesLoaded get state => widget.state;

  @override
  Widget build(BuildContext context) {
    final roots = state.allUbicaciones
        .where((location) => location.parentUuid == null)
        .toList(growable: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (roots.length >= 2)
              Expanded(child: _buildRanchoRow(context, roots)),
            if (widget.showCategoryFilter)
              IconButton(
                tooltip: _categoriesOpen
                    ? 'Ocultar categorías'
                    : 'Filtrar categorías',
                icon: state.selectedCategoryFilters.isEmpty
                    ? const Icon(Icons.tune_outlined)
                    : Badge.count(
                        count: state.selectedCategoryFilters.length,
                        child: const Icon(Icons.tune_outlined),
                      ),
                onPressed: () =>
                    setState(() => _categoriesOpen = !_categoriesOpen),
              ),
          ],
        ),
        if (widget.showCategoryFilter && _categoriesOpen)
          _buildCategoryRow(context),
        if (widget.showCategoryFilter && state.hasActiveFilters)
          _buildClearRow(context),
      ],
    );
  }

  Widget _buildRanchoRow(BuildContext context, List<LocationEntity> ranchos) {
    return SizedBox(
      key: const ValueKey('ubicaciones-root-filter-row'),
      height: 60,
      child: Stack(
        children: [
          ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            itemCount: ranchos.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = state.selectedRanchoUuid == null;
                return _FilterChip(
                  key: const ValueKey('ubicaciones-root-filter-all'),
                  label: 'Todos',
                  icon: Icons.home_work_outlined,
                  selected: isSelected,
                  onSelected: (_) => context.read<UbicacionesBloc>().add(
                    const SelectParentFilter(null),
                  ),
                );
              }
              final rancho = ranchos[index - 1];
              final isSelected = state.selectedRanchoUuid == rancho.uuid;
              return _FilterChip(
                key: ValueKey<String>('ubicaciones-root-filter-${rancho.uuid}'),
                label: rancho.name,
                icon: iconForLocationType(rancho.type),
                selected: isSelected,
                onSelected: (_) => context.read<UbicacionesBloc>().add(
                  SelectParentFilter(isSelected ? null : rancho.uuid),
                ),
              );
            },
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: 26,
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(
                        context,
                      ).scaffoldBackgroundColor.withValues(alpha: 0),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                  ),
                ),
                child: const Icon(Icons.chevron_right, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context) {
    return SizedBox(
      key: const ValueKey('ubicaciones-category-filter-row'),
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        itemCount: LocationCategory.values.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final noneSelected = state.selectedCategoryFilters.isEmpty;
            return _FilterChip(
              label: 'Todas',
              icon: Icons.category_outlined,
              selected: noneSelected,
              onSelected: (_) => context.read<UbicacionesBloc>().add(
                const ClearCategoryFilters(),
              ),
            );
          }
          final category = LocationCategory.values[index - 1];
          final isSelected = state.selectedCategoryFilters.contains(category);
          return _FilterChip(
            label: locationCategoryLabel(context, category),
            icon: iconForLocationCategory(category),
            selected: isSelected,
            onSelected: (selected) {
              context.read<UbicacionesBloc>().add(
                ToggleCategoryFilter(category: category, selected: selected),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildClearRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () =>
              context.read<UbicacionesBloc>().add(const ClearAllFilters()),
          icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
          label: const Text('Limpiar filtros'),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AppDirectoryFilterChip(
        selected: selected,
        label: label,
        icon: icon,
        onTap: () => onSelected(!selected),
      ),
    );
  }
}
