/// Configurable quick action grid for home dashboard.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/utils/color_contrast.dart';
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
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final actionExtent = textScale >= 1.75
        ? 246.0
        : (90 + (textScale - 1) * 120).clamp(90.0, 180.0).toDouble();

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
          final columns = textScale >= 1.75 || constraints.maxWidth < 520
              ? 2
              : constraints.maxWidth < 720
              ? 3
              : 4;
          final itemWidth =
              (constraints.maxWidth - (gap * (columns - 1))) / columns;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: enabled.map((action) {
              final tone = action.tone ?? AppColors.primary;
              final background = Color.alphaBlend(
                tone.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? .18
                      : .08,
                ),
                Theme.of(context).colorScheme.surface,
              );
              final foreground = readableTextColor(tone, background);
              return SizedBox(
                key: ValueKey<String>('quick-action-${action.id}'),
                width: itemWidth,
                height: actionExtent,
                child: Semantics(
                  button: true,
                  label: action.label,
                  child: ExcludeSemantics(
                    child: InkWell(
                      onTap: () => context.pushNamed(
                        action.routeName,
                        queryParameters: action.queryParameters ?? const {},
                      ),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: background,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                          border: Border.all(
                            color: foreground.withValues(alpha: .14),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(action.icon, color: foreground, size: 22),
                            const SizedBox(height: AppSpacing.xxs),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xxs,
                              ),
                              child: Text(
                                action.label,
                                textAlign: TextAlign.center,
                                softWrap: true,
                                style: tt.labelSmall?.copyWith(
                                  height: 1.1,
                                  color: foreground,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
