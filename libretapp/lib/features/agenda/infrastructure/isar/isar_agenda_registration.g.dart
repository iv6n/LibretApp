// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_agenda_registration.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarAgendaRegistrationCollection on Isar {
  IsarCollection<IsarAgendaRegistration> get isarAgendaRegistrations =>
      this.collection();
}

const IsarAgendaRegistrationSchema = CollectionSchema(
  name: r'IsarAgendaRegistration',
  id: -8339372035316499322,
  properties: {
    r'animalId': PropertySchema(
      id: 0,
      name: r'animalId',
      type: IsarType.string,
    ),
    r'batchId': PropertySchema(id: 1, name: r'batchId', type: IsarType.string),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dataJson': PropertySchema(
      id: 3,
      name: r'dataJson',
      type: IsarType.string,
    ),
    r'entryId': PropertySchema(id: 4, name: r'entryId', type: IsarType.string),
    r'eventKey': PropertySchema(
      id: 5,
      name: r'eventKey',
      type: IsarType.string,
    ),
    r'evidencePaths': PropertySchema(
      id: 6,
      name: r'evidencePaths',
      type: IsarType.stringList,
    ),
    r'kind': PropertySchema(id: 7, name: r'kind', type: IsarType.string),
    r'performedAt': PropertySchema(
      id: 8,
      name: r'performedAt',
      type: IsarType.dateTime,
    ),
    r'recordUuid': PropertySchema(
      id: 9,
      name: r'recordUuid',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(id: 11, name: r'uuid', type: IsarType.string),
  },

  estimateSize: _isarAgendaRegistrationEstimateSize,
  serialize: _isarAgendaRegistrationSerialize,
  deserialize: _isarAgendaRegistrationDeserialize,
  deserializeProp: _isarAgendaRegistrationDeserializeProp,
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
        ),
      ],
    ),
    r'batchId': IndexSchema(
      id: -5468368523860846432,
      name: r'batchId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'batchId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'entryId': IndexSchema(
      id: 3733379884318738402,
      name: r'entryId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entryId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'eventKey': IndexSchema(
      id: -6167434590247707527,
      name: r'eventKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'eventKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'animalId': IndexSchema(
      id: -8446297297210463032,
      name: r'animalId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'animalId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'recordUuid': IndexSchema(
      id: -7022185352407143161,
      name: r'recordUuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'recordUuid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'updatedAt': IndexSchema(
      id: -6238191080293565125,
      name: r'updatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'updatedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _isarAgendaRegistrationGetId,
  getLinks: _isarAgendaRegistrationGetLinks,
  attach: _isarAgendaRegistrationAttach,
  version: '3.3.2',
);

int _isarAgendaRegistrationEstimateSize(
  IsarAgendaRegistration object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.animalId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.batchId.length * 3;
  bytesCount += 3 + object.dataJson.length * 3;
  bytesCount += 3 + object.entryId.length * 3;
  bytesCount += 3 + object.eventKey.length * 3;
  bytesCount += 3 + object.evidencePaths.length * 3;
  {
    for (var i = 0; i < object.evidencePaths.length; i++) {
      final value = object.evidencePaths[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.kind.length * 3;
  {
    final value = object.recordUuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _isarAgendaRegistrationSerialize(
  IsarAgendaRegistration object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.animalId);
  writer.writeString(offsets[1], object.batchId);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.dataJson);
  writer.writeString(offsets[4], object.entryId);
  writer.writeString(offsets[5], object.eventKey);
  writer.writeStringList(offsets[6], object.evidencePaths);
  writer.writeString(offsets[7], object.kind);
  writer.writeDateTime(offsets[8], object.performedAt);
  writer.writeString(offsets[9], object.recordUuid);
  writer.writeDateTime(offsets[10], object.updatedAt);
  writer.writeString(offsets[11], object.uuid);
}

IsarAgendaRegistration _isarAgendaRegistrationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarAgendaRegistration();
  object.animalId = reader.readStringOrNull(offsets[0]);
  object.batchId = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.dataJson = reader.readString(offsets[3]);
  object.entryId = reader.readString(offsets[4]);
  object.eventKey = reader.readString(offsets[5]);
  object.evidencePaths = reader.readStringList(offsets[6]) ?? [];
  object.isarId = id;
  object.kind = reader.readString(offsets[7]);
  object.performedAt = reader.readDateTime(offsets[8]);
  object.recordUuid = reader.readStringOrNull(offsets[9]);
  object.updatedAt = reader.readDateTime(offsets[10]);
  object.uuid = reader.readString(offsets[11]);
  return object;
}

P _isarAgendaRegistrationDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarAgendaRegistrationGetId(IsarAgendaRegistration object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _isarAgendaRegistrationGetLinks(
  IsarAgendaRegistration object,
) {
  return [];
}

void _isarAgendaRegistrationAttach(
  IsarCollection<dynamic> col,
  Id id,
  IsarAgendaRegistration object,
) {
  object.isarId = id;
}

extension IsarAgendaRegistrationByIndex
    on IsarCollection<IsarAgendaRegistration> {
  Future<IsarAgendaRegistration?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  IsarAgendaRegistration? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<IsarAgendaRegistration?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<IsarAgendaRegistration?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(IsarAgendaRegistration object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(IsarAgendaRegistration object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<IsarAgendaRegistration> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(
    List<IsarAgendaRegistration> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension IsarAgendaRegistrationQueryWhereSort
    on QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QWhere> {
  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterWhere>
  anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterWhere>
  anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }
}

extension IsarAgendaRegistrationQueryWhere
    on
        QueryBuilder<
          IsarAgendaRegistration,
          IsarAgendaRegistration,
          QWhereClause
        > {
  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: isarId, upper: isarId),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
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

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerIsarId,
          includeLower: includeLower,
          upper: upperIsarId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  uuidEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uuid', value: [uuid]),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  uuidNotEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [],
                upper: [uuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [uuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [uuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [],
                upper: [uuid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  batchIdEqualTo(String batchId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'batchId', value: [batchId]),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  batchIdNotEqualTo(String batchId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'batchId',
                lower: [],
                upper: [batchId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'batchId',
                lower: [batchId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'batchId',
                lower: [batchId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'batchId',
                lower: [],
                upper: [batchId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  entryIdEqualTo(String entryId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'entryId', value: [entryId]),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  entryIdNotEqualTo(String entryId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entryId',
                lower: [],
                upper: [entryId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entryId',
                lower: [entryId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entryId',
                lower: [entryId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entryId',
                lower: [],
                upper: [entryId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  eventKeyEqualTo(String eventKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'eventKey', value: [eventKey]),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  eventKeyNotEqualTo(String eventKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventKey',
                lower: [],
                upper: [eventKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventKey',
                lower: [eventKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventKey',
                lower: [eventKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventKey',
                lower: [],
                upper: [eventKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  animalIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'animalId', value: [null]),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  animalIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'animalId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  animalIdEqualTo(String? animalId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'animalId', value: [animalId]),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  animalIdNotEqualTo(String? animalId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'animalId',
                lower: [],
                upper: [animalId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'animalId',
                lower: [animalId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'animalId',
                lower: [animalId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'animalId',
                lower: [],
                upper: [animalId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  recordUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'recordUuid', value: [null]),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  recordUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'recordUuid',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  recordUuidEqualTo(String? recordUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'recordUuid', value: [recordUuid]),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  recordUuidNotEqualTo(String? recordUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'recordUuid',
                lower: [],
                upper: [recordUuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'recordUuid',
                lower: [recordUuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'recordUuid',
                lower: [recordUuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'recordUuid',
                lower: [],
                upper: [recordUuid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  updatedAtEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'updatedAt', value: [updatedAt]),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  updatedAtNotEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [],
                upper: [updatedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [updatedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [updatedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [],
                upper: [updatedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  updatedAtGreaterThan(DateTime updatedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [updatedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  updatedAtLessThan(DateTime updatedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [],
          upper: [updatedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterWhereClause
  >
  updatedAtBetween(
    DateTime lowerUpdatedAt,
    DateTime upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [lowerUpdatedAt],
          includeLower: includeLower,
          upper: [upperUpdatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension IsarAgendaRegistrationQueryFilter
    on
        QueryBuilder<
          IsarAgendaRegistration,
          IsarAgendaRegistration,
          QFilterCondition
        > {
  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  animalIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'animalId'),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  animalIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'animalId'),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  animalIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'animalId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  animalIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'animalId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  animalIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'animalId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  animalIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'animalId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  animalIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'animalId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  animalIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'animalId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  animalIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'animalId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  animalIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'animalId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  animalIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'animalId', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  animalIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'animalId', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  batchIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'batchId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  batchIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'batchId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  batchIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'batchId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  batchIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'batchId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  batchIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'batchId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  batchIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'batchId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  batchIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'batchId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  batchIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'batchId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  batchIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'batchId', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  batchIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'batchId', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  dataJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'dataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  dataJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  dataJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  dataJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dataJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  dataJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'dataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  dataJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'dataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  dataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'dataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  dataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'dataJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  dataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dataJson', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  dataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'dataJson', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  entryIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'entryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  entryIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  entryIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  entryIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entryId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  entryIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'entryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  entryIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'entryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  entryIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'entryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  entryIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'entryId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  entryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entryId', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  entryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'entryId', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  eventKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'eventKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  eventKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'eventKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  eventKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'eventKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  eventKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'eventKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  eventKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'eventKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  eventKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'eventKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  eventKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'eventKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  eventKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'eventKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  eventKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'eventKey', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  eventKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'eventKey', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  evidencePathsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'evidencePaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  evidencePathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'evidencePaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  evidencePathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'evidencePaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  evidencePathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'evidencePaths',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  evidencePathsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'evidencePaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  evidencePathsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'evidencePaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  evidencePathsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'evidencePaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  evidencePathsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'evidencePaths',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  evidencePathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'evidencePaths', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  evidencePathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'evidencePaths', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  evidencePathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'evidencePaths', length, true, length, true);
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  evidencePathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'evidencePaths', 0, true, 0, true);
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  evidencePathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'evidencePaths', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  evidencePathsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'evidencePaths', 0, true, length, include);
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  evidencePathsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'evidencePaths', length, include, 999999, true);
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  evidencePathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'evidencePaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isarId', value: value),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  isarIdGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'isarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  isarIdLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'isarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'isarId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  kindEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  kindGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  kindLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  kindBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kind',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  kindStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  kindEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  kindContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  kindMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'kind',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kind', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'kind', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  performedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'performedAt', value: value),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  performedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'performedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  performedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'performedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  performedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'performedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  recordUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'recordUuid'),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  recordUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'recordUuid'),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  recordUuidEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'recordUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  recordUuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'recordUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  recordUuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'recordUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  recordUuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'recordUuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  recordUuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'recordUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  recordUuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'recordUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  recordUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'recordUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  recordUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'recordUuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  recordUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recordUuid', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  recordUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'recordUuid', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  uuidEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  uuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  uuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<
    IsarAgendaRegistration,
    IsarAgendaRegistration,
    QAfterFilterCondition
  >
  uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uuid', value: ''),
      );
    });
  }
}

extension IsarAgendaRegistrationQueryObject
    on
        QueryBuilder<
          IsarAgendaRegistration,
          IsarAgendaRegistration,
          QFilterCondition
        > {}

extension IsarAgendaRegistrationQueryLinks
    on
        QueryBuilder<
          IsarAgendaRegistration,
          IsarAgendaRegistration,
          QFilterCondition
        > {}

extension IsarAgendaRegistrationQuerySortBy
    on QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QSortBy> {
  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByAnimalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalId', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByAnimalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalId', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByBatchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchId', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByBatchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchId', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByEntryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByEventKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventKey', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByEventKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventKey', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByPerformedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByPerformedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByRecordUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByRecordUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension IsarAgendaRegistrationQuerySortThenBy
    on
        QueryBuilder<
          IsarAgendaRegistration,
          IsarAgendaRegistration,
          QSortThenBy
        > {
  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByAnimalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalId', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByAnimalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalId', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByBatchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchId', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByBatchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchId', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByEntryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByEventKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventKey', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByEventKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventKey', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByPerformedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByPerformedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByRecordUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByRecordUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QAfterSortBy>
  thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension IsarAgendaRegistrationQueryWhereDistinct
    on QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QDistinct> {
  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QDistinct>
  distinctByAnimalId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animalId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QDistinct>
  distinctByBatchId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'batchId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QDistinct>
  distinctByDataJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QDistinct>
  distinctByEntryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QDistinct>
  distinctByEventKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QDistinct>
  distinctByEvidencePaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'evidencePaths');
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QDistinct>
  distinctByKind({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QDistinct>
  distinctByPerformedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'performedAt');
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QDistinct>
  distinctByRecordUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<IsarAgendaRegistration, IsarAgendaRegistration, QDistinct>
  distinctByUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension IsarAgendaRegistrationQueryProperty
    on
        QueryBuilder<
          IsarAgendaRegistration,
          IsarAgendaRegistration,
          QQueryProperty
        > {
  QueryBuilder<IsarAgendaRegistration, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<IsarAgendaRegistration, String?, QQueryOperations>
  animalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animalId');
    });
  }

  QueryBuilder<IsarAgendaRegistration, String, QQueryOperations>
  batchIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'batchId');
    });
  }

  QueryBuilder<IsarAgendaRegistration, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<IsarAgendaRegistration, String, QQueryOperations>
  dataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataJson');
    });
  }

  QueryBuilder<IsarAgendaRegistration, String, QQueryOperations>
  entryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entryId');
    });
  }

  QueryBuilder<IsarAgendaRegistration, String, QQueryOperations>
  eventKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventKey');
    });
  }

  QueryBuilder<IsarAgendaRegistration, List<String>, QQueryOperations>
  evidencePathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'evidencePaths');
    });
  }

  QueryBuilder<IsarAgendaRegistration, String, QQueryOperations>
  kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<IsarAgendaRegistration, DateTime, QQueryOperations>
  performedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'performedAt');
    });
  }

  QueryBuilder<IsarAgendaRegistration, String?, QQueryOperations>
  recordUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordUuid');
    });
  }

  QueryBuilder<IsarAgendaRegistration, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<IsarAgendaRegistration, String, QQueryOperations>
  uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
