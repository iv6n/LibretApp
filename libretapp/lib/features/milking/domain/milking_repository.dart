library;

import 'package:libretapp/features/milking/domain/milking_models.dart';

abstract class MilkingRepository {
  Future<MilkingSession?> getOpenDraft();
  Future<MilkingSession?> getSession(String uuid);
  Future<List<MilkingSession>> getAllSessions();
  Future<List<MilkingEntry>> getAllEntries();
  Future<List<MilkingEntry>> getEntries(String sessionUuid);
  Future<List<MilkingRecord>> getRecordsByAnimal(String animalUuid);
  Future<void> upsertSession(MilkingSession session);
  Future<MilkingEntry> upsertEntry(MilkingEntry entry);
  Future<void> deleteEntry(String uuid);
  Future<void> finalizeSession(String sessionUuid);
  Future<void> replaceAll({
    required List<MilkingSession> sessions,
    required List<MilkingEntry> entries,
  });

  // Sincronización (respaldo en la nube): dos colecciones comparten este
  // repositorio, por lo que se expone un par get/mark por cada una en vez de
  // un único SyncableRepository<T>.
  Future<List<MilkingSession>> getUnsynchronizedSessions();
  Future<void> markSessionSynced(String uuid, String remoteId);
  Future<List<MilkingEntry>> getUnsynchronizedEntries();
  Future<void> markEntrySynced(String uuid, String remoteId);
}
