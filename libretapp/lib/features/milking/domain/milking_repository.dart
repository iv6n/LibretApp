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
}
