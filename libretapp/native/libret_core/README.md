# libret_core

Cross-platform sensitive core for LibretApp.

## Design goals

- Keep sensitive logic in C++ and expose only a small C ABI (`extern "C"`).
- Minimize exported symbol surface for easier security auditing.
- Reuse one core across Android and iOS.

## Current API

- `libret_core_version()`
- `libret_encrypt_v1(...)`
- `libret_decrypt_v1(...)`
- `libret_kdf_v1(...)`
- `libret_free_buffer(uint8_t* buffer, intptr_t length)`

## Security note

`libret_encrypt_v1`/`libret_decrypt_v1` are currently a migration prototype to validate
FFI memory ownership and call contracts. They are **not production-grade cryptography**.
Replace with an audited AEAD implementation before release.

## Release policy integration

The Dart DI layer rejects insecure or unavailable native crypto in release mode by
default (fail-closed behavior). For controlled migration testing only, you can
override this with a compile-time define:

`--dart-define=LIBRET_ALLOW_INSECURE_CRYPTO_IN_RELEASE=true`

## Build usage

### Android

- Consumed through `android/app/src/main/cpp/CMakeLists.txt`.
- Shared object target name: `libret_core`.

### iOS

- Link compiled static library/XCFramework into Runner.
- Use `DynamicLibrary.process()` from Dart.

## Next implementation steps

1. Add authenticated encryption API (AEAD) with explicit nonce/tag contract.
2. Add token validation/signature verification API.
3. Add secure key derivation API with versioned key metadata.
