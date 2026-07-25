part of '../location_detail_widgets.dart';

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

