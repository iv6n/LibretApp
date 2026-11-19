/// Home dashboard welcome header.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/widgets/app_brand.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/inicio/widgets/dashboard/inicio_weather_card.dart';
import 'package:libretapp/theme/app_theme.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({required this.data, this.weatherCard, super.key});
  final InicioDashboardData data;
  final Widget? weatherCard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name = data.profileName.trim();
    final date = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text.rich(
          TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: colors.primary,
                ),
              ),
              TextSpan(
                text:
                    '  ' +
                    DateFormat('EEEE d MMM', 'es').format(DateTime.now()),
              ),
            ],
          ),
          style: theme.textTheme.labelMedium,
        ),
      ),
    );
    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.isEmpty ? 'Hola' : 'Hola, $name',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        if (data.farmName.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 15, color: colors.primary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(data.farmName, style: theme.textTheme.bodySmall),
              ),
            ],
          ),
        ],
      ],
    );
    final weather =
        weatherCard ??
        (data.weather == null
            ? null
            : InicioWeatherCard(weather: data.weather!));
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(
              colors.primary.withValues(alpha: .08),
              colors.surface,
            ),
            colors.surface,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: LayoutBuilder(
          builder: (context, box) {
            final stacked =
                MediaQuery.textScalerOf(context).scale(14) > 19 ||
                box.maxWidth < 275;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [const AppBrand(height: 30), date],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (stacked || weather == null) ...[
                  identity,
                  if (weather != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    weather,
                  ],
                ] else
                  Row(
                    children: [
                      Expanded(child: identity),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: (box.maxWidth * .53)
                            .clamp(172.0, 210.0)
                            .toDouble(),
                        child: weather,
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
