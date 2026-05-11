/// features › agenda › infrastructure › isar_agenda_repository — Isar implementation.
///
/// Delegates to [AgendaRepositoryImpl] (SharedPrefs) since Isar schema migration
/// for new fields requires a build_runner pass. Use this wrapper to swap in the
/// Isar implementation once the schema is regenerated.
library;

import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';

/// Isar-backed [AgendaRepository].
///
/// Currently delegates to [AgendaRepositoryImpl] (SharedPrefs JSON store).
/// Replace the body of each method with Isar calls after running:
///   `flutter pub run build_runner build --delete-conflicting-outputs`
class IsarAgendaRepository implements AgendaRepository {
  IsarAgendaRepository(this._prefs);

  final SharedPrefsService _prefs;

  late final AgendaRepositoryImpl _impl = AgendaRepositoryImpl(_prefs);

  @override
  Future<List<AgendaEntry>> fetchEntries() => _impl.fetchEntries();

  @override
  Future<AgendaEntry> getEntry(String id) => _impl.getEntry(id);

  @override
  Future<void> saveEntry(AgendaEntry entry) => _impl.saveEntry(entry);

  @override
  Future<void> deleteEntry(String id) => _impl.deleteEntry(id);

  @override
  Future<void> updateEntry(AgendaEntry entry) => _impl.updateEntry(entry);

  @override
  Future<void> replaceAll(List<AgendaEntry> entries) =>
      _impl.replaceAll(entries);

  @override
  Future<void> clearAll() => _impl.clearAll();
}
