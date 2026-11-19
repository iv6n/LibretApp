/// Configurable quick action grid for home dashboard.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/utils/color_contrast.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/features/inicio/data/dashboard_quick_action.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/theme.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({
    required this.actions,
    this.onCustomizeTap,
    this.compact = false,
    super.key,
  });

  final List<DashboardQuickAction> actions;
  final VoidCallback? onCustomizeTap;
  final bool compact;

  void _showMore(BuildContext context, List<DashboardQuickAction> enabled) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: .7,
          child: ListView(
            children: [
              const ListTile(title: Text('Accesos rápidos')),
              for (final action in enabled)
                ListTile(
                  leading: Icon(action.icon),
                  title: Text(action.label),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.pushNamed(
                      action.routeName,
                      queryParameters: action.queryParameters ?? const {},
                    );
                  },
                ),
              if (onCustomizeTap != null)
                ListTile(
                  leading: const Icon(Icons.tune),
                  title: const Text('Personalizar accesos'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onCustomizeTap!();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = actions.where((a) => a.enabled).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    if (enabled.isEmpty && !compact) return const SizedBox.shrink();

    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    if (compact) {
      final entries = <({String label, IconData icon, VoidCallback onTap})>[
        (
          label: 'Buscar',
          icon: Icons.search,
          onTap: () => context.go(AppRoutes.animalesPath(focusSearch: true)),
        ),
        for (final action in enabled.take(6))
          (
            label: action.label,
            icon: action.icon,
            onTap: () => context.pushNamed(
              action.routeName,
              queryParameters: action.queryParameters ?? const {},
            ),
          ),
        (
          label: 'Más',
          icon: Icons.more_horiz,
          onTap: () => _showMore(context, enabled),
        ),
      ];
      return Card(
        key: const ValueKey<String>('quick-action-grid'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Acciones rápidas',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (onCustomizeTap != null)
                    IconButton(
                      onPressed: onCustomizeTap,
                      icon: const Icon(Icons.tune),
                      tooltip: l10n.uiCustomize,
                    ),
                ],
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  const columns = 4;
                  const gap = AppSpacing.xs;
                  final width =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final entry in entries)
                        SizedBox(
                          width: width,
                          height:
                              38 +
                              MediaQuery.textScalerOf(context).scale(12) * 3.8,
                          child: InkWell(
                            onTap: entry.onTap,
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.sm,
                                ),
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 48,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        entry.icon,
                                        size: 20,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        child: Text(
                                          entry.label,
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: tt.labelSmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
          final columns = textScale >= 1.5 || constraints.maxWidth < 270
              ? 2
              : constraints.maxWidth < 720
              ? 3
              : 4;
          final baseExtent = columns == 3 ? 108.0 : 90.0;
          final actionExtent = textScale >= 1.75
              ? 246.0
              : (baseExtent + (textScale - 1) * 120)
                    .clamp(baseExtent, 180.0)
                    .toDouble();
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
