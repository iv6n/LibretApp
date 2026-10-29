import 'dart:async';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'lite_notification_service.dart';

/// Keeps local reminders aligned when an entry created in Lite is edited
/// or completed from the shared Agenda in Completa.
class ReminderAwareAgendaRepository
    implements AgendaRepository, AtomicAgendaRepository {
  ReminderAwareAgendaRepository(this._delegate);
  final AgendaRepository _delegate;

  void _sync() => unawaited(
    LiteNotificationService.syncFromRepository().then(
      (_) {},
      onError: (Object _, StackTrace __) {},
    ),
  );

  @override
  Future<List<AgendaEntry>> fetchEntries() => _delegate.fetchEntries();
  @override
  Future<AgendaEntry> getEntry(String id) => _delegate.getEntry(id);
  @override
  Future<void> saveEntry(AgendaEntry entry) async {
    await _delegate.saveEntry(entry);
    if (entry.sourceType == 'lite') _sync();
  }

  @override
  Future<void> saveEntries(List<AgendaEntry> entries) async {
    await _delegate.saveEntries(entries);
    if (entries.any((entry) => entry.sourceType == 'lite')) _sync();
  }

  @override
  Future<void> updateEntry(AgendaEntry entry) async {
    AgendaEntry? previous;
    try {
      previous = await _delegate.getEntry(entry.id);
    } catch (_) {}
    await _delegate.updateEntry(entry);
    if (entry.sourceType == 'lite' || previous?.sourceType == 'lite') _sync();
  }

  @override
  Future<void> deleteEntry(String id) async {
    AgendaEntry? previous;
    try {
      previous = await _delegate.getEntry(id);
    } catch (_) {}
    await _delegate.deleteEntry(id);
    if (previous?.sourceType == 'lite') _sync();
  }

  @override
  Future<void> replaceAll(List<AgendaEntry> entries) async {
    await _delegate.replaceAll(entries);
    _sync();
  }

  @override
  Future<void> reconcileEntries(
    List<AgendaEntry> Function(List<AgendaEntry> current) update,
  ) async {
    await _delegate.updateEntries(update);
    _sync();
  }

  @override
  Future<void> clearAll() async {
    await _delegate.clearAll();
    _sync();
  }
}
