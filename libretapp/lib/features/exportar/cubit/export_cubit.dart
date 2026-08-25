/// features › exportar › cubit › export_cubit — manages export workflow.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/services/export_service.dart';
import 'package:libretapp/core/services/exportable_sheet.dart';
import 'package:libretapp/features/exportar/cubit/export_state.dart';

class ExportCubit extends Cubit<ExportState> {
  ExportCubit(this._exportService) : super(const ExportIdle());

  final ExportService _exportService;
  List<ExportableSheet> get sheets =>
      List.unmodifiable(_exportService.sheets.values);

  Future<void> export(Set<String> selectedKeys) async {
    if (selectedKeys.isEmpty) {
      emit(const ExportError('Selecciona al menos una sección para exportar.'));
      return;
    }

    emit(const ExportLoading());
    try {
      final file = await _exportService.exportToExcel(selectedKeys);
      emit(ExportSuccess(file.path));
    } catch (e) {
      emit(ExportError('Error al generar el archivo: $e'));
    }
  }

  void reset() => emit(const ExportIdle());
}
