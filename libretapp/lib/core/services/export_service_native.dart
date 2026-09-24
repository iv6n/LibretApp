/// core › services › export_service — exports app data to an Excel (.xlsx) file.
///
/// Owns no feature-specific repositories — each exportable section is an
/// [ExportableSheet] injected from its own feature (see
/// AnimalesExportSheet/UbicacionesExportSheet/EventosExportSheet). Adding a
/// new exportable section means adding a new [ExportableSheet] and wiring it
/// in DI, not modifying this file.
library;

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/services/exportable_sheet.dart';
import 'package:path_provider/path_provider.dart';

class ExportService {
  ExportService(Iterable<ExportableSheet> sheets)
    : sheets = _buildRegistry(sheets);

  final Map<String, ExportableSheet> sheets;

  static Map<String, ExportableSheet> _buildRegistry(
    Iterable<ExportableSheet> sheets,
  ) {
    final registry = <String, ExportableSheet>{};
    for (final sheet in sheets) {
      final key = sheet.key.trim();
      if (key.isEmpty) {
        throw ArgumentError.value(sheet.key, 'sheet.key', 'Must not be empty');
      }
      if (registry.containsKey(key)) {
        throw ArgumentError.value(key, 'sheets', 'Duplicate export key');
      }
      registry[key] = sheet;
    }
    return Map.unmodifiable(registry);
  }

  /// Generates a .xlsx file with the selected sheets and returns its [File].
  Future<File> exportToExcel(Set<String> selectedKeys) async {
    if (selectedKeys.isEmpty) {
      throw ArgumentError.value(
        selectedKeys,
        'selectedKeys',
        'Select at least one export sheet',
      );
    }
    final unknown = selectedKeys.difference(sheets.keys.toSet());
    if (unknown.isNotEmpty) {
      throw ArgumentError.value(
        unknown,
        'selectedKeys',
        'Unknown export sheet keys',
      );
    }

    final excel = Excel.createExcel();
    for (final entry in sheets.entries) {
      if (selectedKeys.contains(entry.key)) await entry.value.writeTo(excel);
    }
    // The package refuses to delete its only sheet. Remove the placeholder
    // after at least one real export sheet has been created.
    excel.delete('Sheet1');

    final bytes = excel.save();
    if (bytes == null) {
      throw StateError('No se pudo generar el archivo Excel.');
    }

    final dir = await getTemporaryDirectory();
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final file = File('${dir.path}/libretapp_export_$dateStr.xlsx');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}


