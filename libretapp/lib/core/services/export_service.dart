/// Platform-selected Excel export service.
library;

export 'export_service_native.dart'
    if (dart.library.html) 'export_service_web.dart';
