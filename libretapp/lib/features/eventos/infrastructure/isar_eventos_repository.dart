/// features › eventos › infrastructure › isar_eventos_repository — Isar
/// implementation of [EventosRepository].
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/eventos/data/eventos_model.dart';
import 'package:libretapp/features/eventos/data/eventos_repository.dart';
import 'package:libretapp/features/eventos/infrastructure/isar/isar_evento.dart';

class IsarEventosRepository implements EventosRepository {
  IsarEventosRepository(this._database);

  final IsarDatabase _database;

  Future<Isar> get _isar async => _database.initialize();

  @override
  Future<List<Evento>> fetchEventos() async {
    final isar = await _isar;
    final records = await isar.isarEventos.where().sortByFechaDesc().findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<Evento> getEvento(String id) async {
    final isar = await _isar;
    final record = await isar.isarEventos.filter().uuidEqualTo(id).findFirst();
    if (record == null) throw StateError('Evento no encontrado: $id');
    return record.toEntity();
  }

  @override
  Future<void> saveEvento(Evento evento) async {
    final isar = await _isar;
    // Upsert: find existing record by uuid to preserve the Isar primary key.
    final existing = await isar.isarEventos
        .filter()
        .uuidEqualTo(evento.id)
        .findFirst();
    final model = evento.toIsar();
    if (existing != null) model.id = existing.id;
    await isar.writeTxn(() async {
      await isar.isarEventos.put(model);
    });
  }

  @override
  Future<void> updateEvento(Evento evento) => saveEvento(evento);

  @override
  Future<void> deleteEvento(String id) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      await isar.isarEventos.filter().uuidEqualTo(id).deleteAll();
    });
  }

  @override
  Future<void> replaceAll(List<Evento> eventos) async {
    final isar = await _isar;
    final models = eventos.map((e) => e.toIsar()).toList(growable: false);
    await isar.writeTxn(() async {
      await isar.isarEventos.clear();
      await isar.isarEventos.putAll(models);
    });
  }

  @override
  Future<void> clearAll() async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      await isar.isarEventos.clear();
    });
  }
}
