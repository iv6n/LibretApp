/// features > directorio > animales > infrastructure > infrastructure — barrel for animal infrastructure layer.
library;

export 'animal_dto.dart';
export 'animal_repository.dart';
export 'isar/index.dart'
    if (dart.library.html) 'web_isar_stub.dart';
