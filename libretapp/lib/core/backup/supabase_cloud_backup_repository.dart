/// Supabase Storage implementation for private, versioned backup snapshots.
library;

import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'backup_identity.dart';

import 'package:crypto/crypto.dart' as crypto;
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/cloud_backup_policy.dart';
import 'package:libretapp/core/backup/cloud_backup_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SupabaseCloudBackupRepository implements CloudBackupRepository {
  SupabaseCloudBackupRepository(this._client, {required BackupIdentity identity,
    Future<bool> Function()? wifiAvailable}) : _identity = identity, _wifiAvailable = wifiAvailable;
  final BackupIdentity _identity;
  final Future<bool> Function()? _wifiAvailable;

  static const _bucket = 'libret-backups';
  static const _retention = 5;

  final SupabaseClient _client;

  Future<String> _userId() => _identity.require(_client);

  Future<void> _requireWifi() async {
    if (!(await (_wifiAvailable?.call() ?? Connectivity().checkConnectivity()
        .then((networks) => networks.contains(ConnectivityResult.wifi))))) {
      throw const CloudBackupUnavailable('Conéctate a Wi-Fi para transmitir el respaldo.');
    }
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
    final userId = await _userId();
    await _requireWifi();
    final snapshotId = const Uuid().v4();
    final objectPath = '$userId/$snapshotId.libretbackup';
    if (bytes.isEmpty || bytes.length > 104857600 || crypto.sha256.convert(bytes).toString() != sha256) {
      throw const FormatException('Copia inválida o mayor de 100 MiB.');
    }
    // Reservations allow cleanup after process death, including Storage orphans.
    await _client.from('backup_snapshots').insert({
      'id': snapshotId, 'user_id': userId, 'object_path': objectPath,
      'sha256': sha256, 'size_bytes': bytes.length,
      'schema_version': schemaVersion, 'app_version': appVersion, 'verified': false,
    });
    await retryCloudUpload(() async {
      await _userId();
      await _requireWifi();
      try {
        await _client.storage.from(_bucket).uploadBinary(objectPath, bytes,
          fileOptions: const FileOptions(
            contentType: 'application/vnd.libretapp.backup+zip', upsert: false));
      } catch (error) {
        await _userId();
        final received = await _client.storage.from(_bucket).download(objectPath);
        if (received.length != bytes.length || crypto.sha256.convert(received).toString() != sha256) {
          throw error;
        }
      }
    });

    try {
      await _userId();
      final downloaded = await _client.storage
          .from(_bucket)
          .download(objectPath);
      if (crypto.sha256.convert(downloaded).toString() != sha256) {
        throw const FormatException(
          'La copia subida no superó la verificación de integridad.',
        );
      }
      final row = await retryCloudUpload(() async {
        await _userId();
        return _client.from('backup_snapshots').update({'verified': true})
            .eq('id', snapshotId).eq('user_id', userId).select().single();
      });
      final metadata = CloudBackupMetadata.fromJson(row);
      try {
        await _enforceRetention();
      } catch (_) {
        // Retention is best-effort. A cleanup outage must not invalidate the
        // newly verified snapshot or leave metadata pointing at a missing file.
      }
      return metadata;
    } catch (_) {
      // Leave the reservation/object for reconciliation; never destroy a copy
      // whose verification commit may have succeeded without a response.
      rethrow;
    }
  }

  @override
  Future<List<CloudBackupMetadata>> listSnapshots() async {
    final userId = await _userId();
    final rows = await _client
        .from('backup_snapshots')
        .select()
        .eq('user_id', userId)
        .eq('verified', true)
        .order('created_at', ascending: false);
    await _userId();
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
    final userId = await _userId();
    if (metadata.objectPath != '$userId/${metadata.id}.libretbackup') {
      throw const CloudBackupUnavailable(
        'El respaldo no pertenece a tu cuenta.',
      );
    }
    final row = await _client.from('backup_snapshots').select()
        .eq('id', metadata.id).eq('user_id', userId).eq('verified', true).single();
    if (row['sha256'] != metadata.sha256 || row['object_path'] != metadata.objectPath) {
      throw const FormatException('Los metadatos de la copia cambiaron.');
    }
    await _userId();
    final bytes = await _client.storage.from(_bucket).download(metadata.objectPath);
    await _userId();
    return bytes;
  }

  Future<void> _enforceRetention() async {
    final userId = await _userId();
    final pending = await _client.from('backup_snapshots').select()
        .eq('user_id', userId).eq('verified', false)
        .lt('created_at', DateTime.now().toUtc().subtract(const Duration(days: 1)).toIso8601String());
    for (final row in pending) {
      await _userId();
      await _client.storage.from(_bucket).remove([row['object_path'] as String]);
      await _userId();
      await _client.from('backup_snapshots').delete().eq('user_id', userId).eq('id', row['id']);
    }
    final snapshots = await listSnapshots();
    await const CloudBackupRetentionPolicy(retain: _retention).cleanBestEffort(
      snapshots,
      (snapshot) async {
        await _userId();
        await _client.storage.from(_bucket).remove([snapshot.objectPath]);
        await _userId();
        await _client.from('backup_snapshots').delete().eq('id', snapshot.id);
      },
    );
  }
}
