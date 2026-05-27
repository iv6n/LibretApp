/// features \u203a inicio \u203a widgets \u203a quick_actions \u2014 quick-actions section on the home dashboard.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';

// ---------------------------------------------------------------------------
// QuickActions body -- 2x2 icon grid of shortcuts
// ---------------------------------------------------------------------------

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final actions = [
      const _QAction(
        icon: Icons.add_circle_outline,
        label: 'Nuevo\nanimal',
        routeName: AppRoutes.nameAnimalNuevoRapido,
      ),
      const _QAction(
        icon: Icons.vaccines,
        label: 'Vacunar\nlote',
        routeName: AppRoutes.nameRegistroTratarLote,
      ),
      const _QAction(
        icon: Icons.monitor_weight,
        label: 'Registrar\npeso',
        routeName: AppRoutes.nameRegistroPeso,
      ),
      const _QAction(
        icon: Icons.event_available,
        label: 'Nuevo\nevento',
        routeName: AppRoutes.nameAgendaNuevo,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flash_on, size: 18, color: cs.primary),
            const SizedBox(width: 6),
            Text('Acciones rapidas', style: tt.titleSmall),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: actions.map((a) => _QuickActionCell(action: a)).toList(),
        ),
      ],
    );
  }
}

class _QAction {
  const _QAction({
    required this.icon,
    required this.label,
    required this.routeName,
  });

  final IconData icon;
  final String label;
  final String routeName;
}

class _QuickActionCell extends StatelessWidget {
  const _QuickActionCell({required this.action});

  final _QAction action;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => context.pushNamed(action.routeName),
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: cs.primary, size: 28),
            const SizedBox(height: 6),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: tt.labelSmall?.copyWith(color: cs.onSurface, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
