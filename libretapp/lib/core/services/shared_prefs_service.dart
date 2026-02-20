import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  SharedPrefsService(this._prefs);

  final SharedPreferences _prefs;

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  int? getInt(String key) => _prefs.getInt(key);

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  DateTime? getDateTime(String key) {
    final millis = _prefs.getInt(key);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> setDateTime(String key, DateTime value) async {
    await _prefs.setInt(key, value.millisecondsSinceEpoch);
  }
}
