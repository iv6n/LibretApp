/// Build-time gates for capabilities that require external hardware or
/// provider credentials before they can be exposed to public users.
library;

class ReleaseFeatures {
  const ReleaseFeatures._();

  /// Public builds are produced with `LIBRETAPP_PUBLIC_RELEASE=true`.
  static const bool publicRelease = bool.fromEnvironment(
    'LIBRETAPP_PUBLIC_RELEASE',
    defaultValue: false,
  );

  /// Internal builds keep the adapters available for QA. Public builds hide
  /// the entry points until a real device has been certified.
  static const bool hardwareIntegrationsEnabled =
      !publicRelease &&
      bool.fromEnvironment('LIBRETAPP_ENABLE_HARDWARE', defaultValue: true);

  /// GPS capture remains optional; manual coordinates continue to work.
  static const bool gpsCaptureEnabled =
      !publicRelease &&
      bool.fromEnvironment('LIBRETAPP_ENABLE_GPS', defaultValue: true);

  /// Cloud/provider flows require configured accounts, privacy disclosures,
  /// and a production contract before being exposed publicly.
  static const bool externalProvidersEnabled =
      !publicRelease &&
      bool.fromEnvironment(
        'LIBRETAPP_ENABLE_EXTERNAL_PROVIDERS',
        defaultValue: true,
      );
}
