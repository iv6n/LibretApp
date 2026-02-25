import 'package:flutter/material.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';

class ThemeRepository {
  ThemeRepository(this._prefs);

  final SharedPrefsService _prefs;

  Future<ThemeMode> loadThemeMode({
    ThemeMode fallback = ThemeMode.system,
  }) async {
    final saved = _prefs.getString(PrefsKeys.appTheme);
    switch (saved) {
      case _themeLight:
        return ThemeMode.light;
      case _themeDark:
        return ThemeMode.dark;
      case _themeSystem:
        return ThemeMode.system;
      default:
        return fallback;
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => _themeLight,
      ThemeMode.dark => _themeDark,
      ThemeMode.system => _themeSystem,
    };
    await _prefs.setString(PrefsKeys.appTheme, value);
  }
}

const _themeLight = 'light';
const _themeDark = 'dark';
const _themeSystem = 'system';
