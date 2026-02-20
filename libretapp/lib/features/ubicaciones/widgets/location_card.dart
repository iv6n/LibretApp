import 'package:flutter/material.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.location,
    required this.animalCount,
    required this.onEdit,
    required this.onDelete,
  });

  final LocationEntity location;
  final int animalCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  child: Icon(
                    _iconByType(location.type),
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_capitalize(location.type.name)} • ${location.terrainType}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: location.status),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Editar')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Eliminar'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Metric(
                  icon: Icons.pets_outlined,
                  label: '$animalCount animales',
                ),
                _Metric(
                  icon: Icons.straighten,
                  label: '${location.surfaceArea.toStringAsFixed(1)} ha',
                ),
                _Metric(
                  icon: Icons.groups,
                  label: '${location.capacity} capacidad',
                ),
                _Metric(
                  icon: Icons.water_drop_outlined,
                  label: location.waterSource,
                ),
                _Metric(icon: Icons.terrain, label: location.terrainType),
              ],
            ),
            if (_hasRecords(location)) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _RecordCount(label: 'Visitas', count: location.visits.length),
                  _RecordCount(label: 'Agua', count: location.waters.length),
                  _RecordCount(
                    label: 'Pasturas',
                    count: location.pastures.length,
                  ),
                  _RecordCount(
                    label: 'Siembra',
                    count: location.seedings.length,
                  ),
                  _RecordCount(
                    label: 'Riego',
                    count: location.irrigations.length,
                  ),
                  _RecordCount(label: 'Lluvia', count: location.rains.length),
                  _RecordCount(label: 'Costos', count: location.costs.length),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
                const SizedBox(width: 8),
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
    );
  }

  IconData _iconByType(Enum type) {
    final name = type.name;
    if (name.contains('corral')) return Icons.storefront_outlined;
    if (name.contains('rancho')) return Icons.house_outlined;
    if (name.contains('siembra')) return Icons.agriculture_outlined;
    return Icons.map_outlined;
  }

  bool _hasRecords(LocationEntity l) =>
      l.visits.isNotEmpty ||
      l.waters.isNotEmpty ||
      l.pastures.isNotEmpty ||
      l.seedings.isNotEmpty ||
      l.irrigations.isNotEmpty ||
      l.rains.isNotEmpty ||
      l.costs.isNotEmpty;
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}

class _RecordCount extends StatelessWidget {
  const _RecordCount({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 4),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = _capitalize(status);
    return Chip(
      label: Text(normalized),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
