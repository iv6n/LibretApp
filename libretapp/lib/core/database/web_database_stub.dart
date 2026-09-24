/// Web placeholder for the mobile Isar database facade.
library;

class IsarDatabase {
  factory IsarDatabase() => _instance;

  IsarDatabase._();
  static final IsarDatabase _instance = IsarDatabase._();

  Future<Object?> initialize() async => null;

  Object get isar => throw UnsupportedError(
        'La base Isar solo está disponible en móvil; usa el repositorio web.',
      );

  Future<void> close() async {}

  Future<void> clearAllCollections() async {}
}
