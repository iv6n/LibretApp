import 'dart:typed_data';

import 'package:libretapp/core/security/models/security_types.dart';

abstract class CryptoPort {
  Future<CipherText> encrypt(Uint8List plaintext, Uint8List key);

  Future<Uint8List> decrypt(CipherText ciphertext, Uint8List key);

  Future<Uint8List> deriveKey({
    required String password,
    required Uint8List salt,
    required int iterations,
    required int keyLength,
  });

  bool constantTimeEquals(Uint8List a, Uint8List b);
}
