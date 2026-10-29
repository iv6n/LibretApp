/// Build-time gates for capabilities that require external hardware or
/// provider credentials before they can be exposed to public users.
library;

class ReleaseFeatures {
  const ReleaseFeatures._();

  /// Set by the composition root before building a workspace's widget tree.
  static bool demoMode = false;

  /// Independent from cloud backup, sync and hardware availability.
  static const bool phoneAuthEnabled =
      !offlinePilot &&
      bool.fromEnvironment('LIBRETAPP_ENABLE_PHONE_AUTH', defaultValue: false);
  static const bool connected =
      String.fromEnvironment('FLUTTER_APP_FLAVOR') == 'connected';

  static const bool cloudBackupEnabled =
      !offlinePilot &&
      bool.fromEnvironment('LIBRETAPP_ENABLE_CLOUD_BACKUP', defaultValue: false);

  static const bool syncEnabled =
      !publicRelease &&
      bool.fromEnvironment('LIBRETAPP_ENABLE_SYNC', defaultValue: false);

  // Compatibility for internal callers; public backup has its own gate.
  static const bool cloudDataEnabled = syncEnabled;

  /// Public builds are produced with `LIBRETAPP_PUBLIC_RELEASE=true`.
  static const bool offlinePilot =
      String.fromEnvironment('FLUTTER_APP_FLAVOR') == 'offline' ||
      bool.fromEnvironment('LIBRETAPP_OFFLINE_PILOT', defaultValue: false);

  static const bool publicRelease =
      offlinePilot || connected ||
      bool.fromEnvironment('LIBRETAPP_PUBLIC_RELEASE', defaultValue: false);

  /// Internal builds keep the adapters available for QA. Public builds hide
  /// the entry points until a real device has been certified.
  static bool get hardwareIntegrationsEnabled =>
      !demoMode &&
      !publicRelease &&
      const bool.fromEnvironment(
        'LIBRETAPP_ENABLE_HARDWARE',
        defaultValue: true,
      );

  /// GPS capture remains optional; manual coordinates continue to work.
  static bool get gpsCaptureEnabled =>
      !demoMode &&
      !publicRelease &&
      const bool.fromEnvironment('LIBRETAPP_ENABLE_GPS', defaultValue: true);

  /// Cloud/provider flows require configured accounts, privacy disclosures,
  /// and a production contract before being exposed publicly.
  static bool get externalProvidersEnabled =>
      !demoMode &&
      !publicRelease &&
      const bool.fromEnvironment(
        'LIBRETAPP_ENABLE_EXTERNAL_PROVIDERS',
        defaultValue: true,
      );
}
