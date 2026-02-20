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
  final List<Evento> eventos;

  const EventosLoaded(this.eventos);

  @override
  List<Object> get props => [eventos];
}

class EventosError extends EventosState {
  final String message;

  const EventosError(this.message);

  @override
  List<Object> get props => [message];
}
