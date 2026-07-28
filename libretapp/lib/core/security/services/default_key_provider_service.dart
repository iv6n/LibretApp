/// core › security › services › default_key_provider_service — derives encryption keys from platform secrets.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:libretapp/core/security/models/models.dart';
import 'package:libretapp/core/security/ports/key_provider_port.dart';
import 'package:libretapp/core/security/services/security_build_mode.dart';

class DefaultKeyProviderService implements KeyProviderPort {
  static const _devDefaultKey = 'dev-token-master-key-change-me';

  static const _envMasterKey = String.fromEnvironment(
    'LIBRET_TOKEN_MASTER_KEY',
    defaultValue: _devDefaultKey,
  );

  // Escape hatch for release builds that intentionally accept the public
  // default (e.g. a demo/staging build). Off by default so release builds
  // fail loudly instead of shipping a key anyone can read from the repo.
  static const _allowInsecureDefaultKeyInRelease = bool.fromEnvironment(
    'LIBRET_ALLOW_INSECURE_TOKEN_KEY_IN_RELEASE',
    defaultValue: false,
  );

  @override
  Future<Uint8List> getTokenMasterKey() async {
    if (isSecurityReleaseMode &&
        _envMasterKey == _devDefaultKey &&
        !_allowInsecureDefaultKeyInRelease) {
      throw SecurityException(
        'Release build requires LIBRET_TOKEN_MASTER_KEY to be provided at '
        'build time; refusing to encrypt tokens with the public default key.',
        code: 'INSECURE_DEFAULT_KEY_IN_RELEASE',
      );
    }
    return Uint8List.fromList(utf8.encode(_envMasterKey));
  }
}
