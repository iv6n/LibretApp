// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_milking_session.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarMilkingSessionCollection on Isar {
  IsarCollection<IsarMilkingSession> get isarMilkingSessions =>
      this.collection();
}

const IsarMilkingSessionSchema = CollectionSchema(
  name: r'IsarMilkingSession',
  id: 1776949145189895832,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'notes': PropertySchema(
      id: 1,
      name: r'notes',
      type: IsarType.string,
    ),
    r'occurredAt': PropertySchema(
      id: 2,
      name: r'occurredAt',
      type: IsarType.dateTime,
    ),
    r'shift': PropertySchema(
      id: 3,
      name: r'shift',
      type: IsarType.string,
    ),
    r'sourceLoteUuid': PropertySchema(
      id: 4,
      name: r'sourceLoteUuid',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 5,
      name: r'status',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(
      id: 7,
      name: r'uuid',
      type: IsarType.string,
    )
  },
  estimateSize: _isarMilkingSessionEstimateSize,
  serialize: _isarMilkingSessionSerialize,
  deserialize: _isarMilkingSessionDeserialize,
  deserializeProp: _isarMilkingSessionDeserializeProp,
  idName: r'id',
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
    r'occurredAt': IndexSchema(
      id: 1229694562040044173,
      name: r'occurredAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'occurredAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'sourceLoteUuid': IndexSchema(
      id: -8110229071666841230,
      name: r'sourceLoteUuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sourceLoteUuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarMilkingSessionGetId,
  getLinks: _isarMilkingSessionGetLinks,
  attach: _isarMilkingSessionAttach,
  version: '3.1.0+1',
);

int _isarMilkingSessionEstimateSize(
  IsarMilkingSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.shift.length * 3;
  {
    final value = object.sourceLoteUuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _isarMilkingSessionSerialize(
  IsarMilkingSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.notes);
  writer.writeDateTime(offsets[2], object.occurredAt);
  writer.writeString(offsets[3], object.shift);
  writer.writeString(offsets[4], object.sourceLoteUuid);
  writer.writeString(offsets[5], object.status);
  writer.writeDateTime(offsets[6], object.updatedAt);
  writer.writeString(offsets[7], object.uuid);
}

IsarMilkingSession _isarMilkingSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarMilkingSession();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.notes = reader.readStringOrNull(offsets[1]);
  object.occurredAt = reader.readDateTime(offsets[2]);
  object.shift = reader.readString(offsets[3]);
  object.sourceLoteUuid = reader.readStringOrNull(offsets[4]);
  object.status = reader.readString(offsets[5]);
  object.updatedAt = reader.readDateTime(offsets[6]);
  object.uuid = reader.readString(offsets[7]);
  return object;
}

P _isarMilkingSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarMilkingSessionGetId(IsarMilkingSession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarMilkingSessionGetLinks(
    IsarMilkingSession object) {
  return [];
}

void _isarMilkingSessionAttach(
    IsarCollection<dynamic> col, Id id, IsarMilkingSession object) {
  object.id = id;
}

extension IsarMilkingSessionByIndex on IsarCollection<IsarMilkingSession> {
  Future<IsarMilkingSession?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  IsarMilkingSession? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<IsarMilkingSession?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<IsarMilkingSession?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(IsarMilkingSession object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(IsarMilkingSession object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<IsarMilkingSession> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<IsarMilkingSession> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension IsarMilkingSessionQueryWhereSort
    on QueryBuilder<IsarMilkingSession, IsarMilkingSession, QWhere> {
  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhere>
      anyOccurredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'occurredAt'),
      );
    });
  }
}

extension IsarMilkingSessionQueryWhere
    on QueryBuilder<IsarMilkingSession, IsarMilkingSession, QWhereClause> {
  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhereClause>
      uuidEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhereClause>
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

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhereClause>
      occurredAtEqualTo(DateTime occurredAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'occurredAt',
        value: [occurredAt],
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhereClause>
      occurredAtNotEqualTo(DateTime occurredAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurredAt',
              lower: [],
              upper: [occurredAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurredAt',
              lower: [occurredAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurredAt',
              lower: [occurredAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurredAt',
              lower: [],
              upper: [occurredAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhereClause>
      occurredAtGreaterThan(
    DateTime occurredAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'occurredAt',
        lower: [occurredAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhereClause>
      occurredAtLessThan(
    DateTime occurredAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'occurredAt',
        lower: [],
        upper: [occurredAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhereClause>
      occurredAtBetween(
    DateTime lowerOccurredAt,
    DateTime upperOccurredAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'occurredAt',
        lower: [lowerOccurredAt],
        includeLower: includeLower,
        upper: [upperOccurredAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhereClause>
      statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhereClause>
      statusNotEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhereClause>
      sourceLoteUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sourceLoteUuid',
        value: [null],
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhereClause>
      sourceLoteUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sourceLoteUuid',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhereClause>
      sourceLoteUuidEqualTo(String? sourceLoteUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sourceLoteUuid',
        value: [sourceLoteUuid],
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterWhereClause>
      sourceLoteUuidNotEqualTo(String? sourceLoteUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceLoteUuid',
              lower: [],
              upper: [sourceLoteUuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceLoteUuid',
              lower: [sourceLoteUuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceLoteUuid',
              lower: [sourceLoteUuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceLoteUuid',
              lower: [],
              upper: [sourceLoteUuid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarMilkingSessionQueryFilter
    on QueryBuilder<IsarMilkingSession, IsarMilkingSession, QFilterCondition> {
  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
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

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      occurredAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'occurredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      occurredAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'occurredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      occurredAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'occurredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      occurredAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'occurredAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      shiftEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shift',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      shiftGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shift',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      shiftLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shift',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      shiftBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shift',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      shiftStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'shift',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      shiftEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'shift',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      shiftContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'shift',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      shiftMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'shift',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      shiftIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shift',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      shiftIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'shift',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      sourceLoteUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceLoteUuid',
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      sourceLoteUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceLoteUuid',
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      sourceLoteUuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceLoteUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      sourceLoteUuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceLoteUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      sourceLoteUuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceLoteUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      sourceLoteUuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceLoteUuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      sourceLoteUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceLoteUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      sourceLoteUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceLoteUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      sourceLoteUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceLoteUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      sourceLoteUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceLoteUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      sourceLoteUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceLoteUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      sourceLoteUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceLoteUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
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

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
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

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
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

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
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

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
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

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
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

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
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

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterFilterCondition>
      uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }
}

extension IsarMilkingSessionQueryObject
    on QueryBuilder<IsarMilkingSession, IsarMilkingSession, QFilterCondition> {}

extension IsarMilkingSessionQueryLinks
    on QueryBuilder<IsarMilkingSession, IsarMilkingSession, QFilterCondition> {}

extension IsarMilkingSessionQuerySortBy
    on QueryBuilder<IsarMilkingSession, IsarMilkingSession, QSortBy> {
  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      sortByOccurredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurredAt', Sort.asc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      sortByOccurredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurredAt', Sort.desc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      sortByShift() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shift', Sort.asc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      sortByShiftDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shift', Sort.desc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      sortBySourceLoteUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceLoteUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      sortBySourceLoteUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceLoteUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension IsarMilkingSessionQuerySortThenBy
    on QueryBuilder<IsarMilkingSession, IsarMilkingSession, QSortThenBy> {
  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      thenByOccurredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurredAt', Sort.asc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      thenByOccurredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurredAt', Sort.desc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      thenByShift() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shift', Sort.asc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      thenByShiftDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shift', Sort.desc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      thenBySourceLoteUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceLoteUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      thenBySourceLoteUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceLoteUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QAfterSortBy>
      thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension IsarMilkingSessionQueryWhereDistinct
    on QueryBuilder<IsarMilkingSession, IsarMilkingSession, QDistinct> {
  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QDistinct>
      distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QDistinct>
      distinctByOccurredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'occurredAt');
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QDistinct>
      distinctByShift({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shift', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QDistinct>
      distinctBySourceLoteUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceLoteUuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<IsarMilkingSession, IsarMilkingSession, QDistinct>
      distinctByUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension IsarMilkingSessionQueryProperty
    on QueryBuilder<IsarMilkingSession, IsarMilkingSession, QQueryProperty> {
  QueryBuilder<IsarMilkingSession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarMilkingSession, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<IsarMilkingSession, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<IsarMilkingSession, DateTime, QQueryOperations>
      occurredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'occurredAt');
    });
  }

  QueryBuilder<IsarMilkingSession, String, QQueryOperations> shiftProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shift');
    });
  }

  QueryBuilder<IsarMilkingSession, String?, QQueryOperations>
      sourceLoteUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceLoteUuid');
    });
  }

  QueryBuilder<IsarMilkingSession, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<IsarMilkingSession, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<IsarMilkingSession, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
