import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/services/backup_service.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/data/workforce_model.dart';
import 'package:libretapp/features/agenda/data/workforce_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_dto.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';

import '../../features/directorio/animales/advisor/rules/rule_test_fixtures.dart';

class _FakeAnimalRepository implements AnimalRepository {
  final Map<String, AnimalEntity> byUuid = {};
  final List<AnimalEntity> archivedOnly = [];
  bool cleared = false;

  @override
  Future<List<AnimalEntity>> getAll() async => byUuid.values.toList();

  Future<List<AnimalEntity>> getAllIncludingArchived() async => [
    ...byUuid.values,
    ...archivedOnly,
  ];

  @override
  Future<AnimalEntity?> getByUuid(String uuid) async => byUuid[uuid];

  @override
  Future<AnimalEntity> save(AnimalEntity animal) async {
    byUuid[animal.uuid] = animal;
    return animal;
  }

  @override
  Future<AnimalEntity> update(AnimalEntity animal) async {
    byUuid[animal.uuid] = animal;
    return animal;
  }

  @override
  Future<void> clearAll() async {
    cleared = true;
    byUuid.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeLotesRepository implements LotesRepository {
  final Map<String, LoteEntity> byUuid = {};
  bool cleared = false;

  @override
  Future<List<LoteEntity>> getAll() async => byUuid.values.toList();

  @override
  Future<void> upsert(LoteEntity lote) async {
    byUuid[lote.uuid] = lote;
  }

  @override
  Future<void> clearAll() async {
    cleared = true;
    byUuid.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeAgendaRepository implements AgendaRepository {
  final List<AgendaEntry> entries = [];
  bool cleared = false;

  @override
  Future<List<AgendaEntry>> fetchEntries() async => List.of(entries);

  @override
  Future<void> saveEntry(AgendaEntry entry) async => entries.add(entry);

  @override
  Future<void> replaceAll(List<AgendaEntry> newEntries) async {
    entries
      ..clear()
      ..addAll(newEntries);
  }

  @override
  Future<void> clearAll() async {
    cleared = true;
    entries.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeWorkforceRepository implements WorkforceRepository {
  final List<WorkerProfile> workers = [];
  final List<WorkTeam> teams = [];

  @override
  Future<List<WorkerProfile>> fetchWorkers({bool includeInactive = false}) async =>
      List.of(workers);

  @override
  Future<List<WorkTeam>> fetchTeams({bool includeInactive = false}) async =>
      List.of(teams);

  @override
  Future<void> saveWorker(WorkerProfile worker) async => workers.add(worker);

  @override
  Future<void> saveTeam(WorkTeam team) async => teams.add(team);

  @override
  Future<void> replaceAll({
    required List<WorkerProfile> workers,
    required List<WorkTeam> teams,
  }) async {
    this.workers
      ..clear()
      ..addAll(workers);
    this.teams
      ..clear()
      ..addAll(teams);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeMilkingRepository implements MilkingRepository {
  final List<MilkingSession> sessions = [];
  final List<MilkingEntry> entries = [];

  @override
  Future<List<MilkingSession>> getAllSessions() async => List.of(sessions);

  @override
  Future<List<MilkingEntry>> getAllEntries() async => List.of(entries);

  @override
  Future<void> upsertSession(MilkingSession session) async =>
      sessions.add(session);

  @override
  Future<MilkingEntry> upsertEntry(MilkingEntry entry) async {
    entries.add(entry);
    return entry;
  }

  @override
  Future<void> replaceAll({
    required List<MilkingSession> sessions,
    required List<MilkingEntry> entries,
  }) async {
    this.sessions
      ..clear()
      ..addAll(sessions);
    this.entries
      ..clear()
      ..addAll(entries);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Repos {
  _Repos()
    : animals = _FakeAnimalRepository(),
      lotes = _FakeLotesRepository(),
      agenda = _FakeAgendaRepository(),
      workforce = _FakeWorkforceRepository(),
      milking = _FakeMilkingRepository();

  final _FakeAnimalRepository animals;
  final _FakeLotesRepository lotes;
  final _FakeAgendaRepository agenda;
  final _FakeWorkforceRepository workforce;
  final _FakeMilkingRepository milking;

  BackupService service({
    Future<List<AnimalEntity>> Function()? fetchAllAnimalsIncludingArchived,
  }) {
    return BackupService(
      animalRepository: animals,
      lotesRepository: lotes,
      agendaRepository: agenda,
      workforceRepository: workforce,
      milkingRepository: milking,
      fetchAllAnimalsIncludingArchived: fetchAllAnimalsIncludingArchived,
    );
  }
}

final _fixedDate = DateTime(2026, 1, 1);

LoteEntity _lote(String uuid) => LoteEntity(
  uuid: uuid,
  name: 'Lote $uuid',
  createdAt: _fixedDate,
  lastUpdateDate: _fixedDate,
);

String _validBackupJson({
  int schemaVersion = 3,
  List<Map<String, dynamic>> animals = const [],
  List<Map<String, dynamic>> lotes = const [],
  Map<String, dynamic>? extraData,
}) {
  return jsonEncode({
    'schemaVersion': schemaVersion,
    'appVersion': '1.0.0+1',
    'exportedAt': _fixedDate.toIso8601String(),
    'data': {'animals': animals, 'lotes': lotes, ...?extraData},
  });
}

void main() {
  group('exportToJsonString', () {
    test('uses the archived-animals hook when provided', () async {
      final repos = _Repos();
      await repos.animals.save(_animal('a1'));
      repos.animals.archivedOnly.add(_animal('a2-archived'));
      final service = repos.service(
        fetchAllAnimalsIncludingArchived: repos.animals.getAllIncludingArchived,
      );

      final json = await service.exportToJsonString();
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      final animalUuids = (decoded['data']['animals'] as List)
          .map((e) => (e as Map<String, dynamic>)['uuid'])
          .toSet();

      expect(animalUuids, {'a1', 'a2-archived'});
    });

    test('falls back to getAll when no hook is provided', () async {
      final repos = _Repos();
      await repos.animals.save(_animal('a1'));
      repos.animals.archivedOnly.add(_animal('a2-archived'));
      final service = repos.service();

      final json = await service.exportToJsonString();
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      final animalUuids = (decoded['data']['animals'] as List)
          .map((e) => (e as Map<String, dynamic>)['uuid'])
          .toSet();

      expect(animalUuids, {'a1'});
    });
  });

  group('importFromJsonString validation', () {
    late BackupService service;

    setUp(() => service = _Repos().service());

    test('rejects a payload that is not a JSON object', () async {
      await expectLater(
        () => service.importFromJsonString(
          jsonEncode([1, 2, 3]),
          mode: BackupImportMode.merge,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a missing or invalid schemaVersion', () async {
      final raw = jsonEncode({'data': {}});
      await expectLater(
        () => service.importFromJsonString(raw, mode: BackupImportMode.merge),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a schemaVersion newer than supported', () async {
      final raw = _validBackupJson(schemaVersion: 99);
      await expectLater(
        () => service.importFromJsonString(raw, mode: BackupImportMode.merge),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a payload missing the data block', () async {
      final raw = jsonEncode({'schemaVersion': 3});
      await expectLater(
        () => service.importFromJsonString(raw, mode: BackupImportMode.merge),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects duplicate animal uuids', () async {
      final dto = _animalDtoJson('dup-1');
      final raw = _validBackupJson(animals: [dto, dto]);
      await expectLater(
        () => service.importFromJsonString(raw, mode: BackupImportMode.merge),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a milking entry pointing at a non-existent session', () async {
      final raw = _validBackupJson(
        extraData: {
          'milkingEntries': [
            {
              'uuid': 'entry-1',
              'sessionUuid': 'missing-session',
              'animalUuid': 'a1',
              'volumeMilliliters': 500,
              'createdAt': _fixedDate.toIso8601String(),
              'updatedAt': _fixedDate.toIso8601String(),
            },
          ],
        },
      );
      await expectLater(
        () => service.importFromJsonString(raw, mode: BackupImportMode.merge),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('importFromJsonString — merge', () {
    test('creates a new animal and updates an existing one by uuid', () async {
      final repos = _Repos();
      final existing = _animal('a1');
      await repos.animals.save(existing);
      final service = repos.service();

      final raw = _validBackupJson(
        animals: [_animalDtoJson('a1'), _animalDtoJson('a2')],
      );
      final summary = await service.importFromJsonString(
        raw,
        mode: BackupImportMode.merge,
      );

      expect(summary.animalsImported, 2);
      expect(repos.animals.byUuid.keys, containsAll(['a1', 'a2']));
      expect(repos.animals.cleared, isFalse);
    });

    test('does not clear existing agenda/workforce/milking data', () async {
      final repos = _Repos();
      repos.agenda.entries.add(_agendaEntry('existing'));
      final service = repos.service();

      final raw = _validBackupJson();
      await service.importFromJsonString(raw, mode: BackupImportMode.merge);

      expect(repos.agenda.cleared, isFalse);
      expect(repos.agenda.entries.map((e) => e.id), contains('existing'));
    });
  });

  group('importFromJsonString — replaceAll', () {
    test('clears repositories before importing', () async {
      final repos = _Repos();
      await repos.animals.save(_animal('stale'));
      await repos.lotes.upsert(_lote('stale-lote'));
      final service = repos.service();

      final raw = _validBackupJson(animals: [_animalDtoJson('fresh')]);
      await service.importFromJsonString(raw, mode: BackupImportMode.replaceAll);

      expect(repos.animals.cleared, isTrue);
      expect(repos.lotes.cleared, isTrue);
      expect(repos.animals.byUuid.keys, ['fresh']);
    });
  });

  test('round-trips export -> import through real DTOs', () async {
    final source = _Repos();
    await source.animals.save(_animal('roundtrip-1'));
    await source.lotes.upsert(_lote('lote-1'));
    source.agenda.entries.add(_agendaEntry('task-1'));
    final sourceService = source.service();

    final json = await sourceService.exportToJsonString();

    final target = _Repos();
    final targetService = target.service();
    final summary = await targetService.importFromJsonString(
      json,
      mode: BackupImportMode.merge,
    );

    expect(summary.animalsImported, 1);
    expect(summary.lotesImported, 1);
    expect(summary.agendaEntriesImported, 1);
    expect(target.animals.byUuid.keys, contains('roundtrip-1'));
    expect(target.lotes.byUuid.keys, contains('lote-1'));
  });
}

AnimalEntity _animal(String uuid) => buildAnimal().copyWith(uuid: uuid);

Map<String, dynamic> _animalDtoJson(String uuid) =>
    AnimalDto.fromEntity(_animal(uuid)).toJson();

AgendaEntry _agendaEntry(String id) => AgendaEntry(
  id: id,
  titulo: 'Tarea $id',
  descripcion: '',
  fecha: _fixedDate,
  tipo: 'general',
  animalIds: const [],
  loteIds: const [],
  ubicacion: '',
  estado: AgendaEstado.pendiente,
  completedAnimalIds: const [],
  notas: '',
);
