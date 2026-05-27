/// features › exportar › cubit › export_cubit — manages export workflow.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/services/export_service.dart';
import 'package:libretapp/features/exportar/cubit/export_state.dart';

class ExportCubit extends Cubit<ExportState> {
  ExportCubit(this._exportService) : super(const ExportIdle());

  final ExportService _exportService;

  Future<void> export({
    required bool animals,
    required bool ubicaciones,
    required bool eventos,
  }) async {
    if (!animals && !ubicaciones && !eventos) {
      emit(const ExportError('Selecciona al menos una sección para exportar.'));
      return;
    }

    emit(const ExportLoading());
    try {
      final file = await _exportService.exportToExcel(
        animals: animals,
        ubicaciones: ubicaciones,
        eventos: eventos,
      );
      emit(ExportSuccess(file.path));
    } catch (e) {
      emit(ExportError('Error al generar el archivo: $e'));
    }
  }

  void reset() => emit(const ExportIdle());
}
