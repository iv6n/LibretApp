/// core › security › ports › secure_store_port — abstract secure key-value store.
library;

/// Port (interface) for encrypted persistent storage of sensitive values.
abstract class SecureStorePort {
  Future<void> write({required String key, required String value});

  Future<String?> read({required String key});

  Future<void> delete({required String key});
}
