library;

import 'package:libretapp/features/milking/domain/milking_models.dart';

abstract class MilkingRepository {
  Future<MilkingSession?> getOpenDraft();
  Future<MilkingSession?> getSession(String uuid);
  Future<List<MilkingSession>> getAllSessions();
  Future<List<MilkingEntry>> getAllEntries();
  Future<List<MilkingEntry>> getEntries(String sessionUuid);
  Future<List<MilkingRecord>> getRecordsByAnimal(String animalUuid);

  /// Milking records for several animals at once, keyed by animal uuid and
  /// optionally limited to sessions on or after [since].
  ///
  /// The date lives on the session rather than the entry, so callers cannot do
  /// this join themselves without loading every session.
  Future<Map<String, List<MilkingRecord>>> getRecordsForAnimals(
    Set<String> animalUuids, {
    DateTime? since,
  });
  Future<void> upsertSession(MilkingSession session);
  Future<MilkingEntry> upsertEntry(MilkingEntry entry);
  Future<void> deleteEntry(String uuid);
  Future<void> finalizeSession(String sessionUuid);
  Future<void> replaceAll({
    required List<MilkingSession> sessions,
    required List<MilkingEntry> entries,
  });
}
