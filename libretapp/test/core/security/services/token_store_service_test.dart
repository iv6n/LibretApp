import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/security/models/models.dart';
import 'package:libretapp/core/security/ports/ports.dart';
import 'package:libretapp/core/security/services/token_store_service.dart';

class _InMemoryStore implements SecureStorePort {
  final Map<String, String> data = <String, String>{};

  @override
  Future<void> delete({required String key}) async {
    data.remove(key);
  }

  @override
  Future<String?> read({required String key}) async {
    return data[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    data[key] = value;
  }
}

class _TestKeyProvider implements KeyProviderPort {
  @override
  Future<Uint8List> getTokenMasterKey() async {
    return Uint8List.fromList(utf8.encode('unit-test-master-key'));
  }
}

class _ReversibleCrypto implements CryptoPort {
  @override
  bool constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) {
      return false;
    }
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  @override
  Future<Uint8List> decrypt(CipherText ciphertext, Uint8List key) async {
    final out = Uint8List(ciphertext.bytes.length);
    for (var i = 0; i < ciphertext.bytes.length; i++) {
      out[i] = ciphertext.bytes[i] ^ key[i % key.length];
    }
    return out;
  }

  @override
  Future<Uint8List> deriveKey({
    required String password,
    required Uint8List salt,
    required int iterations,
    required int keyLength,
  }) async {
    return Uint8List(keyLength);
  }

  @override
  Future<CipherText> encrypt(Uint8List plaintext, Uint8List key) async {
    final out = Uint8List(plaintext.length);
    for (var i = 0; i < plaintext.length; i++) {
      out[i] = plaintext[i] ^ key[i % key.length];
    }
    return CipherText(
      bytes: out,
      nonce: Uint8List(12),
      tag: Uint8List(16),
      keyVersion: 1,
    );
  }
}

void main() {
  group('TokenStoreService', () {
    test('stores encrypted envelope instead of plaintext fields', () async {
      final store = _InMemoryStore();
      final service = TokenStoreService(
        secureStore: store,
        cryptoPort: _ReversibleCrypto(),
        keyProvider: _TestKeyProvider(),
      );

      await service.storeTokenBundle(
        TokenBundle(
          accessToken: 'access-123',
          refreshToken: 'refresh-123',
          expiresAtUtc: DateTime.utc(2030, 1, 1),
        ),
      );

      expect(store.data.containsKey('secure.token_bundle.enc.v1'), isTrue);
      expect(store.data.containsKey('secure.access_token'), isFalse);
      expect(store.data.containsKey('secure.refresh_token'), isFalse);
      expect(store.data.containsKey('secure.access_token_expiry_utc'), isFalse);
    });

    test('loads and migrates legacy plaintext keys', () async {
      final store = _InMemoryStore()
        ..data['secure.access_token'] = 'legacy-a'
        ..data['secure.refresh_token'] = 'legacy-r'
        ..data['secure.access_token_expiry_utc'] = DateTime.utc(
          2031,
          1,
          1,
        ).toIso8601String();

      final service = TokenStoreService(
        secureStore: store,
        cryptoPort: _ReversibleCrypto(),
        keyProvider: _TestKeyProvider(),
      );

      final loaded = await service.loadTokenBundle();

      expect(loaded, isNotNull);
      expect(loaded!.accessToken, 'legacy-a');
      expect(store.data.containsKey('secure.token_bundle.enc.v1'), isTrue);
      expect(store.data.containsKey('secure.access_token'), isFalse);
      expect(store.data.containsKey('secure.refresh_token'), isFalse);
      expect(store.data.containsKey('secure.access_token_expiry_utc'), isFalse);
    });

    test('clearTokens removes encrypted and legacy keys', () async {
      final store = _InMemoryStore()
        ..data['secure.token_bundle.enc.v1'] = 'enc'
        ..data['secure.access_token'] = 'a'
        ..data['secure.refresh_token'] = 'r'
        ..data['secure.access_token_expiry_utc'] = 'e';

      final service = TokenStoreService(
        secureStore: store,
        cryptoPort: _ReversibleCrypto(),
        keyProvider: _TestKeyProvider(),
      );

      await service.clearTokens();

      expect(store.data.isEmpty, isTrue);
    });
  });
}
