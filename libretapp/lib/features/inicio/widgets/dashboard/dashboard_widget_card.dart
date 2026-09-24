/// Generic dashboard widget shell with loading/empty/error states.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/app_empty_state.dart';
import 'package:libretapp/core/widgets/app_loading_indicator.dart';
import 'package:libretapp/theme/app_theme.dart';

enum DashboardWidgetStatus { loading, empty, error, data }

class DashboardWidgetCard extends StatelessWidget {
  const DashboardWidgetCard({
    required this.title,
    required this.status,
    required this.child,
    this.trailing,
    this.onTap,
    this.errorMessage,
    this.emptyTitle,
    this.emptyMessage,
    super.key,
  });

  final String title;
  final DashboardWidgetStatus status;
  final Widget child;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? errorMessage;
  final String? emptyTitle;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trailingWidget = trailing;
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final cardPadding = isTablet ? AppSpacing.md : AppSpacing.sm;
    final titleStyle =
        (isTablet ? theme.textTheme.titleMedium : theme.textTheme.titleSmall)
            ?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(title, style: titleStyle)),
                    if (trailingWidget != null) trailingWidget,
                  ],
                ),
                SizedBox(height: isTablet ? AppSpacing.sm : AppSpacing.xs),
                switch (status) {
                  DashboardWidgetStatus.loading => const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: AppLoadingIndicator.inline(),
                  ),
                  DashboardWidgetStatus.error => AppEmptyState(
                    icon: Icons.error_outline,
                    title: 'Error',
                    message: errorMessage ?? 'No se pudo cargar',
                  ),
                  DashboardWidgetStatus.empty => AppEmptyState(
                    icon: Icons.inbox_outlined,
                    title: emptyTitle ?? 'Sin datos',
                    message: emptyMessage ?? '',
                  ),
                  DashboardWidgetStatus.data => child,
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}
