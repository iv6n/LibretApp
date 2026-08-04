import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/agenda/domain/agenda_categoria.dart';
import 'package:libretapp/features/agenda/domain/agenda_realize_strategy.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';

void main() {
  group('realizeStrategyForCategoria', () {
    const casos = {
      AgendaCategoria.sanidad: AgendaRealizeStrategy.bulkHealth,
      AgendaCategoria.movimientos: AgendaRealizeStrategy.bulkMovement,
      AgendaCategoria.reproduccion: AgendaRealizeStrategy.queuedReproduction,
      AgendaCategoria.produccion: AgendaRealizeStrategy.queuedWeight,
      AgendaCategoria.administracion: AgendaRealizeStrategy.none,
      AgendaCategoria.otros: AgendaRealizeStrategy.none,
    };

    for (final entry in casos.entries) {
      test('${entry.key.name} → ${entry.value.name}', () {
        expect(realizeStrategyForCategoria(entry.key), entry.value);
      });
    }
  });

  group('healthRecordTypeForAgendaTipo', () {
    const casos = {
      'Vacunación': HealthRecordType.vaccine,
      'Desparasitación': HealthRecordType.deworming,
      'Baño garrapaticida': HealthRecordType.tickBath,
      'Suplemento/Vitaminas': HealthRecordType.vitamins,
      'Revisión de casco': HealthRecordType.checkup,
      'Revisión veterinaria': HealthRecordType.checkup,
      'Cuidado': HealthRecordType.other,
    };

    for (final entry in casos.entries) {
      test('${entry.key} → ${entry.value.name}', () {
        expect(healthRecordTypeForAgendaTipo(entry.key), entry.value);
      });
    }

    test('un tipo fuera de Sanidad no tiene HealthRecordType sugerido', () {
      expect(healthRecordTypeForAgendaTipo('Parto'), isNull);
    });

    test('la comparación no distingue mayúsculas/minúsculas', () {
      expect(healthRecordTypeForAgendaTipo('VACUNACIÓN'), HealthRecordType.vaccine);
    });
  });
}
