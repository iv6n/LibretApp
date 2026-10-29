import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';

/// Offers the backup shortcut once after a successful first animal registration.
Future<bool> consumeFirstBackupSuggestion() async {
  if (!locator.isRegistered<SharedPrefsService>()) return false;
  final prefs = locator<SharedPrefsService>();
  if (prefs.getBool(PrefsKeys.firstBackupSuggestionShown) == true) {
    return false;
  }
  if (prefs.getDateTime(PrefsKeys.lastLocalBackup) != null ||
      prefs.getDateTime(PrefsKeys.lastCloudBackup) != null) {
    return false;
  }
  try {
    await prefs.setBool(PrefsKeys.firstBackupSuggestionShown, true);
    return true;
  } catch (_) {
    // A failed preference write must not make a successful registration fail.
    return false;
  }
}
