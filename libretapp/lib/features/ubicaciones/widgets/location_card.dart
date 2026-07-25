/// features › ubicaciones › widgets › location_card — card widget for displaying a location.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_category.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_labels.dart';
import 'package:libretapp/theme/app_theme.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.location,
    required this.animalCount,
    required this.onTap,
    this.totalAnimalCount,
    this.averageWeightKg,
    this.parentName,
    this.childCount = 0,
    this.isExpanded = false,
    this.onToggleExpanded,
    this.isNested = false,
    this.hierarchyDepth = 0,
    this.ejidoCount,
    this.ejidoTotalCapacity,
  });

  final LocationEntity location;
  final int animalCount;
  final int? totalAnimalCount;
  final double? averageWeightKg;
  final String? parentName;
  final int childCount;
  final bool isExpanded;
  final VoidCallback? onToggleExpanded;
  final bool isNested;
  final int hierarchyDepth;
  final VoidCallback onTap;

  /// Number of ejido-type direct children (for communal monte cards).
  final int? ejidoCount;

  /// Sum of capacity across all ejido-type direct children.
  final int? ejidoTotalCapacity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final typeColor = locationTypeColor(location.type);
    final isDark = theme.brightness == Brightness.dark;
    final summary = _locationSummary();
    final radius = isNested ? 16.0 : 20.0;

    final headerColor = isDark
        ? Color.alphaBlend(
            typeColor.withValues(alpha: 0.18 + hierarchyDepth * 0.02),
            colorScheme.surface,
          )
        : Color.alphaBlend(
            typeColor.withValues(alpha: 0.08 + hierarchyDepth * 0.02),
            colorScheme.surface,
          );
    final footerColor = isDark
        ? Color.alphaBlend(
            Colors.white.withValues(alpha: 0.04),
            colorScheme.surface,
          )
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45);

    return Card(
      margin: EdgeInsets.only(bottom: isNested ? 10 : 14),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: isNested
              ? typeColor.withValues(alpha: 0.34)
              : colorScheme.outlineVariant.withValues(alpha: 0.38),
          width: isNested ? 1.2 : 1,
        ),
      ),
      elevation: isNested ? 0.7 : 1.2,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: headerColor,
                    padding: const EdgeInsets.fromLTRB(12, 10, 10, 9),
                    child: Row(
                      children: [
                        LocationTypeAvatar(
                          type: location.type,
                          radius: isNested ? 24 : 28,
                          backgroundColor: typeColor.withValues(alpha: 0.12),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                location.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Wrap(
                                spacing: 7,
                                runSpacing: 2,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  _HeaderPill(
                                    icon: iconForLocationType(location.type),
                                    label: locationTypeLabel(
                                      context,
                                      location.type,
                                    ),
                                    color: typeColor,
                                  ),
                                  if (parentName != null)
                                    Text(
                                      '· $parentName',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                summary,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _StatusPill(status: location.status),
                            const SizedBox(height: 7),
                            Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (location.imagePaths.isNotEmpty)
                    _LocationImageStrip(imagePaths: location.imagePaths),
                  if (childCount > 0)
                    Container(
                      color: Color.alphaBlend(
                        typeColor.withValues(alpha: 0.05),
                        colorScheme.surface,
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 2),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: onToggleExpanded,
                          icon: Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          label: Text(
                            isExpanded
                                ? 'Ocultar sub-ubicaciones ($childCount)'
                                : '$childCount sub-ubicacion${childCount == 1 ? '' : 'es'}',
                          ),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            foregroundColor: typeColor,
                            textStyle: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Container(
                    color: footerColor,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    child: _BottomBar(
                      location: location,
                      animalCount: animalCount,
                      totalAnimalCount: totalAnimalCount,
                      averageWeightKg: averageWeightKg,
                      childCount: childCount,
                      ejidoCount: ejidoCount,
                      ejidoTotalCapacity: ejidoTotalCapacity,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _locationSummary() {
    if (location.isCommunalMonteContainer) {
      final rights = ejidoCount ?? childCount;
      final capacitySuffix = (ejidoTotalCapacity ?? 0) > 0
          ? ' y $ejidoTotalCapacity espacios'
          : '';
      return 'Monte comunal con $rights derecho${rights == 1 ? '' : 's'} ejidal${rights == 1 ? '' : 'es'}$capacitySuffix.';
    }
    if (childCount > 0) {
      return 'Contiene $childCount sub-ubicacion${childCount == 1 ? '' : 'es'} para seguimiento interno.';
    }

    switch (location.type.category) {
      case LocationCategory.water:
        if (location.waters.isEmpty) {
          return 'Recurso de agua sin lectura reciente.';
        }
        final latest = location.waters.reduce(
          (a, b) => a.date.isAfter(b.date) ? a : b,
        );
        return 'Ultima lectura de agua ${latest.level.toStringAsFixed(0)}%.';
      case LocationCategory.agricultural:
        final cropCount = location.crops.length + location.seedings.length;
        if (cropCount == 0) {
          return 'Area agricola lista para registrar cultivos.';
        }
        return '$cropCount cultivo${cropCount == 1 ? '' : 's'} o siembra${cropCount == 1 ? '' : 's'} registrados.';
      case LocationCategory.infrastructure:
        if (location.inventory.isEmpty) {
          return 'Infraestructura disponible sin inventario registrado.';
        }
        return '${location.inventory.length} item${location.inventory.length == 1 ? '' : 's'} de inventario registrados.';
      case LocationCategory.livestock:
      case LocationCategory.handling:
        final capacity = location.capacity;
        if (capacity > 0) {
          return '$animalCount de $capacity espacios ocupados.';
        }
        return '$animalCount animal${animalCount == 1 ? '' : 'es'} asignado${animalCount == 1 ? '' : 's'}.';
      case LocationCategory.macro:
        return 'Propiedad principal para organizar areas internas.';
      case LocationCategory.natural:
        return 'Area natural para manejo, conservacion o pastoreo extensivo.';
    }
  }
}

// ── Image strip ──────────────────────────────────────────────────────────────

class _LocationImageStrip extends StatelessWidget {
  const _LocationImageStrip({required this.imagePaths});

  final List<String> imagePaths;

  @override
  Widget build(BuildContext context) {
    final firstPath = imagePaths.first;
    return SizedBox(
      height: 110,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.file(
              File(firstPath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image_outlined, size: 32),
              ),
            ),
          ),
          if (imagePaths.length > 1)
            Positioned(
              bottom: 6,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+${imagePaths.length - 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LocationTypeAvatar extends StatelessWidget {
  const LocationTypeAvatar({
    super.key,
    required this.type,
    this.radius = 20,
    this.backgroundColor,
    this.fallbackColor,
  });

  final LocationType type;
  final double radius;
  final Color? backgroundColor;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    final color = fallbackColor ?? locationTypeColor(type);
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? color.withValues(alpha: 0.14),
      child: Padding(
        padding: EdgeInsets.all(radius * 0.08),
        child: Image.asset(
          locationAssetForType(type),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Icon(iconForLocationType(type), size: radius, color: color),
        ),
      ),
    );
  }
}

String locationAssetForType(LocationType type) {
  return switch (type) {
    LocationType.warehouse => 'assets/images/location_warehouse.png',
    LocationType.monte => 'assets/images/location_monte.png',
    LocationType.ejido => 'assets/images/location_ejido.png',
    LocationType.corral => 'assets/images/location_corral.png',
    LocationType.spring => 'assets/images/location_spring.png',
    LocationType.well => 'assets/images/location_well.png',
    LocationType.pond => 'assets/images/location_pond.png',
    LocationType.pasture => 'assets/images/location_pasture.png',
    LocationType.field => 'assets/images/location_field.png',
    LocationType.barn => 'assets/images/location_barn.png',
    LocationType.house => 'assets/images/location_house.png',
    LocationType.road => 'assets/images/location_road.png',
    LocationType.gate => 'assets/images/location_gate.png',
    LocationType.waterTank => 'assets/images/location_water_tank.png',
    _ => switch (type.category) {
      LocationCategory.macro => 'assets/images/location_macro.png',
      LocationCategory.livestock => 'assets/images/location_livestock.png',
      LocationCategory.handling => 'assets/images/location_handling.png',
      LocationCategory.agricultural =>
        'assets/images/location_agricultural.png',
      LocationCategory.natural => 'assets/images/location_natural.png',
      LocationCategory.infrastructure =>
        'assets/images/location_infrastructure.png',
      LocationCategory.water => 'assets/images/location_water.png',
    },
  };
}

Color locationTypeColor(LocationType type) {
  switch (type) {
    case LocationType.ranch:
    case LocationType.farm:
    case LocationType.finca:
    case LocationType.hacienda:
    case LocationType.property:
      return AppColors.primary;
    case LocationType.pasture:
    case LocationType.pen:
      return const Color(0xFF5F7E3F);
    case LocationType.monte:
    case LocationType.forest:
    case LocationType.protectedArea:
      return const Color(0xFF244C3F);
    case LocationType.corral:
    case LocationType.feedlot:
    case LocationType.chute:
    case LocationType.quarantineArea:
    case LocationType.loadingArea:
    case LocationType.weighingArea:
      return AppColors.accent;
    case LocationType.warehouse:
    case LocationType.workshop:
    case LocationType.office:
    case LocationType.road:
    case LocationType.gate:
      return const Color(0xFF6B5A4A);
    case LocationType.pond:
    case LocationType.well:
    case LocationType.dam:
    case LocationType.spring:
    case LocationType.trough:
    case LocationType.canal:
    case LocationType.reservoir:
    case LocationType.lagoon:
    case LocationType.river:
    case LocationType.wetland:
    case LocationType.waterTank:
      return AppColors.secondary;
    case LocationType.field:
    case LocationType.plot:
    case LocationType.milpa:
    case LocationType.orchard:
    case LocationType.greenhouse:
    case LocationType.nursery:
    case LocationType.garden:
      return AppColors.primary;
    case LocationType.house:
    case LocationType.barn:
    case LocationType.stable:
      return AppColors.earth;
    default:
      return const Color(0xFF6B5A4A);
  }
}

IconData iconForLocationType(LocationType type) {
  switch (type) {
    case LocationType.ranch:
    case LocationType.farm:
    case LocationType.finca:
    case LocationType.hacienda:
    case LocationType.property:
      return Icons.house;
    case LocationType.pasture:
    case LocationType.pen:
    case LocationType.feedlot:
      return Icons.fence;
    case LocationType.monte:
    case LocationType.forest:
    case LocationType.protectedArea:
      return Icons.forest;
    case LocationType.corral:
    case LocationType.chute:
    case LocationType.quarantineArea:
    case LocationType.loadingArea:
    case LocationType.weighingArea:
      return Icons.home_work;
    case LocationType.warehouse:
    case LocationType.workshop:
    case LocationType.office:
    case LocationType.road:
    case LocationType.gate:
      return Icons.warehouse;
    case LocationType.pond:
    case LocationType.well:
    case LocationType.dam:
    case LocationType.spring:
    case LocationType.trough:
    case LocationType.canal:
    case LocationType.reservoir:
    case LocationType.lagoon:
    case LocationType.river:
    case LocationType.wetland:
    case LocationType.waterTank:
      return Icons.water;
    case LocationType.field:
    case LocationType.plot:
    case LocationType.milpa:
    case LocationType.orchard:
    case LocationType.greenhouse:
    case LocationType.nursery:
    case LocationType.garden:
      return Icons.agriculture;
    case LocationType.house:
      return Icons.cottage;
    case LocationType.barn:
    case LocationType.stable:
      return Icons.home_work;
    default:
      return Icons.location_on;
  }
}

String _formatSurface(double ha) {
  if (ha <= 0) return '—';
  if (ha >= 100) return '${ha.toStringAsFixed(0)} ha';
  if (ha >= 10) return '${ha.toStringAsFixed(0)} ha';
  return '${ha.toStringAsFixed(1)} ha';
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.location,
    required this.animalCount,
    this.totalAnimalCount,
    this.averageWeightKg,
    this.childCount = 0,
    this.ejidoCount,
    this.ejidoTotalCapacity,
  });

  final LocationEntity location;
  final int animalCount;
  final int? totalAnimalCount;
  final double? averageWeightKg;
  final int childCount;
  final int? ejidoCount;
  final int? ejidoTotalCapacity;

  (IconData, String) _mainMetric() {
    if (location.isCommunalMonteContainer) {
      if (ejidoCount != null) {
        final count = ejidoCount!;
        final suffix = (ejidoTotalCapacity ?? 0) > 0
            ? ' / $ejidoTotalCapacity'
            : '';
        return (
          Icons.account_balance_outlined,
          '$count derecho${count == 1 ? '' : 's'}$suffix',
        );
      }
      final total = totalAnimalCount ?? animalCount;
      final capacitySuffix = location.capacity > 0
          ? ' / ${location.capacity}'
          : '';
      return (
        Icons.pets_outlined,
        'Propios: $animalCount · Total: $total$capacitySuffix',
      );
    }

    final cat = location.type.category;
    switch (cat) {
      case LocationCategory.water:
        if (location.waters.isNotEmpty) {
          final latest = location.waters.reduce(
            (a, b) => a.date.isAfter(b.date) ? a : b,
          );
          return (
            Icons.water_drop_outlined,
            '${latest.level.toStringAsFixed(0)}%',
          );
        }
        return (Icons.water_drop_outlined, 'Sin datos');
      case LocationCategory.agricultural:
        final total = location.crops.length + location.seedings.length;
        return (Icons.eco_outlined, '$total cultivo${total == 1 ? '' : 's'}');
      case LocationCategory.infrastructure:
        return (
          Icons.inventory_2_outlined,
          '${location.inventory.length} items',
        );
      default:
        if (location.capacity > 0) {
          return (Icons.pets_outlined, '$animalCount / ${location.capacity}');
        }
        return (Icons.pets_outlined, '$animalCount animales');
    }
  }

  List<(IconData, String)> _metrics() {
    final metrics = <(IconData, String)>[_mainMetric()];
    if (childCount > 0 && !location.isCommunalMonteContainer) {
      metrics.add((
        Icons.account_tree_outlined,
        '$childCount sub${childCount == 1 ? '' : 's'}',
      ));
    }
    if (averageWeightKg != null && averageWeightKg! > 0) {
      metrics.add((
        Icons.monitor_weight_outlined,
        '${averageWeightKg!.toStringAsFixed(0)} kg',
      ));
    }
    metrics.add((Icons.square_foot, _formatSurface(location.surfaceArea)));
    return metrics;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtle = theme.colorScheme.onSurfaceVariant;
    final metrics = _metrics();
    final occupancy = location.capacity > 0
        ? (animalCount / location.capacity).clamp(0.0, 1.0)
        : null;
    final accent = locationTypeColor(location.type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final (icon, label) in metrics)
                    _MetricChip(icon: icon, label: label, color: subtle),
                ],
              ),
            ),
          ],
        ),
        if (occupancy != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: occupancy,
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
              valueColor: AlwaysStoppedAnimation<Color>(
                occupancy > 0.9 ? AppColors.warning : accent,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.38),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final LocationStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        locationStatusLabel(context, status),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }
}
