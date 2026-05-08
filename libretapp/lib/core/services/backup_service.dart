/// core > services > backup_service - app data backup/import service for animals and lotes.
library;

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_dto.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lote_dto.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

enum BackupImportMode { merge, replaceAll }

class BackupImportSummary {
  const BackupImportSummary({
    required this.mode,
    required this.animalsImported,
    required this.lotesImported,
  });

  final BackupImportMode mode;
  final int animalsImported;
  final int lotesImported;
}

class BackupService {
  BackupService({
    required AnimalRepository animalRepository,
    required LotesRepository lotesRepository,
  }) : _animalRepository = animalRepository,
       _lotesRepository = lotesRepository;

  static const _schemaVersion = 1;

  final AnimalRepository _animalRepository;
  final LotesRepository _lotesRepository;

  Future<String> exportToJsonString() async {
    final animals = await _animalRepository.getAll();
    final lotes = await _lotesRepository.getAll();

    final payload = <String, dynamic>{
      'schemaVersion': _schemaVersion,
      'appVersion': '1.0.0+1',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'data': {
        'animals': animals
            .map((e) => AnimalDto.fromEntity(e).toJson())
            .toList(),
        'lotes': lotes.map((e) => LoteDto.fromEntity(e).toJson()).toList(),
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

    _validateUniqueUuids(
      values: animalDtos.map((e) => e.uuid),
      label: 'animals',
    );
    _validateUniqueUuids(values: loteDtos.map((e) => e.uuid), label: 'lotes');

    if (mode == BackupImportMode.replaceAll) {
      await _animalRepository.clearAll();
      await _lotesRepository.clearAll();
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

    return BackupImportSummary(
      mode: mode,
      animalsImported: animalDtos.length,
      lotesImported: loteDtos.length,
    );
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
