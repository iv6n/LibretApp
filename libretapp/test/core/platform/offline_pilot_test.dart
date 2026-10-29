import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/platform/release_features.dart';
import 'package:libretapp/core/backup/supabase_config.dart';

void main() {
  const offline = bool.fromEnvironment('LIBRETAPP_OFFLINE_PILOT');
  test(
    'offline release hides providers and hardware even when credentials exist',
    () {
      if (!offline) return;
      expect(ReleaseFeatures.publicRelease, isTrue);
      expect(ReleaseFeatures.hardwareIntegrationsEnabled, isFalse);
      expect(ReleaseFeatures.gpsCaptureEnabled, isFalse);
      expect(ReleaseFeatures.externalProvidersEnabled, isFalse);
      expect(ReleaseFeatures.phoneAuthEnabled, isFalse);
      expect(ReleaseFeatures.cloudDataEnabled, isFalse);
      expect(SupabaseConfig.isConfigured, isFalse);
    },
  );
}
