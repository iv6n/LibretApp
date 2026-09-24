/// Platform ports keep native-only dependencies out of domain code.
library;

import 'dart:typed_data';

abstract interface class FileAccessPort {
  Future<String?> pickFile({List<String>? extensions});
  Future<void> writeBytes(String path, Uint8List bytes);
  Future<Uint8List> readBytes(String path);
}

abstract interface class ImageAccessPort {
  Future<String?> capture({bool fromCamera = false});
}

abstract interface class ExportPort {
  Future<void> share(Uint8List bytes, {required String fileName, String? mimeType});
}

abstract interface class SecretPort {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}
