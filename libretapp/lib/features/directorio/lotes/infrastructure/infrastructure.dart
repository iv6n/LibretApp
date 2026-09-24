/// features > directorio > lotes > infrastructure > infrastructure — barrel for lotes infrastructure layer.
library;

export 'lotes_repository.dart';
export 'lotes_repository_isar.dart'
    if (dart.library.html) 'web_lotes_repository_stub.dart';
