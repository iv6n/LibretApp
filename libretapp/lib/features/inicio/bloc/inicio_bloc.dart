/// features › inicio › bloc › inicio_bloc — BLoC for the home dashboard.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/inicio/bloc/inicio_event.dart';
import 'package:libretapp/features/inicio/bloc/inicio_state.dart';
import 'package:libretapp/features/inicio/data/dashboard_config_repository.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_service.dart';
import 'package:libretapp/features/perfil/data/library_repository.dart';
import 'package:libretapp/features/perfil/domain/finance_summary_service.dart';

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
  }

  final InicioDashboardService _dashboardService;
  final DashboardConfigRepository _configRepository;
  final FinanceSummaryService _financeService;
  final LibraryRepository _libraryRepository;

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

  void _onUpdateConfig(
    UpdateDashboardConfig event,
    Emitter<InicioState> emit,
  ) {
    emit(
      state.copyWith(
        widgetConfigs: event.widgets,
        quickActions: event.actions,
      ),
    );
  }

  Future<void> _loadData(
    Emitter<InicioState> emit, {
    required bool refreshing,
  }) async {
    emit(
      state.copyWith(
        status: refreshing ? InicioStatus.refreshing : InicioStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final dashboardFuture = _dashboardService.loadDashboard();
      final widgetsFuture = _configRepository.loadWidgets();
      final actionsFuture = _configRepository.loadQuickActions();
      final financeFuture = _financeService.loadForPreset();
      final libraryFuture = _libraryRepository.getAll();

      final dashboard = await dashboardFuture;
      final widgets = await widgetsFuture;
      final actions = await actionsFuture;
      final finance = await financeFuture;
      final library = await libraryFuture;

      emit(
        state.copyWith(
          status: InicioStatus.loaded,
          data: dashboard,
          widgetConfigs: widgets,
          quickActions: actions,
          financeDetail: finance,
          libraryPicks: library.take(5).toList(growable: false),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: InicioStatus.error,
          errorMessage: 'No se pudo cargar el panel: $error',
        ),
      );
    }
  }
}
