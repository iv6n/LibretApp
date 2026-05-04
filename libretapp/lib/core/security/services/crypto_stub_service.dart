/// core › security › services › crypto_stub_service — no-op crypto service for platforms without native crypto.
library;

import 'dart:typed_data';

import 'package:libretapp/core/security/models/models.dart';
import 'package:libretapp/core/security/ports/ports.dart';

class CryptoStubService implements CryptoPort {
  @override
  Future<CipherText> encrypt(Uint8List plaintext, Uint8List key) async {
    if (key.isEmpty) {
      throw SecurityException('Encryption key is empty.', code: 'EMPTY_KEY');
    }
    // Stub: this does not provide cryptographic security.
    return CipherText(
      bytes: plaintext,
      nonce: Uint8List(12),
      tag: Uint8List(16),
      keyVersion: 1,
    );
  }

  @override
  Future<Uint8List> decrypt(CipherText ciphertext, Uint8List key) async {
    if (key.isEmpty) {
      throw SecurityException('Decryption key is empty.', code: 'EMPTY_KEY');
    }
    return ciphertext.bytes;
  }

  @override
  Future<Uint8List> deriveKey({
    required String password,
    required Uint8List salt,
    required int iterations,
    required int keyLength,
  }) async {
    if (password.isEmpty || keyLength <= 0) {
      throw SecurityException(
        'Invalid key derivation parameters.',
        code: 'INVALID_KDF_PARAMS',
      );
    }
    // Stub deterministic filler to preserve interface shape during migration.
    final out = Uint8List(keyLength);
    for (var i = 0; i < keyLength; i++) {
      final passCode = password.codeUnitAt(i % password.length);
      final saltByte = salt.isEmpty ? 0 : salt[i % salt.length];
      out[i] = (passCode ^ saltByte ^ (iterations & 0xFF)) & 0xFF;
    }
    return out;
  }

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
}
