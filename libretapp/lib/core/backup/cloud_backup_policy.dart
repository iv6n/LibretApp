/// Retry and retention policies shared by cloud backup implementations.
library;

import 'package:libretapp/core/backup/backup_models.dart';

Future<T> retryCloudUpload<T>(
  Future<T> Function() upload, {
  int maxAttempts = 3,
  Duration retryDelay = const Duration(milliseconds: 250),
  Future<void> Function(Duration) wait = Future<void>.delayed,
}) async {
  if (maxAttempts < 1) {
    throw ArgumentError.value(maxAttempts, 'maxAttempts', 'must be positive');
  }
  for (var attempt = 1; ; attempt++) {
    try {
      return await upload();
    } catch (_) {
      if (attempt >= maxAttempts) rethrow;
      await wait(retryDelay * attempt);
    }
  }
}

class CloudBackupRetentionPolicy {
  const CloudBackupRetentionPolicy({this.retain = 5});

  final int retain;

  List<CloudBackupMetadata> expired(List<CloudBackupMetadata> newestFirst) {
    if (newestFirst.length <= retain) return const [];
    return newestFirst.skip(retain).toList(growable: false);
  }

  Future<void> cleanBestEffort(
    List<CloudBackupMetadata> newestFirst,
    Future<void> Function(CloudBackupMetadata snapshot) delete,
  ) async {
    for (final snapshot in expired(newestFirst)) {
      try {
        await delete(snapshot);
      } catch (_) {
        // A cleanup outage must not invalidate a newly verified snapshot.
      }
    }
  }
}
