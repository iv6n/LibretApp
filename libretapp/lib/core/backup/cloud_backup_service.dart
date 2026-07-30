/// Orchestrates local archive creation and versioned cloud storage.
library;

import 'package:crypto/crypto.dart';
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/cloud_backup_repository.dart';
import 'package:libretapp/core/services/backup_service.dart';

class CloudBackupService {
  CloudBackupService({
    required BackupService backupService,
    required CloudBackupRepository repository,
  }) : _backupService = backupService,
       _repository = repository;

  final BackupService _backupService;
  final CloudBackupRepository _repository;

  bool get isAvailable => _repository.isAvailable;

  Future<CloudBackupMetadata> backupNow() async {
    if (!isAvailable) {
      throw const CloudBackupUnavailable(
        'Esta compilación no tiene respaldo en la nube configurado.',
      );
    }
    final bytes = await _backupService.createArchiveBytes();
    return _repository.uploadSnapshot(
      bytes: bytes,
      sha256: _backupService.digestArchive(bytes),
      schemaVersion: BackupEnvelope.currentSchemaVersion,
      appVersion: '0.1.0+2',
    );
  }

  Future<List<CloudBackupMetadata>> listSnapshots() =>
      _repository.listSnapshots();

  Future<BackupImportSummary> restore(CloudBackupMetadata metadata) async {
    final bytes = await _repository.downloadSnapshot(metadata);
    final actualDigest = sha256.convert(bytes).toString();
    if (actualDigest != metadata.sha256) {
      throw const FormatException(
        'La copia descargada no coincide con su huella de integridad.',
      );
    }
    return _backupService.importArchiveBytes(
      bytes,
      mode: BackupImportMode.replaceAll,
    );
  }
}
