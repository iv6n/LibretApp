import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase is the sole writer of session tokens; no duplicate TokenBundle.
class SecureSessionStorage extends LocalStorage {
  const SecureSessionStorage({
    required this.projectKey,
    this.storage = const FlutterSecureStorage(),
  });
  final String projectKey;
  final FlutterSecureStorage storage;
  String get _key => 'libretapp.auth.$projectKey';
  @override
  Future<void> initialize() async {
    // Existing email sessions are not adopted as verified phone accounts.
    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      'sb-$projectKey-auth-token',
      'secure.token_bundle.enc.v1',
      'secure.access_token',
      'secure.refresh_token',
      'secure.access_token_expiry_utc',
    ]) {
      if (prefs.containsKey(key) && !await prefs.remove(key)) {
        throw StateError('No se pudo retirar una sesión anterior.');
      }
    }
  }

  @override
  Future<bool> hasAccessToken() async => await accessToken() != null;
  @override
  Future<String?> accessToken() => storage.read(key: _key);
  @override
  Future<void> removePersistedSession() => storage.delete(key: _key);
  @override
  Future<void> persistSession(String persistSessionString) =>
      storage.write(key: _key, value: persistSessionString);
}
