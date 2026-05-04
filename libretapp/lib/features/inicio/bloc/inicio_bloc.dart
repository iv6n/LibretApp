/// features \u203a inicio \u203a bloc \u203a inicio_bloc \u2014 BLoC for the home dashboard.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/inicio/bloc/inicio_event.dart';
import 'package:libretapp/features/inicio/bloc/inicio_state.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_service.dart';

class InicioBloc extends Bloc<InicioEvent, InicioState> {
  InicioBloc(this._dashboardService) : super(InicioState.initial()) {
    on<LoadInicio>(_onLoadInicio);
    on<RefreshInicio>(_onRefreshInicio);
  }

  final InicioDashboardService _dashboardService;

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
      final dashboard = await _dashboardService.loadDashboard();
      emit(
        state.copyWith(
          status: InicioStatus.loaded,
          data: dashboard,
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
