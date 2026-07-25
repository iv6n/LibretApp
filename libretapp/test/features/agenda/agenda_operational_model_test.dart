import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/workforce_model.dart';

void main() {
  test('AgendaEntry conserva asignación, checklist y bitácora en JSON', () {
    final now = DateTime.utc(2026, 7, 20, 12);
    final entry = AgendaEntry(
      id: 'task-1',
      titulo: 'Vacunar lote norte',
      descripcion: 'Aplicar refuerzo',
      fecha: now,
      tipo: 'sanitario',
      animalIds: const ['animal-1'],
      loteIds: const ['lote-1'],
      ubicacion: 'Corral norte',
      estado: AgendaEstado.enProgreso,
      completedAnimalIds: const [],
      notas: '',
      prioridad: AgendaPrioridad.urgente,
      assigneeId: 'worker-1',
      collaboratorIds: const ['worker-2'],
      workTeamId: 'team-1',
      recurrenceRule: 'weekly',
      checklist: [
        AgendaChecklistItem(
          id: 'check-1',
          label: 'Preparar dosis',
          completed: true,
          completedById: 'worker-1',
          completedAt: now,
        ),
      ],
      activities: [
        AgendaActivity(
          id: 'activity-1',
          type: 'status_changed',
          note: 'Tarea iniciada',
          timestamp: now,
          actorId: 'worker-1',
        ),
      ],
    );

    expect(AgendaEntry.fromJson(entry.toJson()), entry);
  });

  test('desmarcar checklist limpia autor y fecha de finalización', () {
    final item = AgendaChecklistItem(
      id: 'check-1',
      label: 'Cerrar manga',
      completed: true,
      completedById: 'worker-1',
      completedAt: DateTime.utc(2026, 7, 20),
    );

    final reopened = item.copyWith(
      completed: false,
      completedById: null,
      completedAt: null,
    );

    expect(reopened.completed, isFalse);
    expect(reopened.completedById, isNull);
    expect(reopened.completedAt, isNull);
  });

  test('integrantes y equipos soportan respaldo JSON', () {
    final now = DateTime.utc(2026, 7, 20);
    final worker = WorkerProfile(
      id: 'worker-1',
      name: 'Ana',
      role: WorkerRole.supervisor,
      phone: '555-0100',
      active: true,
      createdAt: now,
      updatedAt: now,
    );
    final team = WorkTeam(
      id: 'team-1',
      name: 'Sanidad',
      memberIds: const ['worker-1'],
      active: true,
      createdAt: now,
      updatedAt: now,
    );

    expect(WorkerProfile.fromJson(worker.toJson()), worker);
    expect(WorkTeam.fromJson(team.toJson()), team);
  });
}
