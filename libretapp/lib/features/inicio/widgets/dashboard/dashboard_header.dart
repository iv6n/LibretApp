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

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
          final identity = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xxs,
                children: [
                  const AppBrand(height: 24),
                  _InlineMeta(
                    icon: Icons.calendar_today_outlined,
                    label: DateFormat('EEE d MMM', 'es').format(now),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                data.profileName.isEmpty
                    ? greeting
                    : '$greeting, ${data.profileName}',
                softWrap: true,
                style: tt.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  height: 1.08,
                ),
              ),
              if (data.farmName.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxs),
                _InlineMeta(
                  icon: Icons.location_on_outlined,
                  label: data.farmName,
                  maxWidth: constraints.maxWidth - 24,
                  maxLines: 2,
                ),
              ],
            ],
          );

          if (data.weather == null) return identity;

          final weatherWidth = (136 * textScale.clamp(1.0, 2.0))
              .clamp(0.0, constraints.maxWidth)
              .toDouble();
          final weather = SizedBox(
            width: weatherWidth,
            child: InicioWeatherCard(weather: data.weather!),
          );
          if (constraints.maxWidth < weatherWidth + AppSpacing.sm + 240 ||
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
    );
  }
}

class _InlineMeta extends StatelessWidget {
  const _InlineMeta({
    required this.icon,
    required this.label,
    this.maxWidth = 130,
    this.maxLines = 1,
  });

  final IconData icon;
  final String label;
  final double maxWidth;
  final int maxLines;

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
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Text(
            label,
            maxLines: maxLines,
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
