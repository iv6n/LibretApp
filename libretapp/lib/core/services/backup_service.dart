/// Platform-selected backup service.
library;

export 'backup_service_native.dart'
    if (dart.library.html) 'backup_service_web.dart';
