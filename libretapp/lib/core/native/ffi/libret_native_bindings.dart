import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

typedef NativeVersionFn = ffi.Pointer<ffi.Char> Function();
typedef DartVersionFn = ffi.Pointer<ffi.Char> Function();

typedef NativeEncryptV1Fn =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.IntPtr,
      ffi.Pointer<ffi.Uint8>,
      ffi.IntPtr,
      ffi.Pointer<ffi.Pointer<ffi.Uint8>>,
      ffi.Pointer<ffi.IntPtr>,
      ffi.Pointer<ffi.Pointer<ffi.Uint8>>,
      ffi.Pointer<ffi.IntPtr>,
      ffi.Pointer<ffi.Pointer<ffi.Uint8>>,
      ffi.Pointer<ffi.IntPtr>,
    );

typedef DartEncryptV1Fn =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Pointer<ffi.Uint8>>,
      ffi.Pointer<ffi.IntPtr>,
      ffi.Pointer<ffi.Pointer<ffi.Uint8>>,
      ffi.Pointer<ffi.IntPtr>,
      ffi.Pointer<ffi.Pointer<ffi.Uint8>>,
      ffi.Pointer<ffi.IntPtr>,
    );

typedef NativeDecryptV1Fn =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.IntPtr,
      ffi.Pointer<ffi.Uint8>,
      ffi.IntPtr,
      ffi.Pointer<ffi.Uint8>,
      ffi.IntPtr,
      ffi.Pointer<ffi.Uint8>,
      ffi.IntPtr,
      ffi.Pointer<ffi.Pointer<ffi.Uint8>>,
      ffi.Pointer<ffi.IntPtr>,
    );

typedef DartDecryptV1Fn =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Pointer<ffi.Uint8>>,
      ffi.Pointer<ffi.IntPtr>,
    );

typedef NativeKdfV1Fn =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.IntPtr,
      ffi.Pointer<ffi.Uint8>,
      ffi.IntPtr,
      ffi.Int32,
      ffi.IntPtr,
      ffi.Pointer<ffi.Pointer<ffi.Uint8>>,
      ffi.Pointer<ffi.IntPtr>,
    );

typedef DartKdfV1Fn =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      ffi.Pointer<ffi.Pointer<ffi.Uint8>>,
      ffi.Pointer<ffi.IntPtr>,
    );

typedef NativeFreeBufferFn =
    ffi.Void Function(ffi.Pointer<ffi.Uint8>, ffi.IntPtr);
typedef DartFreeBufferFn = void Function(ffi.Pointer<ffi.Uint8>, int);

final class NativeStatusCode {
  static const int ok = 0;
  static const int invalidInput = 1;
  static const int allocationFailed = 2;
  static const int authFailed = 3;

  static String toMessage(int status) {
    return switch (status) {
      ok => 'ok',
      invalidInput => 'invalid input',
      allocationFailed => 'allocation failed',
      authFailed => 'authentication failed',
      _ => 'unknown native status: $status',
    };
  }
}

class LibretNativeBindings {
  LibretNativeBindings(ffi.DynamicLibrary dylib)
    : coreVersion = dylib
          .lookup<ffi.NativeFunction<NativeVersionFn>>('libret_core_version')
          .asFunction<DartVersionFn>(),
      freeBuffer = dylib
          .lookup<ffi.NativeFunction<NativeFreeBufferFn>>('libret_free_buffer')
          .asFunction<DartFreeBufferFn>(),
      encryptV1 = dylib
          .lookup<ffi.NativeFunction<NativeEncryptV1Fn>>('libret_encrypt_v1')
          .asFunction<DartEncryptV1Fn>(),
      decryptV1 = dylib
          .lookup<ffi.NativeFunction<NativeDecryptV1Fn>>('libret_decrypt_v1')
          .asFunction<DartDecryptV1Fn>(),
      kdfV1 = dylib
          .lookup<ffi.NativeFunction<NativeKdfV1Fn>>('libret_kdf_v1')
          .asFunction<DartKdfV1Fn>();

  final DartVersionFn coreVersion;
  final DartFreeBufferFn freeBuffer;
  final DartEncryptV1Fn encryptV1;
  final DartDecryptV1Fn decryptV1;
  final DartKdfV1Fn kdfV1;

  static ffi.DynamicLibrary loadLibrary() {
    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('liblibret_core.so');
    }
    if (Platform.isIOS) {
      return ffi.DynamicLibrary.process();
    }
    throw UnsupportedError('Unsupported platform for Libret native core.');
  }
}
