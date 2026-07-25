/// Real weather data for the home dashboard.
library;

import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';

class WeatherCoordinates {
  const WeatherCoordinates({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

abstract class WeatherPositionProvider {
  Future<WeatherCoordinates?> getCurrentCoordinates();
}

class DeviceWeatherPositionProvider implements WeatherPositionProvider {
  @override
  Future<WeatherCoordinates?> getCurrentCoordinates() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final lastKnown = await Geolocator.getLastKnownPosition();
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return WeatherCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      if (lastKnown == null) return null;
      return WeatherCoordinates(
        latitude: lastKnown.latitude,
        longitude: lastKnown.longitude,
      );
    }
  }
}

abstract class WeatherService {
  Future<WeatherData?> getCurrentWeather({
    required List<LocationEntity> locations,
    required String address,
  });
}

class OpenMeteoWeatherService implements WeatherService {
  OpenMeteoWeatherService({
    http.Client? client,
    WeatherPositionProvider? positionProvider,
  }) : _client = client ?? http.Client(),
       _positionProvider =
           positionProvider ?? DeviceWeatherPositionProvider();

  final http.Client _client;
  final WeatherPositionProvider _positionProvider;

  @override
  Future<WeatherData?> getCurrentWeather({
    required List<LocationEntity> locations,
    required String address,
  }) async {
    final coordinates =
        _coordinatesFromLocations(locations) ??
        await _coordinatesFromAddress(address) ??
        await _positionProvider.getCurrentCoordinates();
    if (coordinates == null) return null;

    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': coordinates.latitude.toString(),
      'longitude': coordinates.longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
      'daily': 'temperature_2m_max',
      'forecast_days': '1',
      'timezone': 'auto',
    });
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw StateError('Weather provider returned ${response.statusCode}');
    }

    final payload = jsonDecode(utf8.decode(response.bodyBytes));
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('Invalid weather response');
    }
    final current = payload['current'];
    final daily = payload['daily'];
    if (current is! Map<String, dynamic> ||
        daily is! Map<String, dynamic>) {
      throw const FormatException('Weather response is incomplete');
    }

    final temperature = _number(current['temperature_2m']);
    final humidity = _number(current['relative_humidity_2m']);
    final weatherCode = _number(current['weather_code']);
    final windSpeed = _number(current['wind_speed_10m']);
    final maximums = daily['temperature_2m_max'];
    final maxTemperature = maximums is List && maximums.isNotEmpty
        ? _number(maximums.first)
        : null;
    if (temperature == null ||
        humidity == null ||
        weatherCode == null ||
        windSpeed == null ||
        maxTemperature == null) {
      throw const FormatException('Weather response contains invalid values');
    }

    return WeatherData(
      temperature: temperature.round(),
      maxTemperature: maxTemperature.round(),
      condition: weatherConditionForCode(weatherCode.round()),
      humidity: humidity.round(),
      windSpeed: windSpeed.round(),
    );
  }

  WeatherCoordinates? _coordinatesFromLocations(
    List<LocationEntity> locations,
  ) {
    final ordered = List<LocationEntity>.from(locations)
      ..sort((a, b) {
        final aPriority = a.status == LocationStatus.inUse ? 0 : 1;
        final bPriority = b.status == LocationStatus.inUse ? 0 : 1;
        return aPriority.compareTo(bPriority);
      });
    for (final location in ordered) {
      final coordinates = coordinatesFromGeoJson(location.geometry);
      if (coordinates != null) return coordinates;
    }
    return null;
  }

  Future<WeatherCoordinates?> _coordinatesFromAddress(String address) async {
    final query = address.trim();
    if (query.isEmpty) return null;
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query,
      'count': '1',
      'language': 'es',
      'format': 'json',
    });
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final payload = jsonDecode(utf8.decode(response.bodyBytes));
      if (payload is! Map<String, dynamic>) return null;
      final results = payload['results'];
      if (results is! List || results.isEmpty) return null;
      final first = results.first;
      if (first is! Map<String, dynamic>) return null;
      return _validatedCoordinates(
        latitude: _number(first['latitude']),
        longitude: _number(first['longitude']),
      );
    } catch (_) {
      return null;
    }
  }
}

WeatherCoordinates? coordinatesFromGeoJson(String? rawGeometry) {
  final raw = rawGeometry?.trim();
  if (raw == null || raw.isEmpty) return null;
  try {
    final decoded = jsonDecode(raw);
    final points = <WeatherCoordinates>[];
    void collect(Object? value) {
      if (value is Map<String, dynamic>) {
        collect(value['coordinates']);
        return;
      }
      if (value is! List) return;
      if (value.length >= 2 && value[0] is num && value[1] is num) {
        final point = _validatedCoordinates(
          latitude: (value[1] as num).toDouble(),
          longitude: (value[0] as num).toDouble(),
        );
        if (point != null) points.add(point);
        return;
      }
      for (final child in value) {
        collect(child);
      }
    }

    collect(decoded);
    if (points.isEmpty) return null;
    return WeatherCoordinates(
      latitude:
          points.fold<double>(0, (sum, point) => sum + point.latitude) /
          points.length,
      longitude:
          points.fold<double>(0, (sum, point) => sum + point.longitude) /
          points.length,
    );
  } catch (_) {
    return null;
  }
}

WeatherCoordinates? _validatedCoordinates({
  required double? latitude,
  required double? longitude,
}) {
  if (latitude == null || longitude == null) return null;
  if (latitude < -90 || latitude > 90) return null;
  if (longitude < -180 || longitude > 180) return null;
  return WeatherCoordinates(latitude: latitude, longitude: longitude);
}

double? _number(Object? value) => value is num ? value.toDouble() : null;

String weatherConditionForCode(int code) {
  return switch (code) {
    0 => 'Despejado',
    1 => 'Mayormente despejado',
    2 => 'Parcialmente nublado',
    3 => 'Nublado',
    45 || 48 => 'Niebla',
    >= 51 && <= 57 => 'Llovizna',
    >= 61 && <= 67 => 'Lluvia',
    >= 71 && <= 77 => 'Nieve',
    >= 80 && <= 82 => 'Chubascos',
    85 || 86 => 'Chubascos de nieve',
    95 => 'Tormenta',
    96 || 99 => 'Tormenta con granizo',
    _ => 'Condición variable',
  };
}
