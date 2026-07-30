library;

import 'dart:typed_data';

import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/cloud_backup_repository.dart';

class UnavailableCloudBackupRepository implements CloudBackupRepository {
  const UnavailableCloudBackupRepository();

  @override
  bool get isAvailable => false;

  Never _unavailable() => throw const CloudBackupUnavailable(
    'Esta compilación no tiene respaldo en la nube configurado.',
  );

  @override
  Future<Uint8List> downloadSnapshot(CloudBackupMetadata metadata) async =>
      _unavailable();

  @override
  Future<List<CloudBackupMetadata>> listSnapshots() async => _unavailable();

  @override
  Future<CloudBackupMetadata> uploadSnapshot({
    required Uint8List bytes,
    required String sha256,
    required int schemaVersion,
    required String appVersion,
  }) async => _unavailable();
}
