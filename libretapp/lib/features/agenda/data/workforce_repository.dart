/// Persistence contract for local workers and work teams.
library;

import 'package:libretapp/features/agenda/data/workforce_model.dart';

abstract class WorkforceRepository {
  Future<List<WorkerProfile>> fetchWorkers({bool includeInactive = false});
  Future<List<WorkTeam>> fetchTeams({bool includeInactive = false});
  Future<void> saveWorker(WorkerProfile worker);
  Future<void> saveTeam(WorkTeam team);
  Future<void> archiveWorker(String id);
  Future<void> archiveTeam(String id);
  Future<void> replaceAll({
    required List<WorkerProfile> workers,
    required List<WorkTeam> teams,
  });

  // Two collections share this repository, so the sync surface is split into
  // one get/mark pair per collection rather than implementing a single
  // SyncableRepository<T>.
  Future<List<WorkerProfile>> getUnsynchronizedWorkers();
  Future<void> markWorkerSynced(String id, String remoteId);
  Future<List<WorkTeam>> getUnsynchronizedTeams();
  Future<void> markTeamSynced(String id, String remoteId);
}
