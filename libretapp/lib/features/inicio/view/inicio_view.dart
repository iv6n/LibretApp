/// features \u203a inicio \u203a view \u203a inicio_view \u2014 main view for the home dashboard.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/eventos/data/eventos_model.dart';
import 'package:libretapp/features/inicio/bloc/inicio_bloc.dart';
import 'package:libretapp/features/inicio/bloc/inicio_event.dart';
import 'package:libretapp/features/inicio/bloc/inicio_state.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/inicio/widgets/widgets.dart';
import 'package:libretapp/theme/app_theme.dart';

class InicioView extends StatelessWidget {
  const InicioView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InicioBloc, InicioState>(
      builder: (context, state) {
        final bottomInset = ShellInsets.bottomSafePadding(context);
        final data = state.data;

        if (data == null && state.status == InicioStatus.loading) {
          return const Center(child: CircularProgressIndicator());
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

        if (data == null) {
          return const SizedBox.shrink();
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<InicioBloc>().add(const RefreshInicio());
            await context.read<InicioBloc>().stream.firstWhere(
              (next) => !next.isLoading,
            );
          },
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 10),
            children: [
              _InicioHeader(data: data),
              const SizedBox(height: AppSpacing.lg),
              const QuickActions(),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Resumen operativo',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              DashboardCard(
                icon: Icons.pets,
                title: 'Animales',
                subtitle: 'Inventario total',
                count: '${data.totalAnimals}',
                accentColor: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.sm),
              DashboardCard(
                icon: Icons.priority_high,
                title: 'Atencion inmediata',
                subtitle: 'Sanidad y observacion',
                count: '${data.attentionAnimals}',
                accentColor: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.sm),
              DashboardCard(
                icon: Icons.event,
                title: 'Eventos proximos',
                subtitle: 'Agenda activa',
                count: '${data.upcomingEventsCount}',
                accentColor: AppColors.accent,
              ),
              const SizedBox(height: AppSpacing.sm),
              DashboardCard(
                icon: Icons.location_on,
                title: 'Ubicaciones y lotes',
                subtitle:
                    '${data.totalLocations} ubicaciones / ${data.activeLotes} lotes activos',
                count: '${data.totalLocations}',
                accentColor: AppColors.secondary,
              ),
              const SizedBox(height: AppSpacing.lg),
              QuickSummarySection(data: data),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(
                title: 'Alertas prioritarias',
                actionText: 'Ver directorio',
                onAction: () => context.push(AppRoutes.directorio),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...data.alerts.map((item) => _AlertCard(item: item)),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(
                title: 'Tareas del dia',
                actionText: 'Ir a eventos',
                onAction: () => context.push(AppRoutes.eventos),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...data.tasks.map((task) => _TaskCard(item: task)),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(
                title: 'Eventos proximos',
                actionText: 'Calendario',
                onAction: () => context.push(AppRoutes.eventos),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (data.upcomingEvents.isEmpty)
                const AppEmptyState(
                  icon: Icons.event_busy,
                  title: 'Sin eventos por ahora',
                  message:
                      'Tu agenda esta al dia. Puedes registrar una actividad nueva.',
                )
              else
                ...data.upcomingEvents.map((event) => _EventCard(event: event)),
            ],
          ),
        );
      },
    );
  }
}

class _InicioHeader extends StatelessWidget {
  const _InicioHeader({required this.data});

  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('dd MMM, HH:mm');

    return AppCard(
      leading: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.dashboard_customize, color: AppColors.primary),
      ),
      title: 'Hola ${data.profileName}',
      subtitle:
          '${data.farmName} · Actualizado ${format.format(data.lastUpdated)}',
      body: Text(
        'Panel central para priorizar salud, eventos y tareas del dia.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onAction,
  });

  final String title;
  final String actionText;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        TextButton(onPressed: onAction, child: Text(actionText)),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.item});

  final InicioAlertItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: () => context.push(item.targetRoute),
        leading: Icon(
          _iconForSeverity(item.severity),
          color: _colorForSeverity(item.severity),
        ),
        title: item.title,
        subtitle: item.message,
        trailing: AppChip(
          label: _labelForSeverity(item.severity),
          tone: _toneForSeverity(item.severity),
        ),
      ),
    );
  }

  IconData _iconForSeverity(InicioAlertSeverity severity) {
    switch (severity) {
      case InicioAlertSeverity.critical:
        return Icons.error;
      case InicioAlertSeverity.warning:
        return Icons.warning_amber;
      case InicioAlertSeverity.info:
        return Icons.info_outline;
    }
  }

  Color _colorForSeverity(InicioAlertSeverity severity) {
    switch (severity) {
      case InicioAlertSeverity.critical:
        return AppColors.error;
      case InicioAlertSeverity.warning:
        return AppColors.warning;
      case InicioAlertSeverity.info:
        return AppColors.secondary;
    }
  }

  String _labelForSeverity(InicioAlertSeverity severity) {
    switch (severity) {
      case InicioAlertSeverity.critical:
        return 'Critica';
      case InicioAlertSeverity.warning:
        return 'Media';
      case InicioAlertSeverity.info:
        return 'Info';
    }
  }

  AppChipTone _toneForSeverity(InicioAlertSeverity severity) {
    switch (severity) {
      case InicioAlertSeverity.critical:
        return AppChipTone.error;
      case InicioAlertSeverity.warning:
        return AppChipTone.warning;
      case InicioAlertSeverity.info:
        return AppChipTone.info;
    }
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.item});

  final InicioTaskItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: () => context.push(item.targetRoute),
        leading: const Icon(Icons.task_alt, color: AppColors.primary),
        title: item.title,
        subtitle: item.message,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final Evento event;

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('dd MMM · HH:mm').format(event.fecha);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: () => context.push(AppRoutes.eventos),
        leading: const Icon(Icons.event_note, color: AppColors.accent),
        title: event.titulo,
        subtitle: '$dateText · ${event.ubicacion}',
        trailing: AppChip(label: event.tipo, tone: AppChipTone.neutral),
      ),
    );
  }
}
