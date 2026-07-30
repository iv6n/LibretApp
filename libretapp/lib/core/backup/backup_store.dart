/// Persistence port used to capture and atomically restore backup snapshots.
library;

import 'package:libretapp/core/backup/backup_models.dart';

abstract interface class BackupStore {
  Future<BackupEnvelope> capture();

  Future<BackupRestoreResult> restore(
    BackupEnvelope envelope, {
    required BackupImportMode mode,
  });
}
