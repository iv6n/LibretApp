import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:libretapp/core/backup/supabase_config.dart';
import 'package:libretapp/core/platform/release_features.dart';
import 'package:libretapp/core/security/ports/phone_auth_port.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'secure_session_storage.dart';
import 'supabase_session.dart';

class SupabasePhoneAuth implements PhoneAuthPort {
  SupabasePhoneAuth({
    Future<SupabaseClient> Function()? clientFactory,
    LocalStorage? sessionStorage,
    bool? enabled,
  }) : _clientFactory = clientFactory,
       _storage = sessionStorage,
       _enabled = enabled;
  final Future<SupabaseClient> Function()? _clientFactory;
  final bool? _enabled;
  Future<SupabaseClient>? _initializing;
  LocalStorage? _storage;
  LocalStorage get _sessionStorage => _storage ??= SecureSessionStorage(
    projectKey:
        Uri.tryParse(SupabaseConfig.url)?.host.split('.').first ??
        'unconfigured',
  );
  @override
  bool get available =>
      _enabled ??
      (!kIsWeb &&
          !ReleaseFeatures.demoMode &&
          defaultTargetPlatform == TargetPlatform.android &&
          ReleaseFeatures.phoneAuthEnabled &&
          SupabaseConfig.isConfigured);

  Future<SupabaseClient> _initialize() async {
    if (!available) {
      throw const PhoneAuthFailure(
        'El acceso por teléfono todavía no está disponible. Puedes entrar como invitado.',
      );
    }
    try {
      return await (_initializing ??=
              (_clientFactory?.call() ?? _createClient()))
          .timeout(const Duration(seconds: 25));
    } catch (_) {
      _initializing = null;
      throw const PhoneAuthFailure(
        'No se pudo conectar al servicio de acceso. Revisa tu conexión o entra como invitado.',
      );
    }
  }

  Future<SupabaseClient> _createClient() async {
    return SupabaseSession.client();
  }

  Future<T> _run<T>(Future<T> Function(SupabaseClient) action) async {
    final client = await _initialize();
    try {
      return await action(client).timeout(const Duration(seconds: 25));
    } on AuthException catch (error) {
      final rateLimited =
          error.statusCode == '429' || error.code == 'over_sms_send_rate_limit';
      if (rateLimited) {
        throw const PhoneAuthFailure(
          'Has solicitado varios códigos. Espera un momento antes de volver a intentarlo.',
        );
      }
      if (error.code == 'otp_expired' ||
          error.code == 'otp_disabled' ||
          error.statusCode == '403') {
        throw const PhoneAuthFailure(
          'El código es incorrecto o ya venció. Revísalo o solicita uno nuevo.',
        );
      }
      throw const PhoneAuthFailure(
        'No se pudo completar la verificación. Revisa el código o intenta más tarde.',
      );
    } on PhoneAuthFailure {
      rethrow;
    } catch (_) {
      throw const PhoneAuthFailure(
        'No se pudo contactar al servicio. Revisa tu conexión e intenta de nuevo.',
      );
    }
  }

  @override
  Future<void> requestCode(
    String phone, {
    PhoneAccessIntent intent = PhoneAccessIntent.createAccount,
  }) => _run(
    (client) => client.auth.signInWithOtp(
      phone: phone,
      channel: OtpChannel.sms,
      shouldCreateUser: intent == PhoneAccessIntent.createAccount,
    ),
  );

  Future<void> requestCodeWithCaptcha(
    String phone,
    String token, {
    PhoneAccessIntent intent = PhoneAccessIntent.createAccount,
  }) {
    if (!RegExp(r'^\+52\d{10}$').hasMatch(phone) || token.isEmpty) {
      throw const PhoneAuthFailure('Verifica el CAPTCHA y tu número mexicano.');
    }
    return _run(
      (client) => client.auth.signInWithOtp(
        phone: phone,
        captchaToken: token,
        channel: OtpChannel.sms,
        shouldCreateUser: intent == PhoneAccessIntent.createAccount,
      ),
    );
  }

  @override
  Future<VerifiedPhoneIdentity> verifyCode(String phone, String code) => _run((
    client,
  ) async {
    final result = await client.auth.verifyOTP(
      phone: phone,
      token: code,
      type: OtpType.sms,
    );
    final user = result.user;
    if (result.session == null ||
        user == null ||
        user.phoneConfirmedAt == null ||
        user.phone?.replaceAll('+', '') != phone.replaceAll('+', '')) {
      throw const PhoneAuthFailure(
        'No se pudo verificar la identidad del teléfono.',
      );
    }
    // Await secure persistence before allowing local ownership to change.
    await _sessionStorage.persistSession(jsonEncode(result.session!.toJson()));
    return VerifiedPhoneIdentity(userId: user.id, phone: phone);
  });

  @override
  Future<void> signOut() async {
    final initializing =
        _initializing ??
        (SupabaseSession.initializedClient == null
            ? null
            : Future.value(SupabaseSession.initializedClient!));
    if (initializing != null) {
      try {
        await (await initializing).auth
            .signOut(scope: SignOutScope.local)
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        /* SDK removes the local session before contacting the server. */
      }
    }
    await _sessionStorage.removePersistedSession();
  }
}
