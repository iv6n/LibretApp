/// Home dashboard welcome header.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/widgets/app_brand.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/inicio/widgets/dashboard/inicio_weather_card.dart';
import 'package:libretapp/theme/app_theme.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({required this.data, super.key});

  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Buenos días'
        : hour < 18
        ? 'Buenas tardes'
        : 'Buenas noches';
    final theme = Theme.of(context);
    final tt = theme.textTheme;

    final alertCount = data.alerts
        .where((a) => a.severity != InicioAlertSeverity.info)
        .length;
    final calvingCount = data.upcomingCalvings.length;
    final activityCount = data.recentActivity.length;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final identity = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AppBrand(height: 24),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  data.profileName.isEmpty
                      ? greeting
                      : '$greeting, ${data.profileName}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (alertCount > 0 || calvingCount > 0)
                  Text(
                    _statusLine(
                      alertCount: alertCount,
                      calvingCount: calvingCount,
                      activityCount: activityCount,
                    ),
                    style: tt.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xxs,
                  children: [
                    _InlineMeta(
                      icon: Icons.location_on_outlined,
                      label: data.farmName.isEmpty ? 'Rancho' : data.farmName,
                    ),
                    _InlineMeta(
                      icon: Icons.calendar_today_outlined,
                      label: DateFormat('EEE d MMM', 'es').format(now),
                    ),
                  ],
                ),
              ],
            );
            if (data.weather == null) return identity;

            final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
            final weatherWidth = (136 * textScale.clamp(1.0, 2.0))
                .clamp(0.0, constraints.maxWidth)
                .toDouble();
            final weather = SizedBox(
              width: weatherWidth,
              child: InicioWeatherCard(weather: data.weather!),
            );

            // Leave room for the identity and scaled weather details on phones.
            if (constraints.maxWidth < weatherWidth + AppSpacing.sm + 160 ||
                textScale > 1.3) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  identity,
                  const SizedBox(height: AppSpacing.md),
                  weather,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: identity),
                const SizedBox(width: AppSpacing.sm),
                weather,
              ],
            );
          },
        ),
      ),
    );
  }

  String _statusLine({
    required int alertCount,
    required int calvingCount,
    required int activityCount,
  }) {
    final parts = <String>[];
    if (alertCount > 0) {
      parts.add('$alertCount alerta${alertCount == 1 ? '' : 's'}');
    }
    if (calvingCount > 0) {
      parts.add('$calvingCount parto${calvingCount == 1 ? '' : 's'}');
    }
    if (activityCount > 0) {
      parts.add('$activityCount registro${activityCount == 1 ? '' : 's'}');
    }
    return parts.join(' - ');
  }
}

class _InlineMeta extends StatelessWidget {
  const _InlineMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.xxs),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 130),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
