/// Resolves the cloud repository on first use after the UI is available.
library;

import 'dart:typed_data';

import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/cloud_backup_repository.dart';

class DeferredCloudBackupRepository implements CloudBackupRepository {
  DeferredCloudBackupRepository(this._createRepository);

  final Future<CloudBackupRepository> Function() _createRepository;
  Future<CloudBackupRepository>? _pendingRepository;

  Future<CloudBackupRepository> get _repository {
    final pending = _pendingRepository;
    if (pending != null) return pending;
    final future = _createRepository();
    _pendingRepository = future;
    return future.catchError((Object error, StackTrace stack) {
      if (identical(_pendingRepository, future)) _pendingRepository = null;
      Error.throwWithStackTrace(error, stack);
    });
  }

  @override
  bool get isAvailable => true;

  @override
  Future<CloudBackupMetadata> uploadSnapshot({
    required Uint8List bytes,
    required String sha256,
    required int schemaVersion,
    required String appVersion,
  }) async => (await _repository).uploadSnapshot(
    bytes: bytes,
    sha256: sha256,
    schemaVersion: schemaVersion,
    appVersion: appVersion,
  );

  @override
  Future<List<CloudBackupMetadata>> listSnapshots() async =>
      (await _repository).listSnapshots();

  @override
  Future<Uint8List> downloadSnapshot(CloudBackupMetadata metadata) async =>
      (await _repository).downloadSnapshot(metadata);
}
