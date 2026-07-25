/// features › ubicaciones › widgets › ubicaciones_filter_bar — rancho + category filter chips.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_category.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_card.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_labels.dart';

class UbicacionesFilterBar extends StatelessWidget {
  const UbicacionesFilterBar({
    super.key,
    required this.state,
    this.showCategoryFilter = true,
  });

  final UbicacionesLoaded state;

  /// When false, only the rancho chip row is shown (used inside scoped tab view).
  final bool showCategoryFilter;

  @override
  Widget build(BuildContext context) {
    final ranchos = state.allUbicaciones
        .where((l) => l.type.isRootType)
        .toList(growable: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ranchos.isNotEmpty) _buildRanchoRow(context, ranchos),
        if (showCategoryFilter) _buildCategoryRow(context),
        if (showCategoryFilter && state.hasActiveFilters) _buildClearRow(context),
      ],
    );
  }

  Widget _buildRanchoRow(
    BuildContext context,
    List<LocationEntity> ranchos,
  ) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        itemCount: ranchos.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = state.selectedRanchoUuid == null;
            return _FilterChip(
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
            label: rancho.name,
            icon: iconForLocationType(rancho.type),
            selected: isSelected,
            onSelected: (_) => context.read<UbicacionesBloc>().add(
              SelectParentFilter(isSelected ? null : rancho.uuid),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context) {
    return SizedBox(
      height: 48,
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
      child: FilterChip(
        selected: selected,
        label: Text(label),
        avatar: Icon(icon, size: 14),
        showCheckmark: false,
        onSelected: onSelected,
      ),
    );
  }
}
