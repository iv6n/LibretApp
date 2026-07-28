/// core › services › exportable_sheet — plugin contract for ExportService.
///
/// Each feature that wants its data included in the Excel export owns its
/// own [ExportableSheet] implementation and the repository it reads from.
/// [ExportService] only depends on this interface, not on any concrete
/// feature repository — new exportable sections are added by writing a new
/// implementation and wiring it in DI, without modifying core.
library;

import 'package:excel/excel.dart';

abstract class ExportableSheet {
  /// Reads its feature's data and writes it into [excel] as a new sheet.
  Future<void> writeTo(Excel excel);
}

/// Shared cell-writing helper for [ExportableSheet] implementations.
void writeExcelRow(
  Sheet sheet,
  int rowIndex,
  List<Object?> values, {
  bool header = false,
}) {
  for (var col = 0; col < values.length; col++) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex),
    );
    final value = values[col];
    if (value is int) {
      cell.value = IntCellValue(value);
    } else if (value is double) {
      cell.value = DoubleCellValue(value);
    } else {
      cell.value = TextCellValue(value?.toString() ?? '');
    }
    if (header) {
      cell.cellStyle = CellStyle(bold: true);
    }
  }
}
