// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_health_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarHealthRecordCollection on Isar {
  IsarCollection<IsarHealthRecord> get isarHealthRecords => this.collection();
}

const IsarHealthRecordSchema = CollectionSchema(
  name: r'IsarHealthRecord',
  id: -2758158634237855545,
  properties: {
    r'animalUuid': PropertySchema(
      id: 0,
      name: r'animalUuid',
      type: IsarType.string,
    ),
    r'appliedBy': PropertySchema(
      id: 1,
      name: r'appliedBy',
      type: IsarType.string,
    ),
    r'cause': PropertySchema(
      id: 2,
      name: r'cause',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 3,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'dose': PropertySchema(
      id: 4,
      name: r'dose',
      type: IsarType.string,
    ),
    r'nextDueDate': PropertySchema(
      id: 5,
      name: r'nextDueDate',
      type: IsarType.dateTime,
    ),
    r'notes': PropertySchema(
      id: 6,
      name: r'notes',
      type: IsarType.string,
    ),
    r'product': PropertySchema(
      id: 7,
      name: r'product',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 8,
      name: r'type',
      type: IsarType.string,
    )
  },
  estimateSize: _isarHealthRecordEstimateSize,
  serialize: _isarHealthRecordSerialize,
  deserialize: _isarHealthRecordDeserialize,
  deserializeProp: _isarHealthRecordDeserializeProp,
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
  getId: _isarHealthRecordGetId,
  getLinks: _isarHealthRecordGetLinks,
  attach: _isarHealthRecordAttach,
  version: '3.1.0+1',
);

int _isarHealthRecordEstimateSize(
  IsarHealthRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.animalUuid.length * 3;
  {
    final value = object.appliedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.cause;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.dose;
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
  bytesCount += 3 + object.product.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _isarHealthRecordSerialize(
  IsarHealthRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.animalUuid);
  writer.writeString(offsets[1], object.appliedBy);
  writer.writeString(offsets[2], object.cause);
  writer.writeDateTime(offsets[3], object.date);
  writer.writeString(offsets[4], object.dose);
  writer.writeDateTime(offsets[5], object.nextDueDate);
  writer.writeString(offsets[6], object.notes);
  writer.writeString(offsets[7], object.product);
  writer.writeString(offsets[8], object.type);
}

IsarHealthRecord _isarHealthRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarHealthRecord();
  object.animalUuid = reader.readString(offsets[0]);
  object.appliedBy = reader.readStringOrNull(offsets[1]);
  object.cause = reader.readStringOrNull(offsets[2]);
  object.date = reader.readDateTime(offsets[3]);
  object.dose = reader.readStringOrNull(offsets[4]);
  object.id = id;
  object.nextDueDate = reader.readDateTimeOrNull(offsets[5]);
  object.notes = reader.readStringOrNull(offsets[6]);
  object.product = reader.readString(offsets[7]);
  object.type = reader.readString(offsets[8]);
  return object;
}

P _isarHealthRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarHealthRecordGetId(IsarHealthRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarHealthRecordGetLinks(IsarHealthRecord object) {
  return [];
}

void _isarHealthRecordAttach(
    IsarCollection<dynamic> col, Id id, IsarHealthRecord object) {
  object.id = id;
}

extension IsarHealthRecordQueryWhereSort
    on QueryBuilder<IsarHealthRecord, IsarHealthRecord, QWhere> {
  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarHealthRecordQueryWhere
    on QueryBuilder<IsarHealthRecord, IsarHealthRecord, QWhereClause> {
  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterWhereClause>
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

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterWhereClause> idBetween(
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

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterWhereClause>
      animalUuidEqualTo(String animalUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'animalUuid',
        value: [animalUuid],
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterWhereClause>
      animalUuidNotEqualTo(String animalUuid) {
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

extension IsarHealthRecordQueryFilter
    on QueryBuilder<IsarHealthRecord, IsarHealthRecord, QFilterCondition> {
  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      animalUuidEqualTo(
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

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      animalUuidGreaterThan(
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

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      animalUuidLessThan(
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

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      animalUuidBetween(
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

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      animalUuidStartsWith(
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

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      animalUuidEndsWith(
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

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      animalUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'animalUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      animalUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'animalUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      animalUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animalUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      animalUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'animalUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      appliedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'appliedBy',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      appliedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'appliedBy',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      appliedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appliedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      appliedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'appliedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      appliedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'appliedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      appliedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'appliedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      appliedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'appliedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      appliedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'appliedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      appliedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'appliedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      appliedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'appliedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      appliedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appliedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      appliedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'appliedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      causeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cause',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      causeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cause',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      causeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cause',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      causeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cause',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      causeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cause',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      causeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cause',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      causeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cause',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      causeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cause',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      causeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cause',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      causeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cause',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      causeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cause',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      causeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cause',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      doseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dose',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      doseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dose',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      doseEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      doseGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      doseLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      doseBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dose',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      doseStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      doseEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      doseContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      doseMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dose',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      doseIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dose',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      doseIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dose',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      nextDueDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextDueDate',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      nextDueDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextDueDate',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      nextDueDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextDueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      nextDueDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextDueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      nextDueDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextDueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      nextDueDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextDueDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      productEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'product',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      productGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'product',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      productLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'product',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      productBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'product',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      productStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'product',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      productEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'product',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      productContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'product',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      productMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'product',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      productIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'product',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      productIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'product',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension IsarHealthRecordQueryObject
    on QueryBuilder<IsarHealthRecord, IsarHealthRecord, QFilterCondition> {}

extension IsarHealthRecordQueryLinks
    on QueryBuilder<IsarHealthRecord, IsarHealthRecord, QFilterCondition> {}

extension IsarHealthRecordQuerySortBy
    on QueryBuilder<IsarHealthRecord, IsarHealthRecord, QSortBy> {
  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      sortByAnimalUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      sortByAnimalUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      sortByAppliedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appliedBy', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      sortByAppliedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appliedBy', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy> sortByCause() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cause', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      sortByCauseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cause', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy> sortByDose() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dose', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      sortByDoseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dose', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      sortByNextDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      sortByNextDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      sortByProduct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'product', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      sortByProductDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'product', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension IsarHealthRecordQuerySortThenBy
    on QueryBuilder<IsarHealthRecord, IsarHealthRecord, QSortThenBy> {
  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      thenByAnimalUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      thenByAnimalUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      thenByAppliedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appliedBy', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      thenByAppliedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appliedBy', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy> thenByCause() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cause', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      thenByCauseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cause', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy> thenByDose() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dose', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      thenByDoseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dose', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      thenByNextDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      thenByNextDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      thenByProduct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'product', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      thenByProductDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'product', Sort.desc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension IsarHealthRecordQueryWhereDistinct
    on QueryBuilder<IsarHealthRecord, IsarHealthRecord, QDistinct> {
  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QDistinct>
      distinctByAnimalUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animalUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QDistinct>
      distinctByAppliedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appliedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QDistinct> distinctByCause(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cause', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QDistinct> distinctByDose(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dose', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QDistinct>
      distinctByNextDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextDueDate');
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QDistinct> distinctByProduct(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'product', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarHealthRecord, IsarHealthRecord, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension IsarHealthRecordQueryProperty
    on QueryBuilder<IsarHealthRecord, IsarHealthRecord, QQueryProperty> {
  QueryBuilder<IsarHealthRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarHealthRecord, String, QQueryOperations>
      animalUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animalUuid');
    });
  }

  QueryBuilder<IsarHealthRecord, String?, QQueryOperations>
      appliedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appliedBy');
    });
  }

  QueryBuilder<IsarHealthRecord, String?, QQueryOperations> causeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cause');
    });
  }

  QueryBuilder<IsarHealthRecord, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<IsarHealthRecord, String?, QQueryOperations> doseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dose');
    });
  }

  QueryBuilder<IsarHealthRecord, DateTime?, QQueryOperations>
      nextDueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextDueDate');
    });
  }

  QueryBuilder<IsarHealthRecord, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<IsarHealthRecord, String, QQueryOperations> productProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'product');
    });
  }

  QueryBuilder<IsarHealthRecord, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
