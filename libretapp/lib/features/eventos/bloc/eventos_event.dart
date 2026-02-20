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
  final Evento evento;

  const AddEvento(this.evento);

  @override
  List<Object> get props => [evento];
}

class UpdateEvento extends EventosEvent {
  final Evento evento;

  const UpdateEvento(this.evento);

  @override
  List<Object> get props => [evento];
}

class DeleteEvento extends EventosEvent {
  final String id;

  const DeleteEvento(this.id);

  @override
  List<Object> get props => [id];
}

class SearchEventos extends EventosEvent {
  final String query;

  const SearchEventos(this.query);

  @override
  List<Object> get props => [query];
}
