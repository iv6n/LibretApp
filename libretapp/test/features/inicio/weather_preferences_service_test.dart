import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/inicio/data/weather_preferences_service.dart';
import 'package:libretapp/features/inicio/data/weather_service.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'refresh guarda datos por espacio y devuelve caché antigua sin red',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = SharedPrefsService(
        await SharedPreferences.getInstance(),
        prefix: 'workspace.guest.',
      );
      final weather = _WeatherService();
      final service = WeatherPreferencesService(
        preferences: prefs,
        weatherService: weather,
      );

      expect(await service.refresh(), isNull);
      await service.saveLocation(
        const WeatherSavedLocation(
          label: 'Hermosillo',
          latitude: 29.0729,
          longitude: -110.9559,
        ),
      );
      final fresh = await service.refresh();
      expect(fresh, isNotNull);
      expect(fresh!.location.label, 'Hermosillo');
      expect(fresh.weather.weatherCode, 65);
      expect(fresh.isStale, isFalse);

      weather.fail = true;
      final old = await service.refresh();
      expect(old, isNotNull);
      expect(old!.isStale, isTrue);
      expect(old.weather.temperature, 8);
    },
  );

  test(
    'la ubicación y el estado de avisos no se comparten entre espacios',
    () async {
      SharedPreferences.setMockInitialValues({});
      final base = await SharedPreferences.getInstance();
      final guest = WeatherPreferencesService(
        preferences: SharedPrefsService(base, prefix: 'workspace.guest.'),
        weatherService: _WeatherService(),
      );
      final account = WeatherPreferencesService(
        preferences: SharedPrefsService(
          base,
          prefix: 'workspace.account.user.',
        ),
        weatherService: _WeatherService(),
      );
      await guest.saveLocation(
        const WeatherSavedLocation(
          label: 'Ciudad',
          latitude: 20,
          longitude: -100,
        ),
      );
      await guest.preferences.setBool(
        WeatherPreferencesService.alertsKey,
        true,
      );
      expect(account.location, isNull);
      expect(account.alertsEnabled, isFalse);
    },
  );
}

class _WeatherService extends WeatherService {
  bool fail = false;

  @override
  Future<WeatherData?> getCurrentWeather({
    required List<LocationEntity> locations,
    required String address,
  }) async => null;

  @override
  Future<WeatherData?> getWeatherAt(WeatherCoordinates coordinates) async {
    if (fail) throw StateError('offline');
    return const WeatherData(
      temperature: 8,
      maxTemperature: 13,
      condition: 'Lluvia',
      humidity: 74,
      windSpeed: 10,
      weatherCode: 65,
    );
  }
}
