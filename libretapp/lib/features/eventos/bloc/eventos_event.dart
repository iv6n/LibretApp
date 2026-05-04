/// features \u203a eventos \u203a bloc \u203a eventos_event \u2014 events for EventosBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/eventos/data/eventos_model.dart';

abstract class EventosEvent extends Equatable {
  const EventosEvent();

  @override
  List<Object> get props => [];
}

class LoadEventos extends EventosEvent {
  const LoadEventos();
}

class AddEvento extends EventosEvent {
  const AddEvento(this.evento);
  final Evento evento;

  @override
  List<Object> get props => [evento];
}

class UpdateEvento extends EventosEvent {
  const UpdateEvento(this.evento);
  final Evento evento;

  @override
  List<Object> get props => [evento];
}

class DeleteEvento extends EventosEvent {
  const DeleteEvento(this.id);
  final String id;

  @override
  List<Object> get props => [id];
}

class SearchEventos extends EventosEvent {
  const SearchEventos(this.query);
  final String query;

  @override
  List<Object> get props => [query];
}
