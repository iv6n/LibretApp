/// core › security › services › native_crypto_service — crypto service backed by native FFI.
library;

import 'dart:typed_data';
import 'dart:convert';

import 'package:libretapp/core/native/ffi/libret_native_bridge.dart';
import 'package:libretapp/core/security/models/models.dart';
import 'package:libretapp/core/security/ports/ports.dart';

class NativeCryptoService implements CryptoPort {
  NativeCryptoService(this._bridge);

  final LibretNativeBridge _bridge;

  @override
  Future<CipherText> encrypt(Uint8List plaintext, Uint8List key) async {
    return _bridge.encrypt(plaintext, key);
  }

  @override
  Future<Uint8List> decrypt(CipherText ciphertext, Uint8List key) async {
    return _bridge.decrypt(ciphertext, key);
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

    if (salt.isEmpty || iterations <= 0) {
      throw SecurityException(
        'Invalid salt or iteration count.',
        code: 'INVALID_KDF_PARAMS',
      );
    }

    return _bridge.deriveKey(
      password: Uint8List.fromList(utf8.encode(password)),
      salt: salt,
      iterations: iterations,
      keyLength: keyLength,
    );
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
