import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';

enum HerdImportField {
  uuid('UUID Animal'),
  earTag('Arete'),
  siniiga('SINIIGA'),
  visualId('Identificación visual'),
  rfid('RFID'),
  name('Nombre'),
  species('Especie'),
  category('Categoría'),
  sex('Sexo'),
  breed('Raza'),
  birthDate('Fecha de nacimiento'),
  birthPrecision('Precisión nacimiento'),
  ageMonths('Edad en meses'),
  weight('Peso en kg'),
  status('Estado'),
  healthStatus('Estado de salud'),
  owner('Propietario');

  const HerdImportField(this.label);
  final String label;
}

enum HerdImportAction { create, update, skip }

class HerdImportSourceRow {
  const HerdImportSourceRow(
    this.number,
    this.cells, {
    this.numericColumns = const {},
  });
  final int number;
  final List<String> cells;
  final Set<int> numericColumns;
}

class HerdImportDocument {
  const HerdImportDocument({
    required this.fileName,
    required this.headers,
    required this.rows,
  });
  final String fileName;
  final List<String> headers;
  final List<HerdImportSourceRow> rows;
}

class HerdImportChange {
  const HerdImportChange(this.field, this.before, this.after);
  final String field;
  final String before;
  final String after;
}

class HerdImportPreviewRow {
  const HerdImportPreviewRow({
    required this.number,
    required this.values,
    required this.errors,
    required this.warnings,
    required this.changes,
    this.current,
    this.proposed,
  });
  final int number;
  final Map<HerdImportField, String> values;
  final List<String> errors;
  final List<String> warnings;
  final List<HerdImportChange> changes;
  final AnimalEntity? current;
  final AnimalEntity? proposed;
  bool get isValid => errors.isEmpty && proposed != null;
  bool get isExisting => current != null;
  HerdImportPreviewRow withErrors(List<String> value) => HerdImportPreviewRow(
    number: number,
    values: values,
    errors: List.unmodifiable(value),
    warnings: warnings,
    changes: changes,
    current: current,
    proposed: proposed,
  );
  String get tag =>
      proposed?.earTagNumber ??
      values[HerdImportField.earTag] ??
      values[HerdImportField.siniiga] ??
      values[HerdImportField.rfid] ??
      'Sin identificación';
  HerdImportAction get defaultAction =>
      isValid && !isExisting ? HerdImportAction.create : HerdImportAction.skip;
}

class HerdImportPreview {
  const HerdImportPreview({
    required this.document,
    required this.mapping,
    required this.rows,
    required this.scope,
    this.farmId,
  });
  final HerdImportDocument document;
  final Map<HerdImportField, int> mapping;
  final List<HerdImportPreviewRow> rows;
  // A preview must never be committed through a different workspace service.
  final Object scope;
  final String? farmId;
  Map<int, HerdImportAction> get defaultActions => {
    for (final row in rows) row.number: row.defaultAction,
  };
  int get newCount =>
      rows.where((row) => row.isValid && !row.isExisting).length;
  int get existingCount =>
      rows.where((row) => row.isValid && row.isExisting).length;
  int get invalidCount => rows.where((row) => !row.isValid).length;
}

class HerdImportSummary {
  const HerdImportSummary({
    required this.created,
    required this.updated,
    required this.skipped,
  });
  final int created;
  final int updated;
  final int skipped;
}
