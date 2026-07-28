import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/security/models/models.dart';
import 'package:libretapp/core/security/ports/ports.dart';
import 'package:libretapp/core/security/services/auth_service.dart';
import 'package:libretapp/core/security/services/security_build_mode.dart';

class _FakeTokenPort implements TokenPort {
  TokenBundle? stored;
  bool accessTokenExpired = false;
  int clearCalls = 0;

  @override
  Future<void> storeTokenBundle(TokenBundle bundle) async {
    stored = bundle;
  }

  @override
  Future<TokenBundle?> loadTokenBundle() async => stored;

  @override
  Future<void> clearTokens() async {
    clearCalls++;
    stored = null;
  }

  @override
  Future<bool> isAccessTokenExpired() async => accessTokenExpired;
}

class _FakeSensitiveLogger implements SensitiveLoggerPort {
  final List<String> infoLogs = [];

  @override
  void info(String message, {String? tag}) => infoLogs.add(message);

  @override
  void warn(String message, {String? tag}) {}

  @override
  void error(String message, {String? tag, StackTrace? stackTrace}) {}

  @override
  String redact(String raw, {PiiKind kind = PiiKind.generic}) => raw;
}

void main() {
  late _FakeTokenPort tokenPort;
  late _FakeSensitiveLogger logger;
  late AuthService service;

  setUp(() {
    tokenPort = _FakeTokenPort();
    logger = _FakeSensitiveLogger();
    service = AuthService(tokenPort: tokenPort, logger: logger);
  });

  tearDown(() => debugOverrideSecurityReleaseMode(null));

  group('AuthService.signIn (debug/test build)', () {
    test('rejects an empty username without storing a token', () async {
      final result = await service.signIn(
        const AuthCredentials(username: '  ', secret: 'whatever'),
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, isNotNull);
      expect(tokenPort.stored, isNull);
    });

    test('rejects an empty secret without storing a token', () async {
      final result = await service.signIn(
        const AuthCredentials(username: 'someone', secret: ''),
      );

      expect(result.isSuccess, isFalse);
      expect(tokenPort.stored, isNull);
    });

    test('accepts non-empty credentials and stores a token bundle', () async {
      final result = await service.signIn(
        const AuthCredentials(username: 'someone', secret: 'anything'),
      );

      expect(result.isSuccess, isTrue);
      expect(result.userId, 'someone');
      expect(result.tokenBundle, isNotNull);
      expect(tokenPort.stored, result.tokenBundle);
      expect(logger.infoLogs, isNotEmpty);
    });
  });

  group('AuthService.signIn (release build)', () {
    test('throws instead of authenticating when the insecure escape hatch is off', () async {
      debugOverrideSecurityReleaseMode(true);

      expect(
        () => service.signIn(
          const AuthCredentials(username: 'someone', secret: 'anything'),
        ),
        throwsA(
          isA<SecurityException>().having(
            (e) => e.code,
            'code',
            'INSECURE_AUTH_STUB_IN_RELEASE',
          ),
        ),
      );
    });
  });

  group('AuthService.signOut / isSessionValid', () {
    test('signOut clears tokens', () async {
      await service.signOut();
      expect(tokenPort.clearCalls, 1);
    });

    test('isSessionValid reflects the negation of isAccessTokenExpired', () async {
      tokenPort.accessTokenExpired = false;
      expect(await service.isSessionValid(), isTrue);

      tokenPort.accessTokenExpired = true;
      expect(await service.isSessionValid(), isFalse);
    });
  });
}
