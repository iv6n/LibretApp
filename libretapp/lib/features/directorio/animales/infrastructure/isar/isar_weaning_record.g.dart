// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_weaning_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarWeaningRecordCollection on Isar {
  IsarCollection<IsarWeaningRecord> get isarWeaningRecords => this.collection();
}

const IsarWeaningRecordSchema = CollectionSchema(
  name: r'IsarWeaningRecord',
  id: 4842543932809967542,
  properties: {
    r'animalUuid': PropertySchema(
      id: 0,
      name: r'animalUuid',
      type: IsarType.string,
    ),
    r'date': PropertySchema(id: 1, name: r'date', type: IsarType.dateTime),
    r'notes': PropertySchema(id: 2, name: r'notes', type: IsarType.string),
    r'performedBy': PropertySchema(
      id: 3,
      name: r'performedBy',
      type: IsarType.string,
    ),
    r'previousCategory': PropertySchema(
      id: 4,
      name: r'previousCategory',
      type: IsarType.string,
    ),
    r'previousProductionStage': PropertySchema(
      id: 5,
      name: r'previousProductionStage',
      type: IsarType.string,
    ),
    r'recordUuid': PropertySchema(
      id: 6,
      name: r'recordUuid',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 7,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'weightKg': PropertySchema(
      id: 8,
      name: r'weightKg',
      type: IsarType.double,
    ),
    r'weightMethod': PropertySchema(
      id: 9,
      name: r'weightMethod',
      type: IsarType.string,
    ),
    r'weightRecordUuid': PropertySchema(
      id: 10,
      name: r'weightRecordUuid',
      type: IsarType.string,
    ),
  },

  estimateSize: _isarWeaningRecordEstimateSize,
  serialize: _isarWeaningRecordSerialize,
  deserialize: _isarWeaningRecordDeserialize,
  deserializeProp: _isarWeaningRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'recordUuid': IndexSchema(
      id: -7022185352407143161,
      name: r'recordUuid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'recordUuid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'animalUuid': IndexSchema(
      id: 3546875230825122358,
      name: r'animalUuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'animalUuid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _isarWeaningRecordGetId,
  getLinks: _isarWeaningRecordGetLinks,
  attach: _isarWeaningRecordAttach,
  version: '3.3.2',
);

int _isarWeaningRecordEstimateSize(
  IsarWeaningRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.animalUuid.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.performedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.previousCategory;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.previousProductionStage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.recordUuid.length * 3;
  bytesCount += 3 + object.weightMethod.length * 3;
  {
    final value = object.weightRecordUuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _isarWeaningRecordSerialize(
  IsarWeaningRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.animalUuid);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeString(offsets[2], object.notes);
  writer.writeString(offsets[3], object.performedBy);
  writer.writeString(offsets[4], object.previousCategory);
  writer.writeString(offsets[5], object.previousProductionStage);
  writer.writeString(offsets[6], object.recordUuid);
  writer.writeDateTime(offsets[7], object.updatedAt);
  writer.writeDouble(offsets[8], object.weightKg);
  writer.writeString(offsets[9], object.weightMethod);
  writer.writeString(offsets[10], object.weightRecordUuid);
}

IsarWeaningRecord _isarWeaningRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarWeaningRecord();
  object.animalUuid = reader.readString(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.id = id;
  object.notes = reader.readStringOrNull(offsets[2]);
  object.performedBy = reader.readStringOrNull(offsets[3]);
  object.previousCategory = reader.readStringOrNull(offsets[4]);
  object.previousProductionStage = reader.readStringOrNull(offsets[5]);
  object.recordUuid = reader.readString(offsets[6]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[7]);
  object.weightKg = reader.readDoubleOrNull(offsets[8]);
  object.weightMethod = reader.readString(offsets[9]);
  object.weightRecordUuid = reader.readStringOrNull(offsets[10]);
  return object;
}

P _isarWeaningRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarWeaningRecordGetId(IsarWeaningRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarWeaningRecordGetLinks(
  IsarWeaningRecord object,
) {
  return [];
}

void _isarWeaningRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  IsarWeaningRecord object,
) {
  object.id = id;
}

extension IsarWeaningRecordByIndex on IsarCollection<IsarWeaningRecord> {
  Future<IsarWeaningRecord?> getByRecordUuid(String recordUuid) {
    return getByIndex(r'recordUuid', [recordUuid]);
  }

  IsarWeaningRecord? getByRecordUuidSync(String recordUuid) {
    return getByIndexSync(r'recordUuid', [recordUuid]);
  }

  Future<bool> deleteByRecordUuid(String recordUuid) {
    return deleteByIndex(r'recordUuid', [recordUuid]);
  }

  bool deleteByRecordUuidSync(String recordUuid) {
    return deleteByIndexSync(r'recordUuid', [recordUuid]);
  }

  Future<List<IsarWeaningRecord?>> getAllByRecordUuid(
    List<String> recordUuidValues,
  ) {
    final values = recordUuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'recordUuid', values);
  }

  List<IsarWeaningRecord?> getAllByRecordUuidSync(
    List<String> recordUuidValues,
  ) {
    final values = recordUuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'recordUuid', values);
  }

  Future<int> deleteAllByRecordUuid(List<String> recordUuidValues) {
    final values = recordUuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'recordUuid', values);
  }

  int deleteAllByRecordUuidSync(List<String> recordUuidValues) {
    final values = recordUuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'recordUuid', values);
  }

  Future<Id> putByRecordUuid(IsarWeaningRecord object) {
    return putByIndex(r'recordUuid', object);
  }

  Id putByRecordUuidSync(IsarWeaningRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'recordUuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRecordUuid(List<IsarWeaningRecord> objects) {
    return putAllByIndex(r'recordUuid', objects);
  }

  List<Id> putAllByRecordUuidSync(
    List<IsarWeaningRecord> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'recordUuid', objects, saveLinks: saveLinks);
  }
}

extension IsarWeaningRecordQueryWhereSort
    on QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QWhere> {
  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarWeaningRecordQueryWhere
    on QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QWhereClause> {
  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterWhereClause>
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

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterWhereClause>
  recordUuidEqualTo(String recordUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'recordUuid', value: [recordUuid]),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterWhereClause>
  recordUuidNotEqualTo(String recordUuid) {
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

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterWhereClause>
  animalUuidEqualTo(String animalUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'animalUuid', value: [animalUuid]),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterWhereClause>
  animalUuidNotEqualTo(String animalUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'animalUuid',
                lower: [],
                upper: [animalUuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'animalUuid',
                lower: [animalUuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'animalUuid',
                lower: [animalUuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'animalUuid',
                lower: [],
                upper: [animalUuid],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension IsarWeaningRecordQueryFilter
    on QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QFilterCondition> {
  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  animalUuidEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'animalUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  animalUuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'animalUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  animalUuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'animalUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  animalUuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'animalUuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  animalUuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'animalUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  animalUuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'animalUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  animalUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'animalUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  animalUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'animalUuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  animalUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'animalUuid', value: ''),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  animalUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'animalUuid', value: ''),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  dateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  dateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'date',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  notesEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  notesStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  notesEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'notes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  performedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'performedBy'),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  performedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'performedBy'),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  performedByEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'performedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  performedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'performedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  performedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'performedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  performedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'performedBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  performedByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'performedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  performedByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'performedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  performedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'performedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  performedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'performedBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  performedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'performedBy', value: ''),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  performedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'performedBy', value: ''),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousCategoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'previousCategory'),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousCategoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'previousCategory'),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousCategoryEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'previousCategory',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousCategoryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'previousCategory',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousCategoryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'previousCategory',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousCategoryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'previousCategory',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousCategoryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'previousCategory',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousCategoryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'previousCategory',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousCategoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'previousCategory',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousCategoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'previousCategory',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousCategoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'previousCategory', value: ''),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousCategoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'previousCategory', value: ''),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousProductionStageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'previousProductionStage'),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousProductionStageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'previousProductionStage'),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousProductionStageEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'previousProductionStage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousProductionStageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'previousProductionStage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousProductionStageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'previousProductionStage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousProductionStageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'previousProductionStage',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousProductionStageStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'previousProductionStage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousProductionStageEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'previousProductionStage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousProductionStageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'previousProductionStage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousProductionStageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'previousProductionStage',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousProductionStageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'previousProductionStage',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  previousProductionStageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'previousProductionStage',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  recordUuidEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  recordUuidGreaterThan(
    String value, {
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

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  recordUuidLessThan(
    String value, {
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

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  recordUuidBetween(
    String lower,
    String upper, {
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

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  recordUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recordUuid', value: ''),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  recordUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'recordUuid', value: ''),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime? value, {bool include = false}) {
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

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  updatedAtLessThan(DateTime? value, {bool include = false}) {
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

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightKgIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'weightKg'),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightKgIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'weightKg'),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightKgEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'weightKg',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightKgGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'weightKg',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightKgLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'weightKg',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightKgBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'weightKg',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightMethodEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'weightMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightMethodGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'weightMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightMethodLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'weightMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightMethodBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'weightMethod',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightMethodStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'weightMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightMethodEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'weightMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightMethodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'weightMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightMethodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'weightMethod',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightMethodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'weightMethod', value: ''),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightMethodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'weightMethod', value: ''),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightRecordUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'weightRecordUuid'),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightRecordUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'weightRecordUuid'),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightRecordUuidEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'weightRecordUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightRecordUuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'weightRecordUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightRecordUuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'weightRecordUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightRecordUuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'weightRecordUuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightRecordUuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'weightRecordUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightRecordUuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'weightRecordUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightRecordUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'weightRecordUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightRecordUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'weightRecordUuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightRecordUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'weightRecordUuid', value: ''),
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterFilterCondition>
  weightRecordUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'weightRecordUuid', value: ''),
      );
    });
  }
}

extension IsarWeaningRecordQueryObject
    on QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QFilterCondition> {}

extension IsarWeaningRecordQueryLinks
    on QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QFilterCondition> {}

extension IsarWeaningRecordQuerySortBy
    on QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QSortBy> {
  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByAnimalUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByAnimalUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByPerformedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedBy', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByPerformedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedBy', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByPreviousCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousCategory', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByPreviousCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousCategory', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByPreviousProductionStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousProductionStage', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByPreviousProductionStageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousProductionStage', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByRecordUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByRecordUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByWeightMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightMethod', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByWeightMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightMethod', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByWeightRecordUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightRecordUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  sortByWeightRecordUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightRecordUuid', Sort.desc);
    });
  }
}

extension IsarWeaningRecordQuerySortThenBy
    on QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QSortThenBy> {
  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByAnimalUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByAnimalUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByPerformedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedBy', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByPerformedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedBy', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByPreviousCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousCategory', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByPreviousCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousCategory', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByPreviousProductionStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousProductionStage', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByPreviousProductionStageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousProductionStage', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByRecordUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByRecordUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByWeightMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightMethod', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByWeightMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightMethod', Sort.desc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByWeightRecordUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightRecordUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QAfterSortBy>
  thenByWeightRecordUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightRecordUuid', Sort.desc);
    });
  }
}

extension IsarWeaningRecordQueryWhereDistinct
    on QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QDistinct> {
  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QDistinct>
  distinctByAnimalUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animalUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QDistinct>
  distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QDistinct>
  distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QDistinct>
  distinctByPerformedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'performedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QDistinct>
  distinctByPreviousCategory({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'previousCategory',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QDistinct>
  distinctByPreviousProductionStage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'previousProductionStage',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QDistinct>
  distinctByRecordUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QDistinct>
  distinctByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightKg');
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QDistinct>
  distinctByWeightMethod({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightMethod', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QDistinct>
  distinctByWeightRecordUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'weightRecordUuid',
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension IsarWeaningRecordQueryProperty
    on QueryBuilder<IsarWeaningRecord, IsarWeaningRecord, QQueryProperty> {
  QueryBuilder<IsarWeaningRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarWeaningRecord, String, QQueryOperations>
  animalUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animalUuid');
    });
  }

  QueryBuilder<IsarWeaningRecord, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<IsarWeaningRecord, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<IsarWeaningRecord, String?, QQueryOperations>
  performedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'performedBy');
    });
  }

  QueryBuilder<IsarWeaningRecord, String?, QQueryOperations>
  previousCategoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previousCategory');
    });
  }

  QueryBuilder<IsarWeaningRecord, String?, QQueryOperations>
  previousProductionStageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previousProductionStage');
    });
  }

  QueryBuilder<IsarWeaningRecord, String, QQueryOperations>
  recordUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordUuid');
    });
  }

  QueryBuilder<IsarWeaningRecord, DateTime?, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<IsarWeaningRecord, double?, QQueryOperations>
  weightKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightKg');
    });
  }

  QueryBuilder<IsarWeaningRecord, String, QQueryOperations>
  weightMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightMethod');
    });
  }

  QueryBuilder<IsarWeaningRecord, String?, QQueryOperations>
  weightRecordUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightRecordUuid');
    });
  }
}
