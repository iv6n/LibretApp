library;

import 'backup_models.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/workforce_model.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';

/// Validated legacy payload. A store must apply every collection atomically.
class LegacyBackupSnapshot {
  const LegacyBackupSnapshot({required this.animals, required this.lotes,
    required this.agenda, required this.workers, required this.teams,
    required this.milkingSessions, required this.milkingEntries});
  final List<AnimalEntity> animals;
  final List<LoteEntity> lotes;
  final List<AgendaEntry> agenda;
  final List<WorkerProfile> workers;
  final List<WorkTeam> teams;
  final List<MilkingSession> milkingSessions;
  final List<MilkingEntry> milkingEntries;
}

abstract interface class TransactionalLegacyBackupStore {
  Future<BackupRestoreResult> restoreLegacy(LegacyBackupSnapshot snapshot,
      {required BackupImportMode mode});
}
