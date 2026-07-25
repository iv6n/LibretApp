/// Home dashboard welcome header.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/inicio/widgets/dashboard/inicio_weather_card.dart';
import 'package:libretapp/theme/app_theme.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({required this.data, super.key});

  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Buenos dias'
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
      padding: EdgeInsets.only(top: topPadding + AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.74),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, ${data.profileName.isEmpty ? 'vaquero' : data.profileName}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleLarge?.copyWith(
                      color: const Color(0xFF174332),
                      fontWeight: FontWeight.w800,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    alertCount > 0 || calvingCount > 0
                        ? _statusLine(
                            alertCount: alertCount,
                            calvingCount: calvingCount,
                            activityCount: activityCount,
                          )
                        : 'Rancho en orden hoy',
                    style: tt.bodySmall?.copyWith(
                      color: const Color(0xFF455A50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _InlineMeta(
                        icon: Icons.location_on_outlined,
                        label: data.farmName.isEmpty
                            ? 'Rancho'
                            : data.farmName,
                      ),
                      _InlineMeta(
                        icon: Icons.calendar_today_outlined,
                        label: DateFormat('EEE d MMM', 'es').format(now),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (data.weather != null) ...[
              const SizedBox(width: 10),
              InicioWeatherCard(weather: data.weather!),
            ],
          ],
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
        Icon(icon, size: 14, color: const Color(0xFF455A50)),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFF455A50),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
