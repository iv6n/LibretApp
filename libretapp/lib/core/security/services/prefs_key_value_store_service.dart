/// core › security › services › prefs_key_value_store_service — SharedPreferences-backed key-value store.
///
/// Stores whatever string it is given as-is; it performs no encryption of
/// its own. Callers that need confidentiality (e.g. [TokenStoreService])
/// must encrypt the value before writing it here.
library;

import 'package:libretapp/core/security/ports/secure_store_port.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';

class PrefsKeyValueStoreService implements SecureStorePort {
  PrefsKeyValueStoreService(this._prefsService);

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
