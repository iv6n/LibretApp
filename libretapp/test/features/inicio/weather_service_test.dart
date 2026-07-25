import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:libretapp/features/inicio/data/weather_service.dart';

void main() {
  test('loads real current conditions from Open-Meteo coordinates', () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'api.open-meteo.com');
      expect(request.url.path, '/v1/forecast');
      expect(request.url.queryParameters['latitude'], '29.0729');
      expect(request.url.queryParameters['longitude'], '-110.9559');
      expect(
        request.url.queryParameters['current'],
        contains('relative_humidity_2m'),
      );
      return http.Response(
        '''
        {
          "current": {
            "temperature_2m": 31.6,
            "relative_humidity_2m": 38,
            "weather_code": 2,
            "wind_speed_10m": 14.4
          },
          "daily": {
            "temperature_2m_max": [39.1]
          }
        }
        ''',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final service = OpenMeteoWeatherService(
      client: client,
      positionProvider: const _FakePositionProvider(
        WeatherCoordinates(latitude: 29.0729, longitude: -110.9559),
      ),
    );

    final weather = await service.getCurrentWeather(
      locations: const [],
      address: '',
    );

    expect(weather, isNotNull);
    expect(weather!.temperature, 32);
    expect(weather.maxTemperature, 39);
    expect(weather.condition, 'Parcialmente nublado');
    expect(weather.humidity, 38);
    expect(weather.windSpeed, 14);
  });

  test('extracts a representative coordinate from GeoJSON', () {
    final point = coordinatesFromGeoJson(
      '{"type":"Point","coordinates":[-110.9559,29.0729]}',
    );
    final polygon = coordinatesFromGeoJson(
      '''
      {
        "type": "Polygon",
        "coordinates": [[
          [-111.0, 29.0],
          [-110.0, 29.0],
          [-110.0, 30.0],
          [-111.0, 30.0]
        ]]
      }
      ''',
    );

    expect(point, isNotNull);
    expect(point!.latitude, closeTo(29.0729, 0.00001));
    expect(point.longitude, closeTo(-110.9559, 0.00001));
    expect(polygon, isNotNull);
    expect(polygon!.latitude, closeTo(29.5, 0.00001));
    expect(polygon.longitude, closeTo(-110.5, 0.00001));
  });

  test('maps WMO weather codes to Spanish conditions', () {
    expect(weatherConditionForCode(0), 'Despejado');
    expect(weatherConditionForCode(65), 'Lluvia');
    expect(weatherConditionForCode(95), 'Tormenta');
    expect(weatherConditionForCode(99), 'Tormenta con granizo');
  });
}

class _FakePositionProvider implements WeatherPositionProvider {
  const _FakePositionProvider(this.coordinates);

  final WeatherCoordinates? coordinates;

  @override
  Future<WeatherCoordinates?> getCurrentCoordinates() async => coordinates;
}
