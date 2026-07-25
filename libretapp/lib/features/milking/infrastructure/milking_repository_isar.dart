library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';
import 'package:libretapp/features/milking/infrastructure/isar/isar_milking_entry.dart';
import 'package:libretapp/features/milking/infrastructure/isar/isar_milking_session.dart';

class MilkingRepositoryIsar implements MilkingRepository {
  MilkingRepositoryIsar(this._database);

  final IsarDatabase _database;

  Future<Isar> get _isar async => _database.initialize();

  @override
  Future<MilkingSession?> getOpenDraft() async {
    final isar = await _isar;
    final records = await isar.isarMilkingSessions
        .filter()
        .statusEqualTo(MilkingStatus.draft.name)
        .sortByUpdatedAtDesc()
        .limit(1)
        .findAll();
    return records.firstOrNull?.toEntity();
  }

  @override
  Future<MilkingSession?> getSession(String uuid) async {
    final isar = await _isar;
    final record = await isar.isarMilkingSessions
        .where()
        .uuidEqualTo(uuid)
        .findFirst();
    return record?.toEntity();
  }

  @override
  Future<List<MilkingSession>> getAllSessions() async {
    final isar = await _isar;
    final records = await isar.isarMilkingSessions
        .where()
        .sortByOccurredAtDesc()
        .findAll();
    return records.map((record) => record.toEntity()).toList(growable: false);
  }

  @override
  Future<List<MilkingEntry>> getAllEntries() async {
    final isar = await _isar;
    final records = await isar.isarMilkingEntrys.where().findAll();
    return records.map((record) => record.toEntity()).toList(growable: false);
  }

  @override
  Future<List<MilkingEntry>> getEntries(String sessionUuid) async {
    final isar = await _isar;
    final records = await isar.isarMilkingEntrys
        .filter()
        .sessionUuidEqualTo(sessionUuid)
        .sortByCreatedAt()
        .findAll();
    return records.map((record) => record.toEntity()).toList(growable: false);
  }

  @override
  Future<List<MilkingRecord>> getRecordsByAnimal(String animalUuid) async {
    final isar = await _isar;
    final storedEntries = await isar.isarMilkingEntrys
        .filter()
        .animalUuidEqualTo(animalUuid)
        .findAll();
    if (storedEntries.isEmpty) return const [];

    final sessions = await getAllSessions();
    final byUuid = {for (final session in sessions) session.uuid: session};
    final records =
        storedEntries
            .map((stored) {
              final entry = stored.toEntity();
              final session = byUuid[entry.sessionUuid];
              return session == null
                  ? null
                  : MilkingRecord(session: session, entry: entry);
            })
            .whereType<MilkingRecord>()
            .toList(growable: false)
          ..sort(
            (a, b) => b.session.occurredAt.compareTo(a.session.occurredAt),
          );
    return records;
  }

  @override
  Future<void> upsertSession(MilkingSession session) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      final existing = await isar.isarMilkingSessions
          .where()
          .uuidEqualTo(session.uuid)
          .findFirst();
      final stored = session.toIsar();
      if (existing != null) stored.id = existing.id;
      await isar.isarMilkingSessions.put(stored);
    });
  }

  @override
  Future<MilkingEntry> upsertEntry(MilkingEntry entry) async {
    final isar = await _isar;
    final stored = entry.toIsar();
    await isar.writeTxn(() async {
      final existingByUuid = await isar.isarMilkingEntrys
          .where()
          .uuidEqualTo(entry.uuid)
          .findFirst();
      final existingForAnimal = await isar.isarMilkingEntrys
          .filter()
          .sessionUuidEqualTo(entry.sessionUuid)
          .and()
          .animalUuidEqualTo(entry.animalUuid)
          .findFirst();
      final existing = existingByUuid ?? existingForAnimal;
      if (existing != null) stored.id = existing.id;
      await isar.isarMilkingEntrys.put(stored);
    });
    return entry;
  }

  @override
  Future<void> deleteEntry(String uuid) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      final stored = await isar.isarMilkingEntrys
          .where()
          .uuidEqualTo(uuid)
          .findFirst();
      if (stored != null) await isar.isarMilkingEntrys.delete(stored.id);
    });
  }

  @override
  Future<void> finalizeSession(String sessionUuid) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      final session = await isar.isarMilkingSessions
          .where()
          .uuidEqualTo(sessionUuid)
          .findFirst();
      if (session == null) throw StateError('Sesión de ordeña no encontrada');
      final entryCount = await isar.isarMilkingEntrys
          .filter()
          .sessionUuidEqualTo(sessionUuid)
          .count();
      if (entryCount == 0) {
        throw StateError('Registra al menos una vaca antes de finalizar');
      }
      session
        ..status = MilkingStatus.completed.name
        ..updatedAt = DateTime.now();
      await isar.isarMilkingSessions.put(session);
    });
  }

  @override
  Future<void> replaceAll({
    required List<MilkingSession> sessions,
    required List<MilkingEntry> entries,
  }) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      await isar.isarMilkingEntrys.clear();
      await isar.isarMilkingSessions.clear();
      await isar.isarMilkingSessions.putAll(
        sessions.map((session) => session.toIsar()).toList(growable: false),
      );
      await isar.isarMilkingEntrys.putAll(
        entries.map((entry) => entry.toIsar()).toList(growable: false),
      );
    });
  }
}
