/// features › agenda › bloc › agenda_bloc — BLoC for the agenda feature.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/agenda/bloc/agenda_event.dart';
import 'package:libretapp/features/agenda/bloc/agenda_state.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';

class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  AgendaBloc(this.repository) : super(const AgendaInitial()) {
    on<LoadAgenda>(_onLoad);
    on<AddAgendaEntry>(_onAdd);
    on<UpdateAgendaEntry>(_onUpdate);
    on<DeleteAgendaEntry>(_onDelete);
    on<SearchAgenda>(_onSearch);
    on<MarkAnimalCompleted>(_onMarkAnimalCompleted);
  }

  final AgendaRepository repository;

  Future<void> _onLoad(LoadAgenda event, Emitter<AgendaState> emit) async {
    emit(const AgendaLoading());
    try {
      final entries = await repository.fetchEntries();
      emit(AgendaLoaded(entries));
    } catch (e) {
      emit(AgendaError(e.toString()));
    }
  }

  Future<void> _onAdd(AddAgendaEntry event, Emitter<AgendaState> emit) async {
    try {
      await repository.saveEntry(event.entry);
      final entries = await repository.fetchEntries();
      emit(AgendaLoaded(entries));
    } catch (e) {
      emit(AgendaError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateAgendaEntry event,
    Emitter<AgendaState> emit,
  ) async {
    try {
      await repository.updateEntry(event.entry);
      final entries = await repository.fetchEntries();
      emit(AgendaLoaded(entries));
    } catch (e) {
      emit(AgendaError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteAgendaEntry event,
    Emitter<AgendaState> emit,
  ) async {
    try {
      await repository.deleteEntry(event.id);
      final entries = await repository.fetchEntries();
      emit(AgendaLoaded(entries));
    } catch (e) {
      emit(AgendaError(e.toString()));
    }
  }

  Future<void> _onSearch(SearchAgenda event, Emitter<AgendaState> emit) async {
    try {
      final entries = await repository.fetchEntries();
      final q = event.query.toLowerCase();
      final filtered = entries
          .where(
            (e) =>
                e.titulo.toLowerCase().contains(q) ||
                e.tipo.toLowerCase().contains(q) ||
                e.ubicacion.toLowerCase().contains(q),
          )
          .toList();
      emit(AgendaLoaded(filtered));
    } catch (e) {
      emit(AgendaError(e.toString()));
    }
  }

  Future<void> _onMarkAnimalCompleted(
    MarkAnimalCompleted event,
    Emitter<AgendaState> emit,
  ) async {
    try {
      final entries = await repository.fetchEntries();
      final entry = entries.firstWhere((e) => e.id == event.entryId);
      final completed = List<String>.from(entry.completedAnimalIds);
      if (!completed.contains(event.animalId)) {
        completed.add(event.animalId);
      }

      final allAnimalIds = entry.animalIds;
      final allDone =
          allAnimalIds.isNotEmpty &&
          allAnimalIds.every((id) => completed.contains(id));

      final updated = entry.copyWith(
        completedAnimalIds: completed,
        estado: allDone
            ? AgendaEstado.completado
            : completed.isEmpty
            ? AgendaEstado.pendiente
            : AgendaEstado.enProgreso,
        fechaCompletado: allDone ? DateTime.now() : entry.fechaCompletado,
      );

      await repository.updateEntry(updated);
      final refreshed = await repository.fetchEntries();
      emit(AgendaLoaded(refreshed));
    } catch (e) {
      emit(AgendaError(e.toString()));
    }
  }
}
