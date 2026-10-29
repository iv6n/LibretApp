import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/domain/operational_planning_service.dart';
import 'package:libretapp/features/agenda/domain/operational_work.dart';

void main() {
  test('reprogramar conserva la ocurrencia original y crea sucesora', () async {
    final repository = _MemoryAgendaRepository();
    final service = OperationalPlanningService(agendaRepository: repository);

    final original = await service.schedule(
      title: 'Vacuna',
      description: 'Aplicación',
      date: DateTime(2026, 8, 4),
      category: 'Sanidad',
      action: WorkActionType.recordHealth,
      targets: const [WorkTargetRef(type: WorkTargetType.animal, id: 'a-1')],
      sourceType: WorkSourceType.health.name,
      sourceId: 'health-1',
    );

    final successor = await service.reschedule(
      original.id,
      DateTime(2026, 8, 9),
      reason: 'El veterinario no pudo venir',
    );
    final entries = await repository.fetchEntries();

    expect(entries, hasLength(2));
    expect(
      entries.singleWhere((entry) => entry.id == original.id).estado,
      AgendaEstado.reprogramada,
    );
    expect(successor.supersedesId, original.id);
    expect(successor.originalFecha, DateTime(2026, 8, 4));
    expect(successor.fecha, DateTime(2026, 8, 9));
    expect(successor.animalIds, ['a-1']);
  });

  test('completar cambia el estado de la misma ocurrencia', () async {
    final repository = _MemoryAgendaRepository();
    final service = OperationalPlanningService(agendaRepository: repository);
    final occurrence = await service.schedule(
      title: 'Inspección de cerco',
      description: '',
      date: DateTime(2026, 8, 4),
      category: 'Mantenimiento',
      action: WorkActionType.maintenance,
      targets: const [
        WorkTargetRef(type: WorkTargetType.location, id: 'location-1'),
      ],
    );

    final completed = await service.complete(occurrence.id, note: 'Listo');

    expect(completed.estado, AgendaEstado.completado);
    expect(completed.fechaCompletado, isNotNull);
    expect(completed.locationUuid, 'location-1');
  });

  test(
    'reconcileAll conserva historial reprogramado y su sucesora activa',
    () async {
      final repository = _MemoryAgendaRepository();
      final service = OperationalPlanningService(agendaRepository: repository);
      final original = await service.schedule(
        title: 'Vacuna automática',
        description: '',
        date: DateTime(2026, 8, 4),
        category: 'Sanidad',
        action: WorkActionType.recordHealth,
        targets: const [WorkTargetRef(type: WorkTargetType.animal, id: 'a-1')],
        sourceType: WorkSourceType.health.name,
        sourceId: 'health-1',
      );

      final successor = await service.reschedule(
        original.id,
        DateTime(2026, 8, 9),
        reason: 'Reagendada',
      );

      await service.reconcileAll();
      final entries = await repository.fetchEntries();

      expect(
        entries.map((entry) => entry.id),
        containsAll([original.id, successor.id]),
      );
      expect(
        entries.singleWhere((entry) => entry.id == original.id).estado,
        AgendaEstado.reprogramada,
      );
      expect(
        entries.singleWhere((entry) => entry.id == successor.id).supersedesId,
        original.id,
      );
    },
  );

  test('reconcileAll conserva tomas distintas del mismo plan', () async {
    final repository = _MemoryAgendaRepository();
    final service = OperationalPlanningService(agendaRepository: repository);
    final targets = const [
      WorkTargetRef(type: WorkTargetType.animal, id: 'pet-1'),
    ];

    final morning = await service.schedule(
      title: 'Medicamento · mañana',
      description: 'Toma de la mañana',
      date: DateTime(2026, 8, 10, 8),
      category: 'Cuidado',
      action: WorkActionType.recordCare,
      targets: targets,
      sourceType: WorkSourceType.care.name,
      sourceId: 'plan-1',
      planId: 'plan-1',
    );
    final evening = await service.schedule(
      title: 'Medicamento · tarde',
      description: 'Toma de la tarde',
      date: DateTime(2026, 8, 10, 8),
      category: 'Cuidado',
      action: WorkActionType.recordCare,
      targets: targets,
      sourceType: WorkSourceType.care.name,
      sourceId: 'plan-1',
      planId: 'plan-1',
    );

    await service.reconcileAll();

    final entries = await repository.fetchEntries();
    expect(
      entries.map((entry) => entry.id),
      containsAll([morning.id, evening.id]),
    );
  });
}

class _MemoryAgendaRepository implements AgendaRepository {
  final Map<String, AgendaEntry> _entries = {};

  @override
  Future<List<AgendaEntry>> fetchEntries() async => _entries.values.toList();

  @override
  Future<AgendaEntry> getEntry(String id) async => _entries[id]!;

  @override
  Future<void> saveEntry(AgendaEntry entry) async {
    _entries[entry.id] = entry;
  }

  @override
  Future<void> saveEntries(List<AgendaEntry> entries) async {
    _entries.addEntries(entries.map((entry) => MapEntry(entry.id, entry)));
  }

  @override
  Future<void> updateEntry(AgendaEntry entry) async {
    _entries[entry.id] = entry;
  }

  @override
  Future<void> deleteEntry(String id) async {
    _entries.remove(id);
  }

  @override
  Future<void> replaceAll(List<AgendaEntry> entries) async {
    _entries
      ..clear()
      ..addEntries(entries.map((entry) => MapEntry(entry.id, entry)));
  }

  @override
  Future<void> clearAll() async => _entries.clear();
}
