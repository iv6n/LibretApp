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
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/reportes/widgets/widgets.dart';
import 'package:libretapp/features/reportes/widgets/report_tiles.dart';
import 'package:libretapp/theme/app_theme.dart';

class ReportesSummaryTab extends StatefulWidget {
  const ReportesSummaryTab({super.key});

  @override
  State<ReportesSummaryTab> createState() => _ReportesSummaryTabState();
}

class _ReportesSummaryTabState extends State<ReportesSummaryTab>
    with AutomaticKeepAliveClientMixin {
  final _calvingsSectionKey = GlobalKey();
  bool _showAllCalvings = false;

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
          return RefreshIndicator(
            onRefresh: () => context.read<ReportesCubit>().refreshReportes(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: listPadding,
              children: [
                AppEmptyState(
                  icon: Icons.pets_outlined,
                  title: 'Sin animales registrados',
                  message: 'Registra animales para ver reportes del rancho.',
                  action: FilledButton.icon(
                    onPressed: () =>
                        context.pushNamed(AppRoutes.nameAnimalNuevoRapido),
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar primer animal'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _shareDataSection(context),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<ReportesCubit>().refreshReportes(),
          child: ListView(
            padding: listPadding,
            children: [
              ReportSummaryHeader(summary: summary),
              _metricsGrid(context, summary),
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
              _shareDataSection(context),
            ],
          ),
        );
      },
    );
  }

  Widget _metricsGrid(BuildContext context, ReportSummary summary) {
    return ReportTiles(
      children: [
        SummaryMetricCard(
          label: 'Total animales',
          value: '${summary.totalAnimals}',
          icon: Icons.pets_outlined,
          onTap: () => context.push(AppRoutes.animalesPath(clearFilters: true)),
        ),
        SummaryMetricCard(
          label: 'Pendientes sanitarios',
          value: '${summary.healthAlertsCount}',
          icon: Icons.medical_services_outlined,
          accentColor: AppColors.warning,
          onTap: summary.healthAlertsCount == 0
              ? null
              : () => context.push(
                  AppRoutes.animalesPath(
                    healthFilter: 'pending',
                    clearFilters: true,
                  ),
                ),
        ),
        SummaryMetricCard(
          label: 'Sin vacuna registrada',
          value: '${summary.unvaccinatedCount}',
          icon: Icons.vaccines_outlined,
          onTap: summary.unvaccinatedCount == 0
              ? null
              : () => context.push(
                  AppRoutes.animalesPath(
                    healthFilter: 'unvaccinated',
                    clearFilters: true,
                  ),
                ),
        ),
        SummaryMetricCard(
          label: 'Próximos partos',
          value: '${summary.upcomingCalvings.length}',
          icon: Icons.pregnant_woman_outlined,
          accentColor: AppColors.secondary,
          onTap: summary.upcomingCalvings.isEmpty ? null : _scrollToCalvings,
        ),
      ],
    );
  }

  Future<void> _scrollToCalvings() async {
    final sectionContext = _calvingsSectionKey.currentContext;
    if (sectionContext == null) return;
    await Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
      key: _calvingsSectionKey,
      title: 'Próximos partos',
      trailing: Text(
        '${summary.upcomingCalvings.length}',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.w800,
        ),
      ),
      child: Column(
        children: [
          ...summary.upcomingCalvings
              .take(_showAllCalvings ? summary.upcomingCalvings.length : 5)
              .map(_calvingTile),
          if (summary.upcomingCalvings.length > 5)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() {
                  _showAllCalvings = !_showAllCalvings;
                }),
                child: Text(
                  _showAllCalvings
                      ? 'Mostrar menos'
                      : 'Ver todos los partos (${summary.upcomingCalvings.length})',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _calvingTile(CalvingItem calving) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            context.push(AppRoutes.animalDetallePath(calving.animalUuid)),
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
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
                      calving.animalTag,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'En ${calving.daysRemaining} días · '
                      '${DateFormat('d MMM', locale).format(calving.expectedDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasRecentActivity(ReportSummary summary) {
    return summary.recentMovements.isNotEmpty ||
        summary.recentRecords.isNotEmpty;
  }

  Widget _activitySection(ReportSummary summary) {
    final items = [...summary.recentMovements, ...summary.recentRecords]
      ..sort((a, b) => b.date.compareTo(a.date));

    return ReportSectionCard(
      title: 'Actividad reciente',
      child: Column(
        children: items.map((item) => ReportActivityTile(item: item)).toList(),
      ),
    );
  }

  Widget _shareDataSection(BuildContext context) {
    return ReportSectionCard(
      title: 'Compartir datos',
      margin: EdgeInsets.zero,
      child: ReportCard(
        icon: Icons.table_chart_outlined,
        title: 'Exportar a Excel',
        subtitle: 'Elige qué información incluir',
        onTap: () => context.push(AppRoutes.exportar),
      ),
    );
  }
}
