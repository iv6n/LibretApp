/// features › agenda › data › agenda_repository — abstract interface and SharedPrefs implementation.
library;

import 'dart:convert';

import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';

abstract class AgendaRepository {
  Future<List<AgendaEntry>> fetchEntries();
  Future<AgendaEntry> getEntry(String id);
  Future<void> saveEntry(AgendaEntry entry);
  Future<void> deleteEntry(String id);
  Future<void> updateEntry(AgendaEntry entry);
  Future<void> replaceAll(List<AgendaEntry> entries);
  Future<void> clearAll();
}

class AgendaRepositoryImpl implements AgendaRepository {
  AgendaRepositoryImpl(this._prefs);

  final SharedPrefsService _prefs;

  List<AgendaEntry>? _cache;

  List<AgendaEntry> _sort(List<AgendaEntry> entries) {
    entries.sort((a, b) => a.fecha.compareTo(b.fecha));
    return entries;
  }

  Future<List<AgendaEntry>> _load() async {
    if (_cache != null) {
      return _sort(List<AgendaEntry>.from(_cache!));
    }

    final raw = _prefs.getString(PrefsKeys.eventsStorage);
    if (raw == null || raw.isEmpty) {
      _cache = <AgendaEntry>[];
      return <AgendaEntry>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    final entries = decoded
        .map((e) => AgendaEntry.fromJson(e as Map<String, dynamic>))
        .toList(growable: true);

    _cache = entries;
    return _sort(List<AgendaEntry>.from(entries));
  }

  Future<void> _persist(List<AgendaEntry> entries) async {
    _cache = List<AgendaEntry>.from(entries);
    final json = jsonEncode(entries.map((e) => e.toJson()).toList());
    await _prefs.setString(PrefsKeys.eventsStorage, json);
  }

  @override
  Future<List<AgendaEntry>> fetchEntries() async {
    final entries = await _load();
    return List.unmodifiable(entries);
  }

  @override
  Future<AgendaEntry> getEntry(String id) async {
    final entries = await fetchEntries();
    return entries.firstWhere((e) => e.id == id);
  }

  @override
  Future<void> saveEntry(AgendaEntry entry) async {
    final entries = await _load();
    final index = entries.indexWhere((e) => e.id == entry.id);
    if (index == -1) {
      entries.add(entry);
    } else {
      entries[index] = entry;
    }
    await _persist(_sort(entries));
  }

  @override
  Future<void> deleteEntry(String id) async {
    final entries = await _load();
    entries.removeWhere((e) => e.id == id);
    await _persist(_sort(entries));
  }

  @override
  Future<void> updateEntry(AgendaEntry entry) async {
    final entries = await _load();
    final index = entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      entries[index] = entry;
      await _persist(_sort(entries));
    }
  }

  @override
  Future<void> replaceAll(List<AgendaEntry> entries) async {
    await _persist(_sort(List<AgendaEntry>.from(entries)));
  }

  @override
  Future<void> clearAll() async {
    _cache = <AgendaEntry>[];
    await _prefs.remove(PrefsKeys.eventsStorage);
  }
}
