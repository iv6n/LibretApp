/// Generic dashboard widget shell with loading/empty/error states.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/app_empty_state.dart';
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
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                const SizedBox(height: 10),
                switch (status) {
                  DashboardWidgetStatus.loading => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
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
