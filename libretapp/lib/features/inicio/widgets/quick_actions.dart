import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/inicio/widgets/quick_action_button.dart';

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
                const Icon(Icons.flash_on, color: Colors.orange),
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
                  icon: Icons.favorite,
                  label: 'Reproducción',
                  onTap: () => context.push(AppRoutes.animales),
                ),
                QuickActionButton(
                  icon: Icons.vaccines,
                  label: 'Salud',
                  onTap: () => context.push(AppRoutes.animales),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Toca una opción y elige el animal en la lista para registrar.',
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
