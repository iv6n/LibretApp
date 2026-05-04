/// features \u203a inicio \u203a widgets \u203a quick_actions \u2014 quick-actions section on the home dashboard.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/inicio/widgets/quick_action_button.dart';
import 'package:libretapp/theme/app_theme.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  'Accesos rápidos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                QuickActionButton(
                  icon: Icons.monitor_weight,
                  label: 'Registrar peso',
                  onTap: () => context.push(AppRoutes.animales),
                ),
                QuickActionButton(
                  icon: Icons.event_available,
                  label: 'Nuevo evento',
                  onTap: () => context.push(AppRoutes.eventos),
                ),
                QuickActionButton(
                  icon: Icons.fmd_good,
                  label: 'Ubicaciones',
                  onTap: () => context.push(AppRoutes.ubicaciones),
                ),
                QuickActionButton(
                  icon: Icons.groups,
                  label: 'Gestionar lotes',
                  onTap: () => context.push(AppRoutes.directorio),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Abre un módulo clave y continúa el flujo operativo sin navegar por múltiples pantallas.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
