import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/data/eventos_export_sheet.dart';
import 'package:libretapp/features/agenda/data/workforce_model.dart';
import 'package:libretapp/features/agenda/data/workforce_repository.dart';

class _FakeAgendaRepository implements AgendaRepository {
  _FakeAgendaRepository(this._entries);
  final List<AgendaEntry> _entries;

  @override
  Future<List<AgendaEntry>> fetchEntries() async => _entries;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWorkforceRepository implements WorkforceRepository {
  _FakeWorkforceRepository({this.workers = const [], this.teams = const []});
  final List<WorkerProfile> workers;
  final List<WorkTeam> teams;

  @override
  Future<List<WorkerProfile>> fetchWorkers({bool includeInactive = false}) async => workers;

  @override
  Future<List<WorkTeam>> fetchTeams({bool includeInactive = false}) async => teams;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AgendaEntry _entry({
  String id = 'entry-1',
  List<String> collaboratorIds = const [],
  String? assigneeId,
  String? workTeamId,
}) {
  return AgendaEntry(
    id: id,
    titulo: 'Vacunar lote norte',
    descripcion: 'Refuerzo semestral',
    fecha: DateTime(2026, 1, 15, 9, 30),
    tipo: 'sanitario',
    animalIds: const ['animal-1', 'animal-2'],
    loteIds: const [],
    ubicacion: 'Corral norte',
    estado: AgendaEstado.pendiente,
    completedAnimalIds: const ['animal-1'],
    notas: '',
    assigneeId: assigneeId,
    workTeamId: workTeamId,
    collaboratorIds: collaboratorIds,
  );
}

final _fixedDate = DateTime(2026, 1, 1);

List<Data?> _row(Excel excel, int index) => excel['Eventos'].rows[index];

String? _text(Data? cell) => cell?.value?.toString();

void main() {
  test('writes the header row and one row per entry, resolving worker/team names', () async {
    final repository = _FakeAgendaRepository([
      _entry(assigneeId: 'w1', workTeamId: 't1', collaboratorIds: const ['w2']),
    ]);
    final workforce = _FakeWorkforceRepository(
      workers: [
        WorkerProfile(
          id: 'w1',
          name: 'Juan',
          role: 'Encargado',
          active: true,
          createdAt: _fixedDate,
          updatedAt: _fixedDate,
        ),
        WorkerProfile(
          id: 'w2',
          name: 'Ana',
          role: 'Ayudante',
          active: true,
          createdAt: _fixedDate,
          updatedAt: _fixedDate,
        ),
      ],
      teams: [
        WorkTeam(
          id: 't1',
          name: 'Equipo Sanidad',
          memberIds: const ['w1', 'w2'],
          active: true,
          createdAt: _fixedDate,
          updatedAt: _fixedDate,
        ),
      ],
    );
    final sheet = EventosExportSheet(
      agendaRepository: repository,
      workforceRepository: workforce,
    );
    final excel = Excel.createExcel();

    await sheet.writeTo(excel);

    final rows = excel['Eventos'].rows;
    expect(rows, hasLength(2));
    expect(_text(_row(excel, 0)[0]), 'Título');

    final dataRow = _row(excel, 1);
    expect(_text(dataRow[0]), 'Vacunar lote norte');
    expect(_text(dataRow[4]), 'animal-1, animal-2');
    expect(_text(dataRow[8]), '1/2', reason: '1 of 2 animals completed');
    expect(_text(dataRow[9]), 'Juan', reason: 'assigneeId resolved to worker name');
    expect(_text(dataRow[10]), 'Equipo Sanidad', reason: 'workTeamId resolved to team name');
    expect(_text(dataRow[11]), 'Ana', reason: 'collaboratorIds resolved to worker names');
  });

  test('falls back to the raw id when a worker/team cannot be resolved', () async {
    final repository = _FakeAgendaRepository([_entry(assigneeId: 'missing-worker')]);
    final sheet = EventosExportSheet(
      agendaRepository: repository,
      workforceRepository: _FakeWorkforceRepository(),
    );
    final excel = Excel.createExcel();

    await sheet.writeTo(excel);

    final dataRow = _row(excel, 1);
    expect(_text(dataRow[9]), '', reason: 'unresolved assigneeId falls back to empty, not the raw id');
  });

  test('writes an empty sheet (header only) when there are no entries', () async {
    final sheet = EventosExportSheet(
      agendaRepository: _FakeAgendaRepository(const []),
      workforceRepository: _FakeWorkforceRepository(),
    );
    final excel = Excel.createExcel();

    await sheet.writeTo(excel);

    expect(excel['Eventos'].rows, hasLength(1));
  });
}
