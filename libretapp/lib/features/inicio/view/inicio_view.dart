/// features > inicio > view > inicio_view - customizable home dashboard.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/inicio/bloc/inicio_bloc.dart';
import 'package:libretapp/features/inicio/bloc/inicio_event.dart';
import 'package:libretapp/features/inicio/bloc/inicio_state.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/inicio/view/dashboard_customize_sheet.dart';
import 'package:libretapp/features/inicio/widgets/dashboard/dashboard_header.dart';
import 'package:libretapp/features/inicio/widgets/dashboard/dashboard_widgets.dart';
import 'package:libretapp/features/inicio/widgets/dashboard/quick_action_grid.dart';
import 'package:libretapp/features/inicio/widgets/dashboard/ranch_summary_card.dart';
import 'package:libretapp/theme/app_theme.dart';

class InicioView extends StatelessWidget {
  const InicioView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InicioBloc, InicioState>(
      builder: (context, state) {
        final data = state.data;

        if (data == null && state.status == InicioStatus.loading) {
          return const AppLoadingIndicator();
        }

        if (data == null && state.status == InicioStatus.error) {
          return AppEmptyState(
            icon: Icons.error_outline,
            title: 'No se pudo cargar Inicio',
            message: state.errorMessage,
            action: FilledButton.icon(
              onPressed: () {
                context.read<InicioBloc>().add(const LoadInicio());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          );
        }

        if (data == null) return const SizedBox.shrink();

        final theme = Theme.of(context);
        final bottomInset = ShellInsets.bottomSafePadding(context);
        final widgets = List.of(state.widgetConfigs)
          ..sort((a, b) => a.order.compareTo(b.order));

        return RefreshIndicator(
          onRefresh: () async {
            context.read<InicioBloc>().add(const RefreshInicio());
            await context.read<InicioBloc>().stream.firstWhere(
              (next) => !next.isLoading,
            );
          },
          child: ColoredBox(
            color: theme.scaffoldBackgroundColor,
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 18),
              children: [
                DashboardHeader(data: data),
                const SizedBox(height: 14),
                _TodayPriorityPanel(data: data),
                const SizedBox(height: 14),
                RanchSummaryCard(data: data),
                const SizedBox(height: 14),
                QuickActionGrid(
                  actions: state.quickActions,
                  onCustomizeTap: () => showDashboardCustomizeSheet(
                    context: context,
                    widgets: state.widgetConfigs,
                    actions: state.quickActions,
                    onSaved: (w, a) {
                      context.read<InicioBloc>().add(
                        UpdateDashboardConfig(widgets: w, actions: a),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                ...widgets.map(
                  (config) => DashboardWidgetHost(
                    config: config,
                    data: data,
                    financeDetail: state.financeDetail,
                    libraryItems: state.libraryPicks,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TodayPriorityPanel extends StatelessWidget {
  const _TodayPriorityPanel({required this.data});

  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionableAlerts = data.alerts
        .where((a) => a.severity != InicioAlertSeverity.info)
        .toList(growable: false);
    final primaryAlert = actionableAlerts.isNotEmpty
        ? actionableAlerts.first
        : _firstItem(data.alerts);
    final primaryTask = _firstItem(data.tasks);
    final calving = _firstItem(data.upcomingCalvings);

    final title = primaryAlert?.title ??
        primaryTask?.title ??
        (calving != null ? 'Proximo parto' : 'Rancho en orden');
    final message = primaryAlert?.message ??
        primaryTask?.message ??
        (calving != null
            ? '${calving.animalTag} en ${calving.daysRemaining} dias'
            : 'No hay pendientes criticos por ahora.');
    final route = primaryAlert?.targetRoute ?? primaryTask?.targetRoute;
    final severity = primaryAlert?.severity;
    final color = switch (severity) {
      InicioAlertSeverity.critical => AppColors.error,
      InicioAlertSeverity.warning => AppColors.warning,
      InicioAlertSeverity.info => AppColors.primary,
      null => primaryTask != null ? AppColors.accent : AppColors.success,
    };

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: route == null ? null : () => context.push(route),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: color.withValues(alpha: 0.22)),
            color: Color.alphaBlend(
              color.withValues(alpha: 0.07),
              theme.colorScheme.surface,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(
                  severity == null
                      ? Icons.today_outlined
                      : Icons.warning_amber_rounded,
                  color: color,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prioridad de hoy',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (route != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.chevron_right, color: color),
              ],
            ],
          ),
        ),
      ),
    );
  }

  T? _firstItem<T>(List<T> items) {
    if (items.isEmpty) return null;
    return items.first;
  }
}
