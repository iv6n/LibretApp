# Native Core Setup (iOS)

This project uses `dart:ffi` and expects the native core symbols to be linked into the Runner binary.

## Current expectation in Dart

`lib/core/native/ffi/libret_native_bindings.dart` uses `DynamicLibrary.process()` on iOS, so exported C symbols must be present in the app process.

## Required steps in Xcode

1. Open `ios/Runner.xcworkspace`.
2. Add `native/libret_core/include` to Header Search Paths for Runner.
3. Add a native source target (or static lib target) that compiles:
   - `native/libret_core/src/libret_secure_api.cc`
4. Ensure C++ language standard is at least C++20 for that target.
5. Link the produced static library into Runner (`Link Binary With Libraries`).
6. Confirm symbols are exported and not stripped unexpectedly in debug.

## Optional (recommended)

- Build `native/libret_core` as an XCFramework for reuse across apps.
- Add release symbol management policy:
  - Keep only required C ABI exports.
  - Strip internal symbols.

## Validation

From Dart, call `LibretNativeBridge.create().getCoreVersion()` and verify it returns `libret-core/0.1.0`.
