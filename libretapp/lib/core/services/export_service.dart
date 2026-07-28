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
  ExportService({
    required ExportableSheet animalsSheet,
    required ExportableSheet ubicacionesSheet,
    required ExportableSheet eventosSheet,
  }) : _animalsSheet = animalsSheet,
       _ubicacionesSheet = ubicacionesSheet,
       _eventosSheet = eventosSheet;

  final ExportableSheet _animalsSheet;
  final ExportableSheet _ubicacionesSheet;
  final ExportableSheet _eventosSheet;

  /// Generates a .xlsx file with the selected sheets and returns its [File].
  Future<File> exportToExcel({
    bool animals = true,
    bool ubicaciones = true,
    bool eventos = true,
  }) async {
    final excel = Excel.createExcel();
    // Remove the default empty sheet that excel package adds.
    excel.delete('Sheet1');

    if (animals) {
      await _animalsSheet.writeTo(excel);
    }
    if (ubicaciones) {
      await _ubicacionesSheet.writeTo(excel);
    }
    if (eventos) {
      await _eventosSheet.writeTo(excel);
    }

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
