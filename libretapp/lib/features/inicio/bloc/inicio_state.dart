/// features › inicio › bloc › inicio_state — state for InicioBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/inicio/data/dashboard_quick_action.dart';
import 'package:libretapp/features/inicio/data/dashboard_widget_config.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/biblioteca/data/library_manifest.dart';
import 'package:libretapp/features/finanzas/domain/finance_summary_service.dart';

enum InicioStatus { initial, loading, loaded, refreshing, error }

class InicioState extends Equatable {
  const InicioState({
    required this.status,
    this.data,
    this.errorMessage,
    this.widgetConfigs = const [],
    this.quickActions = const [],
    this.financeDetail,
    this.financeLoading = false,
    this.financeErrorMessage,
    this.libraryPicks = const [],
    this.libraryLoading = false,
    this.libraryErrorMessage,
  });

  factory InicioState.initial() {
    return const InicioState(status: InicioStatus.initial);
  }

  final InicioStatus status;
  final InicioDashboardData? data;
  final String? errorMessage;
  final List<DashboardWidgetConfig> widgetConfigs;
  final List<DashboardQuickAction> quickActions;
  final FinanceSummaryDetail? financeDetail;
  final bool financeLoading;
  final String? financeErrorMessage;
  final List<LibraryManifestBook> libraryPicks;
  final bool libraryLoading;
  final String? libraryErrorMessage;

  bool get isLoading =>
      status == InicioStatus.loading || status == InicioStatus.refreshing;

  InicioState copyWith({
    InicioStatus? status,
    InicioDashboardData? data,
    String? errorMessage,
    List<DashboardWidgetConfig>? widgetConfigs,
    List<DashboardQuickAction>? quickActions,
    FinanceSummaryDetail? financeDetail,
    bool? financeLoading,
    String? financeErrorMessage,
    bool clearFinanceError = false,
    List<LibraryManifestBook>? libraryPicks,
    bool? libraryLoading,
    String? libraryErrorMessage,
    bool clearLibraryError = false,
  }) {
    return InicioState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage,
      widgetConfigs: widgetConfigs ?? this.widgetConfigs,
      quickActions: quickActions ?? this.quickActions,
      financeDetail: financeDetail ?? this.financeDetail,
      financeLoading: financeLoading ?? this.financeLoading,
      financeErrorMessage: clearFinanceError
          ? null
          : financeErrorMessage ?? this.financeErrorMessage,
      libraryPicks: libraryPicks ?? this.libraryPicks,
      libraryLoading: libraryLoading ?? this.libraryLoading,
      libraryErrorMessage: clearLibraryError
          ? null
          : libraryErrorMessage ?? this.libraryErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    data,
    errorMessage,
    widgetConfigs,
    quickActions,
    financeDetail,
    financeLoading,
    financeErrorMessage,
    libraryPicks,
    libraryLoading,
    libraryErrorMessage,
  ];
}
