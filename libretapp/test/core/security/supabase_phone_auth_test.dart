import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:libretapp/core/security/ports/phone_auth_port.dart';
import 'package:libretapp/core/security/services/supabase_phone_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _Storage extends LocalStorage {
  String? value;
  bool failWrite = false;
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> hasAccessToken() async => value != null;
  @override
  Future<String?> accessToken() async => value;
  @override
  Future<void> persistSession(String persistSessionString) async {
    if (failWrite) throw StateError('secure storage unavailable');
    value = persistSessionString;
  }

  @override
  Future<void> removePersistedSession() async {
    value = null;
  }
}

void main() {
  const phone = '+525555123456';
  late _Storage storage;
  late SupabaseClient client;
  late SupabasePhoneAuth auth;
  late List<http.Request> requests;
  var failure = false;
  setUp(() {
    requests = [];
    failure = false;
    storage = _Storage();
    client = SupabaseClient(
      'https://example.test',
      'public-test-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        requests.add(request);
        if (failure)
          return http.Response(
            jsonEncode({'code': 'otp_expired', 'msg': 'Token expired'}),
            403,
          );
        if (request.url.path.endsWith('/verify'))
          return http.Response(
            jsonEncode({
              'access_token': 'test-token',
              'refresh_token': 'test-refresh',
              'token_type': 'bearer',
              'expires_in': 3600,
              'user': {
                'id': 'verified-user',
                'aud': 'authenticated',
                'phone': phone.substring(1),
                'phone_confirmed_at': '2026-10-18T12:00:00Z',
                'created_at': '2026-10-18T12:00:00Z',
                'app_metadata': {},
                'user_metadata': {},
              },
            }),
            200,
          );
        return http.Response('{}', 200);
      }),
    );
    auth = SupabasePhoneAuth(
      clientFactory: () async => client,
      sessionStorage: storage,
      enabled: true,
    );
  });
  tearDown(() async {
    await client.dispose();
  });
  test(
    'requests SMS and creates identity only after verifying a real provider response',
    () async {
      await auth.requestCode(phone);
      final body = jsonDecode(requests.single.body) as Map;
      expect(body['phone'], phone);
      expect(body['channel'], 'sms');
      expect(body['create_user'], isTrue);
      expect(storage.value, isNull);
      final identity = await auth.verifyCode(phone, '123456');
      expect(identity.userId, 'verified-user');
      expect(identity.phone, phone);
      expect(storage.value, contains('test-refresh'));
    },
  );
  test('sign in requests an SMS without creating an unknown user', () async {
    await auth.requestCode(phone, intent: PhoneAccessIntent.signIn);
    final body = jsonDecode(requests.single.body) as Map;
    expect(body['phone'], phone);
    expect(body['channel'], 'sms');
    expect(body['create_user'], isFalse);
  });
  test('invalid or expired code never returns a verified identity', () async {
    failure = true;
    await expectLater(
      auth.verifyCode(phone, '000000'),
      throwsA(isA<PhoneAuthFailure>()),
    );
    expect(storage.value, isNull);
  });
  test('secure persistence failure prevents successful verification', () async {
    storage.failWrite = true;
    await expectLater(
      auth.verifyCode(phone, '123456'),
      throwsA(isA<PhoneAuthFailure>()),
    );
    expect(storage.value, isNull);
  });
  test(
    'sign out clears cold persisted sessions without initializing network services',
    () async {
      storage.value = 'previous-session';
      await auth.signOut();
      expect(storage.value, isNull);
      expect(requests, isEmpty);
    },
  );
  test('unconfigured auth cannot report successful verification', () async {
    final disabled = SupabasePhoneAuth(enabled: false, sessionStorage: storage);
    expect(disabled.available, isFalse);
    await expectLater(
      disabled.verifyCode(phone, '123456'),
      throwsA(isA<PhoneAuthFailure>()),
    );
    expect(storage.value, isNull);
  });
}
