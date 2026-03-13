import 'package:flutter/material.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/dynamic_attribute.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.location,
    required this.animalCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.averageWeightKg,
    this.parentName,
  });

  final LocationEntity location;
  final int animalCount;
  final double? averageWeightKg;
  final String? parentName;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = _QuickMetrics.fromLocation(location: location);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      _iconByType(location.type.name),
                      size: 18,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_capitalize(location.kind.name)} · ${_capitalize(location.type.name)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(status: location.status),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.account_tree_outlined,
                    text: parentName == null
                        ? 'Raíz'
                        : 'Padre: ${parentName!.trim()}',
                  ),
                  if (location.childUuids.isNotEmpty)
                    _InfoChip(
                      icon: Icons.device_hub_outlined,
                      text: '${location.childUuids.length} hijos',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ..._buildMetricRows(metrics),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMetricRows(_QuickMetrics metrics) {
    switch (location.type) {
      case LocationType.siembra:
        return _buildSiembraMetrics();
      case LocationType.corral:
        return _buildCorralMetrics();
      case LocationType.rancho:
        if (_isStorageLocation(location)) {
          return _buildAlmacenMetrics(metrics);
        }
        return _buildDefaultMetrics(metrics);
      case LocationType.potrero:
        return _buildDefaultMetrics(metrics);
    }
  }

  List<Widget> _buildDefaultMetrics(_QuickMetrics metrics) {
    return [
      _MetricRow(
        leadingIcon: Icons.pets_outlined,
        label: 'Animales / Capacidad',
        value: '$animalCount / ${location.capacity}',
      ),
      const SizedBox(height: 8),
      _MetricRow(
        leadingIcon: Icons.water_drop_outlined,
        label: 'Agua %',
        value: metrics.waterPercent,
      ),
      const SizedBox(height: 8),
      _MetricRow(
        leadingIcon: Icons.grass_outlined,
        label: 'Pastura %',
        value: metrics.pasturePercent,
      ),
      const SizedBox(height: 8),
      _MetricRow(
        leadingIcon: Icons.calendar_today_outlined,
        label: 'Última visita',
        value: metrics.lastVisit,
      ),
    ];
  }

  List<Widget> _buildSiembraMetrics() {
    final latestSeeding = _latestByDate(
      location.seedings,
      (record) => record.date,
    );
    final latestIrrigation = _latestByDate(
      location.irrigations,
      (record) => record.date,
    );
    final growth = _resolveNumberAttribute(
      location.attributes,
      keys: const ['crecimiento', 'crecimiento_pct', 'growth', 'growth_pct'],
    );
    final cycleText = _resolveTextAttribute(
      location.attributes,
      keys: const ['ciclo_cosecha', 'ciclo', 'harvest_cycle'],
    );

    return [
      _MetricRow(
        leadingIcon: Icons.spa_outlined,
        label: 'Siembra',
        value: latestSeeding == null
            ? 'Sin registro'
            : '${latestSeeding.crop} · ${_formatDate(latestSeeding.date)}',
      ),
      const SizedBox(height: 8),
      _MetricRow(
        leadingIcon: Icons.water_drop_outlined,
        label: 'Último riego',
        value: latestIrrigation == null
            ? 'Sin riego'
            : _formatDate(latestIrrigation.date),
      ),
      const SizedBox(height: 8),
      _MetricRow(
        leadingIcon: Icons.trending_up_outlined,
        label: '% crecimiento',
        value: growth == null ? 'N/D' : '${growth.toStringAsFixed(0)}%',
      ),
      const SizedBox(height: 8),
      _MetricRow(
        leadingIcon: Icons.event_repeat_outlined,
        label: 'Ciclo de cosecha',
        value: cycleText ?? 'N/D',
      ),
    ];
  }

  List<Widget> _buildCorralMetrics() {
    final gain = _resolveNumberAttribute(
      location.attributes,
      keys: const ['ganancia_diaria', 'engorda_diaria', 'adg'],
    );
    final feed = _resolveTextAttribute(
      location.attributes,
      keys: const ['dieta', 'alimentacion', 'feed_program'],
    );

    return [
      _MetricRow(
        leadingIcon: Icons.pets_outlined,
        label: 'Animales / Capacidad',
        value: '$animalCount / ${location.capacity}',
      ),
      const SizedBox(height: 8),
      _MetricRow(
        leadingIcon: Icons.monitor_weight_outlined,
        label: 'Peso promedio',
        value: averageWeightKg == null
            ? 'N/D'
            : '${averageWeightKg!.toStringAsFixed(1)} kg',
      ),
      const SizedBox(height: 8),
      _MetricRow(
        leadingIcon: Icons.show_chart_outlined,
        label: 'Ganancia diaria',
        value: gain == null ? 'N/D' : '${gain.toStringAsFixed(2)} kg/día',
      ),
      const SizedBox(height: 8),
      _MetricRow(
        leadingIcon: Icons.info_outline,
        label: 'Info importante',
        value: feed ?? 'Manejo estándar',
      ),
    ];
  }

  List<Widget> _buildAlmacenMetrics(_QuickMetrics metrics) {
    final equipment = _resolveTextAttribute(
      location.attributes,
      keys: const ['equipos', 'equipo', 'inventario_equipos'],
    );
    final inventory = _resolveNumberAttribute(
      location.attributes,
      keys: const ['inventario_total', 'piezas', 'stock'],
    );
    final latestCost = _latestByDate(location.costs, (record) => record.date);

    return [
      _MetricRow(
        leadingIcon: Icons.inventory_2_outlined,
        label: 'Equipo',
        value: equipment ?? 'Monturas, piolas y herramienta',
      ),
      const SizedBox(height: 8),
      _MetricRow(
        leadingIcon: Icons.numbers_outlined,
        label: 'Piezas en almacén',
        value: inventory == null ? 'N/D' : inventory.toStringAsFixed(0),
      ),
      const SizedBox(height: 8),
      _MetricRow(
        leadingIcon: Icons.build_circle_outlined,
        label: 'Último mantenimiento',
        value: latestCost == null
            ? metrics.lastVisit
            : _formatDate(latestCost.date),
      ),
      const SizedBox(height: 8),
      _MetricRow(
        leadingIcon: Icons.water_drop_outlined,
        label: 'Agua %',
        value: metrics.waterPercent,
      ),
    ];
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _capitalize(status),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.leadingIcon,
    required this.label,
    required this.value,
  });

  final IconData leadingIcon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(leadingIcon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _QuickMetrics {
  factory _QuickMetrics.fromLocation({required LocationEntity location}) {
    final water = _resolvePercentage(
      location.attributes,
      keys: const ['agua', 'agua_pct', 'water', 'water_pct'],
      fallback: location.waters.isNotEmpty ? location.waters.last.level : null,
    );

    final pasture = _resolvePercentage(
      location.attributes,
      keys: const ['pastura', 'pastura_pct', 'pasto', 'pasture', 'forraje'],
      fallback: location.pastures.isNotEmpty
          ? (location.pastures.last.carryingCapacity * 10)
          : null,
    );

    final lastVisitDate = location.visits.isNotEmpty
        ? location.visits.last.date
        : null;

    return _QuickMetrics(
      waterPercent: water == null ? 'N/D' : '${water.toStringAsFixed(0)}%',
      pasturePercent: pasture == null
          ? 'N/D'
          : '${pasture.toStringAsFixed(0)}%',
      lastVisit: lastVisitDate == null
          ? 'Sin registro'
          : _formatDate(lastVisitDate),
    );
  }
  const _QuickMetrics({
    required this.waterPercent,
    required this.pasturePercent,
    required this.lastVisit,
  });

  final String waterPercent;
  final String pasturePercent;
  final String lastVisit;

  static double? _resolvePercentage(
    List<DynamicAttribute> attributes, {
    required List<String> keys,
    required double? fallback,
  }) {
    final normalizedKeys = keys.map(_normalize).toSet();
    for (final attribute in attributes.reversed) {
      if (attribute.numberValue == null) continue;
      if (normalizedKeys.contains(_normalize(attribute.key))) {
        final value = attribute.numberValue!.toDouble();
        return value.clamp(0, 100);
      }
    }

    if (fallback == null) return null;
    return fallback.clamp(0, 100);
  }
}

bool _isStorageLocation(LocationEntity location) {
  final normalizedName = _normalize(location.name);
  if (normalizedName.contains('almacen') || normalizedName.contains('bodega')) {
    return true;
  }
  return location.attributes.any((attribute) {
    final key = _normalize(attribute.key);
    return key.contains('equipo') || key.contains('inventario');
  });
}

double? _resolveNumberAttribute(
  List<DynamicAttribute> attributes, {
  required List<String> keys,
}) {
  final normalizedKeys = keys.map(_normalize).toSet();
  for (final attribute in attributes.reversed) {
    if (attribute.numberValue == null) continue;
    if (normalizedKeys.contains(_normalize(attribute.key))) {
      return attribute.numberValue!.toDouble();
    }
  }
  return null;
}

String? _resolveTextAttribute(
  List<DynamicAttribute> attributes, {
  required List<String> keys,
}) {
  final normalizedKeys = keys.map(_normalize).toSet();
  for (final attribute in attributes.reversed) {
    if (attribute.textValue == null || attribute.textValue!.trim().isEmpty) {
      continue;
    }
    if (normalizedKeys.contains(_normalize(attribute.key))) {
      return attribute.textValue!.trim();
    }
  }
  return null;
}

T? _latestByDate<T>(List<T> source, DateTime Function(T item) selector) {
  if (source.isEmpty) return null;
  var latest = source.first;
  for (final item in source.skip(1)) {
    if (selector(item).isAfter(selector(latest))) {
      latest = item;
    }
  }
  return latest;
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

String _normalize(String input) {
  return input
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'[^a-z0-9]'), '');
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}

IconData _iconByType(String typeName) {
  if (typeName.contains('corral')) return Icons.storefront_outlined;
  if (typeName.contains('rancho')) return Icons.house_outlined;
  if (typeName.contains('siembra')) return Icons.agriculture_outlined;
  return Icons.map_outlined;
}
