/// features › agenda › bloc › agenda_bloc — BLoC for the agenda feature.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/agenda/bloc/agenda_event.dart';
import 'package:libretapp/features/agenda/bloc/agenda_state.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/core/utils/id_generator.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  AgendaBloc(this.repository, {LotesRepository? lotesRepository})
    : _lotesRepository = lotesRepository,
      super(const AgendaInitial()) {
    on<LoadAgenda>(_onLoad);
    on<AddAgendaEntry>(_onAdd);
    on<UpdateAgendaEntry>(_onUpdate);
    on<DeleteAgendaEntry>(_onDelete);
    on<MarkAnimalCompleted>(_onMarkAnimalCompleted);
    on<ChangeAgendaStatus>(_onChangeStatus);
    on<ToggleAgendaChecklistItem>(_onToggleChecklistItem);
  }

  final AgendaRepository repository;
  final LotesRepository? _lotesRepository;

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

      final allAnimalIds = <String>{...entry.animalIds};
      final lotesRepository = _lotesRepository;
      if (lotesRepository != null) {
        for (final loteId in entry.loteIds) {
          final lote = await lotesRepository.getByUuid(loteId);
          if (lote != null) allAnimalIds.addAll(lote.animalUuids);
        }
      }
      final allDone =
          allAnimalIds.isNotEmpty &&
          allAnimalIds.every((id) => completed.contains(id));

      final now = DateTime.now();
      final activities = <AgendaActivity>[
        ...entry.activities,
        AgendaActivity(
          id: generateId(),
          type: 'animal_completed',
          timestamp: now,
          note: event.animalId,
        ),
      ];

      final updated = entry.copyWith(
        completedAnimalIds: completed,
        estado: allDone
            ? AgendaEstado.completado
            : completed.isEmpty
            ? AgendaEstado.pendiente
            : AgendaEstado.enProgreso,
        fechaCompletado: allDone ? now : entry.fechaCompletado,
        updatedAt: now,
        activities: activities,
      );

      await repository.updateEntry(updated);
      final refreshed = await repository.fetchEntries();
      emit(AgendaLoaded(refreshed));
    } catch (e) {
      emit(AgendaError(e.toString()));
    }
  }

  Future<void> _onChangeStatus(
    ChangeAgendaStatus event,
    Emitter<AgendaState> emit,
  ) async {
    try {
      final entry = await repository.getEntry(event.entryId);
      final now = DateTime.now();
      final completed = event.status == AgendaEstado.completado ||
          event.status == AgendaEstado.verificado;
      final updated = entry.copyWith(
        estado: event.status,
        blockedReason: event.status == AgendaEstado.bloqueado
            ? event.reason.trim()
            : null,
        fechaCompletado: completed ? now : entry.fechaCompletado,
        updatedAt: now,
        activities: [
          ...entry.activities,
          AgendaActivity(
            id: generateId(),
            type: 'status_changed:${event.status}',
            timestamp: now,
            actorId: event.actorId.isEmpty ? null : event.actorId,
            note: event.reason.trim().isEmpty ? null : event.reason.trim(),
          ),
        ],
      );
      await repository.updateEntry(updated);
      emit(AgendaLoaded(await repository.fetchEntries()));
    } catch (e) {
      emit(AgendaError(e.toString()));
    }
  }

  Future<void> _onToggleChecklistItem(
    ToggleAgendaChecklistItem event,
    Emitter<AgendaState> emit,
  ) async {
    try {
      final entry = await repository.getEntry(event.entryId);
      final now = DateTime.now();
      final checklist = entry.checklist.map((item) {
        if (item.id != event.itemId) return item;
        return item.copyWith(
          completed: event.completed,
          completedById: event.actorId.isEmpty ? null : event.actorId,
          completedAt: event.completed ? now : null,
        );
      }).toList(growable: false);
      final updated = entry.copyWith(
        checklist: checklist,
        updatedAt: now,
        activities: [
          ...entry.activities,
          AgendaActivity(
            id: generateId(),
            type: event.completed ? 'checklist_completed' : 'checklist_reopened',
            timestamp: now,
            actorId: event.actorId.isEmpty ? null : event.actorId,
            note: event.itemId,
          ),
        ],
      );
      await repository.updateEntry(updated);
      emit(AgendaLoaded(await repository.fetchEntries()));
    } catch (e) {
      emit(AgendaError(e.toString()));
    }
  }
}
