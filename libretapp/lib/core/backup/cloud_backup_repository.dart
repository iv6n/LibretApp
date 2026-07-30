/// Cloud persistence port for versioned backup archives.
library;

import 'dart:typed_data';

import 'package:libretapp/core/backup/backup_models.dart';

class CloudBackupUnavailable implements Exception {
  const CloudBackupUnavailable(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract interface class CloudBackupRepository {
  bool get isAvailable;

  Future<CloudBackupMetadata> uploadSnapshot({
    required Uint8List bytes,
    required String sha256,
    required int schemaVersion,
    required String appVersion,
  });

  Future<List<CloudBackupMetadata>> listSnapshots();

  Future<Uint8List> downloadSnapshot(CloudBackupMetadata metadata);
}
