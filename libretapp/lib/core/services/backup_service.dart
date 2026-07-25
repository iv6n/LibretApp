/// core > services > backup_service - app data backup/import service for animals and lotes.
library;

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/data/workforce_model.dart';
import 'package:libretapp/features/agenda/data/workforce_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_dto.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository_isar.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lote_dto.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';

enum BackupImportMode { merge, replaceAll }

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
  });

  final BackupImportMode mode;
  final int animalsImported;
  final int lotesImported;
  final int agendaEntriesImported;
  final int workersImported;
  final int teamsImported;
  final int milkingSessionsImported;
  final int milkingEntriesImported;
}

class BackupService {
  BackupService({
    required AnimalRepository animalRepository,
    required LotesRepository lotesRepository,
    required AgendaRepository agendaRepository,
    required WorkforceRepository workforceRepository,
    required MilkingRepository milkingRepository,
  }) : _animalRepository = animalRepository,
       _lotesRepository = lotesRepository,
       _agendaRepository = agendaRepository,
       _workforceRepository = workforceRepository,
       _milkingRepository = milkingRepository;

  static const _schemaVersion = 3;

  final AnimalRepository _animalRepository;
  final LotesRepository _lotesRepository;
  final AgendaRepository _agendaRepository;
  final WorkforceRepository _workforceRepository;
  final MilkingRepository _milkingRepository;

  Future<String> exportToJsonString() async {
    final animalRepository = _animalRepository;
    final animals = animalRepository is AnimalRepositoryIsar
        ? await animalRepository.getAllIncludingArchived()
        : await animalRepository.getAll();
    final lotes = await _lotesRepository.getAll();
    final agendaEntries = await _agendaRepository.fetchEntries();
    final workers = await _workforceRepository.fetchWorkers(
      includeInactive: true,
    );
    final teams = await _workforceRepository.fetchTeams(includeInactive: true);
    final milkingSessions = await _milkingRepository.getAllSessions();
    final milkingEntries = await _milkingRepository.getAllEntries();

    final payload = <String, dynamic>{
      'schemaVersion': _schemaVersion,
      'appVersion': '1.0.0+1',
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
    final jsonContent = await exportToJsonString();
    final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
      ':',
      '-',
    );

    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar respaldo',
      fileName: 'libretapp-backup-$timestamp.json',
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );

    if (savePath == null || savePath.isEmpty) {
      return null;
    }

    final target = File(savePath);
    await target.writeAsString(jsonContent, flush: true);
    return target.path;
  }

  Future<BackupImportSummary?> importFromFile({
    required BackupImportMode mode,
  }) async {
    final picked = await FilePicker.platform.pickFiles(
      dialogTitle: 'Seleccionar respaldo',
      type: FileType.custom,
      allowedExtensions: const ['json'],
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
    final content = await source.readAsString();
    return importFromJsonString(content, mode: mode);
  }

  Future<BackupImportSummary> importFromJsonString(
    String raw, {
    required BackupImportMode mode,
  }) async {
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
    _validateUniqueUuids(
      values: teams.map((team) => team.id),
      label: 'teams',
    );
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

    if (mode == BackupImportMode.replaceAll) {
      await _animalRepository.clearAll();
      await _lotesRepository.clearAll();
      await _agendaRepository.replaceAll(agendaEntries);
      await _workforceRepository.replaceAll(workers: workers, teams: teams);
      await _milkingRepository.replaceAll(
        sessions: milkingSessions,
        entries: milkingEntries,
      );
    }

    for (final dto in animalDtos) {
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

    for (final dto in loteDtos) {
      final entity = dto.toEntity().copyWith(id: null);
      await _lotesRepository.upsert(entity);
    }

    if (mode == BackupImportMode.merge) {
      for (final entry in agendaEntries) {
        await _agendaRepository.saveEntry(entry);
      }
      for (final worker in workers) {
        await _workforceRepository.saveWorker(worker);
      }
      for (final team in teams) {
        await _workforceRepository.saveTeam(team);
      }
      for (final session in milkingSessions) {
        await _milkingRepository.upsertSession(session);
      }
      for (final entry in milkingEntries) {
        await _milkingRepository.upsertEntry(entry);
      }
    }

    return BackupImportSummary(
      mode: mode,
      animalsImported: animalDtos.length,
      lotesImported: loteDtos.length,
      agendaEntriesImported: agendaEntries.length,
      workersImported: workers.length,
      teamsImported: teams.length,
      milkingSessionsImported: milkingSessions.length,
      milkingEntriesImported: milkingEntries.length,
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
