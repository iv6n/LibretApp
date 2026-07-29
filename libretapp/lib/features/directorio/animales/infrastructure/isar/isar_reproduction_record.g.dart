// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_reproduction_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarReproductionRecordCollection on Isar {
  IsarCollection<IsarReproductionRecord> get isarReproductionRecords =>
      this.collection();
}

const IsarReproductionRecordSchema = CollectionSchema(
  name: r'IsarReproductionRecord',
  id: -2002002950456603058,
  properties: {
    r'actualCalvingDate': PropertySchema(
      id: 0,
      name: r'actualCalvingDate',
      type: IsarType.dateTime,
    ),
    r'animalUuid': PropertySchema(
      id: 1,
      name: r'animalUuid',
      type: IsarType.string,
    ),
    r'calvingResult': PropertySchema(
      id: 2,
      name: r'calvingResult',
      type: IsarType.string,
    ),
    r'contentHash': PropertySchema(
      id: 3,
      name: r'contentHash',
      type: IsarType.string,
    ),
    r'expectedCalvingDate': PropertySchema(
      id: 4,
      name: r'expectedCalvingDate',
      type: IsarType.dateTime,
    ),
    r'maleSireIdentifier': PropertySchema(
      id: 5,
      name: r'maleSireIdentifier',
      type: IsarType.string,
    ),
    r'maleSireUuid': PropertySchema(
      id: 6,
      name: r'maleSireUuid',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 7,
      name: r'notes',
      type: IsarType.string,
    ),
    r'pregnancyCheckDate': PropertySchema(
      id: 8,
      name: r'pregnancyCheckDate',
      type: IsarType.dateTime,
    ),
    r'pregnancyResult': PropertySchema(
      id: 9,
      name: r'pregnancyResult',
      type: IsarType.string,
    ),
    r'remoteId': PropertySchema(
      id: 10,
      name: r'remoteId',
      type: IsarType.string,
    ),
    r'serviceDate': PropertySchema(
      id: 11,
      name: r'serviceDate',
      type: IsarType.dateTime,
    ),
    r'serviceType': PropertySchema(
      id: 12,
      name: r'serviceType',
      type: IsarType.string,
    ),
    r'servicedBy': PropertySchema(
      id: 13,
      name: r'servicedBy',
      type: IsarType.string,
    ),
    r'syncDate': PropertySchema(
      id: 14,
      name: r'syncDate',
      type: IsarType.dateTime,
    ),
    r'synced': PropertySchema(
      id: 15,
      name: r'synced',
      type: IsarType.bool,
    ),
    r'updatedAt': PropertySchema(
      id: 16,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _isarReproductionRecordEstimateSize,
  serialize: _isarReproductionRecordSerialize,
  deserialize: _isarReproductionRecordDeserialize,
  deserializeProp: _isarReproductionRecordDeserializeProp,
  idName: r'id',
  indexes: {
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
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarReproductionRecordGetId,
  getLinks: _isarReproductionRecordGetLinks,
  attach: _isarReproductionRecordAttach,
  version: '3.1.0+1',
);

int _isarReproductionRecordEstimateSize(
  IsarReproductionRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.animalUuid.length * 3;
  {
    final value = object.calvingResult;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.contentHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.maleSireIdentifier;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.maleSireUuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.pregnancyResult;
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
  bytesCount += 3 + object.serviceType.length * 3;
  {
    final value = object.servicedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _isarReproductionRecordSerialize(
  IsarReproductionRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.actualCalvingDate);
  writer.writeString(offsets[1], object.animalUuid);
  writer.writeString(offsets[2], object.calvingResult);
  writer.writeString(offsets[3], object.contentHash);
  writer.writeDateTime(offsets[4], object.expectedCalvingDate);
  writer.writeString(offsets[5], object.maleSireIdentifier);
  writer.writeString(offsets[6], object.maleSireUuid);
  writer.writeString(offsets[7], object.notes);
  writer.writeDateTime(offsets[8], object.pregnancyCheckDate);
  writer.writeString(offsets[9], object.pregnancyResult);
  writer.writeString(offsets[10], object.remoteId);
  writer.writeDateTime(offsets[11], object.serviceDate);
  writer.writeString(offsets[12], object.serviceType);
  writer.writeString(offsets[13], object.servicedBy);
  writer.writeDateTime(offsets[14], object.syncDate);
  writer.writeBool(offsets[15], object.synced);
  writer.writeDateTime(offsets[16], object.updatedAt);
}

IsarReproductionRecord _isarReproductionRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarReproductionRecord();
  object.actualCalvingDate = reader.readDateTimeOrNull(offsets[0]);
  object.animalUuid = reader.readString(offsets[1]);
  object.calvingResult = reader.readStringOrNull(offsets[2]);
  object.contentHash = reader.readStringOrNull(offsets[3]);
  object.expectedCalvingDate = reader.readDateTimeOrNull(offsets[4]);
  object.id = id;
  object.maleSireIdentifier = reader.readStringOrNull(offsets[5]);
  object.maleSireUuid = reader.readStringOrNull(offsets[6]);
  object.notes = reader.readStringOrNull(offsets[7]);
  object.pregnancyCheckDate = reader.readDateTimeOrNull(offsets[8]);
  object.pregnancyResult = reader.readStringOrNull(offsets[9]);
  object.remoteId = reader.readStringOrNull(offsets[10]);
  object.serviceDate = reader.readDateTime(offsets[11]);
  object.serviceType = reader.readString(offsets[12]);
  object.servicedBy = reader.readStringOrNull(offsets[13]);
  object.syncDate = reader.readDateTimeOrNull(offsets[14]);
  object.synced = reader.readBool(offsets[15]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[16]);
  return object;
}

P _isarReproductionRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    case 16:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarReproductionRecordGetId(IsarReproductionRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarReproductionRecordGetLinks(
    IsarReproductionRecord object) {
  return [];
}

void _isarReproductionRecordAttach(
    IsarCollection<dynamic> col, Id id, IsarReproductionRecord object) {
  object.id = id;
}

extension IsarReproductionRecordQueryWhereSort
    on QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QWhere> {
  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarReproductionRecordQueryWhere on QueryBuilder<
    IsarReproductionRecord, IsarReproductionRecord, QWhereClause> {
  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterWhereClause> animalUuidEqualTo(String animalUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'animalUuid',
        value: [animalUuid],
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterWhereClause> animalUuidNotEqualTo(String animalUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'animalUuid',
              lower: [],
              upper: [animalUuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'animalUuid',
              lower: [animalUuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'animalUuid',
              lower: [animalUuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'animalUuid',
              lower: [],
              upper: [animalUuid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarReproductionRecordQueryFilter on QueryBuilder<
    IsarReproductionRecord, IsarReproductionRecord, QFilterCondition> {
  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> actualCalvingDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'actualCalvingDate',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> actualCalvingDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'actualCalvingDate',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> actualCalvingDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actualCalvingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> actualCalvingDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actualCalvingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> actualCalvingDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actualCalvingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> actualCalvingDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actualCalvingDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> animalUuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animalUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> animalUuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'animalUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> animalUuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'animalUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> animalUuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'animalUuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> animalUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'animalUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> animalUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'animalUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      animalUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'animalUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      animalUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'animalUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> animalUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animalUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> animalUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'animalUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> calvingResultIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'calvingResult',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> calvingResultIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'calvingResult',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> calvingResultEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calvingResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> calvingResultGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'calvingResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> calvingResultLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'calvingResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> calvingResultBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'calvingResult',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> calvingResultStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'calvingResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> calvingResultEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'calvingResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      calvingResultContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'calvingResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      calvingResultMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'calvingResult',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> calvingResultIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calvingResult',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> calvingResultIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'calvingResult',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> contentHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contentHash',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> contentHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contentHash',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> contentHashEqualTo(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> contentHashGreaterThan(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> contentHashLessThan(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> contentHashBetween(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> contentHashStartsWith(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> contentHashEndsWith(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      contentHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      contentHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contentHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> contentHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentHash',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> contentHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contentHash',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> expectedCalvingDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expectedCalvingDate',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> expectedCalvingDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expectedCalvingDate',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> expectedCalvingDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedCalvingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> expectedCalvingDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expectedCalvingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> expectedCalvingDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expectedCalvingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> expectedCalvingDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expectedCalvingDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireIdentifierIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'maleSireIdentifier',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireIdentifierIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'maleSireIdentifier',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireIdentifierEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maleSireIdentifier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireIdentifierGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maleSireIdentifier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireIdentifierLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maleSireIdentifier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireIdentifierBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maleSireIdentifier',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireIdentifierStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'maleSireIdentifier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireIdentifierEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'maleSireIdentifier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      maleSireIdentifierContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'maleSireIdentifier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      maleSireIdentifierMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'maleSireIdentifier',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireIdentifierIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maleSireIdentifier',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireIdentifierIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'maleSireIdentifier',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'maleSireUuid',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'maleSireUuid',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireUuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maleSireUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireUuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maleSireUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireUuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maleSireUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireUuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maleSireUuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'maleSireUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'maleSireUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      maleSireUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'maleSireUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      maleSireUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'maleSireUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maleSireUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> maleSireUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'maleSireUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> notesEqualTo(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> notesGreaterThan(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> notesLessThan(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> notesBetween(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> notesStartsWith(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> notesEndsWith(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> pregnancyCheckDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pregnancyCheckDate',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> pregnancyCheckDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pregnancyCheckDate',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> pregnancyCheckDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pregnancyCheckDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> pregnancyCheckDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pregnancyCheckDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> pregnancyCheckDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pregnancyCheckDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> pregnancyCheckDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pregnancyCheckDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> pregnancyResultIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pregnancyResult',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> pregnancyResultIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pregnancyResult',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> pregnancyResultEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pregnancyResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> pregnancyResultGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pregnancyResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> pregnancyResultLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pregnancyResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> pregnancyResultBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pregnancyResult',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> pregnancyResultStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pregnancyResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> pregnancyResultEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pregnancyResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      pregnancyResultContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pregnancyResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      pregnancyResultMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pregnancyResult',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> pregnancyResultIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pregnancyResult',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> pregnancyResultIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pregnancyResult',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> remoteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'remoteId',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> remoteIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'remoteId',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> remoteIdEqualTo(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> remoteIdGreaterThan(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> remoteIdLessThan(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> remoteIdBetween(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> remoteIdStartsWith(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> remoteIdEndsWith(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      remoteIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      remoteIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'remoteId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> remoteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> remoteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'remoteId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> serviceDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serviceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> serviceDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serviceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> serviceDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serviceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> serviceDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serviceDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> serviceTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serviceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> serviceTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serviceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> serviceTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serviceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> serviceTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serviceType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> serviceTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'serviceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> serviceTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'serviceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      serviceTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serviceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      serviceTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serviceType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> serviceTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serviceType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> serviceTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serviceType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> servicedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'servicedBy',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> servicedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'servicedBy',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> servicedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'servicedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> servicedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'servicedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> servicedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'servicedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> servicedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'servicedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> servicedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'servicedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> servicedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'servicedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      servicedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'servicedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
          QAfterFilterCondition>
      servicedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'servicedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> servicedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'servicedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> servicedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'servicedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> syncDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncDate',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> syncDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncDate',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> syncDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> syncDateGreaterThan(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> syncDateLessThan(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> syncDateBetween(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> syncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'synced',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> updatedAtGreaterThan(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord,
      QAfterFilterCondition> updatedAtBetween(
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
}

extension IsarReproductionRecordQueryObject on QueryBuilder<
    IsarReproductionRecord, IsarReproductionRecord, QFilterCondition> {}

extension IsarReproductionRecordQueryLinks on QueryBuilder<
    IsarReproductionRecord, IsarReproductionRecord, QFilterCondition> {}

extension IsarReproductionRecordQuerySortBy
    on QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QSortBy> {
  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByActualCalvingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualCalvingDate', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByActualCalvingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualCalvingDate', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByAnimalUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByAnimalUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByCalvingResult() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calvingResult', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByCalvingResultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calvingResult', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByContentHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByContentHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByExpectedCalvingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedCalvingDate', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByExpectedCalvingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedCalvingDate', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByMaleSireIdentifier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maleSireIdentifier', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByMaleSireIdentifierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maleSireIdentifier', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByMaleSireUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maleSireUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByMaleSireUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maleSireUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByPregnancyCheckDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pregnancyCheckDate', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByPregnancyCheckDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pregnancyCheckDate', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByPregnancyResult() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pregnancyResult', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByPregnancyResultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pregnancyResult', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDate', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByServiceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDate', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByServiceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceType', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByServiceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceType', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByServicedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servicedBy', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByServicedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servicedBy', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortBySyncDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDate', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortBySyncDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDate', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension IsarReproductionRecordQuerySortThenBy on QueryBuilder<
    IsarReproductionRecord, IsarReproductionRecord, QSortThenBy> {
  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByActualCalvingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualCalvingDate', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByActualCalvingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualCalvingDate', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByAnimalUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByAnimalUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByCalvingResult() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calvingResult', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByCalvingResultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calvingResult', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByContentHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByContentHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByExpectedCalvingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedCalvingDate', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByExpectedCalvingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedCalvingDate', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByMaleSireIdentifier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maleSireIdentifier', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByMaleSireIdentifierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maleSireIdentifier', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByMaleSireUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maleSireUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByMaleSireUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maleSireUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByPregnancyCheckDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pregnancyCheckDate', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByPregnancyCheckDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pregnancyCheckDate', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByPregnancyResult() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pregnancyResult', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByPregnancyResultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pregnancyResult', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDate', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByServiceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDate', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByServiceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceType', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByServiceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceType', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByServicedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servicedBy', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByServicedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servicedBy', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenBySyncDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDate', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenBySyncDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDate', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension IsarReproductionRecordQueryWhereDistinct
    on QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QDistinct> {
  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QDistinct>
      distinctByActualCalvingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actualCalvingDate');
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QDistinct>
      distinctByAnimalUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animalUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QDistinct>
      distinctByCalvingResult({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calvingResult',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QDistinct>
      distinctByContentHash({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QDistinct>
      distinctByExpectedCalvingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedCalvingDate');
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QDistinct>
      distinctByMaleSireIdentifier({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maleSireIdentifier',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QDistinct>
      distinctByMaleSireUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maleSireUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QDistinct>
      distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QDistinct>
      distinctByPregnancyCheckDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pregnancyCheckDate');
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QDistinct>
      distinctByPregnancyResult({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pregnancyResult',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QDistinct>
      distinctByRemoteId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QDistinct>
      distinctByServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceDate');
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QDistinct>
      distinctByServiceType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QDistinct>
      distinctByServicedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'servicedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QDistinct>
      distinctBySyncDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncDate');
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QDistinct>
      distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<IsarReproductionRecord, IsarReproductionRecord, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension IsarReproductionRecordQueryProperty on QueryBuilder<
    IsarReproductionRecord, IsarReproductionRecord, QQueryProperty> {
  QueryBuilder<IsarReproductionRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarReproductionRecord, DateTime?, QQueryOperations>
      actualCalvingDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actualCalvingDate');
    });
  }

  QueryBuilder<IsarReproductionRecord, String, QQueryOperations>
      animalUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animalUuid');
    });
  }

  QueryBuilder<IsarReproductionRecord, String?, QQueryOperations>
      calvingResultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calvingResult');
    });
  }

  QueryBuilder<IsarReproductionRecord, String?, QQueryOperations>
      contentHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentHash');
    });
  }

  QueryBuilder<IsarReproductionRecord, DateTime?, QQueryOperations>
      expectedCalvingDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedCalvingDate');
    });
  }

  QueryBuilder<IsarReproductionRecord, String?, QQueryOperations>
      maleSireIdentifierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maleSireIdentifier');
    });
  }

  QueryBuilder<IsarReproductionRecord, String?, QQueryOperations>
      maleSireUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maleSireUuid');
    });
  }

  QueryBuilder<IsarReproductionRecord, String?, QQueryOperations>
      notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<IsarReproductionRecord, DateTime?, QQueryOperations>
      pregnancyCheckDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pregnancyCheckDate');
    });
  }

  QueryBuilder<IsarReproductionRecord, String?, QQueryOperations>
      pregnancyResultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pregnancyResult');
    });
  }

  QueryBuilder<IsarReproductionRecord, String?, QQueryOperations>
      remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<IsarReproductionRecord, DateTime, QQueryOperations>
      serviceDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceDate');
    });
  }

  QueryBuilder<IsarReproductionRecord, String, QQueryOperations>
      serviceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceType');
    });
  }

  QueryBuilder<IsarReproductionRecord, String?, QQueryOperations>
      servicedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'servicedBy');
    });
  }

  QueryBuilder<IsarReproductionRecord, DateTime?, QQueryOperations>
      syncDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncDate');
    });
  }

  QueryBuilder<IsarReproductionRecord, bool, QQueryOperations>
      syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<IsarReproductionRecord, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
