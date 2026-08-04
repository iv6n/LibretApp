import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/domain/agenda_categoria.dart';
import 'package:libretapp/features/agenda/domain/agenda_task_grouping.dart';

AgendaEntry _entry({
  required String id,
  required String tipo,
  required DateTime fecha,
  List<String> animalIds = const [],
  List<String> completedAnimalIds = const [],
  String prioridad = AgendaPrioridad.normal,
  String estado = AgendaEstado.pendiente,
}) {
  return AgendaEntry(
    id: id,
    titulo: '$tipo entry',
    descripcion: '',
    fecha: fecha,
    tipo: tipo,
    animalIds: animalIds,
    loteIds: const [],
    ubicacion: 'Sin ubicación',
    estado: estado,
    completedAnimalIds: completedAnimalIds,
    notas: '',
    prioridad: prioridad,
  );
}

void main() {
  final today = DateTime(2026, 8, 2);
  const grouper = AgendaTaskGrouper();

  group('AgendaTaskGrouper.group', () {
    test('agrupa por categoría > tipo > animales, sin repetir por animal', () {
      final entries = [
        _entry(
          id: 'auto:care:v12:vac:20260804',
          tipo: 'Vacunación',
          fecha: today.add(const Duration(days: 2)),
          animalIds: ['vaca-12'],
        ),
        _entry(
          id: 'auto:care:v45:vac:20260804',
          tipo: 'Vacunación',
          fecha: today.add(const Duration(days: 2)),
          animalIds: ['vaca-45'],
        ),
        _entry(
          id: 'auto:care:v8:banio:20260803',
          tipo: 'Baño garrapaticida',
          fecha: today.add(const Duration(days: 1)),
          animalIds: ['vaca-8'],
        ),
      ];

      final groups = grouper.group(entries, today: today);

      expect(groups, hasLength(1));
      expect(groups.single.categoria, AgendaCategoria.sanidad);

      final subtipos = groups.single.subcategorias.map((s) => s.tipo);
      expect(subtipos, containsAll(['Vacunación', 'Baño garrapaticida']));

      final vacunas = groups.single.subcategorias.firstWhere(
        (s) => s.tipo == 'Vacunación',
      );
      expect(
        vacunas.rows.map((r) => r.animalId),
        containsAll(['vaca-12', 'vaca-45']),
      );
    });

    test(
      'dedupe: dos entradas de fuentes distintas para el mismo animal y tipo '
      'producen una sola fila (la más urgente)',
      () {
        final entries = [
          _entry(
            id: 'auto:care:v1:vac:20260807',
            tipo: 'Vacunación',
            fecha: today.add(const Duration(days: 5)),
            animalIds: ['vaca-1'],
          ),
          _entry(
            id: 'auto:care:v1:vac:20260801',
            tipo: 'Vacunación',
            fecha: today.subtract(const Duration(days: 1)),
            animalIds: ['vaca-1'],
          ),
        ];

        final groups = grouper.group(entries, today: today);

        final events = groups.single.events;
        expect(events, hasLength(1));
        expect(events.single.rows, hasLength(1));
        expect(events.first.primaryEntry.id, 'auto:care:v1:vac:20260801');
      },
    );

    test('groups the same task type across species, rules and dates', () {
      final entries = [
        _entry(
          id: 'auto:care:cow-1:default-cattle-deworming:20260803',
          tipo: 'Desparasitación',
          fecha: today.add(const Duration(days: 1)),
          animalIds: ['cow-1'],
        ),
        _entry(
          id: 'auto:care:goat-1:default-goat-deworming:20260805',
          tipo: 'Desparasitación',
          fecha: today.add(const Duration(days: 3)),
          animalIds: ['goat-1'],
        ),
        _entry(
          id: 'auto:care:sheep-1:default-sheep-deworming:20260807',
          tipo: 'Desparasitación',
          fecha: today.add(const Duration(days: 5)),
          animalIds: ['sheep-1'],
        ),
      ];

      final groups = grouper.group(entries, today: today);
      final events = groups.single.events;

      expect(events, hasLength(1));
      expect(events.single.tipo, 'Desparasitación');
      expect(
        events.single.rows.map((row) => row.animalId),
        containsAll(['cow-1', 'goat-1', 'sheep-1']),
      );
    });

    test('un animal marcado como completado dentro de una entrada compartida '
        'no genera fila, el resto sí', () {
      final entries = [
        _entry(
          id: 'manual:lote-tratamiento',
          tipo: 'Desparasitación',
          fecha: today.add(const Duration(days: 1)),
          animalIds: ['vaca-1', 'vaca-2'],
          completedAnimalIds: ['vaca-1'],
        ),
      ];

      final groups = grouper.group(entries, today: today);

      final rows = groups.single.subcategorias.single.rows;
      expect(rows.map((r) => r.animalId), ['vaca-2']);
    });

    test('lo atrasado siempre va antes que lo de mayor prioridad futura', () {
      final entries = [
        _entry(
          id: 'future-urgente',
          tipo: 'Vacunación',
          fecha: today.add(const Duration(days: 1)),
          animalIds: ['vaca-1'],
          prioridad: AgendaPrioridad.urgente,
        ),
        _entry(
          id: 'atrasado-baja',
          tipo: 'Desparasitación',
          fecha: today.subtract(const Duration(days: 1)),
          animalIds: ['vaca-2'],
          prioridad: AgendaPrioridad.baja,
        ),
      ];

      final groups = grouper.group(entries, today: today);

      expect(
        groups.single.subcategorias.first.tipo,
        'Desparasitación',
        reason: 'lo atrasado (aunque de baja prioridad) va primero',
      );
    });

    test(
      'entre dos pendientes futuros, mayor prioridad primero; luego fecha más próxima',
      () {
        final entries = [
          _entry(
            id: 'normal-proxima',
            tipo: 'Vacunación',
            fecha: today.add(const Duration(days: 1)),
            animalIds: ['vaca-1'],
          ),
          _entry(
            id: 'alta-lejana',
            tipo: 'Desparasitación',
            fecha: today.add(const Duration(days: 5)),
            animalIds: ['vaca-2'],
            prioridad: AgendaPrioridad.alta,
          ),
        ];

        final groups = grouper.group(entries, today: today);

        expect(groups.single.subcategorias.first.tipo, 'Desparasitación');
      },
    );

    test('una tarea sin animales asociados (ej. Mantenimiento) genera una fila '
        'con animalId nulo', () {
      final entries = [
        _entry(
          id: 'manual:mant-1',
          tipo: 'Mantenimiento',
          fecha: today.add(const Duration(days: 1)),
        ),
      ];

      final groups = grouper.group(entries, today: today);

      expect(groups.single.categoria, AgendaCategoria.administracion);
      expect(groups.single.subcategorias.single.rows.single.animalId, isNull);
    });

    test('estados completado/verificado/cancelado quedan afuera', () {
      final entries = [
        _entry(
          id: 'done',
          tipo: 'Vacunación',
          fecha: today,
          animalIds: ['vaca-1'],
          estado: AgendaEstado.completado,
        ),
        _entry(
          id: 'verificado',
          tipo: 'Vacunación',
          fecha: today,
          animalIds: ['vaca-2'],
          estado: AgendaEstado.verificado,
        ),
        _entry(
          id: 'cancelado',
          tipo: 'Vacunación',
          fecha: today,
          animalIds: ['vaca-3'],
          estado: AgendaEstado.cancelado,
        ),
      ];

      expect(grouper.group(entries, today: today), isEmpty);
    });
  });
}
