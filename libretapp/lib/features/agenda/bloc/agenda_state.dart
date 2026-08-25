/// features › agenda › bloc › agenda_state — states for AgendaBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/domain/agenda_registration.dart';

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
  const AgendaLoaded(
    this.entries, {
    this.registrations = const [],
    this.registrationDetails = const [],
  });
  final List<AgendaEntry> entries;
  final List<AgendaRegistration> registrations;
  final List<AgendaRegistrationDetail> registrationDetails;

  Map<String, AgendaRegistrationDetail> get registrationDetailsByRow {
    final result = <String, AgendaRegistrationDetail>{};
    for (final detail in registrationDetails) {
      result.putIfAbsent(detail.rowKey, () => detail);
    }
    return result;
  }

  @override
  List<Object> get props => [entries, registrations, registrationDetails];
}

class AgendaError extends AgendaState {
  const AgendaError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
