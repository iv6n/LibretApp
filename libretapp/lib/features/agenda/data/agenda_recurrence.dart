/// features › agenda › data › agenda_recurrence — expands a recurring agenda entry into its next occurrence.
library;

import 'package:libretapp/core/utils/id_generator.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';

/// Recurrence rule values used by [AgendaEntry.recurrenceRule] and the
/// "Repetición" dropdown in the agenda form.
class AgendaRecurrenceRule {
  static const weekly = 'weekly';
  static const monthly = 'monthly';
}

/// Computes the date of the next occurrence of a recurring entry whose
/// current occurrence falls on [date].
DateTime nextRecurrenceDate(DateTime date, String rule) {
  switch (rule) {
    case AgendaRecurrenceRule.weekly:
      return date.add(const Duration(days: 7));
    case AgendaRecurrenceRule.monthly:
      final year = date.month == 12 ? date.year + 1 : date.year;
      final month = date.month == 12 ? 1 : date.month + 1;
      // Clamp to the last day of the target month (e.g. Jan 31 -> Feb 28/29).
      final daysInTargetMonth = DateTime(year, month + 1, 0).day;
      final day = date.day > daysInTargetMonth ? daysInTargetMonth : date.day;
      return DateTime(year, month, day, date.hour, date.minute);
    default:
      return date;
  }
}

/// Builds the next occurrence of a recurring agenda entry once [completed]
/// has been marked done, or `null` if [completed] does not recur.
///
/// The new entry carries forward the task's template (title, type,
/// assignment, checklist steps) but starts fresh execution state: pending,
/// no completed animals, no checklist progress, no activity log.
AgendaEntry? buildNextOccurrence(AgendaEntry completed) {
  final rule = completed.recurrenceRule;
  if (rule == null) return null;

  final now = DateTime.now();
  final resetChecklist = completed.checklist
      .map(
        (item) => item.copyWith(
          completed: false,
          completedById: null,
          completedAt: null,
        ),
      )
      .toList(growable: false);

  return AgendaEntry(
    id: generateId(),
    titulo: completed.titulo,
    descripcion: completed.descripcion,
    fecha: nextRecurrenceDate(completed.fecha, rule),
    tipo: completed.tipo,
    animalIds: completed.animalIds,
    loteIds: completed.loteIds,
    ubicacion: completed.ubicacion,
    locationUuid: completed.locationUuid,
    estado: AgendaEstado.pendiente,
    completedAnimalIds: const [],
    notas: completed.notas,
    prioridad: completed.prioridad,
    assigneeId: completed.assigneeId,
    collaboratorIds: completed.collaboratorIds,
    workTeamId: completed.workTeamId,
    createdById: completed.createdById,
    createdAt: now,
    updatedAt: now,
    recurrenceRule: rule,
    checklist: resetChecklist,
  );
}
