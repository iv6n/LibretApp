/// features › inicio › bloc › inicio_event — events for InicioBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/inicio/data/dashboard_quick_action.dart';
import 'package:libretapp/features/inicio/data/dashboard_widget_config.dart';

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
  const UpdateDashboardConfig({
    required this.widgets,
    required this.actions,
  });

  final List<DashboardWidgetConfig> widgets;
  final List<DashboardQuickAction> actions;

  @override
  List<Object?> get props => [widgets, actions];
}
