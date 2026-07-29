// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_agenda_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarAgendaEntryCollection on Isar {
  IsarCollection<IsarAgendaEntry> get isarAgendaEntrys => this.collection();
}

const IsarAgendaEntrySchema = CollectionSchema(
  name: r'IsarAgendaEntry',
  id: 3112995893239849704,
  properties: {
    r'activitiesJson': PropertySchema(
      id: 0,
      name: r'activitiesJson',
      type: IsarType.stringList,
    ),
    r'animalIds': PropertySchema(
      id: 1,
      name: r'animalIds',
      type: IsarType.stringList,
    ),
    r'assigneeId': PropertySchema(
      id: 2,
      name: r'assigneeId',
      type: IsarType.string,
    ),
    r'blockedReason': PropertySchema(
      id: 3,
      name: r'blockedReason',
      type: IsarType.string,
    ),
    r'checklistJson': PropertySchema(
      id: 4,
      name: r'checklistJson',
      type: IsarType.stringList,
    ),
    r'collaboratorIds': PropertySchema(
      id: 5,
      name: r'collaboratorIds',
      type: IsarType.stringList,
    ),
    r'completedAnimalIds': PropertySchema(
      id: 6,
      name: r'completedAnimalIds',
      type: IsarType.stringList,
    ),
    r'contentHash': PropertySchema(
      id: 7,
      name: r'contentHash',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 8,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'createdById': PropertySchema(
      id: 9,
      name: r'createdById',
      type: IsarType.string,
    ),
    r'descripcion': PropertySchema(
      id: 10,
      name: r'descripcion',
      type: IsarType.string,
    ),
    r'estado': PropertySchema(
      id: 11,
      name: r'estado',
      type: IsarType.string,
    ),
    r'evidenceJson': PropertySchema(
      id: 12,
      name: r'evidenceJson',
      type: IsarType.stringList,
    ),
    r'fecha': PropertySchema(
      id: 13,
      name: r'fecha',
      type: IsarType.dateTime,
    ),
    r'fechaCompletado': PropertySchema(
      id: 14,
      name: r'fechaCompletado',
      type: IsarType.dateTime,
    ),
    r'locationUuid': PropertySchema(
      id: 15,
      name: r'locationUuid',
      type: IsarType.string,
    ),
    r'loteIds': PropertySchema(
      id: 16,
      name: r'loteIds',
      type: IsarType.stringList,
    ),
    r'notas': PropertySchema(
      id: 17,
      name: r'notas',
      type: IsarType.string,
    ),
    r'prioridad': PropertySchema(
      id: 18,
      name: r'prioridad',
      type: IsarType.string,
    ),
    r'recurrenceRule': PropertySchema(
      id: 19,
      name: r'recurrenceRule',
      type: IsarType.string,
    ),
    r'remoteId': PropertySchema(
      id: 20,
      name: r'remoteId',
      type: IsarType.string,
    ),
    r'syncDate': PropertySchema(
      id: 21,
      name: r'syncDate',
      type: IsarType.dateTime,
    ),
    r'synced': PropertySchema(
      id: 22,
      name: r'synced',
      type: IsarType.bool,
    ),
    r'tipo': PropertySchema(
      id: 23,
      name: r'tipo',
      type: IsarType.string,
    ),
    r'titulo': PropertySchema(
      id: 24,
      name: r'titulo',
      type: IsarType.string,
    ),
    r'ubicacion': PropertySchema(
      id: 25,
      name: r'ubicacion',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 26,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(
      id: 27,
      name: r'uuid',
      type: IsarType.string,
    ),
    r'workTeamId': PropertySchema(
      id: 28,
      name: r'workTeamId',
      type: IsarType.string,
    )
  },
  estimateSize: _isarAgendaEntryEstimateSize,
  serialize: _isarAgendaEntrySerialize,
  deserialize: _isarAgendaEntryDeserialize,
  deserializeProp: _isarAgendaEntryDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'fecha': IndexSchema(
      id: -5395179286312083551,
      name: r'fecha',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'fecha',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'tipo': IndexSchema(
      id: 3681353239984507137,
      name: r'tipo',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tipo',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'estado': IndexSchema(
      id: -4800696143246816208,
      name: r'estado',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'estado',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'prioridad': IndexSchema(
      id: 8505763141741948367,
      name: r'prioridad',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'prioridad',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarAgendaEntryGetId,
  getLinks: _isarAgendaEntryGetLinks,
  attach: _isarAgendaEntryAttach,
  version: '3.1.0+1',
);

int _isarAgendaEntryEstimateSize(
  IsarAgendaEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.activitiesJson.length * 3;
  {
    for (var i = 0; i < object.activitiesJson.length; i++) {
      final value = object.activitiesJson[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.animalIds.length * 3;
  {
    for (var i = 0; i < object.animalIds.length; i++) {
      final value = object.animalIds[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.assigneeId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.blockedReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.checklistJson.length * 3;
  {
    for (var i = 0; i < object.checklistJson.length; i++) {
      final value = object.checklistJson[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.collaboratorIds.length * 3;
  {
    for (var i = 0; i < object.collaboratorIds.length; i++) {
      final value = object.collaboratorIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.completedAnimalIds.length * 3;
  {
    for (var i = 0; i < object.completedAnimalIds.length; i++) {
      final value = object.completedAnimalIds[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.contentHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.createdById;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.descripcion.length * 3;
  bytesCount += 3 + object.estado.length * 3;
  bytesCount += 3 + object.evidenceJson.length * 3;
  {
    for (var i = 0; i < object.evidenceJson.length; i++) {
      final value = object.evidenceJson[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.locationUuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.loteIds.length * 3;
  {
    for (var i = 0; i < object.loteIds.length; i++) {
      final value = object.loteIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.notas.length * 3;
  bytesCount += 3 + object.prioridad.length * 3;
  {
    final value = object.recurrenceRule;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.remoteId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.tipo.length * 3;
  bytesCount += 3 + object.titulo.length * 3;
  bytesCount += 3 + object.ubicacion.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  {
    final value = object.workTeamId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _isarAgendaEntrySerialize(
  IsarAgendaEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.activitiesJson);
  writer.writeStringList(offsets[1], object.animalIds);
  writer.writeString(offsets[2], object.assigneeId);
  writer.writeString(offsets[3], object.blockedReason);
  writer.writeStringList(offsets[4], object.checklistJson);
  writer.writeStringList(offsets[5], object.collaboratorIds);
  writer.writeStringList(offsets[6], object.completedAnimalIds);
  writer.writeString(offsets[7], object.contentHash);
  writer.writeDateTime(offsets[8], object.createdAt);
  writer.writeString(offsets[9], object.createdById);
  writer.writeString(offsets[10], object.descripcion);
  writer.writeString(offsets[11], object.estado);
  writer.writeStringList(offsets[12], object.evidenceJson);
  writer.writeDateTime(offsets[13], object.fecha);
  writer.writeDateTime(offsets[14], object.fechaCompletado);
  writer.writeString(offsets[15], object.locationUuid);
  writer.writeStringList(offsets[16], object.loteIds);
  writer.writeString(offsets[17], object.notas);
  writer.writeString(offsets[18], object.prioridad);
  writer.writeString(offsets[19], object.recurrenceRule);
  writer.writeString(offsets[20], object.remoteId);
  writer.writeDateTime(offsets[21], object.syncDate);
  writer.writeBool(offsets[22], object.synced);
  writer.writeString(offsets[23], object.tipo);
  writer.writeString(offsets[24], object.titulo);
  writer.writeString(offsets[25], object.ubicacion);
  writer.writeDateTime(offsets[26], object.updatedAt);
  writer.writeString(offsets[27], object.uuid);
  writer.writeString(offsets[28], object.workTeamId);
}

IsarAgendaEntry _isarAgendaEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarAgendaEntry();
  object.activitiesJson = reader.readStringList(offsets[0]) ?? [];
  object.animalIds = reader.readStringList(offsets[1]) ?? [];
  object.assigneeId = reader.readStringOrNull(offsets[2]);
  object.blockedReason = reader.readStringOrNull(offsets[3]);
  object.checklistJson = reader.readStringList(offsets[4]) ?? [];
  object.collaboratorIds = reader.readStringList(offsets[5]) ?? [];
  object.completedAnimalIds = reader.readStringList(offsets[6]) ?? [];
  object.contentHash = reader.readStringOrNull(offsets[7]);
  object.createdAt = reader.readDateTimeOrNull(offsets[8]);
  object.createdById = reader.readStringOrNull(offsets[9]);
  object.descripcion = reader.readString(offsets[10]);
  object.estado = reader.readString(offsets[11]);
  object.evidenceJson = reader.readStringList(offsets[12]) ?? [];
  object.fecha = reader.readDateTime(offsets[13]);
  object.fechaCompletado = reader.readDateTimeOrNull(offsets[14]);
  object.isarId = id;
  object.locationUuid = reader.readStringOrNull(offsets[15]);
  object.loteIds = reader.readStringList(offsets[16]) ?? [];
  object.notas = reader.readString(offsets[17]);
  object.prioridad = reader.readString(offsets[18]);
  object.recurrenceRule = reader.readStringOrNull(offsets[19]);
  object.remoteId = reader.readStringOrNull(offsets[20]);
  object.syncDate = reader.readDateTimeOrNull(offsets[21]);
  object.synced = reader.readBool(offsets[22]);
  object.tipo = reader.readString(offsets[23]);
  object.titulo = reader.readString(offsets[24]);
  object.ubicacion = reader.readString(offsets[25]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[26]);
  object.uuid = reader.readString(offsets[27]);
  object.workTeamId = reader.readStringOrNull(offsets[28]);
  return object;
}

P _isarAgendaEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringList(offset) ?? []) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    case 14:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readStringList(offset) ?? []) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 22:
      return (reader.readBool(offset)) as P;
    case 23:
      return (reader.readString(offset)) as P;
    case 24:
      return (reader.readString(offset)) as P;
    case 25:
      return (reader.readString(offset)) as P;
    case 26:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 27:
      return (reader.readString(offset)) as P;
    case 28:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarAgendaEntryGetId(IsarAgendaEntry object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _isarAgendaEntryGetLinks(IsarAgendaEntry object) {
  return [];
}

void _isarAgendaEntryAttach(
    IsarCollection<dynamic> col, Id id, IsarAgendaEntry object) {
  object.isarId = id;
}

extension IsarAgendaEntryByIndex on IsarCollection<IsarAgendaEntry> {
  Future<IsarAgendaEntry?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  IsarAgendaEntry? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<IsarAgendaEntry?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<IsarAgendaEntry?> getAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uuid', values);
  }

  Future<int> deleteAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uuid', values);
  }

  int deleteAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uuid', values);
  }

  Future<Id> putByUuid(IsarAgendaEntry object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(IsarAgendaEntry object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<IsarAgendaEntry> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<IsarAgendaEntry> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension IsarAgendaEntryQueryWhereSort
    on QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QWhere> {
  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhere> anyFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'fecha'),
      );
    });
  }
}

extension IsarAgendaEntryQueryWhere
    on QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QWhereClause> {
  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhereClause> uuidEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhereClause>
      uuidNotEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhereClause>
      fechaEqualTo(DateTime fecha) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'fecha',
        value: [fecha],
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhereClause>
      fechaNotEqualTo(DateTime fecha) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fecha',
              lower: [],
              upper: [fecha],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fecha',
              lower: [fecha],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fecha',
              lower: [fecha],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fecha',
              lower: [],
              upper: [fecha],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhereClause>
      fechaGreaterThan(
    DateTime fecha, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'fecha',
        lower: [fecha],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhereClause>
      fechaLessThan(
    DateTime fecha, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'fecha',
        lower: [],
        upper: [fecha],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhereClause>
      fechaBetween(
    DateTime lowerFecha,
    DateTime upperFecha, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'fecha',
        lower: [lowerFecha],
        includeLower: includeLower,
        upper: [upperFecha],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhereClause> tipoEqualTo(
      String tipo) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tipo',
        value: [tipo],
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhereClause>
      tipoNotEqualTo(String tipo) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tipo',
              lower: [],
              upper: [tipo],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tipo',
              lower: [tipo],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tipo',
              lower: [tipo],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tipo',
              lower: [],
              upper: [tipo],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhereClause>
      estadoEqualTo(String estado) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'estado',
        value: [estado],
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhereClause>
      estadoNotEqualTo(String estado) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'estado',
              lower: [],
              upper: [estado],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'estado',
              lower: [estado],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'estado',
              lower: [estado],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'estado',
              lower: [],
              upper: [estado],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhereClause>
      prioridadEqualTo(String prioridad) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'prioridad',
        value: [prioridad],
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterWhereClause>
      prioridadNotEqualTo(String prioridad) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'prioridad',
              lower: [],
              upper: [prioridad],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'prioridad',
              lower: [prioridad],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'prioridad',
              lower: [prioridad],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'prioridad',
              lower: [],
              upper: [prioridad],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarAgendaEntryQueryFilter
    on QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QFilterCondition> {
  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      activitiesJsonElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activitiesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      activitiesJsonElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activitiesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      activitiesJsonElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activitiesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      activitiesJsonElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activitiesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      activitiesJsonElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activitiesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      activitiesJsonElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activitiesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      activitiesJsonElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activitiesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      activitiesJsonElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activitiesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      activitiesJsonElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activitiesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      activitiesJsonElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activitiesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      activitiesJsonLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activitiesJson',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      activitiesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activitiesJson',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      activitiesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activitiesJson',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      activitiesJsonLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activitiesJson',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      activitiesJsonLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activitiesJson',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      activitiesJsonLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activitiesJson',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      animalIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animalIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      animalIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'animalIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      animalIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'animalIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      animalIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'animalIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      animalIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'animalIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      animalIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'animalIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      animalIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'animalIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      animalIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'animalIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      animalIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animalIds',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      animalIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'animalIds',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      animalIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'animalIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      animalIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'animalIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      animalIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'animalIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      animalIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'animalIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      animalIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'animalIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      animalIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'animalIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      assigneeIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assigneeId',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      assigneeIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assigneeId',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      assigneeIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assigneeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      assigneeIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assigneeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      assigneeIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assigneeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      assigneeIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assigneeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      assigneeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assigneeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      assigneeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assigneeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      assigneeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assigneeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      assigneeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assigneeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      assigneeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assigneeId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      assigneeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assigneeId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      blockedReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'blockedReason',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      blockedReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'blockedReason',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      blockedReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockedReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      blockedReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'blockedReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      blockedReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'blockedReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      blockedReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'blockedReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      blockedReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'blockedReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      blockedReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'blockedReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      blockedReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'blockedReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      blockedReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'blockedReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      blockedReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockedReason',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      blockedReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'blockedReason',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      checklistJsonElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checklistJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      checklistJsonElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'checklistJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      checklistJsonElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'checklistJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      checklistJsonElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'checklistJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      checklistJsonElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'checklistJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      checklistJsonElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'checklistJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      checklistJsonElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'checklistJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      checklistJsonElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'checklistJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      checklistJsonElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checklistJson',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      checklistJsonElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'checklistJson',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      checklistJsonLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'checklistJson',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      checklistJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'checklistJson',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      checklistJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'checklistJson',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      checklistJsonLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'checklistJson',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      checklistJsonLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'checklistJson',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      checklistJsonLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'checklistJson',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      collaboratorIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collaboratorIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      collaboratorIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'collaboratorIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      collaboratorIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'collaboratorIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      collaboratorIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'collaboratorIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      collaboratorIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'collaboratorIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      collaboratorIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'collaboratorIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      collaboratorIdsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'collaboratorIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      collaboratorIdsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'collaboratorIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      collaboratorIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collaboratorIds',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      collaboratorIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'collaboratorIds',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      collaboratorIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'collaboratorIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      collaboratorIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'collaboratorIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      collaboratorIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'collaboratorIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      collaboratorIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'collaboratorIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      collaboratorIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'collaboratorIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      collaboratorIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'collaboratorIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      completedAnimalIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAnimalIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      completedAnimalIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAnimalIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      completedAnimalIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAnimalIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      completedAnimalIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAnimalIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      completedAnimalIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'completedAnimalIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      completedAnimalIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'completedAnimalIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      completedAnimalIdsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'completedAnimalIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      completedAnimalIdsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'completedAnimalIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      completedAnimalIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAnimalIds',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      completedAnimalIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'completedAnimalIds',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      completedAnimalIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedAnimalIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      completedAnimalIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedAnimalIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      completedAnimalIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedAnimalIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      completedAnimalIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedAnimalIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      completedAnimalIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedAnimalIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      completedAnimalIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedAnimalIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      contentHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contentHash',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      contentHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contentHash',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      contentHashEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      contentHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      contentHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      contentHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contentHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      contentHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      contentHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      contentHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      contentHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contentHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      contentHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentHash',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      contentHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contentHash',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      createdByIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdById',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      createdByIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdById',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      createdByIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      createdByIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      createdByIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      createdByIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdById',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      createdByIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'createdById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      createdByIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'createdById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      createdByIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      createdByIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdById',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      createdByIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdById',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      createdByIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdById',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      descripcionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      descripcionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      descripcionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      descripcionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'descripcion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      descripcionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      descripcionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      descripcionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'descripcion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      descripcionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'descripcion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      descripcionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descripcion',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      descripcionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'descripcion',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      estadoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      estadoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      estadoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      estadoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estado',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      estadoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      estadoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      estadoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      estadoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'estado',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      estadoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      estadoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'estado',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      evidenceJsonElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'evidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      evidenceJsonElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'evidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      evidenceJsonElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'evidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      evidenceJsonElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'evidenceJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      evidenceJsonElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'evidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      evidenceJsonElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'evidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      evidenceJsonElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'evidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      evidenceJsonElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'evidenceJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      evidenceJsonElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'evidenceJson',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      evidenceJsonElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'evidenceJson',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      evidenceJsonLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'evidenceJson',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      evidenceJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'evidenceJson',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      evidenceJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'evidenceJson',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      evidenceJsonLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'evidenceJson',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      evidenceJsonLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'evidenceJson',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      evidenceJsonLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'evidenceJson',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      fechaEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      fechaGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      fechaLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      fechaBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fecha',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      fechaCompletadoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaCompletado',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      fechaCompletadoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaCompletado',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      fechaCompletadoEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaCompletado',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      fechaCompletadoGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaCompletado',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      fechaCompletadoLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaCompletado',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      fechaCompletadoBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaCompletado',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      locationUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'locationUuid',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      locationUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'locationUuid',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      locationUuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      locationUuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locationUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      locationUuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locationUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      locationUuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locationUuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      locationUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'locationUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      locationUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'locationUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      locationUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'locationUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      locationUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'locationUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      locationUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      locationUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locationUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      loteIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loteIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      loteIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'loteIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      loteIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'loteIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      loteIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'loteIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      loteIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'loteIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      loteIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'loteIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      loteIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'loteIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      loteIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'loteIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      loteIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loteIds',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      loteIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'loteIds',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      loteIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'loteIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      loteIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'loteIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      loteIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'loteIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      loteIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'loteIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      loteIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'loteIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      loteIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'loteIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      notasEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      notasGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      notasLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      notasBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notas',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      notasStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      notasEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      notasContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      notasMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notas',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      notasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notas',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      notasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notas',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      prioridadEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prioridad',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      prioridadGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'prioridad',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      prioridadLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'prioridad',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      prioridadBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'prioridad',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      prioridadStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'prioridad',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      prioridadEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'prioridad',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      prioridadContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'prioridad',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      prioridadMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'prioridad',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      prioridadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prioridad',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      prioridadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'prioridad',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      recurrenceRuleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'recurrenceRule',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      recurrenceRuleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'recurrenceRule',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      recurrenceRuleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recurrenceRule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      recurrenceRuleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recurrenceRule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      recurrenceRuleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recurrenceRule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      recurrenceRuleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recurrenceRule',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      recurrenceRuleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recurrenceRule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      recurrenceRuleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recurrenceRule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      recurrenceRuleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recurrenceRule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      recurrenceRuleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recurrenceRule',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      recurrenceRuleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recurrenceRule',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      recurrenceRuleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recurrenceRule',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      remoteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'remoteId',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      remoteIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'remoteId',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      remoteIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      remoteIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      remoteIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      remoteIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remoteId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      remoteIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      remoteIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      remoteIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      remoteIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'remoteId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      remoteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      remoteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'remoteId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      syncDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncDate',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      syncDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncDate',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      syncDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      syncDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      syncDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      syncDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      syncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'synced',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tipoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tipoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tipoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tipoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tipoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tipo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tipoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tipo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tipoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tipo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tipoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tipo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tipoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipo',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tipoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tipo',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tituloEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'titulo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tituloGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'titulo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tituloLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'titulo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tituloBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'titulo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tituloStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'titulo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tituloEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'titulo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tituloContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'titulo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tituloMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'titulo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tituloIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'titulo',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      tituloIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'titulo',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      ubicacionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ubicacion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      ubicacionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ubicacion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      ubicacionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ubicacion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      ubicacionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ubicacion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      ubicacionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ubicacion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      ubicacionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ubicacion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      ubicacionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ubicacion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      ubicacionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ubicacion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      ubicacionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ubicacion',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      ubicacionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ubicacion',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      uuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      uuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      uuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      workTeamIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'workTeamId',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      workTeamIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'workTeamId',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      workTeamIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'workTeamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      workTeamIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'workTeamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      workTeamIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'workTeamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      workTeamIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'workTeamId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      workTeamIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'workTeamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      workTeamIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'workTeamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      workTeamIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'workTeamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      workTeamIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'workTeamId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      workTeamIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'workTeamId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterFilterCondition>
      workTeamIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'workTeamId',
        value: '',
      ));
    });
  }
}

extension IsarAgendaEntryQueryObject
    on QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QFilterCondition> {}

extension IsarAgendaEntryQueryLinks
    on QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QFilterCondition> {}

extension IsarAgendaEntryQuerySortBy
    on QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QSortBy> {
  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByAssigneeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assigneeId', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByAssigneeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assigneeId', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByBlockedReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedReason', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByBlockedReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedReason', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByContentHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByContentHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByCreatedById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdById', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByCreatedByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdById', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByDescripcion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByDescripcionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy> sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy> sortByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByFechaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByFechaCompletado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaCompletado', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByFechaCompletadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaCompletado', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByLocationUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByLocationUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy> sortByNotas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notas', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByNotasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notas', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByPrioridad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prioridad', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByPrioridadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prioridad', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByRecurrenceRule() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceRule', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByRecurrenceRuleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceRule', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortBySyncDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDate', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortBySyncDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDate', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy> sortByTipo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByTipoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy> sortByTitulo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titulo', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByTituloDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titulo', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByUbicacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ubicacion', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByUbicacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ubicacion', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByWorkTeamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workTeamId', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      sortByWorkTeamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workTeamId', Sort.desc);
    });
  }
}

extension IsarAgendaEntryQuerySortThenBy
    on QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QSortThenBy> {
  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByAssigneeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assigneeId', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByAssigneeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assigneeId', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByBlockedReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedReason', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByBlockedReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedReason', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByContentHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByContentHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByCreatedById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdById', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByCreatedByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdById', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByDescripcion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByDescripcionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy> thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy> thenByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByFechaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByFechaCompletado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaCompletado', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByFechaCompletadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaCompletado', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByLocationUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByLocationUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy> thenByNotas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notas', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByNotasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notas', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByPrioridad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prioridad', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByPrioridadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prioridad', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByRecurrenceRule() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceRule', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByRecurrenceRuleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceRule', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenBySyncDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDate', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenBySyncDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDate', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy> thenByTipo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByTipoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy> thenByTitulo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titulo', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByTituloDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titulo', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByUbicacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ubicacion', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByUbicacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ubicacion', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByWorkTeamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workTeamId', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QAfterSortBy>
      thenByWorkTeamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workTeamId', Sort.desc);
    });
  }
}

extension IsarAgendaEntryQueryWhereDistinct
    on QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct> {
  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctByActivitiesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activitiesJson');
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctByAnimalIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animalIds');
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctByAssigneeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assigneeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctByBlockedReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockedReason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctByChecklistJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'checklistJson');
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctByCollaboratorIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collaboratorIds');
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctByCompletedAnimalIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAnimalIds');
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctByContentHash({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctByCreatedById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdById', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctByDescripcion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'descripcion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct> distinctByEstado(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctByEvidenceJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'evidenceJson');
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct> distinctByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fecha');
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctByFechaCompletado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaCompletado');
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctByLocationUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctByLoteIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loteIds');
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct> distinctByNotas(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notas', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct> distinctByPrioridad(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'prioridad', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctByRecurrenceRule({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrenceRule',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct> distinctByRemoteId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctBySyncDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncDate');
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct> distinctByTipo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct> distinctByTitulo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'titulo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct> distinctByUbicacion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ubicacion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QDistinct>
      distinctByWorkTeamId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'workTeamId', caseSensitive: caseSensitive);
    });
  }
}

extension IsarAgendaEntryQueryProperty
    on QueryBuilder<IsarAgendaEntry, IsarAgendaEntry, QQueryProperty> {
  QueryBuilder<IsarAgendaEntry, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<IsarAgendaEntry, List<String>, QQueryOperations>
      activitiesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activitiesJson');
    });
  }

  QueryBuilder<IsarAgendaEntry, List<String>, QQueryOperations>
      animalIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animalIds');
    });
  }

  QueryBuilder<IsarAgendaEntry, String?, QQueryOperations>
      assigneeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assigneeId');
    });
  }

  QueryBuilder<IsarAgendaEntry, String?, QQueryOperations>
      blockedReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockedReason');
    });
  }

  QueryBuilder<IsarAgendaEntry, List<String>, QQueryOperations>
      checklistJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'checklistJson');
    });
  }

  QueryBuilder<IsarAgendaEntry, List<String>, QQueryOperations>
      collaboratorIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collaboratorIds');
    });
  }

  QueryBuilder<IsarAgendaEntry, List<String>, QQueryOperations>
      completedAnimalIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAnimalIds');
    });
  }

  QueryBuilder<IsarAgendaEntry, String?, QQueryOperations>
      contentHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentHash');
    });
  }

  QueryBuilder<IsarAgendaEntry, DateTime?, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<IsarAgendaEntry, String?, QQueryOperations>
      createdByIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdById');
    });
  }

  QueryBuilder<IsarAgendaEntry, String, QQueryOperations>
      descripcionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descripcion');
    });
  }

  QueryBuilder<IsarAgendaEntry, String, QQueryOperations> estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<IsarAgendaEntry, List<String>, QQueryOperations>
      evidenceJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'evidenceJson');
    });
  }

  QueryBuilder<IsarAgendaEntry, DateTime, QQueryOperations> fechaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fecha');
    });
  }

  QueryBuilder<IsarAgendaEntry, DateTime?, QQueryOperations>
      fechaCompletadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaCompletado');
    });
  }

  QueryBuilder<IsarAgendaEntry, String?, QQueryOperations>
      locationUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationUuid');
    });
  }

  QueryBuilder<IsarAgendaEntry, List<String>, QQueryOperations>
      loteIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loteIds');
    });
  }

  QueryBuilder<IsarAgendaEntry, String, QQueryOperations> notasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notas');
    });
  }

  QueryBuilder<IsarAgendaEntry, String, QQueryOperations> prioridadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'prioridad');
    });
  }

  QueryBuilder<IsarAgendaEntry, String?, QQueryOperations>
      recurrenceRuleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrenceRule');
    });
  }

  QueryBuilder<IsarAgendaEntry, String?, QQueryOperations> remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<IsarAgendaEntry, DateTime?, QQueryOperations>
      syncDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncDate');
    });
  }

  QueryBuilder<IsarAgendaEntry, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<IsarAgendaEntry, String, QQueryOperations> tipoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipo');
    });
  }

  QueryBuilder<IsarAgendaEntry, String, QQueryOperations> tituloProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'titulo');
    });
  }

  QueryBuilder<IsarAgendaEntry, String, QQueryOperations> ubicacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ubicacion');
    });
  }

  QueryBuilder<IsarAgendaEntry, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<IsarAgendaEntry, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }

  QueryBuilder<IsarAgendaEntry, String?, QQueryOperations>
      workTeamIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'workTeamId');
    });
  }
}
