/// Typed identifiers used by the identification workflow.
library;

import 'package:equatable/equatable.dart';

enum AnimalIdentifierType { visualTag, siniiga, rfid, upp }

class AnimalIdentifier extends Equatable {
  const AnimalIdentifier({required this.type, required this.value, this.issuer});
  final AnimalIdentifierType type;
  final String value;
  final String? issuer;

  String get normalized => switch (type) {
    AnimalIdentifierType.rfid => value.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), ''),
    _ => value.trim(),
  };

  Map<String, dynamic> toJson() => {'type': type.name, 'value': value, 'issuer': issuer};
  factory AnimalIdentifier.fromJson(Map<String, dynamic> json) => AnimalIdentifier(
    type: AnimalIdentifierType.values.byName(json['type'] as String),
    value: json['value'] as String,
    issuer: json['issuer'] as String?,
  );

  @override
  List<Object?> get props => [type, normalized, issuer];
}

class IdentificationValidation {
  const IdentificationValidation({this.errors = const [], this.warnings = const []});
  final List<String> errors;
  final List<String> warnings;
  bool get isValid => errors.isEmpty;
}

class AnimalImportRow {
  const AnimalImportRow({required this.rowNumber, required this.values});
  final int rowNumber;
  final Map<String, String> values;
}

class AnimalImportResult {
  const AnimalImportResult({required this.validRows, required this.invalidRows, required this.duplicates});
  final List<AnimalImportRow> validRows;
  final Map<int, List<String>> invalidRows;
  final Map<int, List<String>> duplicates;
  bool get canImport => invalidRows.isEmpty && duplicates.isEmpty && validRows.isNotEmpty;
}

class AnimalIdentificationService {
  IdentificationValidation validate(AnimalIdentifier identifier) {
    final value = identifier.normalized;
    if (value.isEmpty) return const IdentificationValidation(errors: ['El identificador está vacío.']);
    if (identifier.type == AnimalIdentifierType.siniiga && !RegExp(r'^\d{12,18}$').hasMatch(value)) {
      return const IdentificationValidation(errors: ['El SINIIGA debe conservar sus ceros y contener de 12 a 18 dígitos.']);
    }
    if (identifier.type == AnimalIdentifierType.upp && value.length < 3) {
      return const IdentificationValidation(errors: ['El UPP debe tener al menos 3 caracteres.']);
    }
    return const IdentificationValidation();
  }

  IdentificationValidation validateUnique(AnimalIdentifier identifier, Iterable<AnimalIdentifier> existing) {
    final result = validate(identifier);
    if (!result.isValid) return result;
    final duplicate = existing.any((candidate) => candidate.type == identifier.type && candidate.normalized == identifier.normalized);
    return duplicate ? IdentificationValidation(errors: ['El identificador ya está asignado a otro animal.']) : result;
  }

  AnimalImportResult previewImport({required List<AnimalImportRow> rows, required Iterable<AnimalIdentifier> existing}) {
    final valid = <AnimalImportRow>[];
    final invalid = <int, List<String>>{};
    final duplicates = <int, List<String>>{};
    final seen = <String>{...existing.map((i) => '${i.type.name}:${i.normalized}')};
    for (final row in rows) {
      final tag = _identifierFromRow(row.values);
      if (tag == null) {
        invalid[row.rowNumber] = ['Falta arete visual, SINIIGA o RFID.'];
        continue;
      }
      final validation = validate(tag);
      if (!validation.isValid) {
        invalid[row.rowNumber] = validation.errors;
        continue;
      }
      final key = '${tag.type.name}:${tag.normalized}';
      if (!seen.add(key)) {
        duplicates[row.rowNumber] = ['Identificador duplicado en el archivo o en la finca.'];
      } else {
        valid.add(row);
      }
    }
    return AnimalImportResult(validRows: valid, invalidRows: invalid, duplicates: duplicates);
  }

  AnimalIdentifier? _identifierFromRow(Map<String, String> values) {
    for (final candidate in [
      (AnimalIdentifierType.siniiga, ['siniiga', 'siniiga_id']),
      (AnimalIdentifierType.rfid, ['rfid', 'epc']),
      (AnimalIdentifierType.visualTag, ['arete', 'arete_visual', 'ear_tag']),
    ]) {
      for (final key in candidate.$2) {
        final value = values[key]?.trim();
        if (value != null && value.isNotEmpty) return AnimalIdentifier(type: candidate.$1, value: value);
      }
    }
    return null;
  }
}
