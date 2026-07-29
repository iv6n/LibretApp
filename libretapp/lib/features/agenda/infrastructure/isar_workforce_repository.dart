/// Isar implementation of the local workforce repository.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/agenda/data/workforce_model.dart';
import 'package:libretapp/features/agenda/data/workforce_repository.dart';
import 'package:libretapp/features/agenda/infrastructure/isar/isar_workforce.dart';

class IsarWorkforceRepository implements WorkforceRepository {
  IsarWorkforceRepository(this._database);

  final IsarDatabase _database;

  Future<Isar> get _isar => _database.initialize();

  @override
  Future<List<WorkerProfile>> fetchWorkers({bool includeInactive = false}) async {
    final isar = await _isar;
    final records = includeInactive
        ? await isar.isarWorkerProfiles.where().sortByName().findAll()
        : await isar.isarWorkerProfiles.filter().activeEqualTo(true).sortByName().findAll();
    return records.map((record) => record.toEntity()).toList(growable: false);
  }

  @override
  Future<List<WorkTeam>> fetchTeams({bool includeInactive = false}) async {
    final isar = await _isar;
    final records = includeInactive
        ? await isar.isarWorkTeams.where().sortByName().findAll()
        : await isar.isarWorkTeams.filter().activeEqualTo(true).sortByName().findAll();
    return records.map((record) => record.toEntity()).toList(growable: false);
  }

  @override
  Future<void> saveWorker(WorkerProfile worker) async {
    final isar = await _isar;
    final model = worker.toIsar();
    final existing = await isar.isarWorkerProfiles.where().uuidEqualTo(worker.id).findFirst();
    if (existing != null) model.isarId = existing.isarId;
    await isar.writeTxn(() => isar.isarWorkerProfiles.put(model));
  }

  @override
  Future<void> saveTeam(WorkTeam team) async {
    final isar = await _isar;
    final model = team.toIsar();
    final existing = await isar.isarWorkTeams.where().uuidEqualTo(team.id).findFirst();
    if (existing != null) model.isarId = existing.isarId;
    await isar.writeTxn(() => isar.isarWorkTeams.put(model));
  }

  @override
  Future<void> archiveWorker(String id) async {
    final isar = await _isar;
    final record = await isar.isarWorkerProfiles.where().uuidEqualTo(id).findFirst();
    if (record == null) return;
    record
      ..active = false
      ..updatedAt = DateTime.now();
    await isar.writeTxn(() => isar.isarWorkerProfiles.put(record));
  }

  @override
  Future<void> archiveTeam(String id) async {
    final isar = await _isar;
    final record = await isar.isarWorkTeams.where().uuidEqualTo(id).findFirst();
    if (record == null) return;
    record
      ..active = false
      ..updatedAt = DateTime.now();
    await isar.writeTxn(() => isar.isarWorkTeams.put(record));
  }

  @override
  Future<void> replaceAll({
    required List<WorkerProfile> workers,
    required List<WorkTeam> teams,
  }) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      await isar.isarWorkerProfiles.clear();
      await isar.isarWorkTeams.clear();
      await isar.isarWorkerProfiles.putAll(
        workers.map((worker) => worker.toIsar()).toList(growable: false),
      );
      await isar.isarWorkTeams.putAll(
        teams.map((team) => team.toIsar()).toList(growable: false),
      );
    });
  }
}
