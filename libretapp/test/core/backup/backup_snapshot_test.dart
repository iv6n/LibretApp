import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/backup_store.dart';
import 'package:libretapp/core/backup/cloud_backup_policy.dart';
import 'package:libretapp/core/backup/cloud_backup_repository.dart';
import 'package:libretapp/core/backup/cloud_backup_service.dart';
import 'package:libretapp/core/services/backup_service.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/data/workforce_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';

const _collectionNames = <String>{
  'animals',
  'weightRecords',
  'reproductionRecords',
  'productionRecords',
  'healthRecords',
  'costRecords',
  'commercialRecords',
  'movementRecords',
  'lotes',
  'locations',
  'incomeRecords',
  'generalExpenseRecords',
  'milkingSessions',
  'milkingEntries',
  'agendaEntries',
  'workerProfiles',
  'workTeams',
};

BackupEnvelope _envelope({
  Map<String, List<Map<String, dynamic>>> overrides = const {},
}) {
  return BackupEnvelope(
    schemaVersion: BackupEnvelope.currentSchemaVersion,
    appVersion: '0.1.0+2',
    exportedAt: DateTime.utc(2026, 7, 29),
    collections: {
      for (final name in _collectionNames)
        name: overrides[name] ?? <Map<String, dynamic>>[],
    },
    profile: const {'id': 'profile-1', 'finca': 'Piloto'},
  );
}

class _FakeBackupStore implements BackupStore {
  _FakeBackupStore(this.envelope);

  BackupEnvelope envelope;
  BackupEnvelope? restored;
  BackupImportMode? restoreMode;

  @override
  Future<BackupEnvelope> capture() async => envelope;

  @override
  Future<BackupRestoreResult> restore(
    BackupEnvelope envelope, {
    required BackupImportMode mode,
  }) async {
    restored = envelope;
    restoreMode = mode;
    return BackupRestoreResult({
      for (final entry in envelope.collections.entries)
        entry.key: entry.value.length,
    });
  }
}

class _NoopAnimalRepository implements AnimalRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoopLotesRepository implements LotesRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoopAgendaRepository implements AgendaRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoopWorkforceRepository implements WorkforceRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoopMilkingRepository implements MilkingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

BackupService _backupService(BackupStore store) => BackupService(
  animalRepository: _NoopAnimalRepository(),
  lotesRepository: _NoopLotesRepository(),
  agendaRepository: _NoopAgendaRepository(),
  workforceRepository: _NoopWorkforceRepository(),
  milkingRepository: _NoopMilkingRepository(),
  backupStore: store,
);

CloudBackupMetadata _metadata({String digest = 'digest'}) =>
    CloudBackupMetadata(
      id: 'snapshot-1',
      objectPath: 'user-1/snapshot-1.libretbackup',
      sha256: digest,
      sizeBytes: 100,
      schemaVersion: 4,
      appVersion: '0.1.0+2',
      createdAt: DateTime.utc(2026, 7, 29),
      verified: true,
    );

class _FakeCloudRepository implements CloudBackupRepository {
  _FakeCloudRepository({this.available = true});

  final bool available;
  Uint8List? uploaded;
  String? uploadedDigest;
  Uint8List downloaded = Uint8List(0);

  @override
  bool get isAvailable => available;

  @override
  Future<CloudBackupMetadata> uploadSnapshot({
    required Uint8List bytes,
    required String sha256,
    required int schemaVersion,
    required String appVersion,
  }) async {
    uploaded = bytes;
    uploadedDigest = sha256;
    return _metadata(digest: sha256);
  }

  @override
  Future<List<CloudBackupMetadata>> listSnapshots() async => [_metadata()];

  @override
  Future<Uint8List> downloadSnapshot(CloudBackupMetadata metadata) async =>
      downloaded;
}

void main() {
  test('archive stamps the current schema version and all collections', () async {
    final store = _FakeBackupStore(
      _envelope(
        overrides: {
          'animals': [
            {'id': 1, 'uuid': 'animal-1'},
          ],
        },
      ),
    );
    final bytes = await _backupService(store).createArchiveBytes();
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    final manifestFile = archive.findFile('manifest.json');

    expect(manifestFile, isNotNull);
    final manifest =
        jsonDecode(utf8.decode(List<int>.from(manifestFile!.content as List)))
            as Map<String, dynamic>;
    // Read from the constant instead of a literal: the version moves whenever
    // collections are added, and pinning it here just makes the test a chore.
    expect(manifest['schemaVersion'], BackupEnvelope.currentSchemaVersion);
    expect(
      (manifest['collections'] as Map).keys.toSet(),
      containsAll(_collectionNames),
    );
  });

  test('archive captures referenced local media by content hash', () async {
    final directory = await Directory.systemTemp.createTemp('libret-media-');
    addTearDown(() => directory.delete(recursive: true));
    final image = File('${directory.path}${Platform.pathSeparator}photo.jpg');
    await image.writeAsBytes([1, 2, 3, 4]);
    final store = _FakeBackupStore(
      _envelope(
        overrides: {
          'animals': [
            {'id': 1, 'uuid': 'animal-1', 'profilePhoto': image.path},
          ],
        },
      ),
    );

    final archive = ZipDecoder().decodeBytes(
      await _backupService(store).createArchiveBytes(),
      verify: true,
    );
    expect(
      archive.files.where((file) => file.name.startsWith('media/')),
      hasLength(1),
    );
  });

  test(
    'merge restore delegates the validated envelope to BackupStore',
    () async {
      final store = _FakeBackupStore(
        _envelope(
          overrides: {
            'animals': [
              {'id': 1, 'uuid': 'animal-1'},
            ],
          },
        ),
      );
      final service = _backupService(store);
      final bytes = await service.createArchiveBytes();

      final summary = await service.importArchiveBytes(
        bytes,
        mode: BackupImportMode.merge,
      );

      expect(store.restoreMode, BackupImportMode.merge);
      expect(store.restored, isNotNull);
      expect(summary.animalsImported, 1);
    },
  );

  test('rejects duplicate stable identities before creating archive', () async {
    final store = _FakeBackupStore(
      _envelope(
        overrides: {
          'animals': [
            {'id': 1, 'uuid': 'duplicate'},
            {'id': 2, 'uuid': 'duplicate'},
          ],
        },
      ),
    );
    await expectLater(
      _backupService(store).createArchiveBytes,
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects child records whose animal is missing', () async {
    final store = _FakeBackupStore(
      _envelope(
        overrides: {
          'weightRecords': [
            {'id': 1, 'recordUuid': 'weight-1', 'animalUuid': 'missing'},
          ],
        },
      ),
    );
    await expectLater(
      _backupService(store).createArchiveBytes,
      throwsA(isA<FormatException>()),
    );
  });

  test('cloud backup uploads archive with its digest', () async {
    final backup = _backupService(_FakeBackupStore(_envelope()));
    final cloud = _FakeCloudRepository();
    final service = CloudBackupService(
      backupService: backup,
      repository: cloud,
    );

    final metadata = await service.backupNow();

    expect(cloud.uploaded, isNotNull);
    expect(cloud.uploadedDigest, metadata.sha256);
    expect(metadata.verified, isTrue);
  });

  test('cloud backup reports unavailable configuration', () async {
    final service = CloudBackupService(
      backupService: _backupService(_FakeBackupStore(_envelope())),
      repository: _FakeCloudRepository(available: false),
    );
    await expectLater(
      service.backupNow,
      throwsA(isA<CloudBackupUnavailable>()),
    );
  });

  test(
    'cloud restore rejects a digest mismatch before local mutation',
    () async {
      final store = _FakeBackupStore(_envelope());
      final cloud = _FakeCloudRepository()
        ..downloaded = Uint8List.fromList([1]);
      final service = CloudBackupService(
        backupService: _backupService(store),
        repository: cloud,
      );

      await expectLater(
        () => service.restore(
          _metadata(digest: 'not-the-real-digest'),
          mode: BackupImportMode.replaceAll,
        ),
        throwsA(isA<FormatException>()),
      );
      expect(store.restored, isNull);
    },
  );

  test('cloud upload retries transient failures', () async {
    var attempts = 0;
    final result = await retryCloudUpload(() async {
      attempts++;
      if (attempts < 3) throw StateError('temporary outage');
      return 'uploaded';
    }, retryDelay: Duration.zero);

    expect(result, 'uploaded');
    expect(attempts, 3);
  });

  test('retention keeps five newest verified snapshots', () {
    final snapshots = List.generate(
      7,
      (index) => CloudBackupMetadata(
        id: 'snapshot-$index',
        objectPath: 'user/snapshot-$index.libretbackup',
        sha256: 'digest-$index',
        sizeBytes: 100,
        schemaVersion: 4,
        appVersion: '0.1.0+2',
        createdAt: DateTime.utc(2026, 7, 29).subtract(Duration(days: index)),
        verified: true,
      ),
    );

    final expired = const CloudBackupRetentionPolicy().expired(snapshots);

    expect(expired.map((snapshot) => snapshot.id), [
      'snapshot-5',
      'snapshot-6',
    ]);
  });

  test(
    'retention cleanup failure does not invalidate newer snapshots',
    () async {
      final deleted = <String>[];
      final snapshots = List.generate(
        7,
        (index) => CloudBackupMetadata(
          id: 'snapshot-$index',
          objectPath: 'user/snapshot-$index.libretbackup',
          sha256: 'digest-$index',
          sizeBytes: 100,
          schemaVersion: 4,
          appVersion: '0.1.0+2',
          createdAt: DateTime.utc(2026, 7, 29).subtract(Duration(days: index)),
          verified: true,
        ),
      );

      await const CloudBackupRetentionPolicy().cleanBestEffort(snapshots, (
        snapshot,
      ) async {
        if (snapshot.id == 'snapshot-5') throw StateError('cleanup outage');
        deleted.add(snapshot.id);
      });

      expect(deleted, ['snapshot-6']);
    },
  );
}
