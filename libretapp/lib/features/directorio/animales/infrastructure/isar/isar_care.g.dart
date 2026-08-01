// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_care.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarCareRuleCollection on Isar {
  IsarCollection<IsarCareRule> get isarCareRules => this.collection();
}

const IsarCareRuleSchema = CollectionSchema(
  name: r'IsarCareRule',
  id: -5191280601940880759,
  properties: {
    r'active': PropertySchema(
      id: 0,
      name: r'active',
      type: IsarType.bool,
    ),
    r'intervalDays': PropertySchema(
      id: 1,
      name: r'intervalDays',
      type: IsarType.long,
    ),
    r'leadTimeDays': PropertySchema(
      id: 2,
      name: r'leadTimeDays',
      type: IsarType.long,
    ),
    r'mandatory': PropertySchema(
      id: 3,
      name: r'mandatory',
      type: IsarType.bool,
    ),
    r'maxAgeMonths': PropertySchema(
      id: 4,
      name: r'maxAgeMonths',
      type: IsarType.long,
    ),
    r'maxIntervalDays': PropertySchema(
      id: 5,
      name: r'maxIntervalDays',
      type: IsarType.long,
    ),
    r'minAgeMonths': PropertySchema(
      id: 6,
      name: r'minAgeMonths',
      type: IsarType.long,
    ),
    r'minIntervalDays': PropertySchema(
      id: 7,
      name: r'minIntervalDays',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 8,
      name: r'name',
      type: IsarType.string,
    ),
    r'recordUuid': PropertySchema(
      id: 9,
      name: r'recordUuid',
      type: IsarType.string,
    ),
    r'sex': PropertySchema(
      id: 10,
      name: r'sex',
      type: IsarType.string,
    ),
    r'species': PropertySchema(
      id: 11,
      name: r'species',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 12,
      name: r'type',
      type: IsarType.string,
    )
  },
  estimateSize: _isarCareRuleEstimateSize,
  serialize: _isarCareRuleSerialize,
  deserialize: _isarCareRuleDeserialize,
  deserializeProp: _isarCareRuleDeserializeProp,
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
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarCareRuleGetId,
  getLinks: _isarCareRuleGetLinks,
  attach: _isarCareRuleAttach,
  version: '3.1.0+1',
);

int _isarCareRuleEstimateSize(
  IsarCareRule object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.recordUuid.length * 3;
  {
    final value = object.sex;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.species;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _isarCareRuleSerialize(
  IsarCareRule object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.active);
  writer.writeLong(offsets[1], object.intervalDays);
  writer.writeLong(offsets[2], object.leadTimeDays);
  writer.writeBool(offsets[3], object.mandatory);
  writer.writeLong(offsets[4], object.maxAgeMonths);
  writer.writeLong(offsets[5], object.maxIntervalDays);
  writer.writeLong(offsets[6], object.minAgeMonths);
  writer.writeLong(offsets[7], object.minIntervalDays);
  writer.writeString(offsets[8], object.name);
  writer.writeString(offsets[9], object.recordUuid);
  writer.writeString(offsets[10], object.sex);
  writer.writeString(offsets[11], object.species);
  writer.writeString(offsets[12], object.type);
}

IsarCareRule _isarCareRuleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarCareRule();
  object.active = reader.readBool(offsets[0]);
  object.id = id;
  object.intervalDays = reader.readLong(offsets[1]);
  object.leadTimeDays = reader.readLongOrNull(offsets[2]);
  object.mandatory = reader.readBool(offsets[3]);
  object.maxAgeMonths = reader.readLongOrNull(offsets[4]);
  object.maxIntervalDays = reader.readLongOrNull(offsets[5]);
  object.minAgeMonths = reader.readLongOrNull(offsets[6]);
  object.minIntervalDays = reader.readLongOrNull(offsets[7]);
  object.name = reader.readString(offsets[8]);
  object.recordUuid = reader.readString(offsets[9]);
  object.sex = reader.readStringOrNull(offsets[10]);
  object.species = reader.readStringOrNull(offsets[11]);
  object.type = reader.readString(offsets[12]);
  return object;
}

P _isarCareRuleDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarCareRuleGetId(IsarCareRule object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarCareRuleGetLinks(IsarCareRule object) {
  return [];
}

void _isarCareRuleAttach(
    IsarCollection<dynamic> col, Id id, IsarCareRule object) {
  object.id = id;
}

extension IsarCareRuleByIndex on IsarCollection<IsarCareRule> {
  Future<IsarCareRule?> getByRecordUuid(String recordUuid) {
    return getByIndex(r'recordUuid', [recordUuid]);
  }

  IsarCareRule? getByRecordUuidSync(String recordUuid) {
    return getByIndexSync(r'recordUuid', [recordUuid]);
  }

  Future<bool> deleteByRecordUuid(String recordUuid) {
    return deleteByIndex(r'recordUuid', [recordUuid]);
  }

  bool deleteByRecordUuidSync(String recordUuid) {
    return deleteByIndexSync(r'recordUuid', [recordUuid]);
  }

  Future<List<IsarCareRule?>> getAllByRecordUuid(
      List<String> recordUuidValues) {
    final values = recordUuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'recordUuid', values);
  }

  List<IsarCareRule?> getAllByRecordUuidSync(List<String> recordUuidValues) {
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

  Future<Id> putByRecordUuid(IsarCareRule object) {
    return putByIndex(r'recordUuid', object);
  }

  Id putByRecordUuidSync(IsarCareRule object, {bool saveLinks = true}) {
    return putByIndexSync(r'recordUuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRecordUuid(List<IsarCareRule> objects) {
    return putAllByIndex(r'recordUuid', objects);
  }

  List<Id> putAllByRecordUuidSync(List<IsarCareRule> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'recordUuid', objects, saveLinks: saveLinks);
  }
}

extension IsarCareRuleQueryWhereSort
    on QueryBuilder<IsarCareRule, IsarCareRule, QWhere> {
  QueryBuilder<IsarCareRule, IsarCareRule, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarCareRuleQueryWhere
    on QueryBuilder<IsarCareRule, IsarCareRule, QWhereClause> {
  QueryBuilder<IsarCareRule, IsarCareRule, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterWhereClause> idBetween(
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

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterWhereClause> recordUuidEqualTo(
      String recordUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'recordUuid',
        value: [recordUuid],
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterWhereClause>
      recordUuidNotEqualTo(String recordUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordUuid',
              lower: [],
              upper: [recordUuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordUuid',
              lower: [recordUuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordUuid',
              lower: [recordUuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordUuid',
              lower: [],
              upper: [recordUuid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarCareRuleQueryFilter
    on QueryBuilder<IsarCareRule, IsarCareRule, QFilterCondition> {
  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> activeEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'active',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> idBetween(
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

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      intervalDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'intervalDays',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      intervalDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'intervalDays',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      intervalDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'intervalDays',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      intervalDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'intervalDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      leadTimeDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'leadTimeDays',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      leadTimeDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'leadTimeDays',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      leadTimeDaysEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'leadTimeDays',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      leadTimeDaysGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'leadTimeDays',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      leadTimeDaysLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'leadTimeDays',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      leadTimeDaysBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'leadTimeDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      mandatoryEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mandatory',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      maxAgeMonthsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'maxAgeMonths',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      maxAgeMonthsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'maxAgeMonths',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      maxAgeMonthsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxAgeMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      maxAgeMonthsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxAgeMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      maxAgeMonthsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxAgeMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      maxAgeMonthsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxAgeMonths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      maxIntervalDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'maxIntervalDays',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      maxIntervalDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'maxIntervalDays',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      maxIntervalDaysEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxIntervalDays',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      maxIntervalDaysGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxIntervalDays',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      maxIntervalDaysLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxIntervalDays',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      maxIntervalDaysBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxIntervalDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      minAgeMonthsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'minAgeMonths',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      minAgeMonthsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'minAgeMonths',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      minAgeMonthsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minAgeMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      minAgeMonthsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minAgeMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      minAgeMonthsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minAgeMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      minAgeMonthsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minAgeMonths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      minIntervalDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'minIntervalDays',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      minIntervalDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'minIntervalDays',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      minIntervalDaysEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minIntervalDays',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      minIntervalDaysGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minIntervalDays',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      minIntervalDaysLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minIntervalDays',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      minIntervalDaysBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minIntervalDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      recordUuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      recordUuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recordUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      recordUuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recordUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      recordUuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recordUuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      recordUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recordUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      recordUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recordUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      recordUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recordUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      recordUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recordUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      recordUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      recordUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recordUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> sexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sex',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      sexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sex',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> sexEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      sexGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> sexLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> sexBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> sexStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> sexEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> sexContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> sexMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sex',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> sexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sex',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      sexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sex',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      speciesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'species',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      speciesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'species',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      speciesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'species',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      speciesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'species',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      speciesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'species',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      speciesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'species',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      speciesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'species',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      speciesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'species',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      speciesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'species',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      speciesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'species',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      speciesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'species',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      speciesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'species',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> typeEqualTo(
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

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> typeLessThan(
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

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> typeBetween(
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

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> typeEndsWith(
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

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> typeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition> typeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension IsarCareRuleQueryObject
    on QueryBuilder<IsarCareRule, IsarCareRule, QFilterCondition> {}

extension IsarCareRuleQueryLinks
    on QueryBuilder<IsarCareRule, IsarCareRule, QFilterCondition> {}

extension IsarCareRuleQuerySortBy
    on QueryBuilder<IsarCareRule, IsarCareRule, QSortBy> {
  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> sortByActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> sortByActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> sortByIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalDays', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy>
      sortByIntervalDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalDays', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> sortByLeadTimeDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadTimeDays', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy>
      sortByLeadTimeDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadTimeDays', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> sortByMandatory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mandatory', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> sortByMandatoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mandatory', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> sortByMaxAgeMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAgeMonths', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy>
      sortByMaxAgeMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAgeMonths', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy>
      sortByMaxIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxIntervalDays', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy>
      sortByMaxIntervalDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxIntervalDays', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> sortByMinAgeMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAgeMonths', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy>
      sortByMinAgeMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAgeMonths', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy>
      sortByMinIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minIntervalDays', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy>
      sortByMinIntervalDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minIntervalDays', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> sortByRecordUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy>
      sortByRecordUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> sortBySex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sex', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> sortBySexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sex', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> sortBySpecies() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'species', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> sortBySpeciesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'species', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension IsarCareRuleQuerySortThenBy
    on QueryBuilder<IsarCareRule, IsarCareRule, QSortThenBy> {
  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenByActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenByActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenByIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalDays', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy>
      thenByIntervalDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalDays', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenByLeadTimeDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadTimeDays', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy>
      thenByLeadTimeDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leadTimeDays', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenByMandatory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mandatory', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenByMandatoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mandatory', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenByMaxAgeMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAgeMonths', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy>
      thenByMaxAgeMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAgeMonths', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy>
      thenByMaxIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxIntervalDays', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy>
      thenByMaxIntervalDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxIntervalDays', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenByMinAgeMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAgeMonths', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy>
      thenByMinAgeMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAgeMonths', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy>
      thenByMinIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minIntervalDays', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy>
      thenByMinIntervalDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minIntervalDays', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenByRecordUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy>
      thenByRecordUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenBySex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sex', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenBySexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sex', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenBySpecies() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'species', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenBySpeciesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'species', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension IsarCareRuleQueryWhereDistinct
    on QueryBuilder<IsarCareRule, IsarCareRule, QDistinct> {
  QueryBuilder<IsarCareRule, IsarCareRule, QDistinct> distinctByActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'active');
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QDistinct> distinctByIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'intervalDays');
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QDistinct> distinctByLeadTimeDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'leadTimeDays');
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QDistinct> distinctByMandatory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mandatory');
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QDistinct> distinctByMaxAgeMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxAgeMonths');
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QDistinct>
      distinctByMaxIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxIntervalDays');
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QDistinct> distinctByMinAgeMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minAgeMonths');
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QDistinct>
      distinctByMinIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minIntervalDays');
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QDistinct> distinctByRecordUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QDistinct> distinctBySex(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sex', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QDistinct> distinctBySpecies(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'species', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCareRule, IsarCareRule, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension IsarCareRuleQueryProperty
    on QueryBuilder<IsarCareRule, IsarCareRule, QQueryProperty> {
  QueryBuilder<IsarCareRule, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarCareRule, bool, QQueryOperations> activeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'active');
    });
  }

  QueryBuilder<IsarCareRule, int, QQueryOperations> intervalDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'intervalDays');
    });
  }

  QueryBuilder<IsarCareRule, int?, QQueryOperations> leadTimeDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'leadTimeDays');
    });
  }

  QueryBuilder<IsarCareRule, bool, QQueryOperations> mandatoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mandatory');
    });
  }

  QueryBuilder<IsarCareRule, int?, QQueryOperations> maxAgeMonthsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxAgeMonths');
    });
  }

  QueryBuilder<IsarCareRule, int?, QQueryOperations> maxIntervalDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxIntervalDays');
    });
  }

  QueryBuilder<IsarCareRule, int?, QQueryOperations> minAgeMonthsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minAgeMonths');
    });
  }

  QueryBuilder<IsarCareRule, int?, QQueryOperations> minIntervalDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minIntervalDays');
    });
  }

  QueryBuilder<IsarCareRule, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<IsarCareRule, String, QQueryOperations> recordUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordUuid');
    });
  }

  QueryBuilder<IsarCareRule, String?, QQueryOperations> sexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sex');
    });
  }

  QueryBuilder<IsarCareRule, String?, QQueryOperations> speciesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'species');
    });
  }

  QueryBuilder<IsarCareRule, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarCareRecordCollection on Isar {
  IsarCollection<IsarCareRecord> get isarCareRecords => this.collection();
}

const IsarCareRecordSchema = CollectionSchema(
  name: r'IsarCareRecord',
  id: 7988098618886837787,
  properties: {
    r'animalUuid': PropertySchema(
      id: 0,
      name: r'animalUuid',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 1,
      name: r'notes',
      type: IsarType.string,
    ),
    r'performedAt': PropertySchema(
      id: 2,
      name: r'performedAt',
      type: IsarType.dateTime,
    ),
    r'performedBy': PropertySchema(
      id: 3,
      name: r'performedBy',
      type: IsarType.string,
    ),
    r'recordUuid': PropertySchema(
      id: 4,
      name: r'recordUuid',
      type: IsarType.string,
    ),
    r'ruleId': PropertySchema(
      id: 5,
      name: r'ruleId',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 6,
      name: r'type',
      type: IsarType.string,
    )
  },
  estimateSize: _isarCareRecordEstimateSize,
  serialize: _isarCareRecordSerialize,
  deserialize: _isarCareRecordDeserialize,
  deserializeProp: _isarCareRecordDeserializeProp,
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
        )
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
        )
      ],
    ),
    r'ruleId': IndexSchema(
      id: -7287016718321404572,
      name: r'ruleId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ruleId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarCareRecordGetId,
  getLinks: _isarCareRecordGetLinks,
  attach: _isarCareRecordAttach,
  version: '3.1.0+1',
);

int _isarCareRecordEstimateSize(
  IsarCareRecord object,
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
  bytesCount += 3 + object.recordUuid.length * 3;
  bytesCount += 3 + object.ruleId.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _isarCareRecordSerialize(
  IsarCareRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.animalUuid);
  writer.writeString(offsets[1], object.notes);
  writer.writeDateTime(offsets[2], object.performedAt);
  writer.writeString(offsets[3], object.performedBy);
  writer.writeString(offsets[4], object.recordUuid);
  writer.writeString(offsets[5], object.ruleId);
  writer.writeString(offsets[6], object.type);
}

IsarCareRecord _isarCareRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarCareRecord();
  object.animalUuid = reader.readString(offsets[0]);
  object.id = id;
  object.notes = reader.readStringOrNull(offsets[1]);
  object.performedAt = reader.readDateTime(offsets[2]);
  object.performedBy = reader.readStringOrNull(offsets[3]);
  object.recordUuid = reader.readString(offsets[4]);
  object.ruleId = reader.readString(offsets[5]);
  object.type = reader.readString(offsets[6]);
  return object;
}

P _isarCareRecordDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarCareRecordGetId(IsarCareRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarCareRecordGetLinks(IsarCareRecord object) {
  return [];
}

void _isarCareRecordAttach(
    IsarCollection<dynamic> col, Id id, IsarCareRecord object) {
  object.id = id;
}

extension IsarCareRecordByIndex on IsarCollection<IsarCareRecord> {
  Future<IsarCareRecord?> getByRecordUuid(String recordUuid) {
    return getByIndex(r'recordUuid', [recordUuid]);
  }

  IsarCareRecord? getByRecordUuidSync(String recordUuid) {
    return getByIndexSync(r'recordUuid', [recordUuid]);
  }

  Future<bool> deleteByRecordUuid(String recordUuid) {
    return deleteByIndex(r'recordUuid', [recordUuid]);
  }

  bool deleteByRecordUuidSync(String recordUuid) {
    return deleteByIndexSync(r'recordUuid', [recordUuid]);
  }

  Future<List<IsarCareRecord?>> getAllByRecordUuid(
      List<String> recordUuidValues) {
    final values = recordUuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'recordUuid', values);
  }

  List<IsarCareRecord?> getAllByRecordUuidSync(List<String> recordUuidValues) {
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

  Future<Id> putByRecordUuid(IsarCareRecord object) {
    return putByIndex(r'recordUuid', object);
  }

  Id putByRecordUuidSync(IsarCareRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'recordUuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRecordUuid(List<IsarCareRecord> objects) {
    return putAllByIndex(r'recordUuid', objects);
  }

  List<Id> putAllByRecordUuidSync(List<IsarCareRecord> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'recordUuid', objects, saveLinks: saveLinks);
  }
}

extension IsarCareRecordQueryWhereSort
    on QueryBuilder<IsarCareRecord, IsarCareRecord, QWhere> {
  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarCareRecordQueryWhere
    on QueryBuilder<IsarCareRecord, IsarCareRecord, QWhereClause> {
  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterWhereClause> idBetween(
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterWhereClause>
      recordUuidEqualTo(String recordUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'recordUuid',
        value: [recordUuid],
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterWhereClause>
      recordUuidNotEqualTo(String recordUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordUuid',
              lower: [],
              upper: [recordUuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordUuid',
              lower: [recordUuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordUuid',
              lower: [recordUuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordUuid',
              lower: [],
              upper: [recordUuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterWhereClause>
      animalUuidEqualTo(String animalUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'animalUuid',
        value: [animalUuid],
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterWhereClause>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterWhereClause> ruleIdEqualTo(
      String ruleId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ruleId',
        value: [ruleId],
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterWhereClause>
      ruleIdNotEqualTo(String ruleId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ruleId',
              lower: [],
              upper: [ruleId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ruleId',
              lower: [ruleId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ruleId',
              lower: [ruleId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ruleId',
              lower: [],
              upper: [ruleId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarCareRecordQueryFilter
    on QueryBuilder<IsarCareRecord, IsarCareRecord, QFilterCondition> {
  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      animalUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'animalUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      animalUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'animalUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      animalUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animalUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      animalUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'animalUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition> idBetween(
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      performedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'performedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      performedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'performedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      performedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'performedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      performedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'performedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      performedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'performedBy',
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      performedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'performedBy',
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      performedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'performedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      performedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'performedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      performedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'performedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      performedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'performedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      performedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'performedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      performedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'performedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      performedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'performedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      performedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'performedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      performedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'performedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      performedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'performedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      recordUuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      recordUuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recordUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      recordUuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recordUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      recordUuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recordUuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      recordUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recordUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      recordUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recordUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      recordUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recordUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      recordUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recordUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      recordUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      recordUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recordUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      ruleIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ruleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      ruleIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ruleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      ruleIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ruleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      ruleIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ruleId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      ruleIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ruleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      ruleIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ruleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      ruleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ruleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      ruleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ruleId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      ruleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ruleId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      ruleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ruleId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension IsarCareRecordQueryObject
    on QueryBuilder<IsarCareRecord, IsarCareRecord, QFilterCondition> {}

extension IsarCareRecordQueryLinks
    on QueryBuilder<IsarCareRecord, IsarCareRecord, QFilterCondition> {}

extension IsarCareRecordQuerySortBy
    on QueryBuilder<IsarCareRecord, IsarCareRecord, QSortBy> {
  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy>
      sortByAnimalUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy>
      sortByAnimalUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy>
      sortByPerformedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy>
      sortByPerformedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy>
      sortByPerformedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedBy', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy>
      sortByPerformedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedBy', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy>
      sortByRecordUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy>
      sortByRecordUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy> sortByRuleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruleId', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy>
      sortByRuleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruleId', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension IsarCareRecordQuerySortThenBy
    on QueryBuilder<IsarCareRecord, IsarCareRecord, QSortThenBy> {
  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy>
      thenByAnimalUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy>
      thenByAnimalUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy>
      thenByPerformedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy>
      thenByPerformedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy>
      thenByPerformedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedBy', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy>
      thenByPerformedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedBy', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy>
      thenByRecordUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy>
      thenByRecordUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy> thenByRuleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruleId', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy>
      thenByRuleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruleId', Sort.desc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension IsarCareRecordQueryWhereDistinct
    on QueryBuilder<IsarCareRecord, IsarCareRecord, QDistinct> {
  QueryBuilder<IsarCareRecord, IsarCareRecord, QDistinct> distinctByAnimalUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animalUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QDistinct>
      distinctByPerformedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'performedAt');
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QDistinct> distinctByPerformedBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'performedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QDistinct> distinctByRecordUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QDistinct> distinctByRuleId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ruleId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCareRecord, IsarCareRecord, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension IsarCareRecordQueryProperty
    on QueryBuilder<IsarCareRecord, IsarCareRecord, QQueryProperty> {
  QueryBuilder<IsarCareRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarCareRecord, String, QQueryOperations> animalUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animalUuid');
    });
  }

  QueryBuilder<IsarCareRecord, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<IsarCareRecord, DateTime, QQueryOperations>
      performedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'performedAt');
    });
  }

  QueryBuilder<IsarCareRecord, String?, QQueryOperations>
      performedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'performedBy');
    });
  }

  QueryBuilder<IsarCareRecord, String, QQueryOperations> recordUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordUuid');
    });
  }

  QueryBuilder<IsarCareRecord, String, QQueryOperations> ruleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ruleId');
    });
  }

  QueryBuilder<IsarCareRecord, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarScheduledCareCollection on Isar {
  IsarCollection<IsarScheduledCare> get isarScheduledCares => this.collection();
}

const IsarScheduledCareSchema = CollectionSchema(
  name: r'IsarScheduledCare',
  id: 8695655185769752968,
  properties: {
    r'animalUuid': PropertySchema(
      id: 0,
      name: r'animalUuid',
      type: IsarType.string,
    ),
    r'autoGenerated': PropertySchema(
      id: 1,
      name: r'autoGenerated',
      type: IsarType.bool,
    ),
    r'done': PropertySchema(
      id: 2,
      name: r'done',
      type: IsarType.bool,
    ),
    r'dueAt': PropertySchema(
      id: 3,
      name: r'dueAt',
      type: IsarType.dateTime,
    ),
    r'recordUuid': PropertySchema(
      id: 4,
      name: r'recordUuid',
      type: IsarType.string,
    ),
    r'remindAt': PropertySchema(
      id: 5,
      name: r'remindAt',
      type: IsarType.dateTime,
    ),
    r'ruleId': PropertySchema(
      id: 6,
      name: r'ruleId',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 7,
      name: r'type',
      type: IsarType.string,
    )
  },
  estimateSize: _isarScheduledCareEstimateSize,
  serialize: _isarScheduledCareSerialize,
  deserialize: _isarScheduledCareDeserialize,
  deserializeProp: _isarScheduledCareDeserializeProp,
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
        )
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
        )
      ],
    ),
    r'dueAt': IndexSchema(
      id: 3701044435752459706,
      name: r'dueAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dueAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarScheduledCareGetId,
  getLinks: _isarScheduledCareGetLinks,
  attach: _isarScheduledCareAttach,
  version: '3.1.0+1',
);

int _isarScheduledCareEstimateSize(
  IsarScheduledCare object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.animalUuid.length * 3;
  bytesCount += 3 + object.recordUuid.length * 3;
  bytesCount += 3 + object.ruleId.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _isarScheduledCareSerialize(
  IsarScheduledCare object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.animalUuid);
  writer.writeBool(offsets[1], object.autoGenerated);
  writer.writeBool(offsets[2], object.done);
  writer.writeDateTime(offsets[3], object.dueAt);
  writer.writeString(offsets[4], object.recordUuid);
  writer.writeDateTime(offsets[5], object.remindAt);
  writer.writeString(offsets[6], object.ruleId);
  writer.writeString(offsets[7], object.type);
}

IsarScheduledCare _isarScheduledCareDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarScheduledCare();
  object.animalUuid = reader.readString(offsets[0]);
  object.autoGenerated = reader.readBool(offsets[1]);
  object.done = reader.readBool(offsets[2]);
  object.dueAt = reader.readDateTime(offsets[3]);
  object.id = id;
  object.recordUuid = reader.readString(offsets[4]);
  object.remindAt = reader.readDateTimeOrNull(offsets[5]);
  object.ruleId = reader.readString(offsets[6]);
  object.type = reader.readString(offsets[7]);
  return object;
}

P _isarScheduledCareDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarScheduledCareGetId(IsarScheduledCare object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarScheduledCareGetLinks(
    IsarScheduledCare object) {
  return [];
}

void _isarScheduledCareAttach(
    IsarCollection<dynamic> col, Id id, IsarScheduledCare object) {
  object.id = id;
}

extension IsarScheduledCareByIndex on IsarCollection<IsarScheduledCare> {
  Future<IsarScheduledCare?> getByRecordUuid(String recordUuid) {
    return getByIndex(r'recordUuid', [recordUuid]);
  }

  IsarScheduledCare? getByRecordUuidSync(String recordUuid) {
    return getByIndexSync(r'recordUuid', [recordUuid]);
  }

  Future<bool> deleteByRecordUuid(String recordUuid) {
    return deleteByIndex(r'recordUuid', [recordUuid]);
  }

  bool deleteByRecordUuidSync(String recordUuid) {
    return deleteByIndexSync(r'recordUuid', [recordUuid]);
  }

  Future<List<IsarScheduledCare?>> getAllByRecordUuid(
      List<String> recordUuidValues) {
    final values = recordUuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'recordUuid', values);
  }

  List<IsarScheduledCare?> getAllByRecordUuidSync(
      List<String> recordUuidValues) {
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

  Future<Id> putByRecordUuid(IsarScheduledCare object) {
    return putByIndex(r'recordUuid', object);
  }

  Id putByRecordUuidSync(IsarScheduledCare object, {bool saveLinks = true}) {
    return putByIndexSync(r'recordUuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRecordUuid(List<IsarScheduledCare> objects) {
    return putAllByIndex(r'recordUuid', objects);
  }

  List<Id> putAllByRecordUuidSync(List<IsarScheduledCare> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'recordUuid', objects, saveLinks: saveLinks);
  }
}

extension IsarScheduledCareQueryWhereSort
    on QueryBuilder<IsarScheduledCare, IsarScheduledCare, QWhere> {
  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterWhere> anyDueAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dueAt'),
      );
    });
  }
}

extension IsarScheduledCareQueryWhere
    on QueryBuilder<IsarScheduledCare, IsarScheduledCare, QWhereClause> {
  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterWhereClause>
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

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterWhereClause>
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

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterWhereClause>
      recordUuidEqualTo(String recordUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'recordUuid',
        value: [recordUuid],
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterWhereClause>
      recordUuidNotEqualTo(String recordUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordUuid',
              lower: [],
              upper: [recordUuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordUuid',
              lower: [recordUuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordUuid',
              lower: [recordUuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordUuid',
              lower: [],
              upper: [recordUuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterWhereClause>
      animalUuidEqualTo(String animalUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'animalUuid',
        value: [animalUuid],
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterWhereClause>
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

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterWhereClause>
      dueAtEqualTo(DateTime dueAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dueAt',
        value: [dueAt],
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterWhereClause>
      dueAtNotEqualTo(DateTime dueAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dueAt',
              lower: [],
              upper: [dueAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dueAt',
              lower: [dueAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dueAt',
              lower: [dueAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dueAt',
              lower: [],
              upper: [dueAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterWhereClause>
      dueAtGreaterThan(
    DateTime dueAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dueAt',
        lower: [dueAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterWhereClause>
      dueAtLessThan(
    DateTime dueAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dueAt',
        lower: [],
        upper: [dueAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterWhereClause>
      dueAtBetween(
    DateTime lowerDueAt,
    DateTime upperDueAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dueAt',
        lower: [lowerDueAt],
        includeLower: includeLower,
        upper: [upperDueAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarScheduledCareQueryFilter
    on QueryBuilder<IsarScheduledCare, IsarScheduledCare, QFilterCondition> {
  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
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

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
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

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
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

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
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

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
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

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
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

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      animalUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'animalUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      animalUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'animalUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      animalUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animalUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      animalUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'animalUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      autoGeneratedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoGenerated',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      doneEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'done',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      dueAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dueAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      dueAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dueAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      dueAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dueAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      dueAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dueAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
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

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
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

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
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

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      recordUuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      recordUuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recordUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      recordUuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recordUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      recordUuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recordUuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      recordUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recordUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      recordUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recordUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      recordUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recordUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      recordUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recordUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      recordUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      recordUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recordUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      remindAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'remindAt',
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      remindAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'remindAt',
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      remindAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remindAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      remindAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remindAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      remindAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remindAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      remindAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remindAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      ruleIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ruleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      ruleIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ruleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      ruleIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ruleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      ruleIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ruleId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      ruleIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ruleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      ruleIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ruleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      ruleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ruleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      ruleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ruleId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      ruleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ruleId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      ruleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ruleId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
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

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
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

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
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

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
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

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
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

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
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

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension IsarScheduledCareQueryObject
    on QueryBuilder<IsarScheduledCare, IsarScheduledCare, QFilterCondition> {}

extension IsarScheduledCareQueryLinks
    on QueryBuilder<IsarScheduledCare, IsarScheduledCare, QFilterCondition> {}

extension IsarScheduledCareQuerySortBy
    on QueryBuilder<IsarScheduledCare, IsarScheduledCare, QSortBy> {
  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      sortByAnimalUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      sortByAnimalUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      sortByAutoGenerated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoGenerated', Sort.asc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      sortByAutoGeneratedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoGenerated', Sort.desc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      sortByDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'done', Sort.asc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      sortByDoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'done', Sort.desc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      sortByDueAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAt', Sort.asc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      sortByDueAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAt', Sort.desc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      sortByRecordUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      sortByRecordUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      sortByRemindAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remindAt', Sort.asc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      sortByRemindAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remindAt', Sort.desc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      sortByRuleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruleId', Sort.asc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      sortByRuleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruleId', Sort.desc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension IsarScheduledCareQuerySortThenBy
    on QueryBuilder<IsarScheduledCare, IsarScheduledCare, QSortThenBy> {
  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      thenByAnimalUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      thenByAnimalUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      thenByAutoGenerated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoGenerated', Sort.asc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      thenByAutoGeneratedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoGenerated', Sort.desc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      thenByDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'done', Sort.asc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      thenByDoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'done', Sort.desc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      thenByDueAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAt', Sort.asc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      thenByDueAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAt', Sort.desc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      thenByRecordUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      thenByRecordUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      thenByRemindAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remindAt', Sort.asc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      thenByRemindAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remindAt', Sort.desc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      thenByRuleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruleId', Sort.asc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      thenByRuleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruleId', Sort.desc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension IsarScheduledCareQueryWhereDistinct
    on QueryBuilder<IsarScheduledCare, IsarScheduledCare, QDistinct> {
  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QDistinct>
      distinctByAnimalUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animalUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QDistinct>
      distinctByAutoGenerated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoGenerated');
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QDistinct>
      distinctByDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'done');
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QDistinct>
      distinctByDueAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueAt');
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QDistinct>
      distinctByRecordUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QDistinct>
      distinctByRemindAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remindAt');
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QDistinct>
      distinctByRuleId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ruleId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarScheduledCare, IsarScheduledCare, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension IsarScheduledCareQueryProperty
    on QueryBuilder<IsarScheduledCare, IsarScheduledCare, QQueryProperty> {
  QueryBuilder<IsarScheduledCare, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarScheduledCare, String, QQueryOperations>
      animalUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animalUuid');
    });
  }

  QueryBuilder<IsarScheduledCare, bool, QQueryOperations>
      autoGeneratedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoGenerated');
    });
  }

  QueryBuilder<IsarScheduledCare, bool, QQueryOperations> doneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'done');
    });
  }

  QueryBuilder<IsarScheduledCare, DateTime, QQueryOperations> dueAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueAt');
    });
  }

  QueryBuilder<IsarScheduledCare, String, QQueryOperations>
      recordUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordUuid');
    });
  }

  QueryBuilder<IsarScheduledCare, DateTime?, QQueryOperations>
      remindAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remindAt');
    });
  }

  QueryBuilder<IsarScheduledCare, String, QQueryOperations> ruleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ruleId');
    });
  }

  QueryBuilder<IsarScheduledCare, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
