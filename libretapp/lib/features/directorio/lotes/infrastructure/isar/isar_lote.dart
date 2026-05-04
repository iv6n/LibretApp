/// features \u203a directorio \u203a lotes \u203a infrastructure \u203a isar \u203a isar_lote \u2014 Isar schema for the Lote model.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';

part 'isar_lote.g.dart';

/// Modelo de persistencia Isar para Lotes
@collection
class IsarLote {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String nombre;
  String? descripcion;
  late List<String> animalUuids;

  late DateTime fechaCreacion;
  DateTime? fechaCierre;

  late bool activo;
  String? notas;

  late bool synced;
  String? remoteId;
  DateTime? syncDate;

  late DateTime lastUpdateDate;
}

extension IsarLoteMapper on IsarLote {
  /// Convierte una entidad de base de datos Isar a entidad de dominio
  LoteEntity toEntity() {
    return LoteEntity(
      id: id,
      uuid: uuid,
      nombre: nombre,
      descripcion: descripcion,
      animalUuids: animalUuids,
      fechaCreacion: fechaCreacion,
      fechaCierre: fechaCierre,
      activo: activo,
      notas: notas,
      lastUpdateDate: lastUpdateDate,
      synced: synced,
      remoteId: remoteId,
      syncDate: syncDate,
    );
  }

  /// Actualiza este modelo Isar con datos de una entidad de dominio
  void updateFromEntity(LoteEntity entity) {
    uuid = entity.uuid;
    nombre = entity.nombre;
    descripcion = entity.descripcion;
    animalUuids = entity.animalUuids;
    fechaCreacion = entity.fechaCreacion;
    fechaCierre = entity.fechaCierre;
    activo = entity.activo;
    notas = entity.notas;
    lastUpdateDate = entity.lastUpdateDate;
    synced = entity.synced;
    remoteId = entity.remoteId;
    syncDate = entity.syncDate;
  }
}

extension IsarLoteFromEntityMapper on LoteEntity {
  /// Crea un modelo Isar desde una entidad de dominio
  IsarLote toIsarLote() {
    return IsarLote()
      ..uuid = uuid
      ..nombre = nombre
      ..descripcion = descripcion
      ..animalUuids = animalUuids
      ..fechaCreacion = fechaCreacion
      ..fechaCierre = fechaCierre
      ..activo = activo
      ..notas = notas
      ..lastUpdateDate = lastUpdateDate
      ..synced = synced
      ..remoteId = remoteId
      ..syncDate = syncDate;
  }
}
