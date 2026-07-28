import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/security/models/models.dart';
import 'package:libretapp/core/security/services/default_key_provider_service.dart';
import 'package:libretapp/core/security/services/security_build_mode.dart';

void main() {
  late DefaultKeyProviderService service;

  setUp(() {
    service = DefaultKeyProviderService();
  });

  tearDown(() => debugOverrideSecurityReleaseMode(null));

  group('DefaultKeyProviderService (debug/test build)', () {
    test('returns the dev default key encoded as UTF-8 bytes', () async {
      final key = await service.getTokenMasterKey();

      expect(utf8.decode(key), 'dev-token-master-key-change-me');
    });

    test('returns a non-empty key on every call', () async {
      final key = await service.getTokenMasterKey();
      expect(key, isNotEmpty);
    });
  });

  group('DefaultKeyProviderService (release build)', () {
    test('throws instead of handing out the public default key', () async {
      debugOverrideSecurityReleaseMode(true);

      expect(
        () => service.getTokenMasterKey(),
        throwsA(
          isA<SecurityException>().having(
            (e) => e.code,
            'code',
            'INSECURE_DEFAULT_KEY_IN_RELEASE',
          ),
        ),
      );
    });
  });
}
