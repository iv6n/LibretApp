/// core › security › services › auth_service — default authentication service implementation.
library;

import 'package:libretapp/core/security/models/models.dart';
import 'package:libretapp/core/security/ports/ports.dart';

class AuthService implements AuthPort {
  AuthService({
    required TokenPort tokenPort,
    required SensitiveLoggerPort logger,
  }) : _tokenPort = tokenPort,
       _logger = logger;

  final TokenPort _tokenPort;
  final SensitiveLoggerPort _logger;

  @override
  Future<AuthResult> signIn(AuthCredentials credentials) async {
    if (credentials.username.trim().isEmpty || credentials.secret.isEmpty) {
      return const AuthResult(
        isSuccess: false,
        errorMessage: 'Credenciales inválidas.',
      );
    }

    _logger.info('Auth attempt for user ${credentials.username}', tag: 'Auth');

    // Placeholder behavior until native auth provider is integrated.
    final expiresAtUtc = DateTime.now().toUtc().add(const Duration(hours: 1));
    final tokenBundle = TokenBundle(
      accessToken: 'stub_access_token',
      refreshToken: 'stub_refresh_token',
      expiresAtUtc: expiresAtUtc,
    );

    await _tokenPort.storeTokenBundle(tokenBundle);
    return AuthResult(
      isSuccess: true,
      userId: credentials.username,
      tokenBundle: tokenBundle,
    );
  }

  @override
  Future<void> signOut() async {
    await _tokenPort.clearTokens();
    _logger.info('Session cleared', tag: 'Auth');
  }

  @override
  Future<bool> isSessionValid() async {
    return !(await _tokenPort.isAccessTokenExpired());
  }
}
