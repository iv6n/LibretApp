/// features › agenda › bloc › agenda_state — states for AgendaBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';

abstract class AgendaState extends Equatable {
  const AgendaState();

  @override
  List<Object> get props => [];
}

class AgendaInitial extends AgendaState {
  const AgendaInitial();
}

class AgendaLoading extends AgendaState {
  const AgendaLoading();
}

class AgendaLoaded extends AgendaState {
  const AgendaLoaded(this.entries);
  final List<AgendaEntry> entries;

  @override
  List<Object> get props => [entries];
}

class AgendaError extends AgendaState {
  const AgendaError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
