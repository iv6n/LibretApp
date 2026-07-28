/// Tab A — ranch reports summary.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/widgets/app_empty_state.dart';
import 'package:libretapp/features/reportes/cubit/reportes_cubit.dart';
import 'package:libretapp/features/reportes/data/report_summary.dart';
import 'package:libretapp/features/reportes/widgets/widgets.dart';
import 'package:libretapp/theme/app_theme.dart';

class ReportesSummaryTab extends StatefulWidget {
  const ReportesSummaryTab({super.key});

  @override
  State<ReportesSummaryTab> createState() => _ReportesSummaryTabState();
}

class _ReportesSummaryTabState extends State<ReportesSummaryTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<ReportesCubit>().loadReportes();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bottomInset = ShellInsets.bottomSafePadding(context);
    final listPadding = EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.sm,
      AppSpacing.md,
      bottomInset + 8,
    );

    return BlocBuilder<ReportesCubit, ReportesState>(
      builder: (context, state) {
        if (state.reportStatus == ReportesLoadStatus.loading) {
          return Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state.reportStatus == ReportesLoadStatus.error) {
          return Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: AppEmptyState(
              icon: Icons.error_outline,
              title: 'No se pudieron cargar reportes',
              message: state.errorMessage,
              action: FilledButton(
                onPressed: () =>
                    context.read<ReportesCubit>().refreshReportes(),
                child: const Text('Reintentar'),
              ),
            ),
          );
        }

        final summary = state.reportSummary;
        if (summary == null) return const SizedBox.shrink();

        if (summary.totalAnimals == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: const AppEmptyState(
              icon: Icons.pets_outlined,
              title: 'Sin animales registrados',
              message: 'Registra animales para ver reportes del rancho.',
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<ReportesCubit>().refreshReportes(),
          child: ListView(
            padding: listPadding,
            children: [
              ReportSummaryHeader(summary: summary),
              _metricsGrid(summary),
              const SizedBox(height: AppSpacing.sm),
              _compositionSection(summary),
              if (summary.upcomingCalvings.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                _calvingsSection(summary),
              ],
              if (_hasRecentActivity(summary)) ...[
                const SizedBox(height: AppSpacing.sm),
                _activitySection(summary),
              ],
              const SizedBox(height: AppSpacing.sm),
              _generateReportSection(context),
            ],
          ),
        );
      },
    );
  }

  Widget _metricsGrid(ReportSummary summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.35,
      children: [
        SummaryMetricCard(
          label: 'Total animales',
          value: '${summary.totalAnimals}',
          icon: Icons.pets_outlined,
        ),
        SummaryMetricCard(
          label: 'Alertas sanitarias',
          value: '${summary.healthAlertsCount}',
          icon: Icons.medical_services_outlined,
          accentColor: AppColors.warning,
        ),
        SummaryMetricCard(
          label: 'Sin vacuna',
          value: '${summary.unvaccinatedCount}',
          icon: Icons.vaccines_outlined,
        ),
        SummaryMetricCard(
          label: 'Próximos partos',
          value: '${summary.upcomingCalvings.length}',
          icon: Icons.pregnant_woman_outlined,
          accentColor: AppColors.secondary,
        ),
      ],
    );
  }

  Widget _compositionSection(ReportSummary summary) {
    return ReportSectionCard(
      title: 'Composición del rancho',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Por especie',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...summary.bySpecies.map(
            (s) => ReportBreakdownRow(
              label: s.species.displayName,
              count: s.count,
              total: summary.totalAnimals,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Por categoría',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...summary.byCategory.map(
            (c) => ReportBreakdownRow(
              label: c.category.displayName,
              count: c.count,
              total: summary.totalAnimals,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _calvingsSection(ReportSummary summary) {
    return ReportSectionCard(
      title: 'Próximos partos',
      trailing: Text(
        '${summary.upcomingCalvings.length}',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.w800,
        ),
      ),
      child: Column(
        children: summary.upcomingCalvings.take(5).map((c) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.pregnant_woman_outlined,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.animalTag,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'En ${c.daysRemaining} días · '
                        '${DateFormat('d MMM').format(c.expectedDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _hasRecentActivity(ReportSummary summary) {
    return summary.recentMovements.isNotEmpty ||
        summary.recentRecords.isNotEmpty;
  }

  Widget _activitySection(ReportSummary summary) {
    final items = [
      ...summary.recentMovements,
      ...summary.recentRecords,
    ]..sort((a, b) => b.date.compareTo(a.date));

    return ReportSectionCard(
      title: 'Actividad reciente',
      child: Column(
        children: items.map((item) => ReportActivityTile(item: item)).toList(),
      ),
    );
  }

  Widget _generateReportSection(BuildContext context) {
    return ReportSectionCard(
      title: 'Generar reporte',
      margin: EdgeInsets.zero,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.15,
        children: [
          ReportCard(
            icon: ReportType.sanitary.icon,
            title: ReportType.sanitary.label,
            comingSoon: true,
            onTap: () => _comingSoon(context),
          ),
          ReportCard(
            icon: ReportType.reproductive.icon,
            title: ReportType.reproductive.label,
            comingSoon: true,
            onTap: () => _comingSoon(context),
          ),
          ReportCard(
            icon: ReportType.financial.icon,
            title: ReportType.financial.label,
            onTap: () => context.push(AppRoutes.finanzas),
          ),
          ReportCard(
            icon: ReportType.pdfExport.icon,
            title: 'Exportar datos',
            subtitle: 'Excel / respaldo',
            onTap: () => context.push(AppRoutes.exportar),
          ),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte detallado — próximamente')),
    );
  }
}
