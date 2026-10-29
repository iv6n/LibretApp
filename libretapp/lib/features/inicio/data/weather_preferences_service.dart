import 'dart:convert';

import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/inicio/data/weather_service.dart';

class WeatherSavedLocation {
  const WeatherSavedLocation({
    required this.label,
    required this.latitude,
    required this.longitude,
  });

  final String label;
  final double latitude;
  final double longitude;
  WeatherCoordinates get coordinates =>
      WeatherCoordinates(latitude: latitude, longitude: longitude);
}

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.weather,
    required this.updatedAt,
    required this.isStale,
    required this.location,
  });

  final WeatherData weather;
  final DateTime updatedAt;
  final bool isStale;
  final WeatherSavedLocation location;
}

/// Per-workspace weather location and cache. It never requests location by
/// itself; GPS access is explicit through [requestCurrentCoordinates].
class WeatherPreferencesService {
  WeatherPreferencesService({
    required this.preferences,
    required this.weatherService,
  });

  final SharedPrefsService preferences;
  final WeatherService weatherService;

  static const locationKey = 'weather.location.v1';
  static const cacheKey = 'weather.cache.v1';
  static const alertsKey = 'weather.alerts.enabled.v1';

  WeatherSavedLocation? get location {
    final raw = preferences.getString(locationKey);
    if (raw == null) return null;
    try {
      final value = jsonDecode(raw);
      if (value is! Map<String, dynamic>) return null;
      final latitude = double.tryParse('${value['latitude']}');
      final longitude = double.tryParse('${value['longitude']}');
      if (latitude == null || longitude == null) return null;
      return WeatherSavedLocation(
        label: '${value['label'] ?? 'Ubicación guardada'}',
        latitude: latitude,
        longitude: longitude,
      );
    } catch (_) {
      return null;
    }
  }

  bool get alertsEnabled => preferences.getBool(alertsKey) == true;

  Future<void> saveLocation(WeatherSavedLocation value) async {
    if (value.latitude < -90 ||
        value.latitude > 90 ||
        value.longitude < -180 ||
        value.longitude > 180) {
      throw ArgumentError('Las coordenadas no son válidas.');
    }
    final previous = location;
    if (previous == null ||
        previous.latitude != value.latitude ||
        previous.longitude != value.longitude) {
      await preferences.remove(cacheKey);
    }
    await preferences.setString(
      locationKey,
      jsonEncode({
        'label': value.label.trim(),
        'latitude': value.latitude,
        'longitude': value.longitude,
      }),
    );
  }

  WeatherSnapshot? get cached {
    final place = location;
    final raw = preferences.getString(cacheKey);
    if (place == null || raw == null) return null;
    try {
      final value = jsonDecode(raw);
      if (value is! Map<String, dynamic>) return null;
      final updatedAt = DateTime.tryParse('${value['updatedAt']}');
      final cachedLatitude = double.tryParse('${value['latitude']}');
      final cachedLongitude = double.tryParse('${value['longitude']}');
      final weather = value['weather'];
      if (updatedAt == null ||
          cachedLatitude != place.latitude ||
          cachedLongitude != place.longitude ||
          weather is! Map<String, dynamic>) {
        return null;
      }
      return WeatherSnapshot(
        location: place,
        updatedAt: updatedAt,
        isStale: true,
        weather: WeatherData(
          temperature: (weather['temperature'] as num).round(),
          maxTemperature: (weather['maxTemperature'] as num).round(),
          condition: '${weather['condition']}',
          humidity: (weather['humidity'] as num).round(),
          windSpeed: (weather['windSpeed'] as num).round(),
          weatherCode: (weather['weatherCode'] as num?)?.round() ?? 0,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<WeatherSnapshot?> refresh() async {
    final place = location;
    if (place == null) return null;
    final old = cached;
    try {
      final weather = await weatherService.getWeatherAt(place.coordinates);
      if (weather == null) return old == null ? null : _stale(old);
      final now = DateTime.now();
      await preferences.setString(
        cacheKey,
        jsonEncode({
          'updatedAt': now.toIso8601String(),
          'latitude': place.latitude,
          'longitude': place.longitude,
          'weather': {
            'temperature': weather.temperature,
            'maxTemperature': weather.maxTemperature,
            'condition': weather.condition,
            'humidity': weather.humidity,
            'windSpeed': weather.windSpeed,
            'weatherCode': weather.weatherCode,
          },
        }),
      );
      return WeatherSnapshot(
        weather: weather,
        updatedAt: now,
        isStale: false,
        location: place,
      );
    } catch (_) {
      return old == null ? null : _stale(old);
    }
  }

  WeatherSnapshot _stale(WeatherSnapshot value) => WeatherSnapshot(
    weather: value.weather,
    updatedAt: value.updatedAt,
    isStale: true,
    location: location ?? value.location,
  );
}
