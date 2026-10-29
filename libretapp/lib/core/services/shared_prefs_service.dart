/// core › services › shared_prefs_service — wrapper around SharedPreferences.
library;

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  SharedPrefsService(this._prefs, {this.prefix = ''});

  final SharedPreferences _prefs;
  final String prefix;

  SharedPrefsService scoped(String workspacePrefix) =>
      SharedPrefsService(_prefs, prefix: workspacePrefix);

  Future<void> clearWorkspace() async {
    if (prefix.isEmpty) {
      throw StateError('No se pueden limpiar las preferencias globales.');
    }
    for (final key
        in _prefs.getKeys().where((key) => key.startsWith(prefix)).toList()) {
      await _checked(_prefs.remove(key));
    }
  }

  String _key(String key) =>
      const {
        'app.theme',
        'app.language',
        'onboarding.completed.v1',
        'onboarding.page.v2',
        'onboarding.intro.page.v1',
        'onboarding.experience.pending.v1',
        'workspaces.registry.v1',
      }.contains(key)
      ? key
      : '$prefix$key';

  Future<void> _checked(Future<bool> operation) async {
    if (!await operation) {
      throw StateError(
        'No se pudieron guardar los cambios en este dispositivo.',
      );
    }
  }

  String? getString(String key) => _prefs.getString(_key(key));

  Future<void> setString(String key, String value) async {
    await _checked(_prefs.setString(_key(key), value));
  }

  int? getInt(String key) => _prefs.getInt(_key(key));

  Future<void> setInt(String key, int value) async {
    await _checked(_prefs.setInt(_key(key), value));
  }

  bool? getBool(String key) => _prefs.getBool(_key(key));

  Future<void> setBool(String key, bool value) async {
    await _checked(_prefs.setBool(_key(key), value));
  }

  DateTime? getDateTime(String key) {
    final millis = getInt(key);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> setDateTime(String key, DateTime value) async {
    await setInt(key, value.millisecondsSinceEpoch);
  }

  Future<void> remove(String key) async {
    await _checked(_prefs.remove(_key(key)));
  }
}
