/// Individual dashboard widget implementations.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/inicio/data/dashboard_widget_config.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/inicio/widgets/dashboard/dashboard_widget_card.dart';
import 'package:libretapp/features/inicio/widgets/quick_summary_section.dart';
import 'package:libretapp/features/perfil/data/library_item.dart';
import 'package:libretapp/features/perfil/domain/finance_summary_service.dart';
import 'package:libretapp/theme/app_theme.dart';

class DashboardWidgetHost extends StatelessWidget {
  const DashboardWidgetHost({
    required this.config,
    required this.data,
    this.financeDetail,
    this.libraryItems = const [],
    super.key,
  });

  final DashboardWidgetConfig config;
  final InicioDashboardData data;
  final FinanceSummaryDetail? financeDetail;
  final List<LibraryItem> libraryItems;

  @override
  Widget build(BuildContext context) {
    if (!config.enabled) return const SizedBox.shrink();

    return switch (config.type) {
      DashboardWidgetType.animalSummary => _AnimalSummaryWidget(data: data),
      DashboardWidgetType.upcomingEvents => _UpcomingEventsWidget(data: data),
      DashboardWidgetType.healthAlerts => _HealthAlertsWidget(data: data),
      DashboardWidgetType.upcomingCalvings => _UpcomingCalvingsWidget(data: data),
      DashboardWidgetType.financeMonth => _FinanceWidget(detail: financeDetail),
      DashboardWidgetType.activeLocations => _LocationStatusWidget(data: data),
      DashboardWidgetType.recentActivity => _RecentActivityWidget(data: data),
      DashboardWidgetType.pendingTasks => _PendingTasksWidget(data: data),
      DashboardWidgetType.weather => _WeatherWidget(data: data),
      DashboardWidgetType.inventory => const _InventoryWidget(),
      DashboardWidgetType.libraryPicks => _LibraryPicksWidget(items: libraryItems),
    };
  }
}

class _AnimalSummaryWidget extends StatelessWidget {
  const _AnimalSummaryWidget({required this.data});
  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    return DashboardWidgetCard(
      title: 'Resumen de animales',
      status: data.totalAnimals == 0
          ? DashboardWidgetStatus.empty
          : DashboardWidgetStatus.data,
      emptyTitle: 'Sin animales',
      emptyMessage: 'Registra tu primer animal.',
      onTap: () => context.push(AppRoutes.directorio),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Kpi(
                value: '${data.totalAnimals}',
                label: 'Total',
              ),
              const SizedBox(width: 16),
              _Kpi(
                value: '${data.attentionAnimals}',
                label: 'Atención',
                color: AppColors.warning,
              ),
              const SizedBox(width: 16),
              _Kpi(
                value: '${data.activeLotes}',
                label: 'Lotes',
              ),
            ],
          ),
          if (data.categoryBreakdown.isNotEmpty) ...[
            const SizedBox(height: 12),
            QuickSummarySection(data: data),
          ],
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.value, required this.label, this.color});
  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: color ?? AppColors.primary,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _UpcomingEventsWidget extends StatelessWidget {
  const _UpcomingEventsWidget({required this.data});
  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    final events = data.upcomingEvents;
    return DashboardWidgetCard(
      title: 'Próximos eventos',
      status: events.isEmpty
          ? DashboardWidgetStatus.empty
          : DashboardWidgetStatus.data,
      emptyTitle: 'Sin eventos próximos',
      emptyMessage: 'Agenda vacía por ahora.',
      onTap: () => context.push(AppRoutes.agenda),
      child: Column(
        children: events.take(4).map(_eventTile).toList(),
      ),
    );
  }

  Widget _eventTile(AgendaEntry e) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event, size: 20),
      title: Text(e.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(DateFormat('EEE d MMM').format(e.fecha)),
    );
  }
}

class _HealthAlertsWidget extends StatelessWidget {
  const _HealthAlertsWidget({required this.data});
  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    final alerts = data.alerts
        .where((a) => a.severity != InicioAlertSeverity.info)
        .toList();
    final display = alerts.isEmpty ? data.alerts.take(2) : alerts;

    return DashboardWidgetCard(
      title: 'Alertas sanitarias',
      status: display.isEmpty
          ? DashboardWidgetStatus.empty
          : DashboardWidgetStatus.data,
      emptyTitle: 'Sin alertas',
      child: Column(
        children: display.map((a) {
          final color = switch (a.severity) {
            InicioAlertSeverity.critical => AppColors.error,
            InicioAlertSeverity.warning => AppColors.warning,
            InicioAlertSeverity.info => AppColors.primary,
          };
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.warning_amber_rounded, color: color, size: 20),
            title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(a.message, maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () => context.push(a.targetRoute),
          );
        }).toList(),
      ),
    );
  }
}

class _UpcomingCalvingsWidget extends StatelessWidget {
  const _UpcomingCalvingsWidget({required this.data});
  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    final items = data.upcomingCalvings;
    return DashboardWidgetCard(
      title: 'Próximos partos',
      status: items.isEmpty
          ? DashboardWidgetStatus.empty
          : DashboardWidgetStatus.data,
      emptyTitle: 'Sin partos próximos',
      emptyMessage: 'En los próximos 21 días.',
      child: Column(
        children: items.take(4).map((c) {
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(c.animalTag),
            subtitle: Text('En ${c.daysRemaining} días'),
            trailing: Text(
              DateFormat('d/M').format(c.expectedDate),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onTap: () => context.push(AppRoutes.animalDetallePath(c.animalUuid)),
          );
        }).toList(),
      ),
    );
  }
}

class _FinanceWidget extends StatelessWidget {
  const _FinanceWidget({this.detail});
  final FinanceSummaryDetail? detail;

  @override
  Widget build(BuildContext context) {
    if (detail == null) {
      return const DashboardWidgetCard(
        title: 'Finanzas del mes',
        status: DashboardWidgetStatus.loading,
        child: SizedBox.shrink(),
      );
    }

    final s = detail!.summary;
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final balance = s.netProfit;

    return DashboardWidgetCard(
      title: 'Finanzas del mes',
      status: DashboardWidgetStatus.data,
      onTap: () => context.push(AppRoutes.finanzas),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fmt.format(balance),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: balance >= 0 ? AppColors.success : AppColors.error,
                  ),
                ),
                const Text('Balance'),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('+${fmt.format(s.totalRevenue)}', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
              Text('-${fmt.format(s.totalExpenses)}', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationStatusWidget extends StatelessWidget {
  const _LocationStatusWidget({required this.data});
  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    final locs = data.activeLocations;
    return DashboardWidgetCard(
      title: 'Ubicaciones activas',
      status: locs.isEmpty
          ? DashboardWidgetStatus.empty
          : DashboardWidgetStatus.data,
      emptyTitle: 'Sin ubicaciones',
      emptyMessage: 'Crea potreros, corrales o bodegas.',
      onTap: () => context.push(AppRoutes.ubicaciones),
      child: Column(
        children: locs.map((l) {
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.location_on_outlined, size: 20),
            title: Text(l.name),
            subtitle: Text('${l.animalCount} animales · ${l.typeLabel}'),
            trailing: l.waterEvents > 0 || l.pastureEvents > 0
                ? Icon(
                    l.waterEvents > 0
                        ? Icons.water_drop_outlined
                        : Icons.grass,
                    size: 18,
                    color: AppColors.secondary,
                  )
                : null,
            onTap: () => context.push(AppRoutes.ubicacionDetallePath(l.uuid)),
          );
        }).toList(),
      ),
    );
  }
}

class _RecentActivityWidget extends StatelessWidget {
  const _RecentActivityWidget({required this.data});
  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    final items = data.recentActivity;
    return DashboardWidgetCard(
      title: 'Registros recientes',
      status: items.isEmpty
          ? DashboardWidgetStatus.empty
          : DashboardWidgetStatus.data,
      emptyTitle: 'Sin actividad reciente',
      child: Column(
        children: items.map((a) {
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 14,
              child: Text(a.categoryAbbrev, style: const TextStyle(fontSize: 10)),
            ),
            title: Text(a.animalTag),
            subtitle: Text(a.categoryLabel),
            trailing: Text(
              DateFormat('d/M').format(a.lastUpdate),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            onTap: () => context.push(AppRoutes.animalDetallePath(a.animalUuid)),
          );
        }).toList(),
      ),
    );
  }
}

class _PendingTasksWidget extends StatelessWidget {
  const _PendingTasksWidget({required this.data});
  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    final tasks = data.tasks;
    return DashboardWidgetCard(
      title: 'Tareas pendientes',
      status: tasks.isEmpty
          ? DashboardWidgetStatus.empty
          : DashboardWidgetStatus.data,
      emptyTitle: 'Sin tareas',
      child: Column(
        children: tasks.take(4).map((t) {
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.task_alt_outlined, size: 20),
            title: Text(t.title),
            subtitle: Text(t.message, maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () => context.push(t.targetRoute),
          );
        }).toList(),
      ),
    );
  }
}

class _WeatherWidget extends StatelessWidget {
  const _WeatherWidget({required this.data});
  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    final w = data.weather;
    if (w == null) {
      return const DashboardWidgetCard(
        title: 'Clima',
        status: DashboardWidgetStatus.empty,
        emptyTitle: 'Clima no disponible',
        child: SizedBox.shrink(),
      );
    }

    return DashboardWidgetCard(
      title: 'Clima',
      status: DashboardWidgetStatus.data,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.amber.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Open-Meteo',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.amber,
            fontSize: 10,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${w.temperature}°',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(w.condition, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('Máx ${w.maxTemperature}° · Hum ${w.humidity}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryWidget extends StatelessWidget {
  const _InventoryWidget();

  @override
  Widget build(BuildContext context) {
    return const DashboardWidgetCard(
      title: 'Inventario / Alimento',
      status: DashboardWidgetStatus.empty,
      emptyTitle: 'Próximamente',
      emptyMessage: 'Conecta inventario de ubicaciones.',
      child: SizedBox.shrink(),
    );
  }
}

class _LibraryPicksWidget extends StatelessWidget {
  const _LibraryPicksWidget({required this.items});
  final List<LibraryItem> items;

  @override
  Widget build(BuildContext context) {
    final picks = items.take(3).toList();
    return DashboardWidgetCard(
      title: 'Biblioteca recomendada',
      status: picks.isEmpty
          ? DashboardWidgetStatus.empty
          : DashboardWidgetStatus.data,
      emptyTitle: 'Sin recomendaciones',
      onTap: () => context.push(AppRoutes.perfil),
      child: Column(
        children: picks.map((item) {
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(item.category.icon, size: 20, color: AppColors.primary),
            title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(item.summary, maxLines: 1, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
      ),
    );
  }
}
