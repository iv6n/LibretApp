/// features › inicio › bloc › inicio_event — events for InicioBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/inicio/data/dashboard_quick_action.dart';
import 'package:libretapp/features/inicio/data/dashboard_widget_config.dart';
import 'package:libretapp/features/biblioteca/data/library_manifest.dart';
import 'package:libretapp/features/finanzas/domain/finance_summary_service.dart';

abstract class InicioEvent extends Equatable {
  const InicioEvent();

  @override
  List<Object?> get props => const [];
}

class LoadInicio extends InicioEvent {
  const LoadInicio();
}

class RefreshInicio extends InicioEvent {
  const RefreshInicio();
}

class UpdateDashboardConfig extends InicioEvent {
  const UpdateDashboardConfig({required this.widgets, required this.actions});

  final List<DashboardWidgetConfig> widgets;
  final List<DashboardQuickAction> actions;

  @override
  List<Object?> get props => [widgets, actions];
}

class InicioFinanceLoaded extends InicioEvent {
  const InicioFinanceLoaded({required this.requestId, this.detail, this.error});

  final int requestId;
  final FinanceSummaryDetail? detail;
  final String? error;

  @override
  List<Object?> get props => [requestId, detail, error];
}

class InicioLibraryLoaded extends InicioEvent {
  const InicioLibraryLoaded({required this.requestId, this.items, this.error});

  final int requestId;
  final List<LibraryManifestBook>? items;
  final String? error;

  @override
  List<Object?> get props => [requestId, items, error];
}
