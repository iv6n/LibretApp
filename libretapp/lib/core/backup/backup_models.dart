/// Versioned backup value types shared by local and cloud backup services.
library;

enum BackupImportMode { merge, replaceAll }

class BackupEnvelope {
  const BackupEnvelope({
    required this.schemaVersion,
    required this.appVersion,
    required this.exportedAt,
    required this.collections,
    required this.profile,
  });

  static const currentSchemaVersion = 4;

  /// Stamped into every archive and cloud snapshot. Kept here so a version bump
  /// is a single edit — must stay in step with `version:` in pubspec.yaml.
  static const currentAppVersion = '0.1.0+2';

  final int schemaVersion;
  final String appVersion;
  final DateTime exportedAt;
  final Map<String, List<Map<String, dynamic>>> collections;
  final Map<String, dynamic> profile;

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'appVersion': appVersion,
    'exportedAt': exportedAt.toUtc().toIso8601String(),
    'collections': collections,
    'profile': profile,
  };

  factory BackupEnvelope.fromJson(Map<String, dynamic> json) {
    final rawCollections = json['collections'];
    if (rawCollections is! Map) {
      throw const FormatException('El respaldo no contiene colecciones.');
    }
    final collections = <String, List<Map<String, dynamic>>>{};
    for (final entry in rawCollections.entries) {
      final value = entry.value;
      if (entry.key is! String || value is! List) {
        throw const FormatException('Una colección del respaldo no es válida.');
      }
      collections[entry.key as String] = value
          .map((row) {
            if (row is! Map) {
              throw const FormatException(
                'Un registro del respaldo no es válido.',
              );
            }
            return Map<String, dynamic>.from(row);
          })
          .toList(growable: false);
    }
    return BackupEnvelope(
      schemaVersion: json['schemaVersion'] as int? ?? 0,
      appVersion: json['appVersion'] as String? ?? '',
      exportedAt:
          DateTime.tryParse(json['exportedAt'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      collections: collections,
      profile: json['profile'] is Map
          ? Map<String, dynamic>.from(json['profile'] as Map)
          : const {},
    );
  }
}

class BackupRestoreResult {
  const BackupRestoreResult(this.collectionCounts);

  final Map<String, int> collectionCounts;

  int count(String collection) => collectionCounts[collection] ?? 0;
}

class CloudBackupMetadata {
  const CloudBackupMetadata({
    required this.id,
    required this.objectPath,
    required this.sha256,
    required this.sizeBytes,
    required this.schemaVersion,
    required this.appVersion,
    required this.createdAt,
    required this.verified,
  });

  final String id;
  final String objectPath;
  final String sha256;
  final int sizeBytes;
  final int schemaVersion;
  final String appVersion;
  final DateTime createdAt;
  final bool verified;

  factory CloudBackupMetadata.fromJson(Map<String, dynamic> json) {
    return CloudBackupMetadata(
      id: json['id'] as String,
      objectPath: json['object_path'] as String,
      sha256: json['sha256'] as String,
      sizeBytes: json['size_bytes'] as int,
      schemaVersion: json['schema_version'] as int,
      appVersion: json['app_version'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      verified: json['verified'] as bool? ?? false,
    );
  }
}
