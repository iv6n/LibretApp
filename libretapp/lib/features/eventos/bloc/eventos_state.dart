/// features \u203a eventos \u203a bloc \u203a eventos_state \u2014 state for EventosBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/eventos/data/eventos_model.dart';

abstract class EventosState extends Equatable {
  const EventosState();

  @override
  List<Object> get props => [];
}

class EventosInitial extends EventosState {
  const EventosInitial();
}

class EventosLoading extends EventosState {
  const EventosLoading();
}

class EventosLoaded extends EventosState {
  const EventosLoaded(this.eventos);
  final List<Evento> eventos;

  @override
  List<Object> get props => [eventos];
}

class EventosError extends EventosState {
  const EventosError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
