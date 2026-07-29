/// core › security › services › supabase_auth_service — Supabase-backed
/// implementation of [AuthPort] for the optional cloud backup feature.
///
/// Only wired in when [SupabaseConfig.isConfigured] — see
/// `lib/core/di/injection.dart`. The app must keep working fully offline
/// with the local [AuthService] stub when there's no Supabase project
/// configured.
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
      final res = await _client.auth.signInWithPassword(
        email: credentials.username.trim(),
        password: credentials.secret,
      );
      return _resultFromSession(res.session, res.user);
    } on supabase.AuthException catch (e) {
      _logger.warn('Sign-in failed: ${e.message}', tag: 'Auth');
      return AuthResult(isSuccess: false, errorMessage: e.message);
    }
  }

  @override
  Future<AuthResult> signUp(AuthCredentials credentials) async {
    try {
      final res = await _client.auth.signUp(
        email: credentials.username.trim(),
        password: credentials.secret,
      );
      return _resultFromSession(
        res.session,
        res.user,
        pendingConfirmationMessage:
            'Cuenta creada. Revisa tu correo para confirmarla antes de '
            'respaldar en la nube.',
      );
    } on supabase.AuthException catch (e) {
      _logger.warn('Sign-up failed: ${e.message}', tag: 'Auth');
      return AuthResult(isSuccess: false, errorMessage: e.message);
    }
  }

  Future<AuthResult> _resultFromSession(
    supabase.Session? session,
    supabase.User? user, {
    String pendingConfirmationMessage = 'No se pudo iniciar sesión.',
  }) async {
    if (session == null) {
      return AuthResult(isSuccess: false, errorMessage: pendingConfirmationMessage);
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
    _logger.info('Signed in as ${user?.id}', tag: 'Auth');
    return AuthResult(isSuccess: true, userId: user?.id, tokenBundle: bundle);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
    await _tokenPort.clearTokens();
    _logger.info('Session cleared', tag: 'Auth');
  }

  @override
  Future<bool> isSessionValid() async => _client.auth.currentSession != null;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;
}
