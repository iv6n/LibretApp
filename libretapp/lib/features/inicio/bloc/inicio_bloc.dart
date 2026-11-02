/// features › inicio › bloc › inicio_bloc — BLoC for the home dashboard.
library;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/inicio/bloc/inicio_event.dart';
import 'package:libretapp/features/inicio/bloc/inicio_state.dart';
import 'package:libretapp/features/biblioteca/data/library_manifest.dart';
import 'package:libretapp/features/inicio/data/dashboard_quick_action.dart';
import 'package:libretapp/features/inicio/data/dashboard_widget_config.dart';
import 'package:libretapp/features/inicio/data/dashboard_config_repository.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_service.dart';
import 'package:libretapp/features/biblioteca/data/library_repository.dart';
import 'package:libretapp/features/finanzas/domain/finance_summary_service.dart';

class InicioBloc extends Bloc<InicioEvent, InicioState> {
  InicioBloc({
    required InicioDashboardService dashboardService,
    required DashboardConfigRepository configRepository,
    required FinanceSummaryService financeService,
    required LibraryRepository libraryRepository,
  }) : _dashboardService = dashboardService,
       _configRepository = configRepository,
       _financeService = financeService,
       _libraryRepository = libraryRepository,
       super(InicioState.initial()) {
    on<LoadInicio>(_onLoadInicio);
    on<RefreshInicio>(_onRefreshInicio);
    on<UpdateDashboardConfig>(_onUpdateConfig);
    on<InicioFinanceLoaded>(_onFinanceLoaded);
    on<InicioLibraryLoaded>(_onLibraryLoaded);
  }

  final InicioDashboardService _dashboardService;
  final DashboardConfigRepository _configRepository;
  final FinanceSummaryService _financeService;
  final LibraryRepository _libraryRepository;
  int _requestGeneration = 0;

  Future<void> _onLoadInicio(
    LoadInicio event,
    Emitter<InicioState> emit,
  ) async {
    await _loadData(emit, refreshing: state.data != null);
  }

  Future<void> _onRefreshInicio(
    RefreshInicio event,
    Emitter<InicioState> emit,
  ) async {
    await _loadData(emit, refreshing: true);
  }

  void _onUpdateConfig(UpdateDashboardConfig event, Emitter<InicioState> emit) {
    emit(
      state.copyWith(widgetConfigs: event.widgets, quickActions: event.actions),
    );
  }

  Future<void> _loadData(
    Emitter<InicioState> emit, {
    required bool refreshing,
  }) async {
    final requestId = ++_requestGeneration;
    emit(
      state.copyWith(
        status: refreshing ? InicioStatus.refreshing : InicioStatus.loading,
        errorMessage: null,
        financeLoading: true,
        libraryLoading: true,
        clearFinanceError: true,
        clearLibraryError: true,
      ),
    );

    // Start independent panels immediately. Their results are emitted as
    // separate events so slow or failing optional sources never hold the main
    // dashboard content behind them.
    final dashboardReady = Completer<void>();
    unawaited(_loadFinance(requestId, dashboardReady.future));
    unawaited(_loadLibrary(requestId, dashboardReady.future));

    try {
      final dashboardFuture = _dashboardService.loadDashboard();
      final dashboard = await dashboardFuture;
      final profile = _configRepository.resolveProfile(
        pets: dashboard.petCount,
        livestock: dashboard.livestockCount,
      );
      final configResults = await Future.wait<Object>([
        _configRepository.loadWidgets(profile: profile),
        _configRepository.loadQuickActions(profile: profile),
      ]);
      if (isClosed || requestId != _requestGeneration) return;

      emit(
        state.copyWith(
          status: InicioStatus.loaded,
          data: dashboard,
          widgetConfigs: configResults[0] as List<DashboardWidgetConfig>,
          quickActions: configResults[1] as List<DashboardQuickAction>,
          errorMessage: null,
        ),
      );
    } catch (error) {
      if (requestId != _requestGeneration) return;
      // Drop in-flight supplement results from an unsuccessful dashboard load.
      _requestGeneration++;
      emit(
        state.copyWith(
          status: InicioStatus.error,
          financeLoading: false,
          libraryLoading: false,
          errorMessage: 'No se pudo cargar el panel: $error',
        ),
      );
    } finally {
      if (!dashboardReady.isCompleted) dashboardReady.complete();
    }
  }

  Future<void> _loadFinance(int requestId, Future<void> dashboardReady) async {
    FinanceSummaryDetail? detail;
    String? errorMessage;
    try {
      detail = await _financeService.loadForPreset();
    } catch (error) {
      errorMessage = error.toString();
    }
    await dashboardReady;
    if (!isClosed && requestId == _requestGeneration) {
      add(
        InicioFinanceLoaded(
          requestId: requestId,
          detail: detail,
          error: errorMessage,
        ),
      );
    }
  }

  Future<void> _loadLibrary(int requestId, Future<void> dashboardReady) async {
    List<LibraryManifestBook>? items;
    String? errorMessage;
    try {
      items = await _libraryRepository.getAll();
    } catch (error) {
      errorMessage = error.toString();
    }
    await dashboardReady;
    if (!isClosed && requestId == _requestGeneration) {
      add(
        InicioLibraryLoaded(
          requestId: requestId,
          items: items,
          error: errorMessage,
        ),
      );
    }
  }

  void _onFinanceLoaded(InicioFinanceLoaded event, Emitter<InicioState> emit) {
    if (event.requestId != _requestGeneration || state.data == null) return;
    emit(
      state.copyWith(
        financeDetail: event.detail,
        financeLoading: false,
        financeErrorMessage: event.error,
        clearFinanceError: event.error == null,
      ),
    );
  }

  void _onLibraryLoaded(InicioLibraryLoaded event, Emitter<InicioState> emit) {
    if (event.requestId != _requestGeneration || state.data == null) return;
    emit(
      state.copyWith(
        libraryPicks: event.items?.take(5).toList(growable: false),
        libraryLoading: false,
        libraryErrorMessage: event.error,
        clearLibraryError: event.error == null,
      ),
    );
  }
}
