/// Orchestrates local archive creation and versioned cloud storage.
library;

import 'package:crypto/crypto.dart';
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/cloud_backup_repository.dart';
import 'package:libretapp/core/services/backup_service.dart';
import 'backup_operation_lock.dart';

class CloudBackupService {
  CloudBackupService({
    required BackupService backupService,
    required CloudBackupRepository repository,
  }) : _backupService = backupService,
       _repository = repository;

  final BackupService _backupService;
  final CloudBackupRepository _repository;

  bool get isAvailable => _repository.isAvailable;

  Future<CloudBackupMetadata> backupNow({
    Future<void> Function()? beforeUpload,
  }) => BackupOperationLock().run(() async {
    if (!isAvailable) {
      throw const CloudBackupUnavailable(
        'Esta compilación no tiene respaldo en la nube configurado.',
      );
    }
    final bytes = await _backupService.createArchiveBytes();
    await beforeUpload?.call();
    final metadata = await _repository.uploadSnapshot(
      bytes: bytes,
      sha256: _backupService.digestArchive(bytes),
      schemaVersion: BackupEnvelope.currentSchemaVersion,
      appVersion: BackupEnvelope.currentAppVersion,
    );
    await _backupService.markCloudBackup();
    try {
      final downloaded = await _repository.downloadSnapshot(metadata);
      if (sha256.convert(downloaded).toString() == metadata.sha256) {
        await _backupService.markVerifiedCloudBackup();
      }
    } catch (_) {
      // Upload succeeded, but an unverified copy must remain labelled as such.
    }
    return metadata;
  });

  Future<List<CloudBackupMetadata>> listSnapshots() =>
      _repository.listSnapshots();

  /// Restores [metadata] into local storage.
  ///
  /// [mode] is required rather than defaulted so no caller can reach the
  /// destructive [BackupImportMode.replaceAll] path by omission.
  Future<BackupImportSummary> restore(
    CloudBackupMetadata metadata, {
    required BackupImportMode mode,
  }) => BackupOperationLock().run(() async {
    final bytes = await _repository.downloadSnapshot(metadata);
    final actualDigest = sha256.convert(bytes).toString();
    if (actualDigest != metadata.sha256) {
      throw const FormatException(
        'La copia descargada no coincide con su huella de integridad.',
      );
    }
    return _backupService.importArchiveBytes(bytes, mode: mode);
  });
}
