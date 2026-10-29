/// core › widgets › app_button — semantic button variants for the app.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/theme/theme.dart';

enum AppButtonVariant { primary, secondary, tertiary, danger }

enum AppButtonSize { regular, compact }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.regular,
    this.expanded = false,
    this.isLoading = false,
    this.loadingLabel,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool expanded;
  final bool isLoading;
  final String? loadingLabel;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final height = size == AppButtonSize.compact
        ? AppControlMetrics.compactHeight
        : AppControlMetrics.minHeight;
    final resolvedOnPressed = isLoading ? null : onPressed;
    final child = isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _foregroundColor(context),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(child: Text(loadingLabel ?? label)),
            ],
          )
        : Text(label);

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton.icon(
        onPressed: resolvedOnPressed,
        style: _style(context, height),
        icon: icon == null ? const SizedBox.shrink() : Icon(icon),
        label: child,
      ),
      AppButtonVariant.secondary => OutlinedButton.icon(
        onPressed: resolvedOnPressed,
        style: _style(context, height),
        icon: icon == null ? const SizedBox.shrink() : Icon(icon),
        label: child,
      ),
      AppButtonVariant.tertiary => TextButton.icon(
        onPressed: resolvedOnPressed,
        style: _style(context, height),
        icon: icon == null ? const SizedBox.shrink() : Icon(icon),
        label: child,
      ),
      AppButtonVariant.danger => FilledButton.icon(
        onPressed: resolvedOnPressed,
        style: _style(context, height, danger: true),
        icon: icon == null ? const SizedBox.shrink() : Icon(icon),
        label: child,
      ),
    };

    return Semantics(
      button: true,
      enabled: resolvedOnPressed != null,
      label: semanticLabel ?? label,
      child: expanded
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }

  ButtonStyle _style(
    BuildContext context,
    double height, {
    bool danger = false,
  }) {
    final theme = Theme.of(context);
    final error = theme.colorScheme.error;
    final foreground = danger ? theme.colorScheme.onError : null;
    final background = danger ? error : null;

    if (variant == AppButtonVariant.tertiary) {
      return TextButton.styleFrom(
        minimumSize: Size(0, height),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        foregroundColor: danger ? error : theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      );
    }

    if (variant == AppButtonVariant.secondary) {
      final accent = theme.brightness == Brightness.dark
          ? theme.colorScheme.onSurface
          : theme.colorScheme.primary;
      return OutlinedButton.styleFrom(
        minimumSize: Size(0, height),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        foregroundColor: accent,
        side: BorderSide(color: accent.withValues(alpha: 0.72)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      );
    }

    return FilledButton.styleFrom(
      minimumSize: Size(0, height),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      backgroundColor: background ?? theme.colorScheme.primary,
      foregroundColor: foreground ?? theme.colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
    );
  }

  Color _foregroundColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (variant) {
      AppButtonVariant.danger => scheme.onError,
      AppButtonVariant.secondary =>
        scheme.brightness == Brightness.dark
            ? scheme.onSurface
            : scheme.primary,
      AppButtonVariant.tertiary => scheme.primary,
      AppButtonVariant.primary => scheme.onPrimary,
    };
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.isDestructive = false,
    this.compact = false,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool compact;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final size = compact
        ? AppControlMetrics.compactIconButtonSize
        : AppControlMetrics.iconButtonSize;
    final color = isDestructive ? Theme.of(context).colorScheme.error : null;

    return Semantics(
      button: true,
      label: semanticLabel ?? tooltip,
      enabled: onPressed != null,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
        color: color,
        style: IconButton.styleFrom(
          minimumSize: Size.square(size),
          fixedSize: Size.square(size),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
    );
  }
}
