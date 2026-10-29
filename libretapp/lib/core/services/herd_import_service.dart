import 'dart:convert';

import 'package:excel/excel.dart' as xlsx;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/database/write_transaction.dart';
import 'package:libretapp/core/services/herd_import_models.dart';
import 'package:libretapp/core/tenancy/tenancy.dart';
import 'package:libretapp/core/utils/number_parsing.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_identification.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:uuid/uuid.dart';

export 'herd_import_models.dart';

/// Parsing and preview never write. Only an explicit, reviewed selection is
/// committed, with identity and stale-data checks inside the write transaction.
class HerdImportService {
  HerdImportService({
    required AnimalRepository animals,
    required WriteTransactionRunner transactions,
    FarmContextRepository? context,
  }) : _animals = animals,
       _transactions = transactions,
       _context = context;

  final AnimalRepository _animals;
  final WriteTransactionRunner _transactions;
  final FarmContextRepository? _context;
  final _scope = Object();
  final _identification = AnimalIdentificationService();
  static const maxRows = 10000;

  Future<HerdImportDocument?> pickDocument() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Seleccionar hato',
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'csv', 'tsv'],
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty)
      throw const FormatException('El archivo está vacío o no se pudo leer.');
    return readDocument(bytes, fileName: file.name);
  }

  HerdImportDocument readDocument(List<int> bytes, {required String fileName}) {
    if (bytes.length > 20 * 1024 * 1024)
      throw const FormatException(
        'El archivo supera 20 MB. Divídelo en archivos más pequeños.',
      );
    final rows = <HerdImportSourceRow>[];
    if (fileName.toLowerCase().endsWith('.xlsx')) {
      final book = xlsx.Excel.decodeBytes(bytes);
      final sheet =
          book.tables['Animales'] ??
          book.tables.values.where((s) => s.rows.isNotEmpty).firstOrNull;
      if (sheet == null || sheet.rows.isEmpty)
        throw const FormatException(
          'El archivo no tiene una hoja con encabezados y animales.',
        );
      for (var i = 0; i < sheet.rows.length; i++) {
        final cells = sheet.rows[i];
        rows.add(
          HerdImportSourceRow(
            i + 1,
            [for (final cell in cells) _cellText(cell?.value)],
            numericColumns: {
              for (var j = 0; j < cells.length; j++)
                if (cells[j]?.value is xlsx.IntCellValue ||
                    cells[j]?.value is xlsx.DoubleCellValue)
                  j,
            },
          ),
        );
      }
    } else if (fileName.toLowerCase().endsWith('.csv') ||
        fileName.toLowerCase().endsWith('.tsv')) {
      final source = utf8.decode(bytes).replaceFirst(RegExp(r'^\uFEFF'), '');
      final delimiters = fileName.toLowerCase().endsWith('.tsv')
          ? ['\t']
          : [',', ';', '\t'];
      final counts = {for (final delimiter in delimiters) delimiter: 0};
      var quoted = false;
      for (var i = 0; i < source.length; i++) {
        final character = source[i];
        if (character == '"') {
          if (quoted && i + 1 < source.length && source[i + 1] == '"') {
            i++;
          } else {
            quoted = !quoted;
          }
        } else if (!quoted) {
          if (character == '\n' || character == '\r') break;
          if (counts.containsKey(character))
            counts[character] = counts[character]! + 1;
        }
      }
      delimiters.sort((a, b) => counts[b]!.compareTo(counts[a]!));
      final parsed = _csv(source, delimiters.first);
      for (var i = 0; i < parsed.length; i++) {
        rows.add(HerdImportSourceRow(i + 1, parsed[i]));
      }
    } else {
      throw const FormatException('Selecciona un archivo Excel (.xlsx) o CSV.');
    }
    final first = rows.indexWhere(
      (row) => row.cells.any((cell) => cell.trim().isNotEmpty),
    );
    if (first < 0) throw const FormatException('El archivo está vacío.');
    final data = rows
        .skip(first + 1)
        .where((row) => row.cells.any((cell) => cell.trim().isNotEmpty))
        .toList();
    if (data.isEmpty)
      throw const FormatException(
        'El archivo tiene encabezados, pero no contiene animales.',
      );
    if (data.length > maxRows)
      throw const FormatException(
        'Importa como máximo 10 000 filas por archivo.',
      );
    return HerdImportDocument(
      fileName: fileName,
      headers: rows[first].cells,
      rows: data,
    );
  }

  Map<HerdImportField, int> detectMapping(HerdImportDocument document) {
    final result = <HerdImportField, int>{};
    for (var i = 0; i < document.headers.length; i++) {
      final header = normalize(document.headers[i]);
      for (final field in HerdImportField.values) {
        if ((_aliases[field] ?? [normalize(field.label)]).contains(header))
          result.putIfAbsent(field, () => i);
      }
    }
    return result;
  }

  Future<HerdImportPreview> preview(
    HerdImportDocument document, {
    Map<HerdImportField, int>? mapping,
  }) async {
    final farmId = await _currentFarmId();
    final columns = Map<HerdImportField, int>.unmodifiable(
      mapping ?? detectMapping(document),
    );
    if (!columns.keys.any(_identityFields.contains))
      throw const FormatException(
        'Asigna una columna de arete, SINIIGA o RFID.',
      );
    if (columns.values.any((i) => i < 0 || i >= document.headers.length) ||
        columns.values.toSet().length != columns.length) {
      throw const FormatException(
        'Cada campo debe usar una columna diferente.',
      );
    }
    final existing = await _animals.getAllIncludingInactive();
    final identityIndex = _index(existing);
    final sourceValues = <int, Map<HerdImportField, String>>{};
    final occurrences = <String, Set<int>>{};
    for (final row in document.rows) {
      final values = {
        for (final entry in columns.entries)
          entry.key: entry.value < row.cells.length
              ? row.cells[entry.value].trim()
              : '',
      };
      sourceValues[row.number] = values;
      for (final key in _keys(values)) {
        occurrences.putIfAbsent(key, () => {}).add(row.number);
      }
    }
    final output = <HerdImportPreviewRow>[];
    for (final row in document.rows) {
      final values = sourceValues[row.number]!;
      final errors = <String>[];
      final warnings = <String>[];
      final keys = _keys(values);
      if (keys.isEmpty) errors.add('Falta arete, SINIIGA o RFID.');
      final duplicateRows = {for (final key in keys) ...occurrences[key]!}
        ..remove(row.number);
      if (duplicateRows.isNotEmpty)
        errors.add(
          'Identificación repetida en el archivo: filas ${(duplicateRows.toList()..sort()).join(', ')}.',
        );
      for (final field in _identityFields) {
        final value = values[field];
        if (value == null || value.isEmpty) continue;
        final type = field == HerdImportField.siniiga
            ? AnimalIdentifierType.siniiga
            : field == HerdImportField.rfid
            ? AnimalIdentifierType.rfid
            : AnimalIdentifierType.visualTag;
        errors.addAll(
          _identification
              .validate(AnimalIdentifier(type: type, value: value))
              .errors,
        );
        if (row.numericColumns.contains(columns[field])) {
          warnings.add(
            '${field.label} está guardado como número en Excel. Revisa sus ceros iniciales; usa texto para conservarlos.',
          );
        }
      }
      final matches = _matches(identityIndex, keys);
      if (matches.length > 1)
        errors.add(
          'Los identificadores corresponden a varios animales. Corrige la fila antes de importar.',
        );
      final current = matches.length == 1 ? matches.single : null;
      final externalUuid = values[HerdImportField.uuid];
      if (externalUuid != null && externalUuid.isNotEmpty) {
        final byUuid = existing
            .where((a) => a.uuid == externalUuid)
            .firstOrNull;
        if (byUuid != null && byUuid.uuid != current?.uuid)
          errors.add(
            'El UUID pertenece a otro animal. No se cambiará su identificación desde la importación.',
          );
      }
      AnimalEntity? proposed;
      final changes = <HerdImportChange>[];
      try {
        proposed = _propose(values, current);
        if (!_animalKeys(proposed).containsAll(_keys(values))) {
          errors.add(
            'Una identificación asignada no se puede conservar en esta combinación. Revisa las columnas de arete, SINIIGA e identificación visual.',
          );
        }
        if (current != null) {
          for (final field in [
            HerdImportField.earTag,
            HerdImportField.siniiga,
          ]) {
            final supplied = values[field];
            if (supplied != null &&
                supplied.isNotEmpty &&
                !_animalKeys(current).contains('tag:${_tag(supplied)}')) {
              errors.add(
                'Para cambiar el arete de un animal existente, edita su perfil. La importación conserva su identificación.',
              );
            }
          }
          if (proposed.species != current.species ||
              proposed.sex != current.sex) {
            errors.add(
              'Corrige la especie o el sexo desde el perfil para revisar su historial y genealogía.',
            );
          }
          if (!current.status.isInActiveHerd)
            errors.add(
              'El animal está vendido, fallecido o archivado. Su historia se conserva y no se reactiva desde la importación.',
            );
          changes.addAll(_changes(current, proposed));
        } else {
          if (values[HerdImportField.species]?.isNotEmpty != true)
            warnings.add(
              'Sin especie indicada: se usará ${proposed.species.displayName}.',
            );
          if (values[HerdImportField.sex]?.isNotEmpty != true)
            warnings.add(
              'Sin sexo indicado: se usará ${proposed.sex.displayName}. Revísalo antes de guardar.',
            );
        }
      } on FormatException catch (error) {
        errors.add(error.message);
      }
      output.add(
        HerdImportPreviewRow(
          number: row.number,
          values: Map.unmodifiable(values),
          errors: List.unmodifiable(errors),
          warnings: List.unmodifiable(warnings),
          changes: List.unmodifiable(changes),
          current: current,
          proposed: proposed,
        ),
      );
    }
    final primaryRows = <String, List<int>>{};
    for (final row in output) {
      final primary = row.proposed?.earTagNumber;
      if (primary != null && primary.trim().isNotEmpty)
        primaryRows.putIfAbsent(_tag(primary), () => []).add(row.number);
    }
    final reviewed = output
        .map((row) {
          final proposed = row.proposed;
          if (proposed == null) return row;
          final primary = _tag(proposed.earTagNumber);
          final errors = [...row.errors];
          if ((primaryRows[primary]?.length ?? 0) > 1 &&
              !errors.any((e) => e.contains('repetida'))) {
            errors.add(
              'Las filas ${primaryRows[primary]!.join(', ')} producirían el mismo arete principal. Revisa las identificaciones antes de importar.',
            );
          }
          if (_matches(identityIndex, {'tag:$primary'}).any(
            (a) =>
                a.uuid != row.current?.uuid && _tag(a.earTagNumber) == primary,
          )) {
            errors.add(
              'El arete principal propuesto ya pertenece a otro animal del hato. Revisa la columna de identificación.',
            );
          }
          return row.withErrors(errors);
        })
        .toList(growable: false);
    return HerdImportPreview(
      document: document,
      mapping: columns,
      rows: List.unmodifiable(reviewed),
      scope: _scope,
      farmId: farmId,
    );
  }

  Future<HerdImportSummary> commit(
    HerdImportPreview preview,
    Map<int, HerdImportAction> actions,
  ) async {
    if (!identical(preview.scope, _scope))
      throw StateError('Vuelve a abrir el archivo en esta finca.');
    final selected = preview.rows
        .where(
          (row) =>
              (actions[row.number] ?? HerdImportAction.skip) !=
              HerdImportAction.skip,
        )
        .toList();
    if (selected.isEmpty)
      throw StateError('Selecciona al menos una fila válida.');
    for (final row in selected) {
      final expected = row.isExisting
          ? HerdImportAction.update
          : HerdImportAction.create;
      if (!row.isValid || actions[row.number] != expected)
        throw StateError(
          'La fila ${row.number} no se puede importar con esa acción.',
        );
    }
    return _transactions.run(() async {
      if (await _currentFarmId() != preview.farmId)
        throw StateError(
          'La finca cambió. Genera una vista previa nueva antes de importar.',
        );
      final herd = await _animals.getAllIncludingInactive();
      final identityIndex = _index(herd);
      // Check every selected row before the first write. The transaction also
      // rolls back all earlier writes if storage fails halfway through.
      for (final row in selected) {
        final matches = _matches(identityIndex, _keys(row.values));
        final primary = _tag(row.proposed!.earTagNumber);
        final primaryConflict = _matches(identityIndex, {'tag:$primary'}).any(
          (a) => a.uuid != row.current?.uuid && _tag(a.earTagNumber) == primary,
        );
        if (primaryConflict ||
            (row.current == null
                ? matches.isNotEmpty
                : matches.length != 1 || matches.single != row.current)) {
          throw StateError(
            'El hato cambió desde la vista previa (fila ${row.number}). Actualiza la vista previa antes de guardar.',
          );
        }
      }
      var created = 0;
      var updated = 0;
      for (final row in selected) {
        if (row.current == null) {
          await _animals.save(row.proposed!);
          created++;
        } else {
          await _animals.update(row.proposed!);
          updated++;
        }
      }
      return HerdImportSummary(
        created: created,
        updated: updated,
        skipped: preview.rows.length - selected.length,
      );
    });
  }

  AnimalEntity _propose(
    Map<HerdImportField, String> values,
    AnimalEntity? current,
  ) {
    String? value(HerdImportField field) =>
        values[field]?.isNotEmpty == true ? values[field] : null;
    T pick<T extends Enum>(
      HerdImportField field,
      List<T> options,
      T fallback,
      String Function(T) label,
    ) {
      final raw = value(field);
      if (raw == null) return fallback;
      final found = options
          .where(
            (v) =>
                normalize(v.name) == normalize(raw) ||
                normalize(label(v)) == normalize(raw),
          )
          .firstOrNull;
      if (found == null)
        throw FormatException('${field.label}: "$raw" no es un valor válido.');
      return found;
    }

    final now = DateTime.now();
    final species = pick(
      HerdImportField.species,
      Species.values,
      current?.species ?? Species.cattle,
      (v) => v.displayName,
    );
    final sex = pick(
      HerdImportField.sex,
      Sex.values,
      current?.sex ?? Sex.female,
      (v) => v.displayName,
    );
    final category = pick(
      HerdImportField.category,
      Category.values,
      current?.category ?? Category.other,
      (v) => v.displayName,
    );
    final status = pick(
      HerdImportField.status,
      AnimalStatus.values,
      current?.status ?? AnimalStatus.active,
      (v) => v.displayName,
    );
    final health = pick(
      HerdImportField.healthStatus,
      HealthStatus.values,
      current?.healthStatus ?? HealthStatus.unknown,
      (v) => v.displayName,
    );
    var age = current?.ageMonths ?? 0;
    if (value(HerdImportField.ageMonths) case final String raw) {
      final parsed = int.tryParse(raw);
      if (parsed == null || parsed < 0 || parsed > 1200)
        throw const FormatException(
          'La edad debe ser un número entero de meses entre 0 y 1200.',
        );
      age = parsed;
    }
    var birth =
        current?.birthDate ?? DateTime(now.year, now.month - age, now.day);
    var precision =
        current?.birthDatePrecision ??
        (value(HerdImportField.ageMonths) == null
            ? BirthDatePrecision.unknown
            : BirthDatePrecision.estimated);
    if (value(HerdImportField.birthDate) case final String raw) {
      try {
        birth = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)
            ? DateFormat('yyyy-MM-dd').parseStrict(raw)
            : DateFormat('dd/MM/yyyy').parseStrict(raw);
      } catch (_) {
        throw const FormatException(
          'Fecha de nacimiento inválida. Usa dd/mm/aaaa o aaaa-mm-dd.',
        );
      }
      if (birth.isAfter(now))
        throw const FormatException(
          'El nacimiento no puede estar en el futuro.',
        );
      precision = BirthDatePrecision.exact;
      if (value(HerdImportField.ageMonths) == null)
        age =
            ((now.year - birth.year) * 12 +
                    now.month -
                    birth.month -
                    (now.day < birth.day ? 1 : 0))
                .clamp(0, 1200);
    }
    precision = pick(
      HerdImportField.birthPrecision,
      BirthDatePrecision.values,
      precision,
      (v) => switch (v) {
        BirthDatePrecision.exact => 'Exacta',
        BirthDatePrecision.estimated => 'Estimada',
        BirthDatePrecision.unknown => 'Desconocida',
      },
    );
    if (precision == BirthDatePrecision.exact &&
        value(HerdImportField.birthDate) == null &&
        current?.birthDatePrecision != BirthDatePrecision.exact)
      throw const FormatException(
        'Una fecha exacta requiere fecha de nacimiento.',
      );
    var weight = current?.weight;
    if (value(HerdImportField.weight) case final String raw) {
      weight = parseFormDouble(raw);
      if (weight == null || !weight.isFinite || weight <= 0)
        throw const FormatException('El peso debe ser mayor que cero.');
    }
    final lifeStage = AnimalTaxonomy.resolveLifeStage(
      species: species,
      sex: sex,
      ageMonths: age,
      category: category,
    );
    if (current != null)
      return current.copyWith(
        customName: value(HerdImportField.name) ?? current.customName,
        visualId: value(HerdImportField.visualId) ?? current.visualId,
        rfidTag: value(HerdImportField.rfid) ?? current.rfidTag,
        species: species,
        sex: sex,
        category: category,
        lifeStage: lifeStage,
        breed: value(HerdImportField.breed) ?? current.breed,
        birthDate: birth,
        birthDatePrecision: precision,
        ageMonths: age,
        weight: weight,
        status: status,
        healthStatus: health,
        owner: value(HerdImportField.owner) ?? current.owner,
      );
    final tag =
        value(HerdImportField.siniiga) ??
        value(HerdImportField.earTag) ??
        value(HerdImportField.rfid) ??
        value(HerdImportField.visualId) ??
        '';
    return AnimalEntity(
      uuid: 'ani-${const Uuid().v4()}',
      earTagNumber: tag,
      customName: value(HerdImportField.name),
      visualId:
          value(HerdImportField.visualId) ??
          (value(HerdImportField.siniiga) != null
              ? value(HerdImportField.earTag)
              : null),
      rfidTag: value(HerdImportField.rfid),
      species: species,
      category: category,
      lifeStage: lifeStage,
      sex: sex,
      breed: value(HerdImportField.breed) ?? '',
      birthDate: birth,
      birthDatePrecision: precision,
      ageMonths: age,
      weight: weight,
      status: status,
      healthStatus: health,
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
      owner: value(HerdImportField.owner),
      synced: false,
      creationDate: now,
      lastUpdateDate: now,
    );
  }

  Future<String?> _currentFarmId() async {
    if (_context == null) return null;
    final current = await _context.current();
    if (current == null || !current.membership.role.canOperate)
      throw StateError(
        'Abre una finca con permiso de captura para importar el hato.',
      );
    return current.farmId;
  }

  static const _identityFields = {
    HerdImportField.earTag,
    HerdImportField.siniiga,
    HerdImportField.rfid,
    HerdImportField.visualId,
  };
  static String _tag(String value) => value.trim().toLowerCase();
  static String _rfid(String value) => AnimalIdentifier(
    type: AnimalIdentifierType.rfid,
    value: value,
  ).normalized;
  static Set<String> _keys(Map<HerdImportField, String> values) => {
    for (final field in [
      HerdImportField.earTag,
      HerdImportField.siniiga,
      HerdImportField.visualId,
    ])
      if (values[field]?.isNotEmpty == true) 'tag:${_tag(values[field]!)}',
    if (values[HerdImportField.rfid]?.isNotEmpty == true)
      'rfid:${_rfid(values[HerdImportField.rfid]!)}',
  };
  static Set<String> _animalKeys(AnimalEntity animal) => {
    if (animal.earTagNumber.trim().isNotEmpty)
      'tag:${_tag(animal.earTagNumber)}',
    if (animal.visualId?.trim().isNotEmpty == true)
      'tag:${_tag(animal.visualId!)}',
    if (animal.rfidTag?.trim().isNotEmpty == true)
      'rfid:${_rfid(animal.rfidTag!)}',
  };

  static Map<String, List<AnimalEntity>> _index(
    Iterable<AnimalEntity> animals,
  ) {
    final index = <String, List<AnimalEntity>>{};
    for (final animal in animals) {
      for (final key in _animalKeys(animal)) {
        index.putIfAbsent(key, () => []).add(animal);
      }
    }
    return index;
  }

  static List<AnimalEntity> _matches(
    Map<String, List<AnimalEntity>> index,
    Set<String> keys,
  ) => {
    for (final key in keys)
      for (final animal in index[key] ?? const <AnimalEntity>[])
        animal.uuid: animal,
  }.values.toList(growable: false);

  static List<HerdImportChange> _changes(AnimalEntity a, AnimalEntity b) {
    final result = <HerdImportChange>[];
    void add(String field, Object? before, Object? after) {
      if (before != after)
        result.add(
          HerdImportChange(
            field,
            '${before ?? 'Sin dato'}',
            '${after ?? 'Sin dato'}',
          ),
        );
    }

    add('Nombre', a.customName, b.customName);
    add('Identificación visual', a.visualId, b.visualId);
    add('RFID', a.rfidTag, b.rfidTag);
    add('Especie', a.species.displayName, b.species.displayName);
    add('Sexo', a.sex.displayName, b.sex.displayName);
    add('Categoría', a.category.displayName, b.category.displayName);
    add('Raza', a.breed, b.breed);
    add(
      'Nacimiento',
      DateFormat('dd/MM/yyyy').format(a.birthDate),
      DateFormat('dd/MM/yyyy').format(b.birthDate),
    );
    add(
      'Precisión nacimiento',
      a.birthDatePrecision.name,
      b.birthDatePrecision.name,
    );
    add('Edad en meses', a.ageMonths, b.ageMonths);
    add('Peso', a.weight, b.weight);
    add('Estado', a.status.displayName, b.status.displayName);
    add('Salud', a.healthStatus.displayName, b.healthStatus.displayName);
    add('Propietario', a.owner, b.owner);
    return result;
  }

  static String normalize(String source) {
    var result = source.trim().toLowerCase();
    const accents = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };
    for (final entry in accents.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static String _cellText(xlsx.CellValue? value) => switch (value) {
    xlsx.DateCellValue() => DateFormat(
      'yyyy-MM-dd',
    ).format(value.asDateTimeLocal()),
    xlsx.DateTimeCellValue() => DateFormat(
      'yyyy-MM-dd',
    ).format(value.asDateTimeLocal()),
    xlsx.DoubleCellValue() =>
      value.value == value.value.truncateToDouble()
          ? value.value.toInt().toString()
          : value.value.toString(),
    _ => value?.toString() ?? '',
  };

  static List<List<String>> _csv(String source, String delimiter) {
    final rows = <List<String>>[];
    var row = <String>[];
    var cell = StringBuffer();
    var quoted = false;
    for (var i = 0; i < source.length; i++) {
      final c = source[i];
      if (c == '"') {
        if (quoted && i + 1 < source.length && source[i + 1] == '"') {
          cell.write('"');
          i++;
        } else if (quoted || cell.isEmpty) {
          quoted = !quoted;
        } else {
          throw const FormatException(
            'CSV inválido: comillas dentro de un campo sin delimitar.',
          );
        }
      } else if (!quoted && c == delimiter) {
        row.add(cell.toString());
        cell = StringBuffer();
      } else if (!quoted && (c == '\n' || c == '\r')) {
        row.add(cell.toString());
        rows.add(row);
        row = [];
        cell = StringBuffer();
        if (c == '\r' && i + 1 < source.length && source[i + 1] == '\n') i++;
      } else {
        cell.write(c);
      }
    }
    if (quoted)
      throw const FormatException(
        'CSV inválido: falta cerrar una celda entre comillas.',
      );
    row.add(cell.toString());
    rows.add(row);
    return rows;
  }

  static const _aliases = <HerdImportField, List<String>>{
    HerdImportField.uuid: ['uuidanimal', 'uuid'],
    HerdImportField.earTag: [
      'arete',
      'ear_tag',
      'eartag',
      'eartagnumber',
      'ncaravana',
      'caravana',
      'identificacion',
      'numeroarete',
    ],
    HerdImportField.siniiga: ['siniiga', 'siniigaid'],
    HerdImportField.visualId: [
      'visualid',
      'identificacionvisual',
      'aretevisual',
    ],
    HerdImportField.rfid: ['rfid', 'rfidtag', 'eid', 'epc'],
    HerdImportField.name: ['nombre', 'name', 'customname'],
    HerdImportField.species: ['especie', 'species'],
    HerdImportField.category: ['categoria', 'category'],
    HerdImportField.sex: ['sexo', 'sex'],
    HerdImportField.breed: ['raza', 'breed'],
    HerdImportField.birthDate: [
      'fechanac',
      'fechanacimiento',
      'birthdate',
      'nacimiento',
    ],
    HerdImportField.birthPrecision: [
      'precisionnacimiento',
      'birthdateprecision',
    ],
    HerdImportField.ageMonths: ['edadmeses', 'edad', 'agemonths'],
    HerdImportField.weight: ['pesokg', 'peso', 'weight', 'weightkg'],
    HerdImportField.status: ['estado', 'status'],
    HerdImportField.healthStatus: [
      'estadosalud',
      'estadodesalud',
      'healthstatus',
    ],
    HerdImportField.owner: ['propietario', 'owner'],
  };
}
