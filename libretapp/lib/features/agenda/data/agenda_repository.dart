/// features › agenda › data › agenda_repository — abstract interface and SharedPrefs implementation.
library;

import 'dart:convert';
import 'dart:async';

import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';

abstract class AgendaRepository {
  Future<List<AgendaEntry>> fetchEntries();
  Future<AgendaEntry> getEntry(String id);
  Future<void> saveEntry(AgendaEntry entry);
  Future<void> saveEntries(List<AgendaEntry> entries) async {
    for (final entry in entries) {
      await saveEntry(entry);
    }
  }

  Future<void> deleteEntry(String id);
  Future<void> updateEntry(AgendaEntry entry);
  Future<void> replaceAll(List<AgendaEntry> entries);
  Future<void> clearAll();
}

/// Optional native transaction primitive. Every repository exposes
/// [AgendaRepositoryMutations.updateEntries]; implementations that support
/// atomic compare-and-update implement this contract.
abstract interface class AtomicAgendaRepository {
  Future<void> reconcileEntries(
    List<AgendaEntry> Function(List<AgendaEntry> current) update,
  );
}

extension AgendaRepositoryMutations on AgendaRepository {
  Future<void> updateEntries(
    List<AgendaEntry> Function(List<AgendaEntry> current) update,
  ) async {
    if (this is AtomicAgendaRepository) {
      await (this as AtomicAgendaRepository).reconcileEntries(update);
      return;
    }
    final current = await fetchEntries();
    await replaceAll(update(List<AgendaEntry>.of(current)));
  }
}

class AgendaRepositoryImpl implements AgendaRepository, AtomicAgendaRepository {
  AgendaRepositoryImpl(this._prefs);

  final SharedPrefsService _prefs;

  List<AgendaEntry>? _cache;
  Future<void> _writeQueue = Future<void>.value();

  Future<T> _serialize<T>(Future<T> Function() action) {
    final result = Completer<T>();
    _writeQueue = _writeQueue.then((_) async {
      try {
        result.complete(await action());
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }

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
    final json = jsonEncode(entries.map((e) => e.toJson()).toList());
    await _prefs.setString(PrefsKeys.eventsStorage, json);
    _cache = List<AgendaEntry>.from(entries);
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
    await _serialize(() async {
      final entries = await _load();
      final index = entries.indexWhere((e) => e.id == entry.id);
      if (index == -1) {
        entries.add(entry);
      } else {
        entries[index] = entry;
      }
      await _persist(_sort(entries));
    });
  }

  @override
  Future<void> saveEntries(List<AgendaEntry> additions) async {
    await _serialize(() async {
      final entries = await _load();
      for (final entry in additions) {
        final index = entries.indexWhere((existing) => existing.id == entry.id);
        if (index < 0) {
          entries.add(entry);
        } else {
          entries[index] = entry;
        }
      }
      await _persist(_sort(entries));
    });
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _serialize(() async {
      final entries = await _load();
      entries.removeWhere((e) => e.id == id);
      await _persist(_sort(entries));
    });
  }

  @override
  Future<void> updateEntry(AgendaEntry entry) async {
    await _serialize(() async {
      final entries = await _load();
      final index = entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        entries[index] = entry;
        await _persist(_sort(entries));
      }
    });
  }

  @override
  Future<void> replaceAll(List<AgendaEntry> entries) async {
    await _serialize(() => _persist(_sort(List<AgendaEntry>.from(entries))));
  }

  @override
  Future<void> reconcileEntries(
    List<AgendaEntry> Function(List<AgendaEntry> current) update,
  ) => _serialize(() async {
    final next = update(List<AgendaEntry>.of(await _load()));
    await _persist(_sort(List<AgendaEntry>.of(next)));
  });

  @override
  Future<void> clearAll() async {
    await _serialize(() async {
      await _prefs.remove(PrefsKeys.eventsStorage);
      _cache = <AgendaEntry>[];
    });
  }
}
