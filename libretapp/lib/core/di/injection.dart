/// Platform-selected dependency injection entry point.
library;

export 'injection_native.dart'
    if (dart.library.html) 'injection_web.dart';
