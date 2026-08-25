/// Query helpers over the shared operational occurrence repository.
library;

import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/domain/operational_work.dart';

extension OperationalAgendaQueries on AgendaRepository {
  Future<List<WorkOccurrence>> fetchByDateRange(
    DateTime from,
    DateTime to,
  ) async {
    final entries = await fetchEntries();
    return entries
        .where(
          (entry) => !entry.fecha.isBefore(from) && entry.fecha.isBefore(to),
        )
        .toList(growable: false);
  }

  Future<List<WorkOccurrence>> fetchByTarget(WorkTargetRef target) async {
    final entries = await fetchEntries();
    return entries
        .where((entry) => entry.targetRefs.contains(target))
        .toList(growable: false);
  }

  Future<List<WorkOccurrence>> fetchByLocation(String locationUuid) async {
    final entries = await fetchEntries();
    return entries
        .where((entry) => entry.locationUuid == locationUuid)
        .toList(growable: false);
  }

  Future<List<WorkOccurrence>> fetchByCategory(String category) async {
    final entries = await fetchEntries();
    return entries
        .where((entry) => entry.tipo == category)
        .toList(growable: false);
  }

  Future<List<WorkOccurrence>> fetchByStatus(String status) async {
    final entries = await fetchEntries();
    return entries
        .where((entry) => entry.estado == status)
        .toList(growable: false);
  }

  Future<List<WorkOccurrence>> fetchByAssignee(String assigneeId) async {
    final entries = await fetchEntries();
    return entries
        .where((entry) => entry.assigneeId == assigneeId)
        .toList(growable: false);
  }
}
