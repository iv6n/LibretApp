/// Browser Excel export. The result is a data URL so the existing share
/// workflow can remain platform-neutral.
library;

import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:libretapp/core/services/exportable_sheet.dart';

class WebExportFile {
  const WebExportFile(this.path);
  final String path;
}

class ExportService {
  ExportService(Iterable<ExportableSheet> sheets)
      : sheets = _buildRegistry(sheets);

  final Map<String, ExportableSheet> sheets;

  static Map<String, ExportableSheet> _buildRegistry(
    Iterable<ExportableSheet> values,
  ) {
    final registry = <String, ExportableSheet>{};
    for (final sheet in values) {
      final key = sheet.key.trim();
      if (key.isEmpty || registry.containsKey(key)) {
        throw ArgumentError.value(key, 'sheets', 'Invalid or duplicate export key');
      }
      registry[key] = sheet;
    }
    return Map.unmodifiable(registry);
  }

  Future<WebExportFile> exportToExcel(Set<String> selectedKeys) async {
    if (selectedKeys.isEmpty) throw ArgumentError.value(selectedKeys, 'selectedKeys');
    final unknown = selectedKeys.difference(sheets.keys.toSet());
    if (unknown.isNotEmpty) throw ArgumentError.value(unknown, 'selectedKeys');
    final excel = Excel.createExcel();
    for (final entry in sheets.entries) {
      if (selectedKeys.contains(entry.key)) await entry.value.writeTo(excel);
    }
    excel.delete('Sheet1');
    final bytes = excel.save();
    if (bytes == null) throw StateError('No se pudo generar el archivo Excel.');
    return WebExportFile(
      'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,${base64Encode(bytes)}',
    );
  }
}
