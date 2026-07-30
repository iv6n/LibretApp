/// Supabase Storage implementation for private, versioned backup snapshots.
library;

import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/cloud_backup_policy.dart';
import 'package:libretapp/core/backup/cloud_backup_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SupabaseCloudBackupRepository implements CloudBackupRepository {
  SupabaseCloudBackupRepository(this._client);

  static const _bucket = 'libret-backups';
  static const _retention = 5;

  final SupabaseClient _client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw const CloudBackupUnavailable(
        'Inicia sesión para usar el respaldo en la nube.',
      );
    }
    return id;
  }

  @override
  bool get isAvailable => true;

  @override
  Future<CloudBackupMetadata> uploadSnapshot({
    required Uint8List bytes,
    required String sha256,
    required int schemaVersion,
    required String appVersion,
  }) async {
    final userId = _userId;
    final snapshotId = const Uuid().v4();
    final objectPath = '$userId/$snapshotId.libretbackup';
    await retryCloudUpload(
      () => _client.storage
          .from(_bucket)
          .uploadBinary(
            objectPath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'application/vnd.libretapp.backup+zip',
              upsert: false,
            ),
          ),
    );

    var metadataSaved = false;
    try {
      final downloaded = await _client.storage
          .from(_bucket)
          .download(objectPath);
      if (crypto.sha256.convert(downloaded).toString() != sha256) {
        throw const FormatException(
          'La copia subida no superó la verificación de integridad.',
        );
      }
      final row = await _client
          .from('backup_snapshots')
          .insert({
            'id': snapshotId,
            'user_id': userId,
            'object_path': objectPath,
            'sha256': sha256,
            'size_bytes': bytes.length,
            'schema_version': schemaVersion,
            'app_version': appVersion,
            'verified': true,
          })
          .select()
          .single();
      metadataSaved = true;
      final metadata = CloudBackupMetadata.fromJson(row);
      try {
        await _enforceRetention();
      } catch (_) {
        // Retention is best-effort. A cleanup outage must not invalidate the
        // newly verified snapshot or leave metadata pointing at a missing file.
      }
      return metadata;
    } catch (_) {
      if (!metadataSaved) {
        await _client.storage.from(_bucket).remove([objectPath]);
      }
      rethrow;
    }
  }

  @override
  Future<List<CloudBackupMetadata>> listSnapshots() async {
    _userId;
    final rows = await _client
        .from('backup_snapshots')
        .select()
        .eq('verified', true)
        .order('created_at', ascending: false);
    return (rows as List)
        .map(
          (row) => CloudBackupMetadata.fromJson(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<Uint8List> downloadSnapshot(CloudBackupMetadata metadata) async {
    final userId = _userId;
    if (!metadata.objectPath.startsWith('$userId/')) {
      throw const CloudBackupUnavailable(
        'El respaldo no pertenece a tu cuenta.',
      );
    }
    return _client.storage.from(_bucket).download(metadata.objectPath);
  }

  Future<void> _enforceRetention() async {
    final snapshots = await listSnapshots();
    await const CloudBackupRetentionPolicy(retain: _retention).cleanBestEffort(
      snapshots,
      (snapshot) async {
        await _client.storage.from(_bucket).remove([snapshot.objectPath]);
        await _client.from('backup_snapshots').delete().eq('id', snapshot.id);
      },
    );
  }
}
