/// Platform-selected media persistence.
library;

export 'media_store_native.dart'
    if (dart.library.html) 'media_store_web.dart';
