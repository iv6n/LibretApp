/// core > services > animal_excel_import_service — imports animals from the
/// "Animales" sheet produced by [ExportService.exportToExcel].
///
/// This is a lossy, best-effort import: the Excel export only carries the 12
/// identity/basic-status columns (see [ExportService]), not the full animal
/// record. Existing animals (matched by ear tag) only have those columns
/// updated — everything else (location, health/reproduction/movement
/// history, etc.) is left untouched. New animals get the same sensible
/// defaults as [QuickRegisterAnimalPage].
library;

import 'dart:io';

import 'package:excel/excel.dart' as xlsx;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/utils/id_generator.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';

class AnimalExcelImportSummary {
  const AnimalExcelImportSummary({
    required this.created,
    required this.updated,
    required this.warnings,
  });

  final int created;
  final int updated;

  /// Human-readable notes about rows that were skipped or had a value
  /// defaulted because it couldn't be parsed.
  final List<String> warnings;
}

class AnimalExcelImportService {
  AnimalExcelImportService({required AnimalRepository animalRepository})
    : _animalRepository = animalRepository;

  final AnimalRepository _animalRepository;

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  Future<AnimalExcelImportSummary?> importFromPickedFile() async {
    final picked = await FilePicker.platform.pickFiles(
      dialogTitle: 'Seleccionar Excel de animales',
      type: FileType.custom,
      allowedExtensions: const ['xlsx'],
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

    return importFromFile(File(path));
  }

  Future<AnimalExcelImportSummary> importFromFile(File file) async {
    final bytes = await file.readAsBytes();
    return importFromBytes(bytes);
  }

  Future<AnimalExcelImportSummary> importFromBytes(List<int> bytes) async {
    final workbook = xlsx.Excel.decodeBytes(bytes);
    final sheet =
        workbook.tables['Animales'] ?? workbook.tables.values.firstOrNull;
    if (sheet == null || sheet.rows.isEmpty) {
      throw const FormatException(
        'El archivo no tiene una hoja "Animales" con datos.',
      );
    }

    final existing = await _animalRepository.getAll();
    final byEarTag = {for (final a in existing) a.earTagNumber: a};

    var created = 0;
    var updated = 0;
    final warnings = <String>[];

    for (var i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      final rowNumber = i + 1; // 1-indexed, matching what a spreadsheet shows

      final earTag = _text(row, 0)?.trim();
      if (earTag == null || earTag.isEmpty) {
        warnings.add('Fila $rowNumber: sin N° de caravana, se omitió.');
        continue;
      }

      final customName = _text(row, 1);
      final species = _parseEnum(
        Species.values,
        _text(row, 2),
        Species.cattle,
        'especie',
        rowNumber,
        warnings,
      );
      final category = _parseEnum(
        Category.values,
        _text(row, 3),
        Category.other,
        'categoría',
        rowNumber,
        warnings,
      );
      final sex = _parseEnum(
        Sex.values,
        _text(row, 4),
        Sex.female,
        'sexo',
        rowNumber,
        warnings,
      );
      final breed = _text(row, 5) ?? '';
      final birthDate = _parseDate(_text(row, 6), rowNumber, warnings);
      final ageMonths = int.tryParse(_text(row, 7) ?? '') ?? 0;
      final weight = double.tryParse(_text(row, 8) ?? '');
      final status = _parseEnum(
        AnimalStatus.values,
        _text(row, 9),
        AnimalStatus.active,
        'estado',
        rowNumber,
        warnings,
      );
      final healthStatus = _parseEnum(
        HealthStatus.values,
        _text(row, 10),
        HealthStatus.unknown,
        'estado de salud',
        rowNumber,
        warnings,
      );
      final owner = _text(row, 11);

      final current = byEarTag[earTag];
      final now = DateTime.now();

      if (current != null) {
        final merged = current.copyWith(
          customName: customName?.isEmpty == true ? null : customName,
          species: species,
          category: category,
          sex: sex,
          breed: breed.isEmpty ? current.breed : breed,
          birthDate: birthDate ?? current.birthDate,
          ageMonths: ageMonths,
          weight: weight,
          status: status,
          healthStatus: healthStatus,
          owner: owner?.isEmpty == true ? null : owner,
        );
        await _animalRepository.update(merged);
        updated++;
        continue;
      }

      final resolvedBirthDate =
          birthDate ??
          now.subtract(Duration(days: ageMonths * 30));
      final lifeStage = AnimalTaxonomy.resolveLifeStage(
        species: species,
        sex: sex,
        ageMonths: ageMonths,
        category: category,
      );

      final newAnimal = AnimalEntity(
        uuid: 'ani-${generateId()}',
        earTagNumber: earTag,
        customName: (customName == null || customName.isEmpty)
            ? null
            : customName,
        species: species,
        category: category,
        lifeStage: lifeStage,
        sex: sex,
        breed: breed,
        birthDate: resolvedBirthDate,
        ageMonths: ageMonths,
        weight: weight,
        healthStatus: healthStatus,
        vaccinated: false,
        dewormed: false,
        hasVitamins: false,
        hasChronicIssues: false,
        reproductiveStatus: ReproductiveStatus.unknown,
        productionPurpose: ProductionPurpose.undefined,
        productionStage: ProductionStage.unknown,
        productionSystem: ProductionSystem.unknown,
        underObservation: false,
        requiresAttention: false,
        riskLevel: RiskLevel.low,
        gallery: const [],
        owner: (owner == null || owner.isEmpty) ? null : owner,
        status: status,
        synced: false,
        creationDate: now,
        lastUpdateDate: now,
      );
      await _animalRepository.save(newAnimal);
      created++;
    }

    return AnimalExcelImportSummary(
      created: created,
      updated: updated,
      warnings: warnings,
    );
  }

  String? _text(List<xlsx.Data?> row, int index) {
    if (index >= row.length) return null;
    return row[index]?.value?.toString();
  }

  DateTime? _parseDate(String? raw, int rowNumber, List<String> warnings) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return _dateFormat.parseStrict(raw.trim());
    } catch (_) {
      warnings.add(
        'Fila $rowNumber: fecha de nacimiento "$raw" no reconocida, se dejó sin definir.',
      );
      return null;
    }
  }

  T _parseEnum<T extends Enum>(
    List<T> values,
    String? raw,
    T fallback,
    String fieldLabel,
    int rowNumber,
    List<String> warnings,
  ) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    for (final value in values) {
      if (value.name == raw.trim()) return value;
    }
    warnings.add(
      'Fila $rowNumber: $fieldLabel "$raw" no reconocida, se usó "${fallback.name}".',
    );
    return fallback;
  }
}
