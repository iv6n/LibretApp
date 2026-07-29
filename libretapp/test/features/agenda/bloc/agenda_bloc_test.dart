import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/agenda/bloc/agenda_bloc.dart';
import 'package:libretapp/features/agenda/bloc/agenda_event.dart';
import 'package:libretapp/features/agenda/bloc/agenda_state.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

class _FakeAgendaRepository implements AgendaRepository {
  _FakeAgendaRepository([List<AgendaEntry> seed = const []])
    : _entries = List<AgendaEntry>.from(seed);

  final List<AgendaEntry> _entries;
  bool failFetch = false;
  bool failSave = false;
  bool failUpdate = false;
  bool failDelete = false;
  bool failGetEntry = false;

  @override
  Future<List<AgendaEntry>> fetchEntries() async {
    if (failFetch) throw StateError('fetchEntries failed');
    return List<AgendaEntry>.unmodifiable(_entries);
  }

  @override
  Future<AgendaEntry> getEntry(String id) async {
    if (failGetEntry) throw StateError('getEntry failed');
    return _entries.firstWhere((e) => e.id == id);
  }

  @override
  Future<void> saveEntry(AgendaEntry entry) async {
    if (failSave) throw StateError('saveEntry failed');
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index == -1) {
      _entries.add(entry);
    } else {
      _entries[index] = entry;
    }
  }

  @override
  Future<void> updateEntry(AgendaEntry entry) async {
    if (failUpdate) throw StateError('updateEntry failed');
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) _entries[index] = entry;
  }

  @override
  Future<void> deleteEntry(String id) async {
    if (failDelete) throw StateError('deleteEntry failed');
    _entries.removeWhere((e) => e.id == id);
  }

  @override
  Future<void> replaceAll(List<AgendaEntry> entries) async {
    _entries
      ..clear()
      ..addAll(entries);
  }

  @override
  Future<void> clearAll() async => _entries.clear();
}

class _FakeLotesRepository implements LotesRepository {
  _FakeLotesRepository([Map<String, LoteEntity> lotes = const {}])
    : _lotes = Map<String, LoteEntity>.from(lotes);

  final Map<String, LoteEntity> _lotes;

  @override
  Future<LoteEntity?> getByUuid(String uuid) async => _lotes[uuid];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LoteEntity _buildLote({required String uuid, required List<String> animalUuids}) {
  final now = DateTime(2024, 6, 1);
  return LoteEntity(
    uuid: uuid,
    name: 'Lote $uuid',
    animalUuids: animalUuids,
    createdAt: now,
    lastUpdateDate: now,
  );
}

AgendaEntry _buildEntry({
  String id = 'entry-1',
  String estado = AgendaEstado.pendiente,
  List<String> animalIds = const [],
  List<String> loteIds = const [],
  List<String> completedAnimalIds = const [],
  List<AgendaChecklistItem> checklist = const [],
  List<AgendaActivity> activities = const [],
  String? blockedReason,
  DateTime? fechaCompletado,
  String? recurrenceRule,
}) {
  final fecha = DateTime(2024, 6, 1);
  return AgendaEntry(
    id: id,
    titulo: 'Tarea de prueba',
    descripcion: 'Descripción de prueba',
    fecha: fecha,
    tipo: 'sanitario',
    animalIds: animalIds,
    loteIds: loteIds,
    ubicacion: 'Potrero 1',
    estado: estado,
    completedAnimalIds: completedAnimalIds,
    notas: '',
    blockedReason: blockedReason,
    checklist: checklist,
    activities: activities,
    fechaCompletado: fechaCompletado,
    recurrenceRule: recurrenceRule,
  );
}

Future<void> _flushEvents() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(const Duration(milliseconds: 20));
}

void main() {
  group('AgendaBloc — LoadAgenda', () {
    test('emits loading then loaded with the fetched entries', () async {
      final repository = _FakeAgendaRepository([_buildEntry()]);
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);
      final emitted = <AgendaState>[];
      bloc.stream.listen(emitted.add);

      bloc.add(const LoadAgenda());
      await _flushEvents();

      expect(emitted, [isA<AgendaLoading>(), isA<AgendaLoaded>()]);
      expect((emitted.last as AgendaLoaded).entries, hasLength(1));
    });

    test('emits an error state when the repository throws', () async {
      final repository = _FakeAgendaRepository()..failFetch = true;
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);
      final emitted = <AgendaState>[];
      bloc.stream.listen(emitted.add);

      bloc.add(const LoadAgenda());
      await _flushEvents();

      expect(emitted.last, isA<AgendaError>());
    });
  });

  group('AgendaBloc — AddAgendaEntry', () {
    test('saves the entry and reloads the list', () async {
      final repository = _FakeAgendaRepository();
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(AddAgendaEntry(_buildEntry(id: 'new-entry')));
      await _flushEvents();

      expect(bloc.state, isA<AgendaLoaded>());
      final loaded = bloc.state as AgendaLoaded;
      expect(loaded.entries.map((e) => e.id), contains('new-entry'));
    });

    test('emits an error state when saving fails', () async {
      final repository = _FakeAgendaRepository()..failSave = true;
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(AddAgendaEntry(_buildEntry()));
      await _flushEvents();

      expect(bloc.state, isA<AgendaError>());
    });
  });

  group('AgendaBloc — UpdateAgendaEntry', () {
    test('updates the entry and reloads the list', () async {
      final repository = _FakeAgendaRepository([_buildEntry()]);
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(UpdateAgendaEntry(_buildEntry(estado: AgendaEstado.enProgreso)));
      await _flushEvents();

      final loaded = bloc.state as AgendaLoaded;
      expect(loaded.entries.single.estado, AgendaEstado.enProgreso);
    });

    test('emits an error state when updating fails', () async {
      final repository = _FakeAgendaRepository([_buildEntry()])..failUpdate = true;
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(UpdateAgendaEntry(_buildEntry(estado: AgendaEstado.enProgreso)));
      await _flushEvents();

      expect(bloc.state, isA<AgendaError>());
    });
  });

  group('AgendaBloc — DeleteAgendaEntry', () {
    test('removes the entry and reloads the list', () async {
      final repository = _FakeAgendaRepository([_buildEntry(id: 'to-delete')]);
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const DeleteAgendaEntry('to-delete'));
      await _flushEvents();

      final loaded = bloc.state as AgendaLoaded;
      expect(loaded.entries, isEmpty);
    });

    test('emits an error state when deleting fails', () async {
      final repository = _FakeAgendaRepository([_buildEntry(id: 'to-delete')])
        ..failDelete = true;
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const DeleteAgendaEntry('to-delete'));
      await _flushEvents();

      expect(bloc.state, isA<AgendaError>());
    });
  });

  group('AgendaBloc — MarkAnimalCompleted', () {
    test('marks the sole animal done and moves estado to completado', () async {
      final repository = _FakeAgendaRepository([
        _buildEntry(animalIds: const ['animal-1']),
      ]);
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(
        const MarkAnimalCompleted(entryId: 'entry-1', animalId: 'animal-1'),
      );
      await _flushEvents();

      final entry = (bloc.state as AgendaLoaded).entries.single;
      expect(entry.completedAnimalIds, ['animal-1']);
      expect(entry.estado, AgendaEstado.completado);
      expect(entry.fechaCompletado, isNotNull);
      expect(
        entry.activities.any((a) => a.type == 'animal_completed'),
        isTrue,
      );
    });

    test('moves estado to en_progreso when only some animals are done', () async {
      final repository = _FakeAgendaRepository([
        _buildEntry(animalIds: const ['animal-1', 'animal-2']),
      ]);
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(
        const MarkAnimalCompleted(entryId: 'entry-1', animalId: 'animal-1'),
      );
      await _flushEvents();

      final entry = (bloc.state as AgendaLoaded).entries.single;
      expect(entry.estado, AgendaEstado.enProgreso);
      expect(entry.fechaCompletado, isNull);
    });

    test('does not duplicate an animal id marked done twice', () async {
      final repository = _FakeAgendaRepository([
        _buildEntry(
          animalIds: const ['animal-1', 'animal-2'],
          completedAnimalIds: const ['animal-1'],
        ),
      ]);
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(
        const MarkAnimalCompleted(entryId: 'entry-1', animalId: 'animal-1'),
      );
      await _flushEvents();

      final entry = (bloc.state as AgendaLoaded).entries.single;
      expect(entry.completedAnimalIds, ['animal-1']);
    });

    test('expands lote membership when checking whether all animals are done', () async {
      final repository = _FakeAgendaRepository([
        _buildEntry(loteIds: const ['lote-1']),
      ]);
      final lotesRepository = _FakeLotesRepository({
        'lote-1': _buildLote(uuid: 'lote-1', animalUuids: ['animal-1', 'animal-2']),
      });
      final bloc = AgendaBloc(repository, lotesRepository: lotesRepository);
      addTearDown(bloc.close);

      bloc.add(
        const MarkAnimalCompleted(entryId: 'entry-1', animalId: 'animal-1'),
      );
      await _flushEvents();

      var entry = (bloc.state as AgendaLoaded).entries.single;
      expect(entry.estado, AgendaEstado.enProgreso);

      bloc.add(
        const MarkAnimalCompleted(entryId: 'entry-1', animalId: 'animal-2'),
      );
      await _flushEvents();

      entry = (bloc.state as AgendaLoaded).entries.single;
      expect(entry.estado, AgendaEstado.completado);
    });

    test('emits an error state when the entry does not exist', () async {
      final repository = _FakeAgendaRepository();
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(
        const MarkAnimalCompleted(entryId: 'missing', animalId: 'animal-1'),
      );
      await _flushEvents();

      expect(bloc.state, isA<AgendaError>());
    });

    test('schedules the next occurrence when a recurring task becomes completado', () async {
      final repository = _FakeAgendaRepository([
        _buildEntry(animalIds: const ['animal-1'], recurrenceRule: 'weekly'),
      ]);
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(
        const MarkAnimalCompleted(entryId: 'entry-1', animalId: 'animal-1'),
      );
      await _flushEvents();

      final entries = (bloc.state as AgendaLoaded).entries;
      expect(entries, hasLength(2));
      final next = entries.firstWhere((e) => e.id != 'entry-1');
      expect(next.estado, AgendaEstado.pendiente);
      expect(next.recurrenceRule, 'weekly');
      expect(next.fecha, DateTime(2024, 6, 8));
    });
  });

  group('AgendaBloc — ChangeAgendaStatus', () {
    test('changes estado and records an activity entry', () async {
      final repository = _FakeAgendaRepository([_buildEntry()]);
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(
        const ChangeAgendaStatus(
          entryId: 'entry-1',
          status: AgendaEstado.enProgreso,
          actorId: 'worker-1',
        ),
      );
      await _flushEvents();

      final entry = (bloc.state as AgendaLoaded).entries.single;
      expect(entry.estado, AgendaEstado.enProgreso);
      expect(
        entry.activities.any(
          (a) =>
              a.type == 'status_changed:${AgendaEstado.enProgreso}' &&
              a.actorId == 'worker-1',
        ),
        isTrue,
      );
    });

    test('sets fechaCompletado when moving to completado', () async {
      final repository = _FakeAgendaRepository([_buildEntry()]);
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(
        const ChangeAgendaStatus(
          entryId: 'entry-1',
          status: AgendaEstado.completado,
        ),
      );
      await _flushEvents();

      final entry = (bloc.state as AgendaLoaded).entries.single;
      expect(entry.fechaCompletado, isNotNull);
    });

    test('schedules the next occurrence when a recurring task becomes completado', () async {
      final repository = _FakeAgendaRepository([
        _buildEntry(recurrenceRule: 'monthly'),
      ]);
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(
        const ChangeAgendaStatus(
          entryId: 'entry-1',
          status: AgendaEstado.completado,
        ),
      );
      await _flushEvents();

      final entries = (bloc.state as AgendaLoaded).entries;
      expect(entries, hasLength(2));
      final next = entries.firstWhere((e) => e.id != 'entry-1');
      expect(next.estado, AgendaEstado.pendiente);
      expect(next.recurrenceRule, 'monthly');
      expect(next.fecha, DateTime(2024, 7, 1));
    });

    test('does not schedule another occurrence when already completado', () async {
      final repository = _FakeAgendaRepository([
        _buildEntry(
          estado: AgendaEstado.completado,
          recurrenceRule: 'weekly',
        ),
      ]);
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(
        const ChangeAgendaStatus(
          entryId: 'entry-1',
          status: AgendaEstado.verificado,
        ),
      );
      await _flushEvents();

      final entries = (bloc.state as AgendaLoaded).entries;
      expect(entries, hasLength(1));
    });

    test('records the trimmed reason as blockedReason when blocking', () async {
      final repository = _FakeAgendaRepository([_buildEntry()]);
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(
        const ChangeAgendaStatus(
          entryId: 'entry-1',
          status: AgendaEstado.bloqueado,
          reason: '  Falta insumo  ',
        ),
      );
      await _flushEvents();

      final entry = (bloc.state as AgendaLoaded).entries.single;
      expect(entry.blockedReason, 'Falta insumo');
    });

    test('clears a previous blockedReason when moving to a non-blocked status', () async {
      final repository = _FakeAgendaRepository([
        _buildEntry(
          estado: AgendaEstado.bloqueado,
          blockedReason: 'Falta insumo',
        ),
      ]);
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(
        const ChangeAgendaStatus(
          entryId: 'entry-1',
          status: AgendaEstado.pendiente,
        ),
      );
      await _flushEvents();

      final entry = (bloc.state as AgendaLoaded).entries.single;
      expect(entry.blockedReason, isNull);
    });

    test('emits an error state when the entry does not exist', () async {
      final repository = _FakeAgendaRepository();
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(
        const ChangeAgendaStatus(
          entryId: 'missing',
          status: AgendaEstado.completado,
        ),
      );
      await _flushEvents();

      expect(bloc.state, isA<AgendaError>());
    });
  });

  group('AgendaBloc — ToggleAgendaChecklistItem', () {
    test('marks the matching item completed and leaves others untouched', () async {
      final repository = _FakeAgendaRepository([
        _buildEntry(
          checklist: const [
            AgendaChecklistItem(id: 'item-1', label: 'Preparar dosis'),
            AgendaChecklistItem(id: 'item-2', label: 'Aplicar dosis'),
          ],
        ),
      ]);
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(
        const ToggleAgendaChecklistItem(
          entryId: 'entry-1',
          itemId: 'item-1',
          completed: true,
          actorId: 'worker-1',
        ),
      );
      await _flushEvents();

      final entry = (bloc.state as AgendaLoaded).entries.single;
      final item1 = entry.checklist.firstWhere((i) => i.id == 'item-1');
      final item2 = entry.checklist.firstWhere((i) => i.id == 'item-2');
      expect(item1.completed, isTrue);
      expect(item1.completedById, 'worker-1');
      expect(item1.completedAt, isNotNull);
      expect(item2.completed, isFalse);
      expect(
        entry.activities.any((a) => a.type == 'checklist_completed' && a.note == 'item-1'),
        isTrue,
      );
    });

    test('reopening an item clears its completedAt', () async {
      final now = DateTime(2024, 6, 1);
      final repository = _FakeAgendaRepository([
        _buildEntry(
          checklist: [
            AgendaChecklistItem(
              id: 'item-1',
              label: 'Preparar dosis',
              completed: true,
              completedById: 'worker-1',
              completedAt: now,
            ),
          ],
        ),
      ]);
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(
        const ToggleAgendaChecklistItem(
          entryId: 'entry-1',
          itemId: 'item-1',
          completed: false,
        ),
      );
      await _flushEvents();

      final entry = (bloc.state as AgendaLoaded).entries.single;
      final item1 = entry.checklist.single;
      expect(item1.completed, isFalse);
      expect(item1.completedAt, isNull);
      expect(
        entry.activities.any((a) => a.type == 'checklist_reopened'),
        isTrue,
      );
    });

    test('emits an error state when the entry does not exist', () async {
      final repository = _FakeAgendaRepository();
      final bloc = AgendaBloc(repository);
      addTearDown(bloc.close);

      bloc.add(
        const ToggleAgendaChecklistItem(
          entryId: 'missing',
          itemId: 'item-1',
          completed: true,
        ),
      );
      await _flushEvents();

      expect(bloc.state, isA<AgendaError>());
    });
  });
}
