/// features › ubicaciones › view › location_detail_widgets — display widgets for LocationDetailPage.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/utils/id_generator.dart';
import 'package:libretapp/features/agenda/bloc/agenda_bloc.dart';
import 'package:libretapp/features/agenda/bloc/agenda_event.dart';
import 'package:libretapp/features/agenda/bloc/agenda_state.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/widgets/agenda_form_sheet.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/inventory_item.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_growth_stage.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_task_type.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/widgets/inventory_item_form_sheet.dart';

// ─── LocationHeader ───────────────────────────────────────────────────────────

class LocationHeader extends StatelessWidget {
  const LocationHeader({required this.location, required this.animalsHere});

  final LocationEntity location;
  final List<AnimalEntity> animalsHere;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dominantSpecies = _dominantSpeciesLabel(animalsHere);
    final systemLabel = _systemLabel(location.type);
    final typeIcon = _typeIcon(location.type);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF214035), Color(0xFF2E5B46)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Última actualización ${location.costs.isNotEmpty ? location.costs.last.date : 'N/D'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    location.type.name.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    location.status.label.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(
                              typeIcon,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  location.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_capitalize(location.type.name)} • ${location.terrainType}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary
                                        .withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const _MiniMapPlaceholder(),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoPill(
                  icon: Icons.badge_outlined,
                  label: dominantSpecies ?? 'Especie sin asignar',
                ),
                _InfoPill(icon: Icons.safety_divider, label: systemLabel),
                _InfoPill(
                  icon: Icons.water_drop_outlined,
                  label: location.waterSource,
                ),
                _InfoPill(
                  icon: Icons.landscape_outlined,
                  label: location.terrainType,
                ),
                _InfoPill(
                  icon: Icons.straighten,
                  label:
                      '${location.surfaceArea.toStringAsFixed(1)} ha superficie',
                ),
                _InfoPill(
                  icon: Icons.groups,
                  label: '${location.capacity} capacidad',
                ),
              ],
            ),

            const SizedBox(height: 12),
            const _GalleryStrip(),
          ],
        ),
      ),
    );
  }
}

IconData _typeIcon(LocationType type) {
  switch (type) {
    case LocationType.potrero:
      return Icons.agriculture_outlined;
    case LocationType.monte:
      return Icons.landscape_outlined;
    case LocationType.corral:
      return Icons.yard_outlined;
    case LocationType.almacenamiento:
      return Icons.warehouse_outlined;
    case LocationType.aguada:
      return Icons.water_outlined;
    case LocationType.rancho:
      return Icons.home_work_outlined;
    case LocationType.siembra:
      return Icons.grain_outlined;
    case LocationType.casa:
      return Icons.house_outlined;
  }
}

String _systemLabel(LocationType type) {
  switch (type) {
    case LocationType.potrero:
      return 'Pastoreo';
    case LocationType.monte:
      return 'Pastoreo extensivo';
    case LocationType.corral:
      return 'Confinamiento';
    case LocationType.almacenamiento:
      return 'Almacén';
    case LocationType.aguada:
      return 'Conservación agua';
    case LocationType.rancho:
      return 'Mixto';
    case LocationType.siembra:
      return 'Pastoreo / rotación';
    case LocationType.casa:
      return 'Habitacional';
  }
}

String? _dominantSpeciesLabel(List<AnimalEntity> animals) {
  if (animals.isEmpty) return null;
  final counts = <Species, int>{};
  for (final animal in animals) {
    counts[animal.species] = (counts[animal.species] ?? 0) + 1;
  }
  final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
  return top.key.displayName;
}

// ─── InfoPill ─────────────────────────────────────────────────────────────────

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MiniMapPlaceholder ───────────────────────────────────────────────────────

class _MiniMapPlaceholder extends StatelessWidget {
  const _MiniMapPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Icon(
              Icons.map_outlined,
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              size: 80,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'GPS pendiente',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── GalleryStrip ─────────────────────────────────────────────────────────────

class _GalleryStrip extends StatelessWidget {
  const _GalleryStrip();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Container(
            width: 88,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.photo_outlined),
                const SizedBox(height: 6),
                Text(
                  index == 0 ? 'Agregar foto' : 'Foto ${index + 1}',
                  style: theme.textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── OccupancyCard ────────────────────────────────────────────────────────────

class OccupancyCard extends StatelessWidget {
  const OccupancyCard({required this.location, required this.animalsHere});

  final LocationEntity location;
  final List<AnimalEntity> animalsHere;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rawCapacity = location.capacity;
    final current = animalsHere.length;
    final ratio = rawCapacity <= 0 ? 0.0 : current / rawCapacity;
    final percent = (ratio * 100).clamp(0, 999).toDouble();
    final overCapacity = ratio > 1.0;
    final density = location.surfaceArea > 0
        ? current / location.surfaceArea
        : 0.0;

    final movementDates =
        animalsHere
            .map((a) => a.lastMovementDate)
            .whereType<DateTime>()
            .toList()
          ..sort();
    final entryDate = movementDates.isNotEmpty ? movementDates.first : null;
    final occupancyDays = entryDate == null
        ? null
        : DateTime.now().difference(entryDate).inDays;

    final lotCount = animalsHere
        .map((a) => a.batchUuid)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .length;

    final dominantSpecies = _dominantSpeciesLabel(animalsHere);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ocupación animal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _StatusChip(status: overCapacity ? 'Excedido' : 'En rango'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${percent.toStringAsFixed(0)}% carga animal',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: ratio.clamp(0, 1),
                          minHeight: 12,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          color: overCapacity
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                      ),
                      if (overCapacity)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Capacidad sobrepasada: reasigna o mueve animales',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _MetricBadge(
                      label: 'Animales',
                      value: '$current',
                      icon: Icons.pets_outlined,
                    ),
                    const SizedBox(height: 8),
                    _MetricBadge(
                      label: 'Capacidad',
                      value: rawCapacity > 0 ? '$rawCapacity' : 'Sin dato',
                      icon: Icons.inventory_2_outlined,
                    ),
                    const SizedBox(height: 8),
                    _MetricBadge(
                      label: 'Densidad',
                      value: '${density.toStringAsFixed(2)} cab/ha',
                      icon: Icons.bubble_chart_outlined,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricBadge(
                  label: 'Días de ocupación',
                  value: occupancyDays == null ? 'N/D' : '$occupancyDays días',
                  icon: Icons.calendar_today_outlined,
                ),
                _MetricBadge(
                  label: 'Entrada lote',
                  value: entryDate == null
                      ? 'Sin fecha'
                      : '${entryDate.day}/${entryDate.month}/${entryDate.year}',
                  icon: Icons.login_outlined,
                ),
                _MetricBadge(
                  label: 'Lotes presentes',
                  value: lotCount == 0 ? 'Sin lotes' : '$lotCount lotes',
                  icon: Icons.view_list_outlined,
                ),
                _MetricBadge(
                  label: 'Especie dominante',
                  value: dominantSpecies ?? 'Sin animales',
                  icon: Icons.compass_calibration_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── InventorySection ─────────────────────────────────────────────────────────

class InventorySection extends StatelessWidget {
  const InventorySection({required this.location});

  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastWater = location.waters.isNotEmpty ? location.waters.last : null;
    final lastShade = location.shades.isNotEmpty ? location.shades.last : null;
    final lastPasture = location.pastures.isNotEmpty
        ? location.pastures.last
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Inventarios del potrero',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.storage_rounded),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 620;
                final itemWidth = isWide
                    ? (constraints.maxWidth - 12) / 2
                    : constraints.maxWidth;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _InventoryTile(
                        title: 'Agua',
                        icon: Icons.water_drop_outlined,
                        percent: lastWater?.level,
                        subtitle: location.waterSource,
                        meta: lastWater == null
                            ? 'Sin lecturas'
                            : 'Tipo ${_capitalize(lastWater.type.name)}',
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _InventoryTile(
                        title: 'Sombra / confort',
                        icon: Icons.park_outlined,
                        percent: lastShade?.shadePercent,
                        subtitle:
                            lastShade?.condition ?? 'Condición no registrada',
                        meta: 'Cobertura natural o artificial',
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _InventoryTile(
                        title: 'Forraje / pasto',
                        icon: Icons.grass_outlined,
                        percent: lastPasture?.carryingCapacity == null
                            ? null
                            : (lastPasture!.carryingCapacity * 10)
                                  .clamp(0, 100)
                                  .toDouble(),
                        subtitle:
                            lastPasture?.grassType ??
                            'Tipo de pasto no definido',
                        meta: lastPasture == null
                            ? 'Capacidad de carga sin registrar'
                            : 'Condición ${lastPasture.condition}',
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _InventoryTile(
                        title: 'Minerales y sal',
                        icon: Icons.scatter_plot_outlined,
                        percent: location.salts.isEmpty
                            ? null
                            : (50 + (10 * location.salts.length).clamp(0, 50))
                                  .toDouble(),
                        subtitle: 'Suministro estimado',
                        meta: location.salts.isEmpty
                            ? 'Registra ingestas para ver autonomía'
                            : 'Aplicaciones: ${location.salts.length}',
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ConditionSection ─────────────────────────────────────────────────────────

class ConditionSection extends StatelessWidget {
  const ConditionSection({required this.location});

  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    double rain7 = 0;
    double rain30 = 0;
    DateTime? lastRainDate;
    double? lastRainMm;

    for (final rain in location.rains) {
      final diff = now.difference(rain.date).inDays;
      if (diff <= 30) rain30 += rain.millimeters;
      if (diff <= 7) rain7 += rain.millimeters;
      if (lastRainDate == null || rain.date.isAfter(lastRainDate)) {
        lastRainDate = rain.date;
        lastRainMm = rain.millimeters;
      }
    }

    final lastPasture = location.pastures.isNotEmpty
        ? location.pastures.last
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Condición del área',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.eco_outlined),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _ConditionRow(
                  icon: Icons.grass_outlined,
                  label: 'Condición pasto',
                  value: lastPasture?.condition ?? 'Sin registrar',
                ),
                _ConditionRow(
                  icon: Icons.cloudy_snowing,
                  label: 'Última lluvia',
                  value: lastRainDate == null
                      ? 'Sin registros'
                      : '${lastRainMm?.toStringAsFixed(1) ?? '-'} mm • ${lastRainDate.day}/${lastRainDate.month}',
                ),
                _ConditionRow(
                  icon: Icons.water_outlined,
                  label: 'Lluvia 7 días',
                  value: '${rain7.toStringAsFixed(1)} mm',
                ),
                _ConditionRow(
                  icon: Icons.water_outlined,
                  label: 'Lluvia 30 días',
                  value: '${rain30.toStringAsFixed(1)} mm',
                ),
                const _ConditionRow(
                  icon: Icons.warning_amber_outlined,
                  label: 'Erosión',
                  value: 'Inspección visual pendiente',
                ),
                const _ConditionRow(
                  icon: Icons.local_florist_outlined,
                  label: 'Maleza / arbustos',
                  value: 'Monitorea maleza y plantas tóxicas',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── InfrastructureSection ────────────────────────────────────────────────────

class InfrastructureSection extends StatelessWidget {
  const InfrastructureSection({required this.location});

  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastWater = location.waters.isNotEmpty ? location.waters.last : null;
    final lastShade = location.shades.isNotEmpty ? location.shades.last : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Infraestructura',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.foundation_outlined),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _ConditionRow(
                  icon: Icons.water_drop_outlined,
                  label: 'Bebederos',
                  value: lastWater == null
                      ? 'Sin registrar'
                      : 'Fuente ${_capitalize(lastWater.type.name)}',
                ),
                _ConditionRow(
                  icon: Icons.park_outlined,
                  label: 'Sombras',
                  value: lastShade == null
                      ? 'Pendiente'
                      : '${lastShade.shadePercent.toStringAsFixed(0)}% • ${lastShade.condition}',
                ),
                const _ConditionRow(
                  icon: Icons.fence_outlined,
                  label: 'Cercos',
                  value: 'Estado pendiente de inspección',
                ),
                const _ConditionRow(
                  icon: Icons.agriculture_outlined,
                  label: 'Comederos / saladeros',
                  value: 'Registrar inspección y limpieza',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── WarehouseSection ─────────────────────────────────────────────────────────

class WarehouseSection extends StatelessWidget {
  const WarehouseSection({required this.location});

  final LocationEntity location;

  Future<void> _showAddSheet(BuildContext context) async {
    final item = await showModalBottomSheet<InventoryItem>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const InventoryItemFormSheet(),
    );
    if (item != null && context.mounted) {
      context.read<UbicacionesBloc>().add(
        AddInventoryItemEvent(location.uuid, item),
      );
    }
  }

  Future<void> _showEditSheet(BuildContext context, InventoryItem item) async {
    final updated = await showModalBottomSheet<InventoryItem>(
      context: context,
      isScrollControlled: true,
      builder: (_) => InventoryItemFormSheet(initial: item),
    );
    if (updated != null && context.mounted) {
      context.read<UbicacionesBloc>().add(
        UpdateInventoryItemEvent(location.uuid, updated),
      );
    }
  }

  void _confirmDelete(BuildContext context, InventoryItem item) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar artículo'),
        content: Text('¿Eliminar "${item.name}" del inventario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<UbicacionesBloc>().add(
          RemoveInventoryItemEvent(location.uuid, item.uuid),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = location.inventory;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Inventario',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.warehouse_outlined),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Sin artículos registrados.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ...items.map(
                (item) => _InventoryItemTile(
                  item: item,
                  onEdit: () => _showEditSheet(context, item),
                  onDelete: () => _confirmDelete(context, item),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar artículo'),
                onPressed: () => _showAddSheet(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── InventoryItemTile ────────────────────────────────────────────────────────

class _InventoryItemTile extends StatelessWidget {
  const _InventoryItemTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final InventoryItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.category.icon,
              size: 18,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${item.quantity} ${item.unit}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (item.isLowStock) ...[
                      const SizedBox(width: 6),
                      _Badge(
                        label: 'Stock bajo',
                        color: theme.colorScheme.errorContainer,
                        textColor: theme.colorScheme.onErrorContainer,
                      ),
                    ],
                    if (item.isExpired) ...[
                      const SizedBox(width: 6),
                      _Badge(
                        label: 'Vencido',
                        color: theme.colorScheme.errorContainer,
                        textColor: theme.colorScheme.onErrorContainer,
                      ),
                    ] else if (item.isExpiringSoon) ...[
                      const SizedBox(width: 6),
                      _Badge(
                        label: 'Por vencer',
                        color: theme.colorScheme.tertiaryContainer,
                        textColor: theme.colorScheme.onTertiaryContainer,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: onEdit,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 18,
              color: theme.colorScheme.error,
            ),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ─── Badge ────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.textColor,
  });
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ─── LocationRecords ──────────────────────────────────────────────────────────

class LocationRecords extends StatelessWidget {
  const LocationRecords({required this.location});

  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bitácora',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _RecordCount(label: 'Visitas', count: location.visits.length),
                _RecordCount(label: 'Agua', count: location.waters.length),
                _RecordCount(label: 'Sal', count: location.salts.length),
                _RecordCount(label: 'Sombra', count: location.shades.length),
                _RecordCount(
                  label: 'Pasturas',
                  count: location.pastures.length,
                ),
                _RecordCount(label: 'Siembra', count: location.seedings.length),
                _RecordCount(
                  label: 'Riego',
                  count: location.irrigations.length,
                ),
                _RecordCount(label: 'Lluvia', count: location.rains.length),
                _RecordCount(label: 'Costos', count: location.costs.length),
                _RecordCount(label: 'Cultivos', count: location.crops.length),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── MetricBadge ──────────────────────────────────────────────────────────────

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── InventoryTile ────────────────────────────────────────────────────────────

class _InventoryTile extends StatelessWidget {
  const _InventoryTile({
    required this.title,
    required this.icon,
    required this.subtitle,
    required this.meta,
    this.percent,
  });

  final String title;
  final IconData icon;
  final double? percent;
  final String subtitle;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayPercent = percent?.clamp(0, 100).toDouble();
    final barColor = displayPercent == null
        ? theme.colorScheme.surfaceContainerHighest
        : displayPercent >= 75
        ? theme.colorScheme.primary
        : displayPercent >= 40
        ? theme.colorScheme.secondary
        : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: barColor.withValues(alpha: 0.18),
                child: Icon(icon, color: barColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Text(
                displayPercent == null
                    ? 'N/D'
                    : '${displayPercent.toStringAsFixed(0)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: displayPercent == null
                  ? 0
                  : (displayPercent / 100).clamp(0, 1),
              minHeight: 10,
              backgroundColor: theme.colorScheme.surface,
              color: barColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            meta,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ConditionRow ─────────────────────────────────────────────────────────────

class _ConditionRow extends StatelessWidget {
  const _ConditionRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── UpcomingTasksCard ────────────────────────────────────────────────────────

class UpcomingTasksCard extends StatelessWidget {
  const UpcomingTasksCard({required this.location, required this.onComplete});

  final LocationEntity location;
  final void Function(String cropUuid, String taskUuid) onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final allTasks = <({CropRecord crop, CropTask task})>[];
    for (final crop in location.crops) {
      if (crop.status != CropStatus.active) continue;
      for (final task in crop.tasks) {
        if (!task.completed) {
          allTasks.add((crop: crop, task: task));
        }
      }
      if (crop.isOverdueForWatering) {
        allTasks.add((
          crop: crop,
          task: CropTask(
            uuid: 'auto-water-${crop.uuid}',
            type: CropTaskType.water,
            dueDate: crop.nextWateringDate ?? now,
            notes: 'Riego atrasado',
          ),
        ));
      }
      final daysLeft = crop.daysUntilHarvest;
      if (daysLeft != null && daysLeft <= 7 && daysLeft >= 0) {
        allTasks.add((
          crop: crop,
          task: CropTask(
            uuid: 'auto-harvest-${crop.uuid}',
            type: CropTaskType.harvest,
            dueDate: crop.expectedHarvestDate ?? now,
            notes: '$daysLeft días para cosecha',
          ),
        ));
      }
    }

    allTasks.sort((a, b) => a.task.dueDate.compareTo(b.task.dueDate));

    if (allTasks.isEmpty) return const SizedBox.shrink();

    return Card(
      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pending_actions_outlined,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tareas pendientes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...allTasks.take(8).map((entry) {
              final isOverdue = entry.task.dueDate.isBefore(now);
              final isAuto = entry.task.uuid.startsWith('auto-');
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    if (!isAuto)
                      InkWell(
                        onTap: () =>
                            onComplete(entry.crop.uuid, entry.task.uuid),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    else
                      Icon(
                        isOverdue
                            ? Icons.warning_amber_outlined
                            : Icons.info_outline,
                        size: 20,
                        color: isOverdue
                            ? theme.colorScheme.error
                            : theme.colorScheme.tertiary,
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${entry.task.type.displayName} — ${entry.crop.cropName}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isOverdue ? theme.colorScheme.error : null,
                        ),
                      ),
                    ),
                    Text(
                      '${entry.task.dueDate.day}/${entry.task.dueDate.month}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOverdue
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── CropsSection ─────────────────────────────────────────────────────────────

class CropsSection extends StatelessWidget {
  const CropsSection({
    required this.location,
    required this.onAddCrop,
    required this.onEditCrop,
    required this.onDeleteCrop,
    required this.onWaterCrop,
    required this.onHarvestCrop,
    required this.onHealthCrop,
    required this.onAddTask,
    required this.onCompleteTask,
  });

  final LocationEntity location;
  final VoidCallback onAddCrop;
  final ValueChanged<CropRecord> onEditCrop;
  final ValueChanged<CropRecord> onDeleteCrop;
  final ValueChanged<CropRecord> onWaterCrop;
  final ValueChanged<CropRecord> onHarvestCrop;
  final ValueChanged<CropRecord> onHealthCrop;
  final ValueChanged<CropRecord> onAddTask;
  final void Function(CropRecord crop, String taskUuid) onCompleteTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeCrops = location.crops
        .where((c) => c.status == CropStatus.active)
        .toList();
    final pastCrops = location.crops
        .where((c) => c.status != CropStatus.active)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Cultivos (${location.crops.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onAddCrop,
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (location.crops.isEmpty) const Text('Sin cultivos registrados'),
            if (activeCrops.isNotEmpty) ...[
              Text(
                'Activos',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...activeCrops.map(
                (crop) => _CropTile(
                  crop: crop,
                  onEdit: () => onEditCrop(crop),
                  onDelete: () => onDeleteCrop(crop),
                  onWater: () => onWaterCrop(crop),
                  onHarvest: () => onHarvestCrop(crop),
                  onHealth: () => onHealthCrop(crop),
                  onAddTask: () => onAddTask(crop),
                  onCompleteTask: (taskUuid) => onCompleteTask(crop, taskUuid),
                ),
              ),
            ],
            if (pastCrops.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Anteriores',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              ...pastCrops.map(
                (crop) => _CropTile(
                  crop: crop,
                  onEdit: () => onEditCrop(crop),
                  onDelete: () => onDeleteCrop(crop),
                  onWater: null,
                  onHarvest: null,
                  onHealth: null,
                  onAddTask: null,
                  onCompleteTask: null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── CropTile ─────────────────────────────────────────────────────────────────

class _CropTile extends StatelessWidget {
  const _CropTile({
    required this.crop,
    required this.onEdit,
    required this.onDelete,
    required this.onWater,
    required this.onHarvest,
    required this.onHealth,
    required this.onAddTask,
    required this.onCompleteTask,
  });

  final CropRecord crop;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onWater;
  final VoidCallback? onHarvest;
  final VoidCallback? onHealth;
  final VoidCallback? onAddTask;
  final ValueChanged<String>? onCompleteTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = crop.status == CropStatus.active;
    final overdue = crop.isOverdueForWatering;
    final daysLeft = crop.daysUntilHarvest;
    final pendingTasks = crop.tasks.where((t) => !t.completed).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: overdue
            ? Border.all(color: theme.colorScheme.error.withValues(alpha: 0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isActive
                    ? theme.colorScheme.primary.withValues(alpha: 0.15)
                    : theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.eco_outlined,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop.cropName +
                          (crop.variety.isNotEmpty ? ' (${crop.variety})' : ''),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${crop.growthStage.displayName} • ${crop.status.displayName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _CropInfoChip(
                icon: Icons.calendar_today_outlined,
                label:
                    'Siembra: ${crop.plantingDate.day}/${crop.plantingDate.month}/${crop.plantingDate.year}',
              ),
              if (crop.expectedHarvestDate != null)
                _CropInfoChip(
                  icon: Icons.event_outlined,
                  label: daysLeft != null && daysLeft >= 0
                      ? 'Cosecha en $daysLeft días'
                      : 'Cosecha: ${crop.expectedHarvestDate!.day}/${crop.expectedHarvestDate!.month}',
                  isWarning: daysLeft != null && daysLeft <= 7,
                ),
              if (crop.lastWateredDate != null)
                _CropInfoChip(
                  icon: Icons.water_drop_outlined,
                  label: overdue
                      ? 'Riego atrasado'
                      : 'Regado: ${crop.lastWateredDate!.day}/${crop.lastWateredDate!.month}',
                  isError: overdue,
                ),
              if (crop.lastWateredDate == null && isActive)
                const _CropInfoChip(
                  icon: Icons.water_drop_outlined,
                  label: 'Sin riego registrado',
                  isError: true,
                ),
              if (crop.surface > 0)
                _CropInfoChip(
                  icon: Icons.straighten_outlined,
                  label: '${crop.surface.toStringAsFixed(1)} ha',
                ),
              if (crop.totalYieldKg > 0)
                _CropInfoChip(
                  icon: Icons.scale_outlined,
                  label: '${crop.totalYieldKg.toStringAsFixed(1)} kg cosechado',
                ),
              _CropInfoChip(
                icon: Icons.water_drop,
                label: 'Riegos: ${crop.waterings.length}',
              ),
              if (crop.harvests.isNotEmpty)
                _CropInfoChip(
                  icon: Icons.agriculture_outlined,
                  label: 'Cosechas: ${crop.harvests.length}',
                ),
              if (crop.healthRecords.isNotEmpty)
                _CropInfoChip(
                  icon: Icons.bug_report_outlined,
                  label: 'Salud: ${crop.healthRecords.length}',
                ),
            ],
          ),

          if (pendingTasks.isNotEmpty && isActive) ...[
            const SizedBox(height: 8),
            ...pendingTasks
                .take(3)
                .map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => onCompleteTask?.call(task.uuid),
                          child: Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: task.isOverdue
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${task.type.displayName} — ${task.dueDate.day}/${task.dueDate.month}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: task.isOverdue
                                  ? theme.colorScheme.error
                                  : null,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],

          if (isActive) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _CropActionChip(
                  icon: Icons.water_drop_outlined,
                  label: 'Regar',
                  onPressed: onWater,
                ),
                _CropActionChip(
                  icon: Icons.agriculture_outlined,
                  label: 'Cosechar',
                  onPressed: onHarvest,
                ),
                _CropActionChip(
                  icon: Icons.bug_report_outlined,
                  label: 'Salud',
                  onPressed: onHealth,
                ),
                _CropActionChip(
                  icon: Icons.add_task_outlined,
                  label: 'Tarea',
                  onPressed: onAddTask,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── CropInfoChip ─────────────────────────────────────────────────────────────

class _CropInfoChip extends StatelessWidget {
  const _CropInfoChip({
    required this.icon,
    required this.label,
    this.isWarning = false,
    this.isError = false,
  });

  final IconData icon;
  final String label;
  final bool isWarning;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isError
        ? theme.colorScheme.error
        : isWarning
        ? Colors.orange
        : theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isError
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
            : isWarning
            ? Colors.orange.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CropActionChip ───────────────────────────────────────────────────────────

class _CropActionChip extends StatelessWidget {
  const _CropActionChip({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}

// ─── RecordActions ────────────────────────────────────────────────────────────

class RecordActions extends StatelessWidget {
  const RecordActions({
    required this.onVisit,
    required this.onWater,
    required this.onSalt,
    required this.onShade,
    required this.onPasture,
    required this.onCost,
  });

  final VoidCallback onVisit;
  final VoidCallback onWater;
  final VoidCallback onSalt;
  final VoidCallback onShade;
  final VoidCallback onPasture;
  final VoidCallback onCost;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registrar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionButton(
                  icon: Icons.fact_check_outlined,
                  label: 'Visita',
                  onPressed: onVisit,
                ),
                _ActionButton(
                  icon: Icons.water_drop_outlined,
                  label: 'Agua',
                  onPressed: onWater,
                ),
                _ActionButton(
                  icon: Icons.scatter_plot_outlined,
                  label: 'Sal',
                  onPressed: onSalt,
                ),
                _ActionButton(
                  icon: Icons.nature_outlined,
                  label: 'Sombra',
                  onPressed: onShade,
                ),
                _ActionButton(
                  icon: Icons.grass_outlined,
                  label: 'Pastura',
                  onPressed: onPasture,
                ),
                _ActionButton(
                  icon: Icons.payments_outlined,
                  label: 'Costo',
                  onPressed: onCost,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ActionButton ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }
}

// ─── AnimalsSection ───────────────────────────────────────────────────────────

class AnimalsSection extends StatelessWidget {
  const AnimalsSection({
    required this.animalsHere,
    required this.location,
    required this.assigning,
    required this.onAssign,
  });

  final List<AnimalEntity> animalsHere;
  final LocationEntity location;
  final bool assigning;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Animales (${animalsHere.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: assigning ? null : onAssign,
                  icon: const Icon(Icons.pets_outlined),
                  label: const Text('Asignar / mover'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (animalsHere.isEmpty)
              const Text('Sin animales en esta ubicación')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: animalsHere.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final animal = animalsHere[index];
                  final subtitle = _animalSubtitle(animal);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_animalTitle(animal)),
                    subtitle: subtitle == null ? null : Text(subtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        context.push(AppRoutes.animalDetallePath(animal.uuid)),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _animalTitle(AnimalEntity animal) {
    return animal.earTagNumber.isNotEmpty
        ? animal.earTagNumber
        : (animal.visualId?.isNotEmpty == true ? animal.visualId! : 'Animal');
  }

  String? _animalSubtitle(AnimalEntity animal) {
    final breed = animal.breed;
    final species = animal.species.displayName;
    final stage = animal.lifeStage.displayName;
    final pieces = [breed, species, stage].where((e) => e.isNotEmpty).toList();
    if (pieces.isEmpty) return null;
    return pieces.join(' • ');
  }
}

// ─── ActionsRow ───────────────────────────────────────────────────────────────

class ActionsRow extends StatelessWidget {
  const ActionsRow({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar ubicación'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Eliminar'),
          ),
        ),
      ],
    );
  }
}

// ─── RecordCount ──────────────────────────────────────────────────────────────

class _RecordCount extends StatelessWidget {
  const _RecordCount({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(width: 6),
        CircleAvatar(
          radius: 12,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.12),
          child: Text(
            '$count',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── StatusChip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(_capitalize(status)),
      backgroundColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: theme.colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─── ActivitiesSection ────────────────────────────────────────────────────────

class ActivitiesSection extends StatelessWidget {
  const ActivitiesSection({required this.location});

  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AgendaBloc, AgendaState>(
      builder: (context, state) {
        final entries = state is AgendaLoaded
            ? state.entries
                  .where((e) => e.locationUuid == location.uuid)
                  .toList()
            : <AgendaEntry>[];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Actividades',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Icon(Icons.event_note_outlined),
                  ],
                ),
                const SizedBox(height: 12),
                if (state is AgendaLoading)
                  const Center(child: CircularProgressIndicator())
                else if (entries.isEmpty)
                  Text(
                    'Sin actividades programadas.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  ...entries.map((entry) => _AgendaEntryTile(entry: entry)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Agregar actividad'),
                    onPressed: () => _showAddActivity(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddActivity(BuildContext context) {
    final bloc = context.read<AgendaBloc>();
    final ubBloc = context.read<UbicacionesBloc>();
    final allLocations = ubBloc.state is UbicacionesLoaded
        ? (ubBloc.state as UbicacionesLoaded).allUbicaciones
        : <LocationEntity>[];
    showAgendaFormSheet(
      context: context,
      initialDate: DateTime.now(),
      locations: allLocations,
      entry: AgendaEntry(
        id: '',
        titulo: '',
        descripcion: '',
        fecha: DateTime.now(),
        tipo: 'General',
        animalIds: const [],
        loteIds: const [],
        ubicacion: location.name,
        estado: AgendaEstado.pendiente,
        completedAnimalIds: const [],
        notas: '',
        locationUuid: location.uuid,
      ),
      onSave: (saved) {
        bloc.add(AddAgendaEntry(saved.copyWith(id: generateId())));
      },
    );
  }
}

// ─── AgendaEntryTile ──────────────────────────────────────────────────────────

class _AgendaEntryTile extends StatelessWidget {
  const _AgendaEntryTile({required this.entry});

  final AgendaEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = entry.estado == AgendaEstado.completado;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCompleted
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_outline
                  : Icons.radio_button_unchecked,
              size: 18,
              color: isCompleted
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.titulo,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '${entry.tipo} · '
                  '${entry.fecha.day.toString().padLeft(2, '0')}/'
                  '${entry.fecha.month.toString().padLeft(2, '0')}/'
                  '${entry.fecha.year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
