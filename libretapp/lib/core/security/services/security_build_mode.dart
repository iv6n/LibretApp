/// core › security › services › security_build_mode — testable seam over kReleaseMode.
///
/// [kReleaseMode] is a compile-time constant fixed by the actual build mode;
/// under `flutter test` it is always `false`, so the release-only guards in
/// [DefaultKeyProviderService]/[AuthService] can never be exercised by a
/// unit test that just calls the code — the `if (kReleaseMode)` branch is
/// unreachable at test time no matter what. This mutable wrapper defaults to
/// the real [kReleaseMode] in production, but lets tests flip it to observe
/// the release-only behavior.
library;

import 'package:flutter/foundation.dart';

bool _isReleaseModeOverride = kReleaseMode;

/// Whether the app should currently behave as a release build.
bool get isSecurityReleaseMode => _isReleaseModeOverride;

/// Overrides [isSecurityReleaseMode] for the duration of a test. Pass `null`
/// to restore the real [kReleaseMode]. Not for use outside tests.
@visibleForTesting
void debugOverrideSecurityReleaseMode(bool? value) {
  _isReleaseModeOverride = value ?? kReleaseMode;
}
