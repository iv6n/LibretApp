import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:libretapp/core/native/ffi/libret_native_bindings.dart';
import 'package:libretapp/core/security/models/models.dart';

class LibretNativeBridge {
  LibretNativeBridge._(this._bindings);

  final LibretNativeBindings _bindings;

  static LibretNativeBridge create() {
    final dylib = LibretNativeBindings.loadLibrary();
    return LibretNativeBridge._(LibretNativeBindings(dylib));
  }

  String getCoreVersion() {
    final ptr = _bindings.coreVersion();
    if (ptr == ffi.nullptr) {
      throw SecurityException(
        'Native core returned null version pointer.',
        code: 'NATIVE_NULL_VERSION',
      );
    }
    return ptr.cast<Utf8>().toDartString();
  }

  CipherText encrypt(Uint8List plaintext, Uint8List key) {
    final inPlain = calloc<ffi.Uint8>(plaintext.length);
    final inKey = calloc<ffi.Uint8>(key.length);
    final outCipherPtr = calloc<ffi.Pointer<ffi.Uint8>>();
    final outCipherLen = calloc<ffi.IntPtr>();
    final outNoncePtr = calloc<ffi.Pointer<ffi.Uint8>>();
    final outNonceLen = calloc<ffi.IntPtr>();
    final outTagPtr = calloc<ffi.Pointer<ffi.Uint8>>();
    final outTagLen = calloc<ffi.IntPtr>();

    try {
      inPlain.asTypedList(plaintext.length).setAll(0, plaintext);
      inKey.asTypedList(key.length).setAll(0, key);

      final status = _bindings.encryptV1(
        inPlain,
        plaintext.length,
        inKey,
        key.length,
        outCipherPtr,
        outCipherLen,
        outNoncePtr,
        outNonceLen,
        outTagPtr,
        outTagLen,
      );

      if (status != NativeStatusCode.ok) {
        throw SecurityException(
          'Native encrypt failed: ${NativeStatusCode.toMessage(status)}',
          code: 'NATIVE_ENCRYPT_FAIL',
        );
      }

      final cipher = Uint8List.fromList(
        outCipherPtr.value.asTypedList(outCipherLen.value),
      );
      final nonce = Uint8List.fromList(
        outNoncePtr.value.asTypedList(outNonceLen.value),
      );
      final tag = Uint8List.fromList(
        outTagPtr.value.asTypedList(outTagLen.value),
      );

      return CipherText(bytes: cipher, nonce: nonce, tag: tag, keyVersion: 1);
    } finally {
      if (outCipherPtr.value != ffi.nullptr && outCipherLen.value > 0) {
        _bindings.freeBuffer(outCipherPtr.value, outCipherLen.value);
      }
      if (outNoncePtr.value != ffi.nullptr && outNonceLen.value > 0) {
        _bindings.freeBuffer(outNoncePtr.value, outNonceLen.value);
      }
      if (outTagPtr.value != ffi.nullptr && outTagLen.value > 0) {
        _bindings.freeBuffer(outTagPtr.value, outTagLen.value);
      }
      calloc.free(inPlain);
      calloc.free(inKey);
      calloc.free(outCipherPtr);
      calloc.free(outCipherLen);
      calloc.free(outNoncePtr);
      calloc.free(outNonceLen);
      calloc.free(outTagPtr);
      calloc.free(outTagLen);
    }
  }

  Uint8List decrypt(CipherText cipherText, Uint8List key) {
    final inCipher = calloc<ffi.Uint8>(cipherText.bytes.length);
    final inKey = calloc<ffi.Uint8>(key.length);
    final inNonce = calloc<ffi.Uint8>(cipherText.nonce.length);
    final inTag = calloc<ffi.Uint8>(cipherText.tag.length);
    final outPlainPtr = calloc<ffi.Pointer<ffi.Uint8>>();
    final outPlainLen = calloc<ffi.IntPtr>();

    try {
      inCipher.asTypedList(cipherText.bytes.length).setAll(0, cipherText.bytes);
      inKey.asTypedList(key.length).setAll(0, key);
      inNonce.asTypedList(cipherText.nonce.length).setAll(0, cipherText.nonce);
      inTag.asTypedList(cipherText.tag.length).setAll(0, cipherText.tag);

      final status = _bindings.decryptV1(
        inCipher,
        cipherText.bytes.length,
        inKey,
        key.length,
        inNonce,
        cipherText.nonce.length,
        inTag,
        cipherText.tag.length,
        outPlainPtr,
        outPlainLen,
      );

      if (status != NativeStatusCode.ok) {
        throw SecurityException(
          'Native decrypt failed: ${NativeStatusCode.toMessage(status)}',
          code: status == NativeStatusCode.authFailed
              ? 'NATIVE_AUTH_FAIL'
              : 'NATIVE_DECRYPT_FAIL',
        );
      }

      return Uint8List.fromList(
        outPlainPtr.value.asTypedList(outPlainLen.value),
      );
    } finally {
      if (outPlainPtr.value != ffi.nullptr && outPlainLen.value > 0) {
        _bindings.freeBuffer(outPlainPtr.value, outPlainLen.value);
      }
      calloc.free(inCipher);
      calloc.free(inKey);
      calloc.free(inNonce);
      calloc.free(inTag);
      calloc.free(outPlainPtr);
      calloc.free(outPlainLen);
    }
  }

  Uint8List deriveKey({
    required Uint8List password,
    required Uint8List salt,
    required int iterations,
    required int keyLength,
  }) {
    final inPassword = calloc<ffi.Uint8>(password.length);
    final inSalt = calloc<ffi.Uint8>(salt.length);
    final outKeyPtr = calloc<ffi.Pointer<ffi.Uint8>>();
    final outKeyLen = calloc<ffi.IntPtr>();

    try {
      inPassword.asTypedList(password.length).setAll(0, password);
      inSalt.asTypedList(salt.length).setAll(0, salt);

      final status = _bindings.kdfV1(
        inPassword,
        password.length,
        inSalt,
        salt.length,
        iterations,
        keyLength,
        outKeyPtr,
        outKeyLen,
      );

      if (status != NativeStatusCode.ok) {
        throw SecurityException(
          'Native kdf failed: ${NativeStatusCode.toMessage(status)}',
          code: 'NATIVE_KDF_FAIL',
        );
      }

      return Uint8List.fromList(outKeyPtr.value.asTypedList(outKeyLen.value));
    } finally {
      if (outKeyPtr.value != ffi.nullptr && outKeyLen.value > 0) {
        _bindings.freeBuffer(outKeyPtr.value, outKeyLen.value);
      }
      calloc.free(inPassword);
      calloc.free(inSalt);
      calloc.free(outKeyPtr);
      calloc.free(outKeyLen);
    }
  }
}
