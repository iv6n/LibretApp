/// features \u203a inicio \u203a bloc \u203a inicio_event \u2014 events for InicioBloc.
library;

import 'package:equatable/equatable.dart';

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
