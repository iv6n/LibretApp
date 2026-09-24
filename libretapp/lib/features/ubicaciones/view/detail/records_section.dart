part of '../location_detail_widgets.dart';

// ─── LocationRecords ──────────────────────────────────────────────────────────

class LocationRecords extends StatelessWidget {
  const LocationRecords({super.key, required this.location});

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
                _RecordCount(
                  label: 'Mantenimientos',
                  count: location.maintenances.length,
                ),
                _RecordCount(label: 'Costos', count: location.costs.length),
                _RecordCount(label: 'Cultivos', count: location.crops.length),
              ],
            ),
            if (location.maintenances.any((record) => record.isDue)) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Hay mantenimientos vencidos o pendientes de revisar.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

