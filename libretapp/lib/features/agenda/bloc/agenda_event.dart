/// features › agenda › bloc › agenda_event — events for AgendaBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';

abstract class AgendaEvent extends Equatable {
  const AgendaEvent();

  @override
  List<Object> get props => [];
}

class LoadAgenda extends AgendaEvent {
  const LoadAgenda();
}

class AddAgendaEntry extends AgendaEvent {
  const AddAgendaEntry(this.entry);
  final AgendaEntry entry;

  @override
  List<Object> get props => [entry];
}

class UpdateAgendaEntry extends AgendaEvent {
  const UpdateAgendaEntry(this.entry);
  final AgendaEntry entry;

  @override
  List<Object> get props => [entry];
}

class DeleteAgendaEntry extends AgendaEvent {
  const DeleteAgendaEntry(this.id);
  final String id;

  @override
  List<Object> get props => [id];
}

class SearchAgenda extends AgendaEvent {
  const SearchAgenda(this.query);
  final String query;

  @override
  List<Object> get props => [query];
}

/// Marks a single animal as completed within a task and auto-updates estado.
class MarkAnimalCompleted extends AgendaEvent {
  const MarkAnimalCompleted({required this.entryId, required this.animalId});
  final String entryId;
  final String animalId;

  @override
  List<Object> get props => [entryId, animalId];
}
