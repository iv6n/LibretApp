import 'package:flutter/material.dart';
import 'package:libretapp/theme/app_theme.dart';

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
    final colors = _colorsForTone();
    final background = selected ? colors.backgroundSelected : colors.background;
    final borderColor = selected ? colors.borderSelected : colors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.sm),
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
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ChipColors _colorsForTone() {
    switch (tone) {
      case AppChipTone.info:
        return _ChipColors(
          foreground: AppColors.primary,
          background: AppColors.primary.withValues(alpha: 0.06),
          backgroundSelected: AppColors.primary.withValues(alpha: 0.12),
          border: AppColors.primary.withValues(alpha: 0.24),
          borderSelected: AppColors.primary.withValues(alpha: 0.36),
        );
      case AppChipTone.success:
        return _ChipColors(
          foreground: AppColors.success,
          background: AppColors.success.withValues(alpha: 0.08),
          backgroundSelected: AppColors.success.withValues(alpha: 0.16),
          border: AppColors.success.withValues(alpha: 0.24),
          borderSelected: AppColors.success.withValues(alpha: 0.36),
        );
      case AppChipTone.warning:
        return _ChipColors(
          foreground: AppColors.warning,
          background: AppColors.warning.withValues(alpha: 0.10),
          backgroundSelected: AppColors.warning.withValues(alpha: 0.18),
          border: AppColors.warning.withValues(alpha: 0.30),
          borderSelected: AppColors.warning.withValues(alpha: 0.40),
        );
      case AppChipTone.error:
        return _ChipColors(
          foreground: AppColors.error,
          background: AppColors.error.withValues(alpha: 0.08),
          backgroundSelected: AppColors.error.withValues(alpha: 0.16),
          border: AppColors.error.withValues(alpha: 0.30),
          borderSelected: AppColors.error.withValues(alpha: 0.40),
        );
      case AppChipTone.neutral:
        return const _ChipColors(
          foreground: AppColors.textSecondary,
          background: Colors.white,
          backgroundSelected: AppColors.surfaceAlt,
          border: AppColors.border,
          borderSelected: AppColors.border,
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
