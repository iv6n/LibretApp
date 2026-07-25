/// Restored home weather card (compact white box with full details).
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';

class InicioWeatherCard extends StatelessWidget {
  const InicioWeatherCard({required this.weather, super.key});

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
    return const Color(0xFFE9A620);
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final theme = Theme.of(context);
    final tt = theme.textTheme;
    final iconColor = _colorForCondition(weather.condition);

    return Container(
      width: 122,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                _iconFor(weather.condition, hour),
                size: 30,
                color: iconColor,
              ),
              const SizedBox(width: 7),
              Text(
                '${weather.temperature}°',
                style: tt.headlineSmall?.copyWith(
                  color: const Color(0xFF1F271F),
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            weather.condition,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.labelSmall?.copyWith(color: const Color(0xFF4F5F54)),
          ),
          const SizedBox(height: 8),
          Text(
            'Máx. ${weather.maxTemperature}°',
            style: tt.labelSmall?.copyWith(
              color: const Color(0xFF3F4C43),
              fontSize: 10,
            ),
          ),
          Text(
            'Hum. ${weather.humidity}%  ${weather.windSpeed}km/h',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.labelSmall?.copyWith(
              color: const Color(0xFF3F4C43),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Open-Meteo',
            style: tt.labelSmall?.copyWith(
              color: const Color(0xFF6B786E),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}
