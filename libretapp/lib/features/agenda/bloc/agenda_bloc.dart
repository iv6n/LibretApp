/// features › agenda › bloc › agenda_bloc — BLoC for the agenda feature.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/agenda/bloc/agenda_event.dart';
import 'package:libretapp/features/agenda/bloc/agenda_state.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_registration_repository.dart';
import 'package:libretapp/features/agenda/data/agenda_recurrence.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/data/agenda_refresh_signal.dart';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/features/agenda/domain/agenda_registration_read_service.dart';
import 'package:libretapp/core/utils/id_generator.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  AgendaBloc(
    this.repository, {
    LotesRepository? lotesRepository,
    AgendaReminderSyncService? syncService,
    AgendaRefreshSignal? refreshSignal,
    AgendaRegistrationRepository? registrationRepository,
    AgendaRegistrationReadService? registrationReadService,
  }) : _lotesRepository = lotesRepository,
       _syncService = syncService,
       _refreshSignal = refreshSignal,
       _registrationRepository = registrationRepository,
       _registrationReadService = registrationReadService,
       super(const AgendaInitial()) {
    on<LoadAgenda>(_onLoad);
    on<RefreshAgenda>(_onRefresh);
    on<AddAgendaEntry>(_onAdd);
    on<UpdateAgendaEntry>(_onUpdate);
    on<DeleteAgendaEntry>(_onDelete);
    on<MarkAnimalCompleted>(_onMarkAnimalCompleted);
    on<ChangeAgendaStatus>(_onChangeStatus);
    on<ToggleAgendaChecklistItem>(_onToggleChecklistItem);
    _refreshSignal?.addListener(_handleExternalRefresh);
  }

  final AgendaRepository repository;
  final LotesRepository? _lotesRepository;
  final AgendaReminderSyncService? _syncService;
  final AgendaRefreshSignal? _refreshSignal;
  final AgendaRegistrationRepository? _registrationRepository;
  final AgendaRegistrationReadService? _registrationReadService;

  void _handleExternalRefresh() {
    if (!isClosed) add(const RefreshAgenda());
  }

  void _notifyAgendaChanged() => _refreshSignal?.notifyChanged();

  Future<void> _emitLoaded(Emitter<AgendaState> emit) async {
    final entries = await repository.fetchEntries();
    final registrations =
        await _registrationRepository?.fetchForEntries({
          for (final entry in entries) entry.id,
        }) ??
        const [];
    final details =
        await _registrationReadService?.resolve(registrations) ?? const [];
    emit(
      AgendaLoaded(
        entries,
        registrations: registrations,
        registrationDetails: details,
      ),
    );
  }

  Future<void> _notifyAndEmitLoaded(Emitter<AgendaState> emit) async {
    _notifyAgendaChanged();
    await _emitLoaded(emit);
  }

  Future<void> _onRefresh(
    RefreshAgenda event,
    Emitter<AgendaState> emit,
  ) async {
    try {
      await _emitLoaded(emit);
    } catch (e) {
      emit(AgendaError(e.toString()));
    }
  }

  Future<void> _onLoad(LoadAgenda event, Emitter<AgendaState> emit) async {
    emit(const AgendaLoading());
    try {
      await _syncService?.sync();
      await _emitLoaded(emit);
    } catch (e) {
      emit(AgendaError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _refreshSignal?.removeListener(_handleExternalRefresh);
    return super.close();
  }

  Future<void> _onAdd(AddAgendaEntry event, Emitter<AgendaState> emit) async {
    try {
      await repository.saveEntry(event.entry);
      await _notifyAndEmitLoaded(emit);
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
      await _notifyAndEmitLoaded(emit);
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
      await _registrationRepository?.deleteForEntry(event.id);
      await _notifyAndEmitLoaded(emit);
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
      await _scheduleNextOccurrenceIfNeeded(before: entry, after: updated);
      await _notifyAndEmitLoaded(emit);
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
      final completed =
          event.status == AgendaEstado.completado ||
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
      await _scheduleNextOccurrenceIfNeeded(before: entry, after: updated);
      await _notifyAndEmitLoaded(emit);
    } catch (e) {
      emit(AgendaError(e.toString()));
    }
  }

  /// If [after] just transitioned into `completado` (and wasn't already),
  /// and the entry recurs, persists the next occurrence so a recurring task
  /// actually keeps producing future tasks instead of ending after one.
  Future<void> _scheduleNextOccurrenceIfNeeded({
    required AgendaEntry before,
    required AgendaEntry after,
  }) async {
    if (after.estado != AgendaEstado.completado) return;
    if (before.estado == AgendaEstado.completado) return;
    final next = buildNextOccurrence(after);
    if (next != null) await repository.saveEntry(next);
  }

  Future<void> _onToggleChecklistItem(
    ToggleAgendaChecklistItem event,
    Emitter<AgendaState> emit,
  ) async {
    try {
      final entry = await repository.getEntry(event.entryId);
      final now = DateTime.now();
      final checklist = entry.checklist
          .map((item) {
            if (item.id != event.itemId) return item;
            return item.copyWith(
              completed: event.completed,
              completedById: event.actorId.isEmpty ? null : event.actorId,
              completedAt: event.completed ? now : null,
            );
          })
          .toList(growable: false);
      final updated = entry.copyWith(
        checklist: checklist,
        updatedAt: now,
        activities: [
          ...entry.activities,
          AgendaActivity(
            id: generateId(),
            type: event.completed
                ? 'checklist_completed'
                : 'checklist_reopened',
            timestamp: now,
            actorId: event.actorId.isEmpty ? null : event.actorId,
            note: event.itemId,
          ),
        ],
      );
      await repository.updateEntry(updated);
      await _notifyAndEmitLoaded(emit);
    } catch (e) {
      emit(AgendaError(e.toString()));
    }
  }
}
