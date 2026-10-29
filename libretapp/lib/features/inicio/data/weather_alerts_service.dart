import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:libretapp/features/inicio/data/weather_preferences_service.dart';
import 'package:permission_handler/permission_handler.dart';

class WeatherAlertsService {
  WeatherAlertsService({
    required this.preferences,
    required this.locationService,
  });

  final SharedPrefsService preferences;
  final WeatherPreferencesService locationService;
  static const _channel = MethodChannel('libretapp/weather_alerts');

  Future<bool> setEnabled({
    required bool enabled,
    required LocalWorkspace workspace,
    required AppExperience experience,
  }) async {
    if (workspace.isDemo) return false;
    if (!enabled) {
      await preferences.setBool(WeatherPreferencesService.alertsKey, false);
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await _channel.invokeMethod<void>('cancel');
      }
      return true;
    }
    final location = locationService.location;
    if (location == null) {
      throw StateError('Primero configura una ciudad o ubicación GPS.');
    }
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    final status = await Permission.notification.request();
    if (!status.isGranted) return false;
    await _channel.invokeMethod<void>('configure', {
      'enabled': true,
      'workspaceId': workspace.id,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'experience': experience.name,
    });
    await preferences.setBool(WeatherPreferencesService.alertsKey, true);
    return true;
  }

  Future<void> syncExisting({
    required LocalWorkspace workspace,
    required AppExperience experience,
  }) async {
    if (workspace.isDemo || !locationService.alertsEnabled) {
      await cancelForWorkspaceChange();
      return;
    }
    final location = locationService.location;
    if (location == null ||
        kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    await _channel.invokeMethod<void>('configure', {
      'enabled': true,
      'workspaceId': workspace.id,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'experience': experience.name,
    });
  }

  static Future<void> cancelForWorkspaceChange() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('cancel');
    } on MissingPluginException {
      // Android-only background scheduling.
    } on PlatformException {
      // The next active workspace will write its own configuration.
    }
  }
}
