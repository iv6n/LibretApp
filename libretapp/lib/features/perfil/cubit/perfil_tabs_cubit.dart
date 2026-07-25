/// features › perfil › cubit › perfil_tabs_cubit — lazy-loads tab summaries.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/perfil/data/library_item.dart';
import 'package:libretapp/features/perfil/data/library_repository.dart';
import 'package:libretapp/features/perfil/data/report_summary.dart';
import 'package:libretapp/features/perfil/domain/finance_summary_service.dart';
import 'package:libretapp/features/perfil/domain/report_summary_service.dart';

enum PerfilTabLoadStatus { initial, loading, loaded, error }

class PerfilTabsState extends Equatable {
  const PerfilTabsState({
    this.reportStatus = PerfilTabLoadStatus.initial,
    this.financeStatus = PerfilTabLoadStatus.initial,
    this.libraryStatus = PerfilTabLoadStatus.initial,
    this.reportSummary,
    this.financeDetail,
    this.libraryItems = const [],
    this.libraryQuery = '',
    this.errorMessage,
  });

  final PerfilTabLoadStatus reportStatus;
  final PerfilTabLoadStatus financeStatus;
  final PerfilTabLoadStatus libraryStatus;
  final ReportSummary? reportSummary;
  final FinanceSummaryDetail? financeDetail;
  final List<LibraryItem> libraryItems;
  final String libraryQuery;
  final String? errorMessage;

  PerfilTabsState copyWith({
    PerfilTabLoadStatus? reportStatus,
    PerfilTabLoadStatus? financeStatus,
    PerfilTabLoadStatus? libraryStatus,
    ReportSummary? reportSummary,
    FinanceSummaryDetail? financeDetail,
    List<LibraryItem>? libraryItems,
    String? libraryQuery,
    String? errorMessage,
  }) {
    return PerfilTabsState(
      reportStatus: reportStatus ?? this.reportStatus,
      financeStatus: financeStatus ?? this.financeStatus,
      libraryStatus: libraryStatus ?? this.libraryStatus,
      reportSummary: reportSummary ?? this.reportSummary,
      financeDetail: financeDetail ?? this.financeDetail,
      libraryItems: libraryItems ?? this.libraryItems,
      libraryQuery: libraryQuery ?? this.libraryQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    reportStatus,
    financeStatus,
    libraryStatus,
    reportSummary,
    financeDetail,
    libraryItems,
    libraryQuery,
    errorMessage,
  ];
}

class PerfilTabsCubit extends Cubit<PerfilTabsState> {
  PerfilTabsCubit({
    required ReportSummaryService reportService,
    required FinanceSummaryService financeService,
    required LibraryRepository libraryRepository,
  }) : _reportService = reportService,
       _financeService = financeService,
       _libraryRepository = libraryRepository,
       super(const PerfilTabsState());

  final ReportSummaryService _reportService;
  final FinanceSummaryService _financeService;
  final LibraryRepository _libraryRepository;

  Future<void> loadReportes() async {
    if (state.reportStatus == PerfilTabLoadStatus.loaded) return;
    emit(state.copyWith(reportStatus: PerfilTabLoadStatus.loading));
    try {
      final summary = await _reportService.loadSummary();
      emit(
        state.copyWith(
          reportStatus: PerfilTabLoadStatus.loaded,
          reportSummary: summary,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          reportStatus: PerfilTabLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadFinanzas() async {
    if (state.financeStatus == PerfilTabLoadStatus.loaded) return;
    emit(state.copyWith(financeStatus: PerfilTabLoadStatus.loading));
    try {
      final detail = await _financeService.loadForPreset();
      emit(
        state.copyWith(
          financeStatus: PerfilTabLoadStatus.loaded,
          financeDetail: detail,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          financeStatus: PerfilTabLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refreshReportes() async {
    emit(state.copyWith(reportStatus: PerfilTabLoadStatus.loading));
    try {
      final summary = await _reportService.loadSummary();
      emit(
        state.copyWith(
          reportStatus: PerfilTabLoadStatus.loaded,
          reportSummary: summary,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          reportStatus: PerfilTabLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refreshFinanzas() async {
    emit(state.copyWith(financeStatus: PerfilTabLoadStatus.loading));
    try {
      final detail = await _financeService.loadForPreset();
      emit(
        state.copyWith(
          financeStatus: PerfilTabLoadStatus.loaded,
          financeDetail: detail,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          financeStatus: PerfilTabLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadBiblioteca({String query = ''}) async {
    emit(
      state.copyWith(
        libraryStatus: PerfilTabLoadStatus.loading,
        libraryQuery: query,
      ),
    );
    try {
      final items = query.trim().isEmpty
          ? await _libraryRepository.getAll()
          : await _libraryRepository.search(query);
      emit(
        state.copyWith(
          libraryStatus: PerfilTabLoadStatus.loaded,
          libraryItems: items,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          libraryStatus: PerfilTabLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
