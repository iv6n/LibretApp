/// Application service for scheduling, executing and reprogramming work.
library;

import 'package:libretapp/core/utils/id_generator.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/domain/operational_work.dart';

class OperationalPlanningService {
  OperationalPlanningService({required AgendaRepository agendaRepository})
    : _agendaRepository = agendaRepository;

  final AgendaRepository _agendaRepository;

  Future<WorkOccurrence> schedulePlan(
    WorkPlan plan, {
    String locationLabel = 'Sin ubicación',
    String? notes,
  }) {
    if (!plan.active) {
      throw StateError('No se puede agendar un plan inactivo: ${plan.id}.');
    }
    final reminder = plan.remindLeadDays <= 0
        ? null
        : plan.nextDate.subtract(Duration(days: plan.remindLeadDays));
    return schedule(
      title: plan.title,
      description: 'Trabajo generado desde un plan operativo.',
      date: plan.nextDate,
      category: plan.category,
      action: plan.action,
      targets: plan.targets,
      locationLabel: locationLabel,
      locationUuid: plan.locationUuid,
      remindAt: reminder,
      sourceType: WorkSourceType.locationPlan.name,
      sourceId: plan.id,
      planId: plan.id,
      recurrenceRule: plan.recurrenceRule,
      priority: plan.priority,
      assigneeId: plan.assigneeId,
      workTeamId: plan.workTeamId,
      checklist: plan.checklist,
      notes: notes,
    );
  }

  Future<WorkOccurrence> schedule({
    required String title,
    required String description,
    required DateTime date,
    required String category,
    required WorkActionType action,
    List<WorkTargetRef> targets = const [],
    String locationLabel = 'Sin ubicación',
    String? locationUuid,
    String? cropUuid,
    DateTime? remindAt,
    String? sourceType,
    String? sourceId,
    String? planId,
    String? recurrenceRule,
    String priority = AgendaPrioridad.normal,
    String? assigneeId,
    String? workTeamId,
    List<AgendaChecklistItem> checklist = const [],
    String? notes,
    String? id,
  }) async {
    final animalIds = targets
        .where((target) => target.type == WorkTargetType.animal)
        .map((target) => target.id)
        .toList(growable: false);
    final loteIds = targets
        .where((target) => target.type == WorkTargetType.lote)
        .map((target) => target.id)
        .toList(growable: false);
    final occurrence = AgendaEntry(
      id: id ?? generateId(),
      titulo: title,
      descripcion: description,
      fecha: date,
      tipo: category,
      animalIds: animalIds,
      loteIds: loteIds,
      ubicacion: locationLabel,
      locationUuid: locationUuid ?? _targetId(targets, WorkTargetType.location),
      cropUuid: cropUuid ?? _targetId(targets, WorkTargetType.crop),
      estado: AgendaEstado.pendiente,
      completedAnimalIds: const [],
      notas: notes ?? '',
      prioridad: priority,
      assigneeId: assigneeId,
      workTeamId: workTeamId,
      actionKind: action.name,
      sourceType: sourceType,
      sourceId: sourceId,
      planId: planId,
      recurrenceRule: recurrenceRule,
      remindAt: remindAt,
      originalFecha: date,
      checklist: checklist,
      createdAt: DateTime.now(),
    );
    await _agendaRepository.saveEntry(occurrence);
    return occurrence;
  }

  Future<WorkOccurrence> reschedule(
    String occurrenceId,
    DateTime newDate, {
    String? reason,
    DateTime? remindAt,
  }) async {
    final current = await _agendaRepository.getEntry(occurrenceId);
    final now = DateTime.now();
    final originalDate = current.originalFecha ?? current.fecha;
    final old = current.copyWith(
      estado: AgendaEstado.reprogramada,
      updatedAt: now,
      rescheduleReason: reason,
      activities: [
        ...current.activities,
        AgendaActivity(
          id: generateId(),
          type: 'reprogramada',
          timestamp: now,
          note: reason,
        ),
      ],
    );
    final successor = current.copyWith(
      id: generateId(),
      fecha: newDate,
      estado: AgendaEstado.pendiente,
      completedAnimalIds: const [],
      fechaCompletado: null,
      updatedAt: now,
      createdAt: now,
      originalFecha: originalDate,
      supersedesId: current.id,
      rescheduleReason: reason,
      remindAt: remindAt,
      activities: [
        ...current.activities,
        AgendaActivity(
          id: generateId(),
          type: 'creada_por_reprogramacion',
          timestamp: now,
          note: reason,
        ),
      ],
    );
    await _agendaRepository.updateEntry(old);
    await _agendaRepository.saveEntry(successor);
    return successor;
  }

  Future<WorkOccurrence> complete(
    String occurrenceId, {
    String? note,
    String? actorId,
  }) async {
    final current = await _agendaRepository.getEntry(occurrenceId);
    final now = DateTime.now();
    final updated = current.copyWith(
      estado: AgendaEstado.completado,
      fechaCompletado: now,
      updatedAt: now,
      notas: note ?? current.notas,
      activities: [
        ...current.activities,
        AgendaActivity(
          id: generateId(),
          type: 'completada',
          timestamp: now,
          actorId: actorId,
          note: note,
        ),
      ],
    );
    await _agendaRepository.updateEntry(updated);
    return updated;
  }

  Future<void> cancel(String occurrenceId, {String? reason}) async {
    final current = await _agendaRepository.getEntry(occurrenceId);
    final now = DateTime.now();
    await _agendaRepository.updateEntry(
      current.copyWith(
        estado: AgendaEstado.cancelado,
        updatedAt: now,
        rescheduleReason: reason,
        activities: [
          ...current.activities,
          AgendaActivity(
            id: generateId(),
            type: 'cancelada',
            timestamp: now,
            note: reason,
          ),
        ],
      ),
    );
  }

  /// Replaces only the generated occurrences for one target, preserving
  /// manual work and history belonging to every other target.
  Future<void> syncTarget({
    required WorkTargetRef target,
    required List<WorkOccurrence> desired,
  }) async {
    final existing = await _agendaRepository.fetchEntries();
    final targetEntries = existing.where(
      (entry) => entry.targetRefs.contains(target),
    );
    final desiredIds = desired.map((entry) => entry.id).toSet();
    final untouched = existing.where(
      (entry) =>
          !entry.targetRefs.contains(target) ||
          (!_isAutomatic(entry) && !desiredIds.contains(entry.id)),
    );
    final history = targetEntries.where(
      (entry) => _isTerminal(entry.estado) && !desiredIds.contains(entry.id),
    );
    await _agendaRepository.replaceAll([...untouched, ...history, ...desired]);
  }

  /// Reconciliation is injected as a generator by the startup composition
  /// root. Keeping it optional makes this service usable in isolated tests.
  Future<int> reconcileAll({Future<int> Function()? generator}) async {
    if (generator != null) return generator();
    final entries = await _agendaRepository.fetchEntries();
    final deduplicated = <WorkOccurrence>[];
    final groupedSources = <String, List<WorkOccurrence>>{};
    for (final entry in entries) {
      final sourceKey = entry.sourceType == null || entry.sourceId == null
          ? null
          : '${entry.sourceType}:${entry.sourceId}';
      if (sourceKey == null || !_isAutomatic(entry)) {
        deduplicated.add(entry);
        continue;
      }
      groupedSources.putIfAbsent(sourceKey, () => []).add(entry);
    }
    for (final sourceEntries in groupedSources.values) {
      deduplicated.addAll(
        sourceEntries.where((entry) => _isTerminal(entry.estado)),
      );
      final active = sourceEntries.where((entry) => !_isTerminal(entry.estado));
      final preferred = active.fold<WorkOccurrence?>(
        null,
        (previous, entry) =>
            previous == null || _prefer(entry, previous) ? entry : previous,
      );
      if (preferred != null) deduplicated.add(preferred);
    }
    if (deduplicated.length != entries.length) {
      await _agendaRepository.replaceAll(deduplicated);
    }
    return deduplicated.length;
  }

  String? _targetId(List<WorkTargetRef> targets, WorkTargetType type) {
    for (final target in targets) {
      if (target.type == type) return target.id;
    }
    return null;
  }

  bool _isAutomatic(WorkOccurrence entry) =>
      entry.sourceType != null || entry.id.startsWith('auto:');

  bool _isTerminal(String status) =>
      status == AgendaEstado.completado ||
      status == AgendaEstado.verificado ||
      status == AgendaEstado.cancelado ||
      status == AgendaEstado.reprogramada;

  bool _prefer(WorkOccurrence candidate, WorkOccurrence previous) =>
      candidate.supersedesId == previous.id ||
      candidate.updatedAt?.isAfter(previous.updatedAt ?? DateTime(0)) == true;
}
