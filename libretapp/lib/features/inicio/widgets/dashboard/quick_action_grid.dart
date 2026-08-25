/// Configurable quick action grid for home dashboard.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/features/inicio/data/dashboard_quick_action.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/theme.dart';

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

    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final actionExtent = (74 * textScale).clamp(74.0, 96.0).toDouble();

    return AppCard(
      key: const ValueKey<String>('quick-action-grid'),
      title: l10n.uiQuickActions,
      trailing: onCustomizeTap == null
          ? null
          : AppIconButton(
              icon: Icons.tune,
              tooltip: l10n.uiCustomize,
              onPressed: onCustomizeTap,
              compact: true,
            ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const gap = AppSpacing.xs;
          final itemWidth = (constraints.maxWidth - (gap * 3)) / 4;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: enabled.map((action) {
              final tone = action.tone ?? AppColors.primary;
              return SizedBox(
                width: itemWidth,
                height: actionExtent,
                child: InkWell(
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
                        const SizedBox(height: AppSpacing.xxs),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxs,
                          ),
                          child: Text(
                            action.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: tt.labelSmall?.copyWith(height: 1.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
