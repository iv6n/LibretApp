/// core > services > backup_service - app data backup/import service for animals and lotes.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/backup_store.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/data/workforce_model.dart';
import 'package:libretapp/features/agenda/data/workforce_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_dto.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lote_dto.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';
import 'package:path_provider/path_provider.dart';

export 'package:libretapp/core/backup/backup_models.dart' show BackupImportMode;

class BackupImportSummary {
  const BackupImportSummary({
    required this.mode,
    required this.animalsImported,
    required this.lotesImported,
    required this.agendaEntriesImported,
    required this.workersImported,
    required this.teamsImported,
    required this.milkingSessionsImported,
    required this.milkingEntriesImported,
    this.collectionCounts = const {},
  });

  final BackupImportMode mode;
  final int animalsImported;
  final int lotesImported;
  final int agendaEntriesImported;
  final int workersImported;
  final int teamsImported;
  final int milkingSessionsImported;
  final int milkingEntriesImported;
  final Map<String, int> collectionCounts;
}

/// Result of parsing and cross-validating a raw backup payload, before any
/// repository write happens.
class _DecodedBackup {
  const _DecodedBackup({
    required this.animalDtos,
    required this.loteDtos,
    required this.agendaEntries,
    required this.workers,
    required this.teams,
    required this.milkingSessions,
    required this.milkingEntries,
  });

  final List<AnimalDto> animalDtos;
  final List<LoteDto> loteDtos;
  final List<AgendaEntry> agendaEntries;
  final List<WorkerProfile> workers;
  final List<WorkTeam> teams;
  final List<MilkingSession> milkingSessions;
  final List<MilkingEntry> milkingEntries;
}

class BackupService {
  BackupService({
    required AnimalRepository animalRepository,
    required LotesRepository lotesRepository,
    required AgendaRepository agendaRepository,
    required WorkforceRepository workforceRepository,
    required MilkingRepository milkingRepository,
    BackupStore? backupStore,
    Future<List<AnimalEntity>> Function()? fetchAllAnimalsIncludingArchived,
  }) : _animalRepository = animalRepository,
       _lotesRepository = lotesRepository,
       _agendaRepository = agendaRepository,
       _workforceRepository = workforceRepository,
       _milkingRepository = milkingRepository,
       _backupStore = backupStore,
       _fetchAllAnimalsIncludingArchived = fetchAllAnimalsIncludingArchived;

  static const _schemaVersion = BackupEnvelope.currentSchemaVersion;
  static const _appVersion = '0.1.0+2';

  final AnimalRepository _animalRepository;
  final LotesRepository _lotesRepository;
  final AgendaRepository _agendaRepository;
  final WorkforceRepository _workforceRepository;
  final MilkingRepository _milkingRepository;
  final BackupStore? _backupStore;

  /// Backup exports must include archived animals even though the default
  /// [AnimalRepository.getAll] filters them out. Which concrete repository
  /// can actually answer that is a composition-root concern (see
  /// `injection.dart`), not something this service should downcast to
  /// figure out — so it's handed in as a hook, defaulting to plain [getAll]
  /// when the caller doesn't provide one.
  final Future<List<AnimalEntity>> Function()?
  _fetchAllAnimalsIncludingArchived;

  Future<String> exportToJsonString() async {
    final backupStore = _backupStore;
    if (backupStore != null) {
      final envelope = await backupStore.capture();
      _validateEnvelope(envelope);
      return const JsonEncoder.withIndent(' ').convert(envelope.toJson());
    }
    final fetchArchived = _fetchAllAnimalsIncludingArchived;
    final animals = fetchArchived != null
        ? await fetchArchived()
        : await _animalRepository.getAll();
    final lotes = await _lotesRepository.getAll();
    final agendaEntries = await _agendaRepository.fetchEntries();
    final workers = await _workforceRepository.fetchWorkers(
      includeInactive: true,
    );
    final teams = await _workforceRepository.fetchTeams(includeInactive: true);
    final milkingSessions = await _milkingRepository.getAllSessions();
    final milkingEntries = await _milkingRepository.getAllEntries();

    final payload = <String, dynamic>{
      // Keep the repository-only fallback on the legacy schema. Production
      // always injects [BackupStore] and emits the complete v4 format.
      'schemaVersion': 3,
      'appVersion': _appVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'data': {
        'animals': animals
            .map((e) => AnimalDto.fromEntity(e).toJson())
            .toList(),
        'lotes': lotes.map((e) => LoteDto.fromEntity(e).toJson()).toList(),
        'agenda': agendaEntries.map((entry) => entry.toJson()).toList(),
        'workers': workers.map((worker) => worker.toJson()).toList(),
        'teams': teams.map((team) => team.toJson()).toList(),
        'milkingSessions': milkingSessions
            .map((session) => session.toJson())
            .toList(),
        'milkingEntries': milkingEntries
            .map((entry) => entry.toJson())
            .toList(),
      },
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<String?> exportToFile() async {
    final archiveBytes = await createArchiveBytes();
    final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
      ':',
      '-',
    );

    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar respaldo',
      fileName: 'libretapp-backup-$timestamp.libretbackup',
      type: FileType.custom,
      allowedExtensions: const ['libretbackup'],
    );

    if (savePath == null || savePath.isEmpty) {
      return null;
    }

    final target = File(savePath);
    await target.writeAsBytes(archiveBytes, flush: true);
    return target.path;
  }

  Future<BackupImportSummary?> importFromFile({
    required BackupImportMode mode,
  }) async {
    final picked = await FilePicker.platform.pickFiles(
      dialogTitle: 'Seleccionar respaldo',
      type: FileType.custom,
      allowedExtensions: const ['libretbackup', 'json'],
      allowMultiple: false,
      withData: false,
    );

    if (picked == null || picked.files.isEmpty) {
      return null;
    }

    final path = picked.files.single.path;
    if (path == null || path.isEmpty) {
      throw const FormatException(
        'No se pudo leer la ruta del archivo seleccionado.',
      );
    }

    final source = File(path);
    if (path.toLowerCase().endsWith('.json')) {
      return importFromJsonString(await source.readAsString(), mode: mode);
    }
    return importArchiveBytes(await source.readAsBytes(), mode: mode);
  }

  Future<BackupImportSummary> importFromJsonString(
    String raw, {
    required BackupImportMode mode,
  }) async {
    final rawDecoded = jsonDecode(raw);
    if (rawDecoded is Map<String, dynamic> &&
        rawDecoded['schemaVersion'] == BackupEnvelope.currentSchemaVersion) {
      final envelope = BackupEnvelope.fromJson(rawDecoded);
      _validateEnvelope(envelope);
      if (mode == BackupImportMode.replaceAll) {
        await _writeEmergencySnapshot();
      }
      final result = await _requireBackupStore().restore(envelope, mode: mode);
      return _summaryFromRestore(mode, result);
    }
    final decoded = _decodeAndValidate(raw);
    if (mode == BackupImportMode.replaceAll && _backupStore != null) {
      await _writeEmergencySnapshot();
    }
    return _applyImport(decoded, mode);
  }

  Future<Uint8List> createArchiveBytes() async {
    final store = _requireBackupStore();
    final envelope = await store.capture();
    _validateEnvelope(envelope);
    final archive = Archive();
    final encodedJson = await _encodeMediaValue(envelope.toJson(), archive);
    final manifestBytes = utf8.encode(
      const JsonEncoder.withIndent('  ').convert(encodedJson),
    );
    archive.addFile(
      ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
    );
    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }

  Future<BackupImportSummary> importArchiveBytes(
    Uint8List bytes, {
    required BackupImportMode mode,
  }) async {
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    final manifest = archive.findFile('manifest.json');
    if (manifest == null || !manifest.isFile) {
      throw const FormatException('El respaldo no contiene manifest.json.');
    }
    final decoded = jsonDecode(
      utf8.decode(List<int>.from(manifest.content as List)),
    );
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('El manifiesto del respaldo no es válido.');
    }
    final restoredJson = await _decodeMediaValue(decoded, archive);
    final envelope = BackupEnvelope.fromJson(
      Map<String, dynamic>.from(restoredJson as Map),
    );
    _validateEnvelope(envelope);
    if (mode == BackupImportMode.replaceAll) {
      await _writeEmergencySnapshot();
    }
    final result = await _requireBackupStore().restore(envelope, mode: mode);
    return _summaryFromRestore(mode, result);
  }

  String digestArchive(Uint8List bytes) => sha256.convert(bytes).toString();

  BackupStore _requireBackupStore() {
    final store = _backupStore;
    if (store == null) {
      throw StateError(
        'El almacén de respaldos completos no está configurado.',
      );
    }
    return store;
  }

  BackupImportSummary _summaryFromRestore(
    BackupImportMode mode,
    BackupRestoreResult result,
  ) {
    return BackupImportSummary(
      mode: mode,
      animalsImported: result.count('animals'),
      lotesImported: result.count('lotes'),
      agendaEntriesImported: result.count('agendaEntries'),
      workersImported: result.count('workerProfiles'),
      teamsImported: result.count('workTeams'),
      milkingSessionsImported: result.count('milkingSessions'),
      milkingEntriesImported: result.count('milkingEntries'),
      collectionCounts: result.collectionCounts,
    );
  }

  void _validateEnvelope(BackupEnvelope envelope) {
    if (envelope.schemaVersion != BackupEnvelope.currentSchemaVersion) {
      throw FormatException(
        'Versión de respaldo no compatible: ${envelope.schemaVersion}.',
      );
    }
    const requiredCollections = <String>{
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
    final missing = requiredCollections.difference(
      envelope.collections.keys.toSet(),
    );
    if (missing.isNotEmpty) {
      throw FormatException(
        'Faltan colecciones en el respaldo: ${missing.join(', ')}.',
      );
    }
    const stableFields = <String, String>{
      'animals': 'uuid',
      'weightRecords': 'recordUuid',
      'reproductionRecords': 'recordUuid',
      'productionRecords': 'recordUuid',
      'healthRecords': 'recordUuid',
      'costRecords': 'recordUuid',
      'commercialRecords': 'recordUuid',
      'movementRecords': 'recordUuid',
      'lotes': 'uuid',
      'locations': 'uuid',
      'incomeRecords': 'recordUuid',
      'generalExpenseRecords': 'recordUuid',
      'milkingSessions': 'uuid',
      'milkingEntries': 'uuid',
      'agendaEntries': 'uuid',
      'workerProfiles': 'uuid',
      'workTeams': 'uuid',
    };
    for (final entry in stableFields.entries) {
      _validateUniqueRows(
        envelope.collections[entry.key]!,
        collection: entry.key,
        field: entry.value,
      );
    }

    final animalIds = _stringValues(envelope.collections['animals']!, 'uuid');
    for (final name in const [
      'weightRecords',
      'reproductionRecords',
      'productionRecords',
      'healthRecords',
      'costRecords',
      'commercialRecords',
      'movementRecords',
    ]) {
      for (final row in envelope.collections[name]!) {
        final animalUuid = row['animalUuid'];
        if (animalUuid is! String || !animalIds.contains(animalUuid)) {
          throw FormatException(
            '$name contiene un registro sin animal válido.',
          );
        }
      }
    }
    final sessionIds = _stringValues(
      envelope.collections['milkingSessions']!,
      'uuid',
    );
    for (final row in envelope.collections['milkingEntries']!) {
      if (!sessionIds.contains(row['sessionUuid'])) {
        throw const FormatException(
          'Una entrada de ordeña no tiene una sesión válida.',
        );
      }
      if (!animalIds.contains(row['animalUuid'])) {
        throw const FormatException(
          'Una entrada de ordeña no tiene un animal válido.',
        );
      }
    }
    _validateLocationHierarchy(envelope.collections['locations']!);
  }

  void _validateUniqueRows(
    List<Map<String, dynamic>> rows, {
    required String collection,
    required String field,
  }) {
    final seen = <String>{};
    for (final row in rows) {
      final value = row[field];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('$collection contiene $field vacío.');
      }
      if (!seen.add(value)) {
        throw FormatException('$collection contiene $field duplicado: $value.');
      }
    }
  }

  Set<String> _stringValues(List<Map<String, dynamic>> rows, String field) =>
      rows.map((row) => row[field]).whereType<String>().toSet();

  void _validateLocationHierarchy(List<Map<String, dynamic>> rows) {
    final parents = <String, String?>{
      for (final row in rows)
        if (row['uuid'] is String)
          row['uuid'] as String: row['parentUuid'] as String?,
    };
    for (final entry in parents.entries) {
      final parent = entry.value;
      if (parent != null && !parents.containsKey(parent)) {
        throw FormatException(
          'La ubicación ${entry.key} tiene un padre inexistente.',
        );
      }
      final visited = <String>{entry.key};
      var cursor = parent;
      while (cursor != null) {
        if (!visited.add(cursor)) {
          throw FormatException(
            'El respaldo contiene un ciclo de ubicaciones en ${entry.key}.',
          );
        }
        cursor = parents[cursor];
      }
    }
  }

  Future<Object?> _encodeMediaValue(Object? value, Archive archive) async {
    if (value is Map) {
      final result = <String, dynamic>{};
      for (final entry in value.entries) {
        result[entry.key.toString()] = await _encodeMediaValue(
          entry.value,
          archive,
        );
      }
      return result;
    }
    if (value is List) {
      final result = <Object?>[];
      for (final item in value) {
        result.add(await _encodeMediaValue(item, archive));
      }
      return result;
    }
    if (value is! String || value.startsWith('media://')) return value;
    final source = File(value);
    if (!source.isAbsolute || !await source.exists()) return value;
    final bytes = await source.readAsBytes();
    final digest = sha256.convert(bytes).toString();
    final fileName = source.uri.pathSegments.isEmpty
        ? 'attachment'
        : source.uri.pathSegments.last;
    final dot = fileName.lastIndexOf('.');
    final extension = dot >= 0 ? fileName.substring(dot).toLowerCase() : '';
    final archivePath = 'media/$digest$extension';
    if (archive.findFile(archivePath) == null) {
      archive.addFile(ArchiveFile(archivePath, bytes.length, bytes));
    }
    return 'media://$archivePath';
  }

  Future<Object?> _decodeMediaValue(Object? value, Archive archive) async {
    if (value is Map) {
      final result = <String, dynamic>{};
      for (final entry in value.entries) {
        result[entry.key.toString()] = await _decodeMediaValue(
          entry.value,
          archive,
        );
      }
      return result;
    }
    if (value is List) {
      final result = <Object?>[];
      for (final item in value) {
        result.add(await _decodeMediaValue(item, archive));
      }
      return result;
    }
    if (value is! String || !value.startsWith('media://')) return value;
    final archivePath = value.substring('media://'.length);
    final attachment = archive.findFile(archivePath);
    if (attachment == null || !attachment.isFile) {
      throw FormatException('Falta el archivo adjunto $archivePath.');
    }
    final support = await getApplicationSupportDirectory();
    final mediaDirectory = Directory(
      '${support.path}${Platform.pathSeparator}backup_media',
    );
    await mediaDirectory.create(recursive: true);
    final localName = archivePath.split('/').last;
    final target = File(
      '${mediaDirectory.path}${Platform.pathSeparator}$localName',
    );
    await target.writeAsBytes(
      List<int>.from(attachment.content as List),
      flush: true,
    );
    return target.path;
  }

  Future<String> _writeEmergencySnapshot() async {
    final bytes = await createArchiveBytes();
    final support = await getApplicationSupportDirectory();
    final directory = Directory(
      '${support.path}${Platform.pathSeparator}emergency_backups',
    );
    await directory.create(recursive: true);
    final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
      ':',
      '-',
    );
    final target = File(
      '${directory.path}${Platform.pathSeparator}'
      'before-restore-$timestamp.libretbackup',
    );
    await target.writeAsBytes(bytes, flush: true);
    return target.path;
  }

  /// Parses and validates the raw backup JSON into typed, cross-checked
  /// lists. Pure (no repository I/O), so schema/validation bugs can be
  /// tested without a fake repository per entity type.
  _DecodedBackup _decodeAndValidate(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'El respaldo no tiene un objeto JSON valido.',
      );
    }

    final schemaVersion = decoded['schemaVersion'];
    if (schemaVersion is! int || schemaVersion <= 0) {
      throw const FormatException('schemaVersion ausente o invalido.');
    }
    if (schemaVersion > _schemaVersion) {
      throw FormatException(
        'El respaldo usa schemaVersion $schemaVersion, pero esta app soporta hasta $_schemaVersion.',
      );
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException(
        'No se encontro el bloque data en el respaldo.',
      );
    }

    final animalRaw = data['animals'];
    final loteRaw = data['lotes'];
    if (animalRaw is! List || loteRaw is! List) {
      throw const FormatException(
        'Las colecciones animals o lotes no son listas validas.',
      );
    }

    final animalDtos = animalRaw
        .map(
          (item) => AnimalDto.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false);
    final loteDtos = loteRaw
        .map((item) => LoteDto.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
    final agendaEntries = _decodeOptionalList(
      data['agenda'],
      AgendaEntry.fromJson,
    );
    final workers = _decodeOptionalList(
      data['workers'],
      WorkerProfile.fromJson,
    );
    final teams = _decodeOptionalList(data['teams'], WorkTeam.fromJson);
    final milkingSessions = _decodeOptionalList(
      data['milkingSessions'],
      MilkingSession.fromJson,
    );
    final milkingEntries = _decodeOptionalList(
      data['milkingEntries'],
      MilkingEntry.fromJson,
    );

    _validateUniqueUuids(
      values: animalDtos.map((e) => e.uuid),
      label: 'animals',
    );
    _validateUniqueUuids(values: loteDtos.map((e) => e.uuid), label: 'lotes');
    _validateUniqueUuids(
      values: agendaEntries.map((entry) => entry.id),
      label: 'agenda',
    );
    _validateUniqueUuids(
      values: workers.map((worker) => worker.id),
      label: 'workers',
    );
    _validateUniqueUuids(values: teams.map((team) => team.id), label: 'teams');
    _validateUniqueUuids(
      values: milkingSessions.map((session) => session.uuid),
      label: 'milkingSessions',
    );
    _validateUniqueUuids(
      values: milkingEntries.map((entry) => entry.uuid),
      label: 'milkingEntries',
    );

    final sessionUuids = milkingSessions.map((session) => session.uuid).toSet();
    for (final entry in milkingEntries) {
      if (!sessionUuids.contains(entry.sessionUuid)) {
        throw FormatException(
          'La entrada de ordeña ${entry.uuid} no tiene una sesión válida.',
        );
      }
    }

    return _DecodedBackup(
      animalDtos: animalDtos,
      loteDtos: loteDtos,
      agendaEntries: agendaEntries,
      workers: workers,
      teams: teams,
      milkingSessions: milkingSessions,
      milkingEntries: milkingEntries,
    );
  }

  /// Writes an already-decoded backup to the repositories and reports what
  /// was imported.
  Future<BackupImportSummary> _applyImport(
    _DecodedBackup decoded,
    BackupImportMode mode,
  ) async {
    if (mode == BackupImportMode.replaceAll) {
      await _animalRepository.clearAll();
      await _lotesRepository.clearAll();
      await _agendaRepository.replaceAll(decoded.agendaEntries);
      await _workforceRepository.replaceAll(
        workers: decoded.workers,
        teams: decoded.teams,
      );
      await _milkingRepository.replaceAll(
        sessions: decoded.milkingSessions,
        entries: decoded.milkingEntries,
      );
    }

    for (final dto in decoded.animalDtos) {
      final entity = dto.toEntity().copyWith(id: null);
      final existing = mode == BackupImportMode.merge
          ? await _animalRepository.getByUuid(entity.uuid)
          : null;

      if (existing == null) {
        await _animalRepository.save(entity);
      } else {
        await _animalRepository.update(entity.copyWith(id: existing.id));
      }
    }

    for (final dto in decoded.loteDtos) {
      final entity = dto.toEntity().copyWith(id: null);
      await _lotesRepository.upsert(entity);
    }

    if (mode == BackupImportMode.merge) {
      for (final entry in decoded.agendaEntries) {
        await _agendaRepository.saveEntry(entry);
      }
      for (final worker in decoded.workers) {
        await _workforceRepository.saveWorker(worker);
      }
      for (final team in decoded.teams) {
        await _workforceRepository.saveTeam(team);
      }
      for (final session in decoded.milkingSessions) {
        await _milkingRepository.upsertSession(session);
      }
      for (final entry in decoded.milkingEntries) {
        await _milkingRepository.upsertEntry(entry);
      }
    }

    return BackupImportSummary(
      mode: mode,
      animalsImported: decoded.animalDtos.length,
      lotesImported: decoded.loteDtos.length,
      agendaEntriesImported: decoded.agendaEntries.length,
      workersImported: decoded.workers.length,
      teamsImported: decoded.teams.length,
      milkingSessionsImported: decoded.milkingSessions.length,
      milkingEntriesImported: decoded.milkingEntries.length,
    );
  }

  List<T> _decodeOptionalList<T>(
    Object? raw,
    T Function(Map<String, dynamic>) decode,
  ) {
    if (raw == null) return <T>[];
    if (raw is! List) {
      throw const FormatException('Una coleccion del respaldo no es valida.');
    }
    return raw
        .map((item) => decode(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }

  void _validateUniqueUuids({
    required Iterable<String> values,
    required String label,
  }) {
    final seen = <String>{};
    for (final value in values) {
      if (value.trim().isEmpty) {
        throw FormatException('Se encontro un UUID vacio en $label.');
      }
      if (!seen.add(value)) {
        throw FormatException('UUID duplicado en $label: $value');
      }
    }
  }
}
