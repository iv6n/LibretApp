part of '../location_detail_widgets.dart';

// ─── RecordActions ────────────────────────────────────────────────────────────

class RecordActions extends StatelessWidget {
  const RecordActions({super.key, 
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

