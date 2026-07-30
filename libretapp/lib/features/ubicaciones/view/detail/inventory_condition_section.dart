part of '../location_detail_widgets.dart';

// ─── InventorySection ─────────────────────────────────────────────────────────

class InventorySection extends StatelessWidget {
  const InventorySection({super.key, required this.location});

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
  const ConditionSection({super.key, required this.location});

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

