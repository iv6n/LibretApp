/// features \u203a directorio \u203a lotes \u203a infrastructure \u203a isar \u203a isar_lote \u2014 Isar schema for the Lote model.
///
/// @Name annotations preserve the original Spanish column names in the Isar
/// store so that existing data survives the Dart field rename without a
/// data migration.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';

part 'isar_lote.g.dart';

@collection
class IsarLote {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Name('nombre')
  late String name;

  @Name('descripcion')
  String? description;

  late List<String> animalUuids;

  @Name('fechaCreacion')
  late DateTime createdAt;

  @Name('fechaCierre')
  DateTime? closedAt;

  @Name('activo')
  late bool active;

  @Name('notas')
  String? notes;

  String? currentLocationId;

  late bool synced;
  String? remoteId;
  DateTime? syncDate;

  late DateTime lastUpdateDate;
}

extension IsarLoteMapper on IsarLote {
  LoteEntity toEntity() {
    return LoteEntity(
      id: id,
      uuid: uuid,
      name: name,
      description: description,
      animalUuids: animalUuids,
      createdAt: createdAt,
      closedAt: closedAt,
      active: active,
      notes: notes,
      currentLocationId: currentLocationId,
      lastUpdateDate: lastUpdateDate,
      synced: synced,
      remoteId: remoteId,
      syncDate: syncDate,
    );
  }

  void updateFromEntity(LoteEntity entity) {
    uuid = entity.uuid;
    name = entity.name;
    description = entity.description;
    animalUuids = entity.animalUuids;
    createdAt = entity.createdAt;
    closedAt = entity.closedAt;
    active = entity.active;
    notes = entity.notes;
    currentLocationId = entity.currentLocationId;
    lastUpdateDate = entity.lastUpdateDate;
    synced = entity.synced;
    remoteId = entity.remoteId;
    syncDate = entity.syncDate;
  }
}

extension IsarLoteFromEntityMapper on LoteEntity {
  IsarLote toIsarLote() {
    return IsarLote()
      ..uuid = uuid
      ..name = name
      ..description = description
      ..animalUuids = animalUuids
      ..createdAt = createdAt
      ..closedAt = closedAt
      ..currentLocationId = currentLocationId
      ..active = active
      ..notes = notes
      ..lastUpdateDate = lastUpdateDate
      ..synced = synced
      ..remoteId = remoteId
      ..syncDate = syncDate;
  }
}
