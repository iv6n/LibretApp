import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_recurrence.dart';

AgendaEntry _entry({
  String id = 'entry-1',
  DateTime? fecha,
  String? recurrenceRule,
  List<AgendaChecklistItem> checklist = const [],
}) {
  return AgendaEntry(
    id: id,
    titulo: 'Vacunar lote norte',
    descripcion: 'Refuerzo semestral',
    fecha: fecha ?? DateTime(2026, 1, 15, 9, 30),
    tipo: 'sanitario',
    animalIds: const ['animal-1'],
    loteIds: const ['lote-1'],
    ubicacion: 'Corral norte',
    estado: AgendaEstado.completado,
    completedAnimalIds: const ['animal-1'],
    notas: 'Nota original',
    recurrenceRule: recurrenceRule,
    checklist: checklist,
  );
}

void main() {
  group('nextRecurrenceDate', () {
    test('weekly adds 7 days', () {
      final date = DateTime(2026, 1, 15, 9, 30);

      expect(
        nextRecurrenceDate(date, AgendaRecurrenceRule.weekly),
        DateTime(2026, 1, 22, 9, 30),
      );
    });

    test('monthly advances to the same day next month, keeping the time', () {
      final date = DateTime(2026, 1, 15, 9, 30);

      expect(
        nextRecurrenceDate(date, AgendaRecurrenceRule.monthly),
        DateTime(2026, 2, 15, 9, 30),
      );
    });

    test('monthly clamps to the last day when the next month is shorter', () {
      final date = DateTime(2026, 1, 31);

      expect(
        nextRecurrenceDate(date, AgendaRecurrenceRule.monthly),
        DateTime(2026, 2, 28),
      );
    });

    test('monthly rolls over from December to January', () {
      final date = DateTime(2026, 12, 10);

      expect(
        nextRecurrenceDate(date, AgendaRecurrenceRule.monthly),
        DateTime(2027, 1, 10),
      );
    });
  });

  group('buildNextOccurrence', () {
    test('returns null when the entry does not recur', () {
      final entry = _entry(recurrenceRule: null);

      expect(buildNextOccurrence(entry), isNull);
    });

    test('carries the template forward but resets execution state', () {
      final entry = _entry(
        recurrenceRule: AgendaRecurrenceRule.weekly,
        checklist: const [
          AgendaChecklistItem(
            id: 'item-1',
            label: 'Preparar dosis',
            completed: true,
            completedById: 'worker-1',
          ),
        ],
      );

      final next = buildNextOccurrence(entry);

      expect(next, isNotNull);
      expect(next!.id, isNot(entry.id));
      expect(next.titulo, entry.titulo);
      expect(next.tipo, entry.tipo);
      expect(next.animalIds, entry.animalIds);
      expect(next.loteIds, entry.loteIds);
      expect(next.ubicacion, entry.ubicacion);
      expect(next.recurrenceRule, entry.recurrenceRule);
      expect(next.fecha, DateTime(2026, 1, 22, 9, 30));
      expect(next.estado, AgendaEstado.pendiente);
      expect(next.completedAnimalIds, isEmpty);
      expect(next.activities, isEmpty);
      expect(next.evidence, isEmpty);
      expect(next.checklist.single.completed, isFalse);
      expect(next.checklist.single.completedById, isNull);
      expect(next.checklist.single.label, 'Preparar dosis');
    });
  });
}
