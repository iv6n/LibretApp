/// features › eventos › infrastructure › isar › isar_evento — Isar schema for Evento.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/eventos/data/eventos_model.dart';

part 'isar_evento.g.dart';

@collection
class IsarEvento {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  late DateTime fecha;

  late String titulo;
  late String descripcion;
  late String tipo;
  late String animalId;
  late String ubicacion;
}

extension IsarEventoMapper on IsarEvento {
  Evento toEntity() {
    return Evento(
      id: uuid,
      titulo: titulo,
      descripcion: descripcion,
      fecha: fecha,
      tipo: tipo,
      animalId: animalId,
      ubicacion: ubicacion,
    );
  }
}

extension EventoToIsar on Evento {
  IsarEvento toIsar() {
    return IsarEvento()
      ..uuid = id
      ..fecha = fecha
      ..titulo = titulo
      ..descripcion = descripcion
      ..tipo = tipo
      ..animalId = animalId
      ..ubicacion = ubicacion;
  }
}
