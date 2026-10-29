/// core › widgets › app_empty_state — empty-state placeholder widget with icon and message.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/theme/theme.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.message,
    this.action,
    this.compact = false,
    this.illustrationAsset,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  /// Use inside a scrollable section (not a full-page state) for a smaller
  /// icon and tighter, vertical-only padding.
  final bool compact;

  /// Enables the illustrated directory card without changing existing uses.
  final String? illustrationAsset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (illustrationAsset != null) {
      final scheme = theme.colorScheme;
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: Image.asset(
                      illustrationAsset!,
                      width: 136,
                      height: 136,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (action != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    action!,
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      label: message == null ? title : '$title. $message',
      child: Center(
        child: Padding(
          padding: compact
              ? const EdgeInsets.symmetric(vertical: AppSpacing.md)
              : const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: compact ? 36 : 44,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.56),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.64),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: AppSpacing.lg),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
