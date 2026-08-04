/// Groups agenda entries into logical events without changing persistence.
///
/// Automatic reminders are still stored per animal. This layer turns all
/// entries that belong to the same occurrence into one event card and keeps
/// the source entry on every row so completing an animal updates the right
/// record.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/domain/agenda_categoria.dart';

class AgendaTaskRow extends Equatable {
  const AgendaTaskRow({required this.entry, this.animalId});

  final AgendaEntry entry;
  final String? animalId;

  bool get isCompleted =>
      animalId != null && entry.completedAnimalIds.contains(animalId);

  bool isOverdue(DateTime todayKey) => entry.fecha.isBefore(todayKey);

  @override
  List<Object?> get props => [entry, animalId];
}

/// One logical occurrence shown as a single card in Agenda.
class AgendaEventGroup extends Equatable {
  const AgendaEventGroup({
    required this.key,
    required this.titulo,
    required this.tipo,
    required this.categoria,
    required this.rows,
    required this.entries,
  });

  final String key;
  final String titulo;
  final String tipo;
  final AgendaCategoria categoria;

  /// One row per animal (or one null-animal row for a ranch-level task).
  final List<AgendaTaskRow> rows;

  /// Unique persisted entries represented by this event.
  final List<AgendaEntry> entries;

  AgendaEntry get primaryEntry => entries.first;

  int get animalCount => rows.where((row) => row.animalId != null).length;

  int get completedCount => rows.where((row) => row.isCompleted).length;

  @override
  List<Object?> get props => [key, titulo, tipo, categoria, rows, entries];
}

class AgendaCategoryGroup extends Equatable {
  const AgendaCategoryGroup({required this.categoria, required this.events});

  final AgendaCategoria categoria;
  final List<AgendaEventGroup> events;

  /// Compatibility alias for callers built against the first grouping draft.
  List<AgendaEventGroup> get subcategorias => events;

  int get pendingAnimalCount =>
      events.fold(0, (total, event) => total + event.rows.length);

  @override
  List<Object?> get props => [categoria, events];
}

typedef AgendaSubcategoryGroup = AgendaEventGroup;

int _priorityRank(String priority) => switch (priority) {
  AgendaPrioridad.urgente => 3,
  AgendaPrioridad.alta => 2,
  AgendaPrioridad.normal => 1,
  AgendaPrioridad.baja => 0,
  _ => 1,
};

class AgendaTaskGrouper {
  const AgendaTaskGrouper();

  DateTime dayKey(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  bool isTerminal(AgendaEntry entry) =>
      entry.estado == AgendaEstado.completado ||
      entry.estado == AgendaEstado.verificado ||
      entry.estado == AgendaEstado.cancelado;

  /// Stable worklist identity: one card per pending type.
  ///
  /// Protocol, source and date remain available on every [AgendaTaskRow], but
  /// do not split the worklist. Thus cattle, goat and sheep deworming tasks
  /// are presented in a single "Desparasitación" card with their individual
  /// due dates inside it.
  String eventKeyForEntry(AgendaEntry entry) {
    if (entry.animalIds.isNotEmpty) {
      return 'animals:${_normalizeType(entry.tipo)}';
    }

    // Ranch-level tasks without animals remain independent events.
    return 'entry:${entry.id}';
  }

  String _normalizeType(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ñ', 'n');

  String titleForEntry(AgendaEntry entry) {
    if (!entry.id.startsWith('auto:')) return entry.titulo;
    final separator = entry.titulo.lastIndexOf(' - ');
    return separator > 0 ? entry.titulo.substring(0, separator) : entry.tipo;
  }

  int compareUrgency(AgendaEntry a, AgendaEntry b, DateTime todayKey) {
    final aOverdue = dayKey(a.fecha).isBefore(todayKey);
    final bOverdue = dayKey(b.fecha).isBefore(todayKey);
    if (aOverdue != bOverdue) return aOverdue ? -1 : 1;
    final priorityDiff = _priorityRank(
      b.prioridad,
    ).compareTo(_priorityRank(a.prioridad));
    if (priorityDiff != 0) return priorityDiff;
    return a.fecha.compareTo(b.fecha);
  }

  List<AgendaCategoryGroup> group(
    List<AgendaEntry> entries, {
    required DateTime today,
    bool includeFinished = false,
    bool includeCompletedAnimals = false,
  }) {
    final todayKey = dayKey(today);
    final byEvent = <String, List<AgendaEntry>>{};

    for (final entry in entries) {
      if (!includeFinished && isTerminal(entry)) continue;
      byEvent.putIfAbsent(eventKeyForEntry(entry), () => []).add(entry);
    }

    final byCategory = <AgendaCategoria, List<AgendaEventGroup>>{};
    for (final eventEntries in byEvent.values) {
      final event = _buildEvent(
        eventEntries,
        todayKey: todayKey,
        includeCompletedAnimals: includeCompletedAnimals,
      );
      if (event == null) continue;
      byCategory.putIfAbsent(event.categoria, () => []).add(event);
    }

    final groups = <AgendaCategoryGroup>[];
    for (final categoryEntry in byCategory.entries) {
      final events = categoryEntry.value
        ..sort(
          (a, b) => compareUrgency(a.primaryEntry, b.primaryEntry, todayKey),
        );
      if (events.isEmpty) continue;
      groups.add(
        AgendaCategoryGroup(
          categoria: categoryEntry.key,
          events: List.unmodifiable(events),
        ),
      );
    }

    groups.sort(
      (a, b) => compareUrgency(
        a.events.first.primaryEntry,
        b.events.first.primaryEntry,
        todayKey,
      ),
    );
    return groups;
  }

  AgendaEventGroup? _buildEvent(
    List<AgendaEntry> sourceEntries, {
    required DateTime todayKey,
    required bool includeCompletedAnimals,
  }) {
    if (sourceEntries.isEmpty) return null;
    sourceEntries.sort((a, b) => compareUrgency(a, b, todayKey));
    final primary = sourceEntries.first;

    final byAnimal = <String, AgendaTaskRow>{};
    final ranchRows = <AgendaTaskRow>[];
    for (final entry in sourceEntries) {
      if (entry.animalIds.isEmpty) {
        ranchRows.add(AgendaTaskRow(entry: entry));
        continue;
      }
      for (final animalId in entry.animalIds) {
        final completed = entry.completedAnimalIds.contains(animalId);
        if (completed && !includeCompletedAnimals) continue;
        final current = byAnimal[animalId];
        if (current == null ||
            compareUrgency(entry, current.entry, todayKey) < 0) {
          byAnimal[animalId] = AgendaTaskRow(entry: entry, animalId: animalId);
        }
      }
    }

    final rows = <AgendaTaskRow>[...byAnimal.values, ...ranchRows]
      ..sort((a, b) => compareUrgency(a.entry, b.entry, todayKey));
    if (rows.isEmpty) return null;

    final uniqueEntries = <String, AgendaEntry>{
      for (final entry in sourceEntries) entry.id: entry,
    }.values.toList(growable: false);

    return AgendaEventGroup(
      key: eventKeyForEntry(primary),
      titulo: titleForEntry(primary),
      tipo: primary.tipo,
      categoria: categoriaForTipo(primary.tipo),
      rows: List.unmodifiable(rows),
      entries: List.unmodifiable(uniqueEntries),
    );
  }
}
