import 'dart:convert';

import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/eventos/data/eventos_model.dart';

abstract class EventosRepository {
  Future<List<Evento>> fetchEventos();
  Future<Evento> getEvento(String id);
  Future<void> saveEvento(Evento evento);
  Future<void> deleteEvento(String id);
  Future<void> updateEvento(Evento evento);
  Future<void> replaceAll(List<Evento> eventos);
  Future<void> clearAll();
}

class EventosRepositoryImpl implements EventosRepository {
  EventosRepositoryImpl(this._prefs);

  final SharedPrefsService _prefs;

  List<Evento>? _cache;

  List<Evento> _sort(List<Evento> eventos) {
    eventos.sort((a, b) => a.fecha.compareTo(b.fecha));
    return eventos;
  }

  Future<List<Evento>> _load() async {
    if (_cache != null) {
      return _sort(List<Evento>.from(_cache!));
    }

    final raw = _prefs.getString(PrefsKeys.eventsStorage);
    if (raw == null || raw.isEmpty) {
      _cache = <Evento>[];
      return <Evento>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    final eventos = decoded
        .map((e) => Evento.fromJson(e as Map<String, dynamic>))
        .toList(growable: true);

    _cache = eventos;
    return _sort(List<Evento>.from(eventos));
  }

  Future<void> _persist(List<Evento> eventos) async {
    _cache = List<Evento>.from(eventos);
    final json = jsonEncode(eventos.map((e) => e.toJson()).toList());
    await _prefs.setString(PrefsKeys.eventsStorage, json);
  }

  @override
  Future<List<Evento>> fetchEventos() async {
    final eventos = await _load();
    return List.unmodifiable(eventos);
  }

  @override
  Future<Evento> getEvento(String id) async {
    final eventos = await fetchEventos();
    return eventos.firstWhere((e) => e.id == id);
  }

  @override
  Future<void> saveEvento(Evento evento) async {
    final eventos = await _load();
    final index = eventos.indexWhere((e) => e.id == evento.id);
    if (index == -1) {
      eventos.add(evento);
    } else {
      eventos[index] = evento;
    }
    await _persist(_sort(eventos));
  }

  @override
  Future<void> deleteEvento(String id) async {
    final eventos = await _load();
    eventos.removeWhere((e) => e.id == id);
    await _persist(_sort(eventos));
  }

  @override
  Future<void> updateEvento(Evento evento) async {
    final eventos = await _load();
    final index = eventos.indexWhere((e) => e.id == evento.id);
    if (index != -1) {
      eventos[index] = evento;
      await _persist(_sort(eventos));
    }
  }

  @override
  Future<void> replaceAll(List<Evento> eventos) async {
    await _persist(_sort(List<Evento>.from(eventos)));
  }

  @override
  Future<void> clearAll() async {
    _cache = <Evento>[];
    await _prefs.remove(PrefsKeys.eventsStorage);
  }
}
