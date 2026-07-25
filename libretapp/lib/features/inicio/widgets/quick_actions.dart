/// features > inicio > widgets > quick_actions - quick-actions section on the home dashboard.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final actions = [
      const _QAction(
        icon: Icons.add_circle_outline,
        label: 'Nuevo animal',
        routeName: AppRoutes.nameAnimalNuevoRapido,
        tone: Color(0xFF2F855A),
      ),
      const _QAction(
        icon: Icons.add_location_alt_outlined,
        label: 'Nueva ubicacion',
        routeName: AppRoutes.nameUbicacionNueva,
        tone: Color(0xFF2F855A),
      ),
      const _QAction(
        icon: Icons.vaccines,
        label: 'Vacunar',
        routeName: AppRoutes.nameRegistroTratarLote,
        tone: Color(0xFFC27A12),
      ),
      const _QAction(
        icon: Icons.event_available,
        label: 'Nuevo evento',
        routeName: AppRoutes.nameAgendaNuevo,
        tone: Color(0xFFD97706),
      ),
      const _QAction(
        icon: Icons.paid_outlined,
        label: 'Registrar gasto',
        routeName: AppRoutes.nameRegistroGastoGeneral,
        tone: Color(0xFF6B5A4A),
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Acciones rapidas', style: tt.titleSmall)),
              Icon(Icons.edit_outlined, size: 15, color: cs.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                Expanded(child: _QuickActionCell(action: actions[i])),
                if (i < actions.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _QAction {
  const _QAction({
    required this.icon,
    required this.label,
    required this.routeName,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final String routeName;
  final Color tone;
}

class _QuickActionCell extends StatelessWidget {
  const _QuickActionCell({required this.action});

  final _QAction action;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => context.pushNamed(action.routeName),
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        height: 76,
        decoration: BoxDecoration(
          color: action.tone.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: action.tone, size: 24),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.labelSmall?.copyWith(
                  color: const Color(0xFF26312B),
                  fontSize: 10,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
