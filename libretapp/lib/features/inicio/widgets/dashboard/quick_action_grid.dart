/// Configurable quick action grid for home dashboard.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/features/inicio/data/dashboard_quick_action.dart';
import 'package:libretapp/theme/app_theme.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({
    required this.actions,
    this.onCustomizeTap,
    super.key,
  });

  final List<DashboardQuickAction> actions;
  final VoidCallback? onCustomizeTap;

  @override
  Widget build(BuildContext context) {
    final enabled = actions.where((a) => a.enabled).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    if (enabled.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.55),
        ),
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
              Expanded(
                child: Text(
                  'Accesos rápidos',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (onCustomizeTap != null)
                IconButton(
                  icon: const Icon(Icons.tune, size: 20),
                  tooltip: 'Personalizar',
                  onPressed: onCustomizeTap,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemCount: enabled.length,
            itemBuilder: (context, i) {
              final action = enabled[i];
              final tone = action.tone ?? AppColors.primary;
              return InkWell(
                onTap: () => context.pushNamed(action.routeName),
                borderRadius: BorderRadius.circular(AppRadii.sm),
                child: Ink(
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(action.icon, color: tone, size: 22),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          action.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tt.labelSmall?.copyWith(
                            fontSize: 9,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
