/// Platform-selected startup migrations.
library;

export 'app_migrations_native.dart'
    if (dart.library.html) 'app_migrations_web.dart';
