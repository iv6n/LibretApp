/// features \u203a inicio \u203a bloc \u203a inicio_state \u2014 state for InicioBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';

enum InicioStatus { initial, loading, loaded, refreshing, error }

class InicioState extends Equatable {
  const InicioState({required this.status, this.data, this.errorMessage});

  factory InicioState.initial() {
    return const InicioState(status: InicioStatus.initial);
  }

  final InicioStatus status;
  final InicioDashboardData? data;
  final String? errorMessage;

  bool get isLoading =>
      status == InicioStatus.loading || status == InicioStatus.refreshing;

  InicioState copyWith({
    InicioStatus? status,
    InicioDashboardData? data,
    String? errorMessage,
  }) {
    return InicioState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}
