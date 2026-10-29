import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/isar_backup_store.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/backup_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_projection_recalculator.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'data_maintenance.dart';

class IsarDataMaintenance implements DataMaintenance {
  IsarDataMaintenance({
    required this.database,
    required this.store,
    required this.backup,
    required this.directory,
  });
  final IsarDatabase database;
  final IsarBackupStore store;
  final BackupService backup;
  final Future<Directory> Function() directory;
  bool _busy = false;

  Object? _canonical(Object? value) {
    if (value is Map)
      return {
        for (final key in value.keys.map((e) => e.toString()).toList()..sort())
          key: _canonical(value[key]),
      };
    if (value is List) return value.map(_canonical).toList();
    if (value is num && !value.isFinite) return value.toString();
    return value;
  }

  String _fingerprint(Map<String, List<Map<String, dynamic>>> rows) =>
      sha256.convert(utf8.encode(jsonEncode(_canonical(rows)))).toString();
  int _id(Map<String, dynamic> row) => (row['id'] ?? row['isarId']) as int;

  bool _mentions(Object? value, String uuid) {
    // JSON payloads and old free-text links may contain a record identity.
    // A conservative match requires individual review instead of deletion.
    if (value is String) return value.contains(uuid);
    if (value is Map)
      return value.values.any((child) => _mentions(child, uuid));
    return value is List && value.any((child) => _mentions(child, uuid));
  }

  bool _referenced(
    Map<String, List<Map<String, dynamic>>> rows,
    Map<String, dynamic> target,
  ) {
    final uuid = target['recordUuid'] ?? target['uuid'];
    if (uuid is! String || uuid.isEmpty) return true;
    return rows.values
        .expand((list) => list)
        .any((row) => !identical(row, target) && _mentions(row, uuid));
  }

  MaintenanceReview _review(Map<String, List<Map<String, dynamic>>> rows) {
    final issues = <MaintenanceIssue>[];
    final animalIds = (rows['animals'] ?? []).map((r) => r['uuid']).toSet();
    Set<Object?> ids(String collection, [String field = 'uuid']) =>
        (rows[collection] ?? []).map((r) => r[field]).toSet();
    final references = <String, Set<Object?>>{
      'animalUuid': animalIds,
      'animalUuids': animalIds,
      'animalIds': animalIds,
      'damUuid': animalIds,
      'sireUuid': animalIds,
      'batchUuid': ids('lotes'),
      'lotUuid': ids('lotes'),
      'loteIds': ids('lotes'),
      'initialLocationId': ids('locations'),
      'currentLocationId': ids('locations'),
      'locationUuid': ids('locations'),
      'ruleId': ids('careRules', 'recordUuid'),
      'weightRecordUuid': ids('weightRecords', 'recordUuid'),
      'workTeamId': ids('workTeams'),
      'assigneeId': ids('workerProfiles'),
      'collaboratorIds': ids('workerProfiles'),
      'memberIds': ids('workerProfiles'),
    };
    final groups = <String, List<Map<String, dynamic>>>{};
    const eventCollections = {
      'weightRecords',
      'healthRecords',
      'productionRecords',
      'costRecords',
      'commercialRecords',
      'movementRecords',
      'incomeRecords',
      'generalExpenseRecords',
    };
    const numberFields = {
      'weightRecords': 'weight',
      'incomeRecords': 'amount',
      'generalExpenseRecords': 'amount',
      'costRecords': 'amount',
    };
    for (final entry in rows.entries) {
      if (entry.key == 'profile') continue;
      for (final row in entry.value) {
        final id = _id(row);
        final owner = row['animalUuid'] as String?;
        final referenced = _referenced(rows, row);
        void add(
          MaintenanceIssueKind kind,
          String title,
          String detail, {
          String? numberField,
          bool canDelete = false,
        }) {
          issues.add(
            MaintenanceIssue(
              id: '${entry.key}:$id:${kind.name}',
              collection: entry.key,
              rowId: id,
              kind: kind,
              title: title,
              detail: detail,
              canDelete: canDelete && !referenced,
              numberField: numberField,
              animalUuid: owner,
              manualVaccinated:
                  (row['manualVaccinated'] ?? row['vaccinated']) == true,
              manualDewormed:
                  (row['manualDewormed'] ?? row['dewormed']) == true,
              manualHasVitamins:
                  (row['manualHasVitamins'] ?? row['hasVitamins']) == true,
              manualObservation:
                  (row['manualUnderObservation'] ?? row['underObservation']) ==
                  true,
              manualAttention:
                  (row['manualRequiresAttention'] ??
                      row['requiresAttention']) ==
                  true,
            ),
          );
        }

        final field = numberFields[entry.key];
        if (field != null) {
          final value = row[field];
          if (value is! num || !value.isFinite || value <= 0) {
            add(
              MaintenanceIssueKind.invalidNumber,
              'Importe o peso inválido',
              '${entry.key} · registro $id. Introduce el valor correcto o revisa su eliminación.',
              numberField: field,
              canDelete: true,
            );
          }
        }
        final broken = <String>[];
        final rowReferences = {
          ...references,
          if (entry.key == 'locations') 'parentUuid': ids('locations'),
          if (entry.key == 'locations') 'templateUuid': ids('locations'),
          if (entry.key == 'milkingEntries')
            'sessionUuid': ids('milkingSessions'),
          if (entry.key == 'agendaRegistrations')
            'entryId': ids('agendaEntries'),
          if (entry.key == 'agendaRegistrations') 'animalId': animalIds,
        };
        for (final reference in rowReferences.entries) {
          final value = row[reference.key];
          final values = value is List ? value : [value];
          if (values.any(
            (v) => v is String && v.isNotEmpty && !reference.value.contains(v),
          )) {
            broken.add(reference.key);
          }
        }
        if (broken.isNotEmpty) {
          add(
            MaintenanceIssueKind.orphan,
            'Referencias pendientes de revisión',
            '${entry.key} · registro $id · ${broken.join(', ')}. Revisa el vínculo antes de eliminar datos.',
            canDelete:
                eventCollections.contains(entry.key) &&
                broken.every((field) => field == 'animalUuid'),
          );
        }
        if (entry.key == 'animals' &&
            row['locationProjectionUncertain'] == true) {
          add(
            MaintenanceIssueKind.orphan,
            'Revisar ubicación histórica',
            'No se puede reconstruir el origen con certeza. Revisa la ubicación desde el perfil del animal.',
          );
        }
        if (entry.key == 'animals' &&
            (row['monitoringNeedsReview'] == true ||
                (row['manualUnderObservation'] == null &&
                    row['underObservation'] == true) ||
                (row['manualRequiresAttention'] == null &&
                    row['requiresAttention'] == true) ||
                (row['manualVaccinated'] == null &&
                    row['vaccinated'] == true) ||
                (row['manualDewormed'] == null && row['dewormed'] == true) ||
                (row['manualHasVitamins'] == null &&
                    row['hasVitamins'] == true))) {
          add(
            MaintenanceIssueKind.monitoring,
            'Revisar procedencia de indicadores',
            'Animal ${row['earTagNumber'] ?? row['uuid']}. Los valores antiguos se conservaron; revisa las alertas manuales.',
          );
        }
        if (entry.key == 'featureRecords' && row['payloadJson'] is String) {
          final payload = jsonDecode(row['payloadJson'] as String);
          if (payload is Map &&
              payload['type'] == 'transfer' &&
              (payload['locationId'] == null ||
                  payload['destinationLocationId'] == null ||
                  payload['locationId'] == payload['destinationLocationId'])) {
            add(
              MaintenanceIssueKind.invalidTransfer,
              'Traslado antiguo incompleto',
              'El movimiento se conserva para revisión individual y no acredita existencias.',
            );
          }
        }
        if (eventCollections.contains(entry.key)) {
          final content = Map<String, dynamic>.from(row)
            ..removeWhere(
              (key, _) => const {
                'id',
                'isarId',
                'recordUuid',
                'createdAt',
                'updatedAt',
                'synced',
                'remoteId',
                'syncDate',
              }.contains(key),
            );
          final key = '${entry.key}:${jsonEncode(_canonical(content))}';
          groups.putIfAbsent(key, () => []).add(row);
        }
      }
    }
    for (final entry in groups.entries.where((e) => e.value.length > 1)) {
      final collection = entry.key.substring(0, entry.key.indexOf(':'));
      final duplicates = entry.value
        ..sort((a, b) {
          final refs = (_referenced(rows, b) ? 1 : 0).compareTo(
            _referenced(rows, a) ? 1 : 0,
          );
          if (refs != 0) return refs;
          return _id(a).compareTo(_id(b));
        });
      for (final row in duplicates.skip(1)) {
        final id = _id(row);
        issues.add(
          MaintenanceIssue(
            id: '$collection:$id:duplicate',
            collection: collection,
            rowId: id,
            kind: MaintenanceIssueKind.duplicate,
            title: 'Posible duplicado exacto',
            detail:
                '$collection · registro $id coincide con ${_id(duplicates.first)}. Comprueba que no sean dos actividades intencionales.',
            canDelete: !_referenced(rows, row),
            animalUuid: row['animalUuid'] as String?,
          ),
        );
      }
    }
    return MaintenanceReview(_fingerprint(rows), List.unmodifiable(issues));
  }

  @override
  Future<MaintenanceReview> scan() async =>
      _review(await store.readForMaintenance());

  @override
  Future<String> apply(
    MaintenanceReview review,
    List<MaintenanceChange> changes,
  ) async {
    if (_busy)
      throw StateError('Ya hay una operación de mantenimiento en curso.');
    if (changes.isEmpty)
      throw ArgumentError('Selecciona al menos una corrección.');
    _busy = true;
    try {
      final before = await store.readForMaintenance();
      if (_fingerprint(before) != review.fingerprint)
        throw StateError(
          'Los datos cambiaron. Vuelve a revisar antes de aplicar.',
        );
      final snapshotId = await _createSnapshot();
      final db = database.isar;
      await db.writeTxn(() async {
        final current = await store.readForMaintenance(inTransaction: true);
        if (_fingerprint(current) != review.fingerprint)
          throw StateError(
            'Los datos cambiaron. Vuelve a revisar antes de aplicar.',
          );
        final collections = store.collectionsForMaintenance(db);
        final changed = <String>{};
        final targets = <String>{};
        for (final change in changes) {
          final issue = _review(
            current,
          ).issues.where((i) => i.id == change.issueId).single;
          if (!targets.add('${issue.collection}:${issue.rowId}'))
            throw ArgumentError('Selecciona una sola corrección por registro.');
          final row = Map<String, dynamic>.from(
            current[issue.collection]!.firstWhere((r) => _id(r) == issue.rowId),
          );
          if (change.delete) {
            if (!issue.canDelete ||
                _referenced(
                  current,
                  current[issue.collection]!.firstWhere(
                    (r) => _id(r) == issue.rowId,
                  ),
                )) {
              throw StateError(
                'El registro tiene vínculos y requiere revisión individual.',
              );
            }
            await collections[issue.collection]!.delete(issue.rowId);
          } else if (issue.kind == MaintenanceIssueKind.invalidNumber) {
            final number = change.number;
            if (number == null || !number.isFinite || number <= 0)
              throw ArgumentError('Introduce un valor finito y positivo.');
            row[issue.numberField!] = number;
            row['updatedAt'] = DateTime.now().microsecondsSinceEpoch;
            await collections[issue.collection]!.importJson([row]);
          } else if (issue.kind == MaintenanceIssueKind.monitoring) {
            if (change.manualObservation == null ||
                change.manualAttention == null ||
                change.manualVaccinated == null ||
                change.manualDewormed == null ||
                change.manualHasVitamins == null)
              throw ArgumentError('Revisa las dos alertas manuales.');
            final animal = await db.isarAnimals.get(issue.rowId);
            if (animal == null) throw StateError('Animal no encontrado.');
            animal.manualUnderObservation = change.manualObservation;
            animal.manualRequiresAttention = change.manualAttention;
            animal.manualVaccinated = change.manualVaccinated;
            animal.manualDewormed = change.manualDewormed;
            animal.manualHasVitamins = change.manualHasVitamins;
            animal.monitoringNeedsReview = false;
            // Location uncertainty is not resolved by a health decision.
            await db.isarAnimals.put(animal);
            changed.add(animal.uuid);
          } else {
            throw ArgumentError(
              'Esta incidencia requiere una corrección individual.',
            );
          }
          if (issue.animalUuid != null) changed.add(issue.animalUuid!);
        }
        for (final uuid in changed) {
          await AnimalProjectionRecalculator.recalculate(db, uuid);
        }
        final after = _review(
          await store.readForMaintenance(inTransaction: true),
        );
        final priorKeys = review.issues.map((e) => e.id).toSet();
        if (after.issues.any((e) => !priorKeys.contains(e.id)))
          throw StateError(
            'La selección crearía nuevas inconsistencias. No se aplicaron cambios.',
          );
      });
      return snapshotId;
    } finally {
      _busy = false;
    }
  }

  Future<Directory> _snapshotsRoot() async {
    final root = Directory(
      '${(await directory()).path}${Platform.pathSeparator}emergency_backups',
    );
    await root.create(recursive: true);
    return root;
  }

  Future<String> _path(String id) async {
    if (!RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(id) || id == '.' || id == '..')
      throw ArgumentError('Copia inválida.');
    return '${(await _snapshotsRoot()).path}${Platform.pathSeparator}$id';
  }

  Future<Map<String, String>> _mediaRoots() async {
    final roots = {'workspace': (await directory()).absolute.path};
    try {
      roots['documents'] =
          '${(await getApplicationDocumentsDirectory()).absolute.path}${Platform.pathSeparator}libretapp_media';
    } catch (_) {
      /* Workspace media remains available. */
    }
    return roots;
  }

  String _mediaTarget(Map<String, dynamic> media, Map<String, String> roots) {
    final root = roots[media['root']];
    final relative = media['relative'];
    if (root == null ||
        relative is! String ||
        relative.contains('\\') ||
        relative
            .split('/')
            .any(
              (s) =>
                  s.isEmpty ||
                  s == '.' ||
                  s == '..' ||
                  s.trim() != s ||
                  s.endsWith('.') ||
                  RegExp(r'[\x00-\x1f:*?"<>|]').hasMatch(s) ||
                  RegExp(
                    r'^(con|prn|aux|nul|com[1-9]|lpt[1-9])(?:\.|$)',
                    caseSensitive: false,
                  ).hasMatch(s),
            ))
      throw const FormatException('Ruta de medio inválida.');
    return '$root${Platform.pathSeparator}${relative.split('/').join(Platform.pathSeparator)}';
  }

  @override
  Future<String> createSnapshot() async {
    if (_busy) throw StateError("Hay otra operación en curso.");
    _busy = true;
    try {
      return await _createSnapshot();
    } finally {
      _busy = false;
    }
  }

  Future<String> _createSnapshot() async {
    final id = 'native-${const Uuid().v4()}';
    final folder = Directory(await _path(id));
    await folder.create();
    try {
      final file = File('${folder.path}${Platform.pathSeparator}database.isar');
      await database.isar.copyToFile(file.path);
      final mediaRoots = await _mediaRoots();
      final media = <Map<String, dynamic>>[];
      final paths = <String>{};
      void visit(Object? value) {
        if (value is Map)
          for (final child in value.values) {
            visit(child);
          }
        if (value is List)
          for (final child in value) {
            visit(child);
          }
        if (value is String && File(value).isAbsolute)
          paths.add(File(value).absolute.path);
      }

      final frozen = IsarDatabase.workspace(folder.path, name: 'database');
      try {
        await frozen.initialize();
        visit(await store.readDatabaseForMaintenance(frozen.isar));
      } finally {
        await frozen.close();
      }
      for (final path in paths) {
        final source = File(path);
        if (!await source.exists()) continue;
        final roots = mediaRoots.entries.where(
          (e) => path.startsWith('${e.value}${Platform.pathSeparator}'),
        );
        if (roots.isEmpty) continue;
        final root = roots.first;
        final bytes = await source.readAsBytes();
        final digest = sha256.convert(bytes).toString();
        final archivePath = 'media/$digest';
        final target = File(
          '${folder.path}${Platform.pathSeparator}media${Platform.pathSeparator}$digest',
        );
        await target.parent.create(recursive: true);
        await target.writeAsBytes(bytes, flush: true);
        media.add({
          'root': root.key,
          'relative': path
              .substring(root.value.length + 1)
              .replaceAll('\\', '/'),
          'archive': archivePath,
          'sha256': digest,
        });
      }
      final manifest = {
        'format': 'libret-native-recovery-v1',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'workspaceRoot': (await directory()).absolute.path,
        'databaseName': database.name,
        'appVersion': BackupEnvelope.currentAppVersion,
        'schemaVersion': BackupEnvelope.currentSchemaVersion,
        'databaseSha256': sha256.convert(await file.readAsBytes()).toString(),
        'media': media,
      };
      await File(
        '${folder.path}${Platform.pathSeparator}manifest.json',
      ).writeAsString(jsonEncode(manifest), flush: true);
      return id;
    } catch (_) {
      if (await folder.exists()) await folder.delete(recursive: true);
      rethrow;
    }
  }

  @override
  Future<List<RecoverySnapshot>> snapshots() async {
    final results = <RecoverySnapshot>[];
    await for (final entry in (await _snapshotsRoot()).list(
      followLinks: false,
    )) {
      final id = entry.uri.pathSegments.where((s) => s.isNotEmpty).last;
      if (entry is File && id.endsWith('.libretbackup')) {
        results.add(
          RecoverySnapshot(
            id: id,
            createdAt: (await entry.stat()).modified,
            native: false,
          ),
        );
      } else if (entry is Directory && id.startsWith('native-')) {
        try {
          final manifest =
              jsonDecode(
                    await File(
                      '${entry.path}${Platform.pathSeparator}manifest.json',
                    ).readAsString(),
                  )
                  as Map;
          results.add(
            RecoverySnapshot(
              id: id,
              createdAt: DateTime.parse(manifest['createdAt'] as String),
              native: true,
            ),
          );
        } catch (_) {
          /* Incomplete snapshots are never offered for restore. */
        }
      }
    }
    return results..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Uint8List> exportSnapshot(String id) async {
    final path = await _path(id);
    if (id.endsWith('.libretbackup')) return File(path).readAsBytes();
    final archive = Archive();
    await for (final entry in Directory(
      path,
    ).list(recursive: true, followLinks: false)) {
      if (entry is! File) continue;
      final bytes = await entry.readAsBytes();
      archive.addFile(
        ArchiveFile(
          entry.path.substring(path.length + 1).replaceAll('\\', '/'),
          bytes.length,
          bytes,
        ),
      );
    }
    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }

  @override
  Future<String?> saveSnapshot(String id) async {
    final bytes = await exportSnapshot(id);
    final extension = id.endsWith('.libretbackup') ? '' : '.libretrecovery';
    final path = await FilePicker.platform.saveFile(
      fileName: '$id$extension',
      bytes: bytes,
      dialogTitle: 'Guardar copia de recuperación',
    );
    if (path != null) await File(path).writeAsBytes(bytes, flush: true);
    return path;
  }

  Future<Map<String, dynamic>> _validateNative(String path) async {
    final manifest = Map<String, dynamic>.from(
      jsonDecode(
            await File(
              '$path${Platform.pathSeparator}manifest.json',
            ).readAsString(),
          )
          as Map,
    );
    if (manifest['format'] != 'libret-native-recovery-v1' ||
        manifest['databaseName'] != database.name ||
        manifest['workspaceRoot'] != (await directory()).absolute.path ||
        manifest['schemaVersion'] is! int ||
        (manifest['schemaVersion'] as int) >
            BackupEnvelope.currentSchemaVersion) {
      throw const FormatException(
        'Esta copia nativa corresponde a otro espacio o versión. Usa .libretbackup para cambiar de dispositivo.',
      );
    }
    final file = File('$path${Platform.pathSeparator}database.isar');
    if (sha256.convert(await file.readAsBytes()).toString() !=
        manifest['databaseSha256'])
      throw const FormatException('La base de recuperación está incompleta.');
    final roots = await _mediaRoots();
    for (final item in manifest['media'] as List) {
      final media = Map<String, dynamic>.from(item as Map);
      _mediaTarget(media, roots);
      final digest = media['sha256'];
      if (digest is! String ||
          !RegExp(r'^[a-f0-9]{64}$').hasMatch(digest) ||
          media['archive'] != 'media/$digest')
        throw const FormatException('Adjunto de recuperación inválido.');
      if (sha256
              .convert(
                await File(
                  '$path${Platform.pathSeparator}media${Platform.pathSeparator}$digest',
                ).readAsBytes(),
              )
              .toString() !=
          digest)
        throw const FormatException('Adjunto incompleto.');
    }
    return manifest;
  }

  @override
  Future<bool> importSnapshot() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (picked == null) return false;
    final file = picked.files.single;
    if (!file.name.endsWith('.libretrecovery'))
      throw const FormatException(
        'Selecciona una copia .libretrecovery de este espacio.',
      );
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    final folder = Directory(await _path('native-import-${const Uuid().v4()}'));
    await folder.create();
    try {
      final names = <String>{};
      for (final entry in archive.files) {
        if (!names.add(entry.name))
          throw const FormatException('Archivo duplicado en la copia.');
        if (!entry.isFile ||
            entry.isSymbolicLink ||
            !(entry.name == 'manifest.json' ||
                entry.name == 'database.isar' ||
                RegExp(r'^media/[a-f0-9]{64}$').hasMatch(entry.name)))
          throw const FormatException('Contenido de recuperación inválido.');
        final target = File(
          '${folder.path}${Platform.pathSeparator}${entry.name.replaceAll('/', Platform.pathSeparator)}',
        );
        await target.parent.create(recursive: true);
        await target.writeAsBytes(
          List<int>.from(entry.content as List),
          flush: true,
        );
      }
      await _validateNative(folder.path);
      return true;
    } catch (_) {
      await folder.delete(recursive: true);
      rethrow;
    }
  }

  @override
  Future<void> restoreSnapshot(
    String id, {
    required MaintenanceReopener reopen,
  }) async {
    if (_busy) throw StateError('Hay otra operación en curso.');
    _busy = true;
    try {
      final path = await _path(id);
      if (id.endsWith('.libretbackup')) {
        await backup.importArchiveBytes(
          await File(path).readAsBytes(),
          mode: BackupImportMode.replaceAll,
        );
        await reopen(() async {});
        return;
      }
      final manifest = await _validateNative(path);
      await _createSnapshot();
      final root = await directory();
      final uuid = const Uuid().v4();
      final stage = File(
        '${root.path}${Platform.pathSeparator}pending-$uuid.isar',
      );
      await File(
        '$path${Platform.pathSeparator}database.isar',
      ).copy(stage.path);
      final handle = await stage.open(mode: FileMode.append);
      await handle.flush();
      await handle.close();
      // Validate that Isar can open this file while the live database is still
      // untouched. A valid hash alone does not prove it is an Isar database.
      final probe = IsarDatabase.workspace(root.path, name: 'pending-$uuid');
      try {
        await probe.initialize();
        await probe.isar.isarAnimals.count();
      } finally {
        await probe.close();
      }
      final stagedHash = sha256.convert(await stage.readAsBytes()).toString();
      final roots = await _mediaRoots();
      final missing = <(File, File)>[];
      for (final item in manifest['media'] as List) {
        final media = Map<String, dynamic>.from(item as Map);
        final target = File(_mediaTarget(media, roots));
        final source = File(
          '$path${Platform.pathSeparator}media${Platform.pathSeparator}${media['sha256']}',
        );
        if (await target.exists()) {
          if (sha256.convert(await target.readAsBytes()).toString() !=
              media['sha256']) {
            throw StateError(
              'Un medio existente cambió. Se conserva sin sobrescribir; revisa la copia exportada.',
            );
          }
        } else {
          missing.add((source, target));
        }
      }
      for (final item in missing) {
        await item.$2.parent.create(recursive: true);
        await item.$2.writeAsBytes(await item.$1.readAsBytes(), flush: true);
      }
      await reopen(() async {
        final marker = File(
          '${root.path}${Platform.pathSeparator}recovery-pending.json',
        );
        final temporary = File('${marker.path}.tmp');
        await temporary.writeAsString(
          jsonEncode({
            'name': database.name,
            'staged': 'pending-$uuid.isar',
            'rollback': 'before-recovery-$uuid.isar',
            'sha256': stagedHash,
          }),
          flush: true,
        );
        if (await marker.exists())
          throw StateError('Hay otra recuperación pendiente.');
        await temporary.rename(marker.path);
      });
    } finally {
      _busy = false;
    }
  }
}
