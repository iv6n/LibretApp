import 'dart:convert';
import 'dart:typed_data';

import 'package:libretapp/core/security/models/models.dart';
import 'package:libretapp/core/security/ports/ports.dart';

class TokenStoreService implements TokenPort {
  TokenStoreService({
    required SecureStorePort secureStore,
    required CryptoPort cryptoPort,
    required KeyProviderPort keyProvider,
  }) : _secureStore = secureStore,
       _cryptoPort = cryptoPort,
       _keyProvider = keyProvider;

  final SecureStorePort _secureStore;
  final CryptoPort _cryptoPort;
  final KeyProviderPort _keyProvider;

  static const _keyEncryptedBundle = 'secure.token_bundle.enc.v1';

  // Legacy keys kept for one-way migration.
  static const _legacyKeyAccessToken = 'secure.access_token';
  static const _legacyKeyRefreshToken = 'secure.refresh_token';
  static const _legacyKeyExpiry = 'secure.access_token_expiry_utc';

  @override
  Future<void> storeTokenBundle(TokenBundle bundle) async {
    final masterKey = await _keyProvider.getTokenMasterKey();
    final plaintext = Uint8List.fromList(
      utf8.encode(
        jsonEncode(<String, dynamic>{
          'accessToken': bundle.accessToken,
          'refreshToken': bundle.refreshToken,
          'expiresAtUtc': bundle.expiresAtUtc.toUtc().toIso8601String(),
        }),
      ),
    );

    final cipherText = await _cryptoPort.encrypt(plaintext, masterKey);
    final envelope = jsonEncode(<String, dynamic>{
      'v': 1,
      'k': cipherText.keyVersion,
      'c': base64Encode(cipherText.bytes),
      'n': base64Encode(cipherText.nonce),
      't': base64Encode(cipherText.tag),
    });

    await _secureStore.write(key: _keyEncryptedBundle, value: envelope);

    // Wipe legacy keys after successful encrypted write.
    await _clearLegacyKeys();
  }

  @override
  Future<TokenBundle?> loadTokenBundle() async {
    final encryptedRaw = await _secureStore.read(key: _keyEncryptedBundle);
    if (encryptedRaw == null || encryptedRaw.isEmpty) {
      return _loadLegacyAndMigrate();
    }

    try {
      final envelope = jsonDecode(encryptedRaw) as Map<String, dynamic>;
      final bytes = base64Decode(envelope['c'] as String);
      final nonce = base64Decode(envelope['n'] as String);
      final tag = base64Decode(envelope['t'] as String);
      final keyVersion = (envelope['k'] as num?)?.toInt() ?? 1;

      final masterKey = await _keyProvider.getTokenMasterKey();
      final plainBytes = await _cryptoPort.decrypt(
        CipherText(
          bytes: bytes,
          nonce: nonce,
          tag: tag,
          keyVersion: keyVersion,
        ),
        masterKey,
      );

      final decoded =
          jsonDecode(utf8.decode(plainBytes)) as Map<String, dynamic>;
      final accessToken = decoded['accessToken'] as String?;
      final refreshToken = decoded['refreshToken'] as String?;
      final expiryRaw = decoded['expiresAtUtc'] as String?;

      if (accessToken == null || refreshToken == null || expiryRaw == null) {
        throw SecurityException(
          'Encrypted token payload is missing required fields.',
          code: 'TOKEN_PAYLOAD_INVALID',
        );
      }

      final parsedExpiry = DateTime.tryParse(expiryRaw)?.toUtc();
      if (parsedExpiry == null) {
        throw SecurityException(
          'Stored token bundle contains invalid expiry payload.',
          code: 'TOKEN_PARSE_ERROR',
        );
      }

      return TokenBundle(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAtUtc: parsedExpiry,
      );
    } on SecurityException {
      rethrow;
    } catch (_) {
      throw SecurityException(
        'Unable to decode encrypted token bundle.',
        code: 'TOKEN_DECRYPT_ERROR',
      );
    }
  }

  Future<TokenBundle?> _loadLegacyAndMigrate() async {
    final accessToken = await _secureStore.read(key: _legacyKeyAccessToken);
    final refreshToken = await _secureStore.read(key: _legacyKeyRefreshToken);
    final expiryRaw = await _secureStore.read(key: _legacyKeyExpiry);

    if (accessToken == null || refreshToken == null || expiryRaw == null) {
      return null;
    }

    final parsedExpiry = DateTime.tryParse(expiryRaw)?.toUtc();
    if (parsedExpiry == null) {
      throw SecurityException(
        'Stored token bundle contains invalid expiry payload.',
        code: 'TOKEN_PARSE_ERROR',
      );
    }

    final bundle = TokenBundle(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAtUtc: parsedExpiry,
    );

    await storeTokenBundle(bundle);
    return bundle;
  }

  @override
  Future<void> clearTokens() async {
    await _secureStore.delete(key: _keyEncryptedBundle);
    await _clearLegacyKeys();
  }

  Future<void> _clearLegacyKeys() async {
    await _secureStore.delete(key: _legacyKeyAccessToken);
    await _secureStore.delete(key: _legacyKeyRefreshToken);
    await _secureStore.delete(key: _legacyKeyExpiry);
  }

  @override
  Future<bool> isAccessTokenExpired() async {
    final bundle = await loadTokenBundle();
    if (bundle == null) {
      return true;
    }
    return DateTime.now().toUtc().isAfter(bundle.expiresAtUtc);
  }

  Map<String, dynamic> exportDebugSafeState(TokenBundle bundle) {
    return <String, dynamic>{
      'hasAccessToken': bundle.accessToken.isNotEmpty,
      'hasRefreshToken': bundle.refreshToken.isNotEmpty,
      'expiresAtUtc': bundle.expiresAtUtc.toIso8601String(),
      'accessTokenLength': bundle.accessToken.length,
      'refreshTokenLength': bundle.refreshToken.length,
    };
  }

  String exportDebugSafeJson(TokenBundle bundle) {
    return jsonEncode(exportDebugSafeState(bundle));
  }
}
