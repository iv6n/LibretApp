/// features › agenda › data › eventos_export_sheet — writes the "Eventos"
/// sheet for [ExportService].
library;

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/services/exportable_sheet.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/data/workforce_repository.dart';

class EventosExportSheet implements ExportableSheet {
  EventosExportSheet({
    required AgendaRepository agendaRepository,
    required WorkforceRepository workforceRepository,
  }) : _agendaRepository = agendaRepository,
       _workforceRepository = workforceRepository;

  final AgendaRepository _agendaRepository;
  final WorkforceRepository _workforceRepository;

  @override
  Future<void> writeTo(Excel excel) async {
    final sheet = excel['Eventos'];
    writeExcelRow(sheet, 0, [
      'Título',
      'Descripción',
      'Fecha',
      'Tipo',
      'ID Animal',
      'Ubicación',
      'Estado',
      'Prioridad',
      'Progreso',
      'Responsable',
      'Equipo',
      'Colaboradores',
      'Checklist',
      'Recurrencia',
      'Actualizada',
    ], header: true);

    final eventList = await _agendaRepository.fetchEntries();
    final workers = await _workforceRepository.fetchWorkers(
      includeInactive: true,
    );
    final teams = await _workforceRepository.fetchTeams(includeInactive: true);
    final workerNames = {for (final worker in workers) worker.id: worker.name};
    final teamNames = {for (final team in teams) team.id: team.name};
    for (var i = 0; i < eventList.length; i++) {
      final e = eventList[i];
      writeExcelRow(sheet, i + 1, [
        e.titulo,
        e.descripcion,
        DateFormat('dd/MM/yyyy HH:mm').format(e.fecha),
        e.tipo,
        e.animalIds.join(', '),
        e.ubicacion,
        e.estado,
        e.prioridad,
        '${e.completedAnimalIds.length}/${e.animalIds.length}',
        workerNames[e.assigneeId] ?? '',
        teamNames[e.workTeamId] ?? '',
        e.collaboratorIds.map((id) => workerNames[id] ?? id).join(', '),
        '${e.checklist.where((item) => item.completed).length}/${e.checklist.length}',
        e.recurrenceRule ?? '',
        e.updatedAt == null
            ? ''
            : DateFormat('dd/MM/yyyy HH:mm').format(e.updatedAt!),
      ]);
    }
  }
}
