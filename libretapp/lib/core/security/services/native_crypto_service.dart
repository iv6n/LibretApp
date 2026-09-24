/// Platform-selected native crypto implementation.
library;

export 'native_crypto_service_native.dart'
    if (dart.library.html) 'native_crypto_service_web.dart';
