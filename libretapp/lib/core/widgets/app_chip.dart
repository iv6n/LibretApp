/// core › widgets › app_chip — themed chip widget used across features.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/theme/theme.dart';

enum AppChipTone { neutral, info, success, warning, error }

class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    this.icon,
    this.tone = AppChipTone.neutral,
    this.onTap,
    this.selected = false,
    super.key,
  });

  final String label;
  final IconData? icon;
  final AppChipTone tone;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForTone(context);
    final background = selected ? colors.backgroundSelected : colors.background;
    final borderColor = selected ? colors.borderSelected : colors.border;

    return Semantics(
      button: onTap != null,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: onTap == null ? AppControlMetrics.compactHeight : 48,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(color: borderColor),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: colors.foreground),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _ChipColors _colorsForTone(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status =
        Theme.of(context).extension<AppStatusTheme>() ??
        AppStatusTheme(
          info: scheme.primary,
          success: AppColors.success,
          warning: AppColors.warning,
          error: scheme.error,
        );
    _ChipColors semantic(Color foreground) => _ChipColors(
      foreground: foreground,
      background: foreground.withValues(alpha: 0.08),
      backgroundSelected: foreground.withValues(alpha: 0.16),
      border: foreground.withValues(alpha: 0.30),
      borderSelected: foreground.withValues(alpha: 0.44),
    );
    switch (tone) {
      case AppChipTone.info:
        return semantic(status.info);
      case AppChipTone.success:
        return semantic(status.success);
      case AppChipTone.warning:
        return semantic(status.warning);
      case AppChipTone.error:
        return semantic(status.error);
      case AppChipTone.neutral:
        return _ChipColors(
          foreground: scheme.onSurface.withValues(alpha: 0.78),
          background: Theme.of(context).cardColor,
          backgroundSelected: scheme.surface.withValues(alpha: 0.92),
          border: scheme.outline.withValues(alpha: 0.6),
          borderSelected: scheme.outline,
        );
    }
  }
}

class _ChipColors {
  const _ChipColors({
    required this.foreground,
    required this.background,
    required this.backgroundSelected,
    required this.border,
    required this.borderSelected,
  });

  final Color foreground;
  final Color background;
  final Color backgroundSelected;
  final Color border;
  final Color borderSelected;
}
