/// core › security › models › security_types — value objects for security domain.
library;

import 'dart:typed_data';

class CipherText {
  const CipherText({
    required this.bytes,
    required this.nonce,
    required this.tag,
    required this.keyVersion,
  });

  final Uint8List bytes;
  final Uint8List nonce;
  final Uint8List tag;
  final int keyVersion;
}

class TokenBundle {
  const TokenBundle({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAtUtc,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAtUtc;
}

enum PiiKind { email, phone, uuid, generic }

class AuthCredentials {
  const AuthCredentials({required this.username, required this.secret});

  final String username;
  final String secret;
}

class AuthResult {
  const AuthResult({
    required this.isSuccess,
    this.userId,
    this.tokenBundle,
    this.errorMessage,
  });

  final bool isSuccess;
  final String? userId;
  final TokenBundle? tokenBundle;
  final String? errorMessage;
}

class SecurityException implements Exception {
  SecurityException(this.message, {this.code = 'SECURITY_ERROR'});

  final String message;
  final String code;

  @override
  String toString() => 'SecurityException($code): $message';
}
