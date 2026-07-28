/// features › reportes › cubit › reportes_cubit — lazy-loads report/finance summaries.
///
/// Owns only the reportes tabs' state. Split out of the old shared
/// `PerfilTabsCubit` so `reportes/` no longer depends on `perfil/`'s cubit.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/finanzas/domain/finance_summary_service.dart';
import 'package:libretapp/features/reportes/data/report_summary.dart';
import 'package:libretapp/features/reportes/domain/report_summary_service.dart';

enum ReportesLoadStatus { initial, loading, loaded, error }

class ReportesState extends Equatable {
  const ReportesState({
    this.reportStatus = ReportesLoadStatus.initial,
    this.financeStatus = ReportesLoadStatus.initial,
    this.reportSummary,
    this.financeDetail,
    this.errorMessage,
  });

  final ReportesLoadStatus reportStatus;
  final ReportesLoadStatus financeStatus;
  final ReportSummary? reportSummary;
  final FinanceSummaryDetail? financeDetail;
  final String? errorMessage;

  ReportesState copyWith({
    ReportesLoadStatus? reportStatus,
    ReportesLoadStatus? financeStatus,
    ReportSummary? reportSummary,
    FinanceSummaryDetail? financeDetail,
    String? errorMessage,
  }) {
    return ReportesState(
      reportStatus: reportStatus ?? this.reportStatus,
      financeStatus: financeStatus ?? this.financeStatus,
      reportSummary: reportSummary ?? this.reportSummary,
      financeDetail: financeDetail ?? this.financeDetail,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    reportStatus,
    financeStatus,
    reportSummary,
    financeDetail,
    errorMessage,
  ];
}

class ReportesCubit extends Cubit<ReportesState> {
  ReportesCubit({
    required ReportSummaryService reportService,
    required FinanceSummaryService financeService,
  }) : _reportService = reportService,
       _financeService = financeService,
       super(const ReportesState());

  final ReportSummaryService _reportService;
  final FinanceSummaryService _financeService;

  Future<void> loadReportes() async {
    if (state.reportStatus == ReportesLoadStatus.loaded) return;
    emit(state.copyWith(reportStatus: ReportesLoadStatus.loading));
    try {
      final summary = await _reportService.loadSummary();
      emit(
        state.copyWith(
          reportStatus: ReportesLoadStatus.loaded,
          reportSummary: summary,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          reportStatus: ReportesLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadFinanzas() async {
    if (state.financeStatus == ReportesLoadStatus.loaded) return;
    emit(state.copyWith(financeStatus: ReportesLoadStatus.loading));
    try {
      final detail = await _financeService.loadForPreset();
      emit(
        state.copyWith(
          financeStatus: ReportesLoadStatus.loaded,
          financeDetail: detail,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          financeStatus: ReportesLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refreshReportes() async {
    emit(state.copyWith(reportStatus: ReportesLoadStatus.loading));
    try {
      final summary = await _reportService.loadSummary();
      emit(
        state.copyWith(
          reportStatus: ReportesLoadStatus.loaded,
          reportSummary: summary,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          reportStatus: ReportesLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refreshFinanzas() async {
    emit(state.copyWith(financeStatus: ReportesLoadStatus.loading));
    try {
      final detail = await _financeService.loadForPreset();
      emit(
        state.copyWith(
          financeStatus: ReportesLoadStatus.loaded,
          financeDetail: detail,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          financeStatus: ReportesLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
