import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

AgendaEntry _buildEntry({
  required String id,
  required String titulo,
  DateTime? fecha,
  String estado = AgendaEstado.pendiente,
}) {
  return AgendaEntry(
    id: id,
    titulo: titulo,
    descripcion: 'Descripción de $titulo',
    fecha: fecha ?? DateTime(2025, 6, 15),
    tipo: 'sanitario',
    animalIds: const ['animal-1'],
    loteIds: const [],
    ubicacion: 'Potrero Norte',
    estado: estado,
    completedAnimalIds: const [],
    notas: 'Notas de prueba',
  );
}

Future<AgendaRepositoryImpl> _buildRepo() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  return AgendaRepositoryImpl(SharedPrefsService(prefs));
}

void main() {
  group('AgendaRepositoryImpl', () {
    test(
      'saveEntry persiste la entrada y fetchEntries la retorna con todos los campos',
      () async {
        final repo = await _buildRepo();
        final entry = _buildEntry(id: 'entrada-1', titulo: 'Vacunación lote A');

        await repo.saveEntry(entry);
        final entries = await repo.fetchEntries();

        expect(entries, hasLength(1));
        expect(entries.first.id, 'entrada-1');
        expect(entries.first.titulo, 'Vacunación lote A');
        expect(entries.first.descripcion, 'Descripción de Vacunación lote A');
        expect(entries.first.tipo, 'sanitario');
        expect(entries.first.ubicacion, 'Potrero Norte');
        expect(entries.first.estado, AgendaEstado.pendiente);
        expect(entries.first.animalIds, ['animal-1']);
        expect(entries.first.notas, 'Notas de prueba');
      },
    );

    test('getEntry retorna la entrada correcta por id', () async {
      final repo = await _buildRepo();

      await repo.saveEntry(_buildEntry(id: 'entrada-A', titulo: 'Pesaje'));
      await repo.saveEntry(
        _buildEntry(id: 'entrada-B', titulo: 'Desparasitación'),
      );

      final fetched = await repo.getEntry('entrada-B');

      expect(fetched.id, 'entrada-B');
      expect(fetched.titulo, 'Desparasitación');
    });

    test(
      'updateEntry modifica la entrada existente sin afectar las demás',
      () async {
        final repo = await _buildRepo();
        final original = _buildEntry(id: 'entrada-upd', titulo: 'Original');
        final otra = _buildEntry(id: 'entrada-otra', titulo: 'Sin cambios');

        await repo.saveEntry(original);
        await repo.saveEntry(otra);

        final actualizada = original.copyWith(
          titulo: 'Actualizado',
          estado: AgendaEstado.completado,
        );
        await repo.updateEntry(actualizada);

        final fetched = await repo.getEntry('entrada-upd');
        expect(fetched.titulo, 'Actualizado');
        expect(fetched.estado, AgendaEstado.completado);

        final fetchedOtra = await repo.getEntry('entrada-otra');
        expect(fetchedOtra.titulo, 'Sin cambios');
      },
    );

    test(
      'deleteEntry elimina solo la entrada indicada y deja el resto intacto',
      () async {
        final repo = await _buildRepo();

        await repo.saveEntry(_buildEntry(id: 'del-1', titulo: 'A eliminar'));
        await repo.saveEntry(_buildEntry(id: 'del-2', titulo: 'A conservar'));

        await repo.deleteEntry('del-1');
        final entries = await repo.fetchEntries();

        expect(entries, hasLength(1));
        expect(entries.first.id, 'del-2');
      },
    );

    test(
      'fetchEntries retorna las entradas ordenadas por fecha ascendente',
      () async {
        final repo = await _buildRepo();

        await repo.saveEntry(
          _buildEntry(
            id: 'orden-C',
            titulo: 'Tercera',
            fecha: DateTime(2025, 9, 1),
          ),
        );
        await repo.saveEntry(
          _buildEntry(
            id: 'orden-A',
            titulo: 'Primera',
            fecha: DateTime(2025, 3, 1),
          ),
        );
        await repo.saveEntry(
          _buildEntry(
            id: 'orden-B',
            titulo: 'Segunda',
            fecha: DateTime(2025, 6, 1),
          ),
        );

        final entries = await repo.fetchEntries();

        expect(entries[0].id, 'orden-A');
        expect(entries[1].id, 'orden-B');
        expect(entries[2].id, 'orden-C');
      },
    );

    test('clearAll vacía el repositorio', () async {
      final repo = await _buildRepo();

      await repo.saveEntry(_buildEntry(id: 'clear-1', titulo: 'Entrada'));
      await repo.clearAll();
      final entries = await repo.fetchEntries();

      expect(entries, isEmpty);
    });

    test('saveEntry actualiza la entrada si ya existe el mismo id', () async {
      final repo = await _buildRepo();
      final original = _buildEntry(id: 'upsert-1', titulo: 'Primero');
      final reemplazada = _buildEntry(id: 'upsert-1', titulo: 'Reemplazado');

      await repo.saveEntry(original);
      await repo.saveEntry(reemplazada);
      final entries = await repo.fetchEntries();

      expect(entries, hasLength(1));
      expect(entries.first.titulo, 'Reemplazado');
    });
  });
}
