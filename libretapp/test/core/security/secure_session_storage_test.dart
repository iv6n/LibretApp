import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/security/services/secure_session_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'session is persisted only through OS secure storage and old copies are removed',
    () async {
      SharedPreferences.setMockInitialValues({
        'sb-project-auth-token': 'old-session',
        'secure.token_bundle.enc.v1': 'old-bundle',
        'perfil_v1': 'local-profile',
      });
      FlutterSecureStorage.setMockInitialValues({});
      const storage = SecureSessionStorage(projectKey: 'project');
      await storage.initialize();
      await storage.persistSession('session-with-refresh-token');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('perfil_v1'), 'local-profile');
      expect(prefs.getString('sb-project-auth-token'), isNull);
      expect(prefs.getString('secure.token_bundle.enc.v1'), isNull);
      expect(prefs.getKeys().any((key) => key.contains('auth')), isFalse);
      expect(await storage.accessToken(), 'session-with-refresh-token');
      await storage.removePersistedSession();
      expect(await storage.hasAccessToken(), isFalse);
    },
  );
}
