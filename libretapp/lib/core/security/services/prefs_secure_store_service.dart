/// core › security › services › prefs_secure_store_service — encrypted SharedPreferences key-value store.
library;

import 'package:libretapp/core/security/ports/secure_store_port.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';

class PrefsSecureStoreService implements SecureStorePort {
  PrefsSecureStoreService(this._prefsService);

  final SharedPrefsService _prefsService;

  @override
  Future<void> write({required String key, required String value}) {
    return _prefsService.setString(key, value);
  }

  @override
  Future<String?> read({required String key}) async {
    return _prefsService.getString(key);
  }

  @override
  Future<void> delete({required String key}) {
    return _prefsService.remove(key);
  }
}
