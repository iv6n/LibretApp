/// Supabase email/password authentication for optional cloud backups.
library;

import 'package:libretapp/core/security/models/models.dart';
import 'package:libretapp/core/security/ports/ports.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class SupabaseAuthService implements AuthPort {
  SupabaseAuthService({
    required supabase.SupabaseClient client,
    required TokenPort tokenPort,
    required SensitiveLoggerPort logger,
  }) : _client = client,
       _tokenPort = tokenPort,
       _logger = logger;

  final supabase.SupabaseClient _client;
  final TokenPort _tokenPort;
  final SensitiveLoggerPort _logger;

  @override
  Future<AuthResult> signIn(AuthCredentials credentials) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: credentials.username.trim(),
        password: credentials.secret,
      );
      return _result(response.session, response.user);
    } on supabase.AuthException catch (error) {
      _logger.warn('Cloud sign-in failed', tag: 'Auth');
      return AuthResult(isSuccess: false, errorMessage: error.message);
    }
  }

  @override
  Future<AuthResult> signUp(AuthCredentials credentials) async {
    try {
      final response = await _client.auth.signUp(
        email: credentials.username.trim(),
        password: credentials.secret,
      );
      if (response.session == null) {
        return const AuthResult(
          isSuccess: false,
          errorMessage:
              'Cuenta creada. Revisa tu correo antes de iniciar sesión.',
        );
      }
      return _result(response.session, response.user);
    } on supabase.AuthException catch (error) {
      _logger.warn('Cloud sign-up failed', tag: 'Auth');
      return AuthResult(isSuccess: false, errorMessage: error.message);
    }
  }

  Future<AuthResult> _result(
    supabase.Session? session,
    supabase.User? user,
  ) async {
    if (session == null) {
      return const AuthResult(
        isSuccess: false,
        errorMessage: 'No se pudo iniciar sesión.',
      );
    }
    final bundle = TokenBundle(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken ?? '',
      expiresAtUtc: DateTime.fromMillisecondsSinceEpoch(
        (session.expiresAt ?? 0) * 1000,
        isUtc: true,
      ),
    );
    await _tokenPort.storeTokenBundle(bundle);
    return AuthResult(isSuccess: true, userId: user?.id, tokenBundle: bundle);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
    await _tokenPort.clearTokens();
  }

  @override
  Future<bool> isSessionValid() async => _client.auth.currentSession != null;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;
}
