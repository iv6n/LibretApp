part of '../location_detail_widgets.dart';

// ─── RecordActions ────────────────────────────────────────────────────────────

class RecordActions extends StatelessWidget {
  const RecordActions({
    super.key,
    required this.onVisit,
    this.onWater,
    this.onSalt,
    this.onShade,
    this.onPasture,
    this.onSeeding,
    this.onIrrigation,
    this.onRain,
    this.onMaintenance,
    required this.onCost,
  });

  final VoidCallback onVisit;
  final VoidCallback? onWater;
  final VoidCallback? onSalt;
  final VoidCallback? onShade;
  final VoidCallback? onPasture;
  final VoidCallback? onSeeding;
  final VoidCallback? onIrrigation;
  final VoidCallback? onRain;
  final VoidCallback? onMaintenance;
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
                if (onWater != null)
                  _ActionButton(
                    icon: Icons.water_drop_outlined,
                    label: 'Agua',
                    onPressed: onWater!,
                  ),
                if (onSalt != null)
                  _ActionButton(
                    icon: Icons.scatter_plot_outlined,
                    label: 'Sal',
                    onPressed: onSalt!,
                  ),
                if (onShade != null)
                  _ActionButton(
                    icon: Icons.nature_outlined,
                    label: 'Sombra',
                    onPressed: onShade!,
                  ),
                if (onPasture != null)
                  _ActionButton(
                    icon: Icons.grass_outlined,
                    label: 'Pastura',
                    onPressed: onPasture!,
                  ),
                if (onSeeding != null)
                  _ActionButton(
                    icon: Icons.grass_outlined,
                    label: 'Siembra',
                    onPressed: onSeeding!,
                  ),
                if (onIrrigation != null)
                  _ActionButton(
                    icon: Icons.waterfall_chart_outlined,
                    label: 'Riego',
                    onPressed: onIrrigation!,
                  ),
                if (onRain != null)
                  _ActionButton(
                    icon: Icons.umbrella_outlined,
                    label: 'Lluvia',
                    onPressed: onRain!,
                  ),
                if (onMaintenance != null)
                  _ActionButton(
                    icon: Icons.build_outlined,
                    label: 'Mantenimiento',
                    onPressed: onMaintenance!,
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

