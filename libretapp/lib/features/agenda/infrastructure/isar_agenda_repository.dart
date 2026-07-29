/// Isar-backed agenda repository with a lossless SharedPreferences migration.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/infrastructure/isar/isar_agenda_entry.dart';

class IsarAgendaRepository implements AgendaRepository {
  IsarAgendaRepository(this._database, this._prefs);

  final IsarDatabase _database;
  final SharedPrefsService _prefs;

  Future<Isar> get _isar async {
    final isar = await _database.initialize();
    await _migrateLegacyIfNeeded(isar);
    return isar;
  }

  Future<void> _migrateLegacyIfNeeded(Isar isar) async {
    if (_prefs.getBool(PrefsKeys.agendaIsarMigrationV1Done) == true) return;

    final legacy = await AgendaRepositoryImpl(_prefs).fetchEntries();
    final existingCount = await isar.isarAgendaEntrys.count();

    if (existingCount == 0 && legacy.isNotEmpty) {
      await isar.writeTxn(() async {
        await isar.isarAgendaEntrys.putAll(
          legacy.map((entry) => entry.toIsar()).toList(growable: false),
        );
      });

      final migratedCount = await isar.isarAgendaEntrys.count();
      if (migratedCount != legacy.length) {
        throw StateError(
          'Migración de Agenda incompleta: $migratedCount/${legacy.length}.',
        );
      }
    }

    // The legacy payload is intentionally retained as a rollback copy.
    await _prefs.setBool(PrefsKeys.agendaIsarMigrationV1Done, true);
  }

  @override
  Future<List<AgendaEntry>> fetchEntries() async {
    final isar = await _isar;
    final records = await isar.isarAgendaEntrys.where().sortByFecha().findAll();
    return List<AgendaEntry>.unmodifiable(records.map((record) => record.toEntity()));
  }

  @override
  Future<AgendaEntry> getEntry(String id) async {
    final isar = await _isar;
    final record = await isar.isarAgendaEntrys.where().uuidEqualTo(id).findFirst();
    if (record == null) {
      throw StateError('No existe la tarea de Agenda $id.');
    }
    return record.toEntity();
  }

  @override
  Future<void> saveEntry(AgendaEntry entry) => _upsert(entry);

  @override
  Future<void> updateEntry(AgendaEntry entry) => _upsert(entry);

  Future<void> _upsert(AgendaEntry entry) async {
    final isar = await _isar;
    final model = entry.toIsar();
    final existing = await isar.isarAgendaEntrys.where().uuidEqualTo(entry.id).findFirst();
    if (existing != null) model.isarId = existing.isarId;
    await isar.writeTxn(() => isar.isarAgendaEntrys.put(model));
  }

  @override
  Future<void> deleteEntry(String id) async {
    final isar = await _isar;
    await isar.writeTxn(
      () => isar.isarAgendaEntrys.where().uuidEqualTo(id).deleteAll(),
    );
  }

  @override
  Future<void> replaceAll(List<AgendaEntry> entries) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      await isar.isarAgendaEntrys.clear();
      await isar.isarAgendaEntrys.putAll(
        entries.map((entry) => entry.toIsar()).toList(growable: false),
      );
    });
  }

  @override
  Future<void> clearAll() async {
    final isar = await _isar;
    await isar.writeTxn(() => isar.isarAgendaEntrys.clear());
  }
}
