/// features \u203a inicio \u203a view \u203a inicio_view \u2014 main view for the home dashboard.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/inicio/bloc/inicio_bloc.dart';
import 'package:libretapp/features/inicio/bloc/inicio_event.dart';
import 'package:libretapp/features/inicio/bloc/inicio_state.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/inicio/widgets/widgets.dart';
import 'package:libretapp/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// InicioView
// ---------------------------------------------------------------------------

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
            padding: EdgeInsets.only(bottom: bottomInset + 10),
            children: [
              // ── Hero header (edge-to-edge, no horizontal padding) ─────────
              _HeroHeader(data: data),
              const SizedBox(height: 16),
              // ── Compact stats row ─────────────────────────────────────────
              _StatsRow(data: data),
              const SizedBox(height: AppSpacing.lg),
              // ── Actividad reciente ────────────────────────────────────────
              if (data.recentActivity.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SectionHeader(
                    title: 'Actividad reciente',
                    actionText: 'Ver todo →',
                    onAction: () => context.go(AppRoutes.directorio),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _RecentActivityRow(items: data.recentActivity),
                const SizedBox(height: AppSpacing.lg),
              ],
              // ── Quick actions ─────────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: QuickActions(),
              ),
              const SizedBox(height: AppSpacing.lg),
              // ── Alertas ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SectionHeader(
                  title: 'Alertas prioritarias',
                  actionText: 'Ver directorio',
                  onAction: () => context.go(AppRoutes.directorio),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...data.alerts.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _AlertCard(item: item),
                ),
              ),
              // ── Partos proximos ───────────────────────────────────────────
              if (data.upcomingCalvings.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SectionHeader(
                    title: 'Partos proximos',
                    actionText: 'Ver animales',
                    onAction: () => context.go(AppRoutes.animales),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...data.upcomingCalvings.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _CalvingCard(item: item),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              // ── Tareas del dia ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SectionHeader(
                  title: 'Tareas del dia',
                  actionText: 'Ir a agenda',
                  onAction: () => context.go(AppRoutes.agenda),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...data.tasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _TaskCard(item: task),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // ── Eventos proximos ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SectionHeader(
                  title: 'Eventos proximos',
                  actionText: 'Calendario',
                  onAction: () => context.go(AppRoutes.agenda),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (data.upcomingEvents.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: AppEmptyState(
                    icon: Icons.event_busy,
                    title: 'Sin eventos por ahora',
                    message:
                        'Tu agenda esta al dia. Puedes registrar una actividad nueva.',
                  ),
                )
              else
                ...data.upcomingEvents.map(
                  (event) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _EventCard(event: event),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _HeroHeader -- edge-to-edge banner with time-based greeting
// ---------------------------------------------------------------------------

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.data});

  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final hour = DateTime.now().hour;

    final greeting = hour < 12
        ? 'Buenos dias'
        : hour < 18
        ? 'Buenas tardes'
        : 'Buenas noches';

    final dateText = DateFormat('EEE d MMM').format(DateTime.now());

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      color: cs.primaryContainer,
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡$greeting,',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onPrimaryContainer.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data.profileName} 👋',
                      style: tt.headlineSmall?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (data.weather != null) _WeatherCard(weather: data.weather!),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: cs.onPrimaryContainer.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                data.farmName,
                style: tt.bodySmall?.copyWith(
                  color: cs.onPrimaryContainer.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: cs.onPrimaryContainer.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                dateText,
                style: tt.bodySmall?.copyWith(
                  color: cs.onPrimaryContainer.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _StatsRow -- horizontal scrollable compact stat chips
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data});

  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.pets,
            label: 'Animales',
            sublabel: 'Activos',
            count: '${data.totalAnimals}',
            accentColor: AppColors.primary,
          ),
          const SizedBox(width: 8),
          _StatChip(
            icon: Icons.warning_amber_rounded,
            label: 'Atención',
            sublabel: 'Pendientes',
            count: '${data.attentionAnimals}',
            accentColor: data.attentionAnimals > 0
                ? AppColors.error
                : AppColors.secondary,
          ),
          const SizedBox(width: 8),
          _StatChip(
            icon: Icons.event,
            label: 'Eventos',
            sublabel: 'Programados',
            count: '${data.upcomingEventsCount}',
            accentColor: AppColors.accent,
          ),
          const SizedBox(width: 8),
          _StatChip(
            icon: Icons.layers_outlined,
            label: 'Lotes',
            sublabel: 'Activos',
            count: '${data.activeLotes}',
            accentColor: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.count,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final String count;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(height: 8),
          Text(
            count,
            style: tt.titleLarge?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            sublabel,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _SectionHeader
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// _AlertCard
// ---------------------------------------------------------------------------

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.item});

  final InicioAlertItem item;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isActionable =
        item.severity == InicioAlertSeverity.critical ||
        item.severity == InicioAlertSeverity.warning;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: () => context.go(item.targetRoute),
        leading: Icon(
          _iconForSeverity(item.severity),
          color: _colorForSeverity(item.severity),
        ),
        title: item.title,
        subtitle: item.message,
        trailing: isActionable
            ? FilledButton(
                onPressed: () => context.go(item.targetRoute),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: tt.labelSmall,
                ),
                child: const Text('Ver detalles'),
              )
            : const Icon(Icons.chevron_right),
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
}

// ---------------------------------------------------------------------------
// _CalvingCard
// ---------------------------------------------------------------------------

class _CalvingCard extends StatelessWidget {
  const _CalvingCard({required this.item});

  final CalvingItem item;

  @override
  Widget build(BuildContext context) {
    final urgencyColor = item.daysRemaining <= 3
        ? AppColors.error
        : item.daysRemaining <= 7
        ? AppColors.warning
        : AppColors.secondary;

    final daysLabel = item.daysRemaining == 0
        ? 'Hoy'
        : item.daysRemaining == 1
        ? 'Manana'
        : 'En ${item.daysRemaining} dias';

    final animalLabel = item.animalName != null && item.animalName!.isNotEmpty
        ? '${item.animalTag} · ${item.animalName}'
        : item.animalTag;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: () => context.push(AppRoutes.animalDetallePath(item.animalUuid)),
        leading: Icon(Icons.child_care, color: urgencyColor),
        title: animalLabel,
        subtitle:
            'Parto esperado · ${DateFormat('dd MMM').format(item.expectedDate)}',
        trailing: AppChip(
          label: daysLabel,
          tone: item.daysRemaining <= 3
              ? AppChipTone.error
              : item.daysRemaining <= 7
              ? AppChipTone.warning
              : AppChipTone.neutral,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _TaskCard
// ---------------------------------------------------------------------------

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.item});

  final InicioTaskItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: () => context.go(item.targetRoute),
        leading: const Icon(Icons.task_alt, color: AppColors.primary),
        title: item.title,
        subtitle: item.message,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _EventCard
// ---------------------------------------------------------------------------

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final AgendaEntry event;

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('dd MMM · HH:mm').format(event.fecha);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: () => context.go(AppRoutes.agenda),
        leading: const Icon(Icons.event_note, color: AppColors.accent),
        title: event.titulo,
        subtitle: '$dateText · ${event.ubicacion}',
        trailing: AppChip(label: event.tipo, tone: AppChipTone.neutral),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _WeatherCard -- floating card shown top-right of _HeroHeader
// ---------------------------------------------------------------------------

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.weather});

  final WeatherData weather;

  IconData _iconFor(String condition, int hour) {
    final condLower = condition.toLowerCase();
    if (condLower.contains('lluvia') || condLower.contains('rain')) {
      return Icons.grain;
    }
    if (condLower.contains('nube') || condLower.contains('cloud')) {
      return Icons.cloud_outlined;
    }
    if (condLower.contains('tormenta') || condLower.contains('storm')) {
      return Icons.thunderstorm_outlined;
    }
    // Clear/Despejado — day vs night
    return hour >= 6 && hour < 20
        ? Icons.wb_sunny_outlined
        : Icons.nights_stay_outlined;
  }

  Color _colorForCondition(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('lluvia') || c.contains('rain')) {
      return const Color(0xFF3B82F6);
    }
    if (c.contains('tormenta') || c.contains('storm')) {
      return const Color(0xFF6366F1);
    }
    if (c.contains('nube') || c.contains('cloud')) {
      return const Color(0xFF94A3B8);
    }
    return const Color(0xFFF59E0B); // sunny / default → amber
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final tt = Theme.of(context).textTheme;
    final iconColor = _colorForCondition(weather.condition);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _iconFor(weather.condition, hour),
                size: 28,
                color: iconColor,
              ),
              const SizedBox(width: 6),
              Text(
                '${weather.temperature}°',
                style: tt.headlineSmall?.copyWith(
                  color: const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            weather.condition,
            style: tt.bodySmall?.copyWith(
              color: const Color(0xFF666666),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Máx. ${weather.maxTemperature}°C',
            style: tt.bodySmall?.copyWith(
              color: const Color(0xFF444444),
              fontSize: 9,
            ),
          ),
          Text(
            'Hum. ${weather.humidity}% · ${weather.windSpeed}km/h',
            style: tt.bodySmall?.copyWith(
              color: const Color(0xFF444444),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _RecentActivityRow + _RecentActivityChip
// ---------------------------------------------------------------------------

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}min';
  if (diff.inHours < 24) return 'hace ${diff.inHours}h';
  if (diff.inDays == 1) return 'ayer';
  return 'hace ${diff.inDays} dias';
}

class _RecentActivityRow extends StatelessWidget {
  const _RecentActivityRow({required this.items});

  final List<RecentActivityItem> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _RecentActivityCard(item: items[i], index: i),
            if (i < items.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.item, required this.index});

  final RecentActivityItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final badge = '${item.categoryAbbrev}${index + 1}';
    final displayName = (item.animalName != null && item.animalName!.isNotEmpty)
        ? item.animalName!
        : item.animalTag;
    final hasPhoto =
        item.photoPath != null &&
        item.photoPath!.isNotEmpty &&
        File(item.photoPath!).existsSync();

    return GestureDetector(
      onTap: () => context.push(AppRoutes.animalDetallePath(item.animalUuid)),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Photo area ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 4, 0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(52),
                    child: hasPhoto
                        ? Image.file(
                            File(item.photoPath!),
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, e) =>
                                _ActivityAvatar(abbrev: item.categoryAbbrev),
                          )
                        : _ActivityAvatar(abbrev: item.categoryAbbrev),
                  ),
                  // N1 badge – top-left
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: tt.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                  // 3-dot menu – top-right (visual placeholder)
                  Positioned(
                    top: -4,
                    right: -2,
                    child: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: cs.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
            // ── Text area ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.categoryLabel,
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    displayName,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 10,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          _timeAgo(item.lastUpdate),
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityAvatar extends StatelessWidget {
  const _ActivityAvatar({required this.abbrev});
  final String abbrev;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      color: AppColors.primary.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Text(
        abbrev,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
