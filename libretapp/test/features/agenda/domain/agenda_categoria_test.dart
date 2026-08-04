import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/agenda/domain/agenda_categoria.dart';

void main() {
  group('categoriaForTipo', () {
    const casos = {
      'Vacunación': AgendaCategoria.sanidad,
      'Desparasitación': AgendaCategoria.sanidad,
      'Baño garrapaticida': AgendaCategoria.sanidad,
      'Suplemento/Vitaminas': AgendaCategoria.sanidad,
      'Revisión de casco': AgendaCategoria.sanidad,
      'Revisión veterinaria': AgendaCategoria.sanidad,
      'Cuidado': AgendaCategoria.sanidad,
      'Inseminación': AgendaCategoria.reproduccion,
      'Parto': AgendaCategoria.reproduccion,
      'Gestación': AgendaCategoria.reproduccion,
      'Chequeo reproductivo': AgendaCategoria.reproduccion,
      'Pesaje': AgendaCategoria.produccion,
      'Movimiento de lote': AgendaCategoria.movimientos,
      'Mantenimiento': AgendaCategoria.administracion,
      'Alerta': AgendaCategoria.administracion,
      'Recordatorio': AgendaCategoria.administracion,
    };

    for (final entry in casos.entries) {
      test('${entry.key} → ${entry.value.name}', () {
        expect(categoriaForTipo(entry.key), entry.value);
      });
    }

    test('un tipo desconocido cae en otros', () {
      expect(categoriaForTipo('Algo inventado'), AgendaCategoria.otros);
    });

    test('la comparación no distingue mayúsculas/minúsculas', () {
      expect(categoriaForTipo('VACUNACIÓN'), AgendaCategoria.sanidad);
    });
  });
}
