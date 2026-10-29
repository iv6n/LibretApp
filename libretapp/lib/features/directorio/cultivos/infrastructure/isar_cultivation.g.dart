// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_cultivation.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarCultivationCollection on Isar {
  IsarCollection<IsarCultivation> get isarCultivations => this.collection();
}

const IsarCultivationSchema = CollectionSchema(
  name: r'IsarCultivation',
  id: -174142495585871876,
  properties: {
    r'areaSquareMeters': PropertySchema(
      id: 0,
      name: r'areaSquareMeters',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'expectedHarvestDate': PropertySchema(
      id: 2,
      name: r'expectedHarvestDate',
      type: IsarType.dateTime,
    ),
    r'growthStage': PropertySchema(
      id: 3,
      name: r'growthStage',
      type: IsarType.string,
    ),
    r'harvests': PropertySchema(
      id: 4,
      name: r'harvests',
      type: IsarType.objectList,

      target: r'IsarHarvestRecord',
    ),
    r'healthRecords': PropertySchema(
      id: 5,
      name: r'healthRecords',
      type: IsarType.objectList,

      target: r'IsarCropHealthRecord',
    ),
    r'lastWateredDate': PropertySchema(
      id: 6,
      name: r'lastWateredDate',
      type: IsarType.dateTime,
    ),
    r'locationUuid': PropertySchema(
      id: 7,
      name: r'locationUuid',
      type: IsarType.string,
    ),
    r'name': PropertySchema(id: 8, name: r'name', type: IsarType.string),
    r'notes': PropertySchema(id: 9, name: r'notes', type: IsarType.string),
    r'plantingDate': PropertySchema(
      id: 10,
      name: r'plantingDate',
      type: IsarType.dateTime,
    ),
    r'preferredAreaUnit': PropertySchema(
      id: 11,
      name: r'preferredAreaUnit',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(id: 12, name: r'quantity', type: IsarType.long),
    r'scale': PropertySchema(id: 13, name: r'scale', type: IsarType.string),
    r'status': PropertySchema(id: 14, name: r'status', type: IsarType.string),
    r'tasks': PropertySchema(
      id: 15,
      name: r'tasks',
      type: IsarType.objectList,

      target: r'IsarCropTask',
    ),
    r'updatedAt': PropertySchema(
      id: 16,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(id: 17, name: r'uuid', type: IsarType.string),
    r'variety': PropertySchema(id: 18, name: r'variety', type: IsarType.string),
    r'wateringFrequencyDays': PropertySchema(
      id: 19,
      name: r'wateringFrequencyDays',
      type: IsarType.long,
    ),
    r'waterings': PropertySchema(
      id: 20,
      name: r'waterings',
      type: IsarType.objectList,

      target: r'IsarCropWateringRecord',
    ),
  },

  estimateSize: _isarCultivationEstimateSize,
  serialize: _isarCultivationSerialize,
  deserialize: _isarCultivationDeserialize,
  deserializeProp: _isarCultivationDeserializeProp,
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
        ),
      ],
    ),
    r'locationUuid': IndexSchema(
      id: 2798644635071884079,
      name: r'locationUuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'locationUuid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
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
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {
    r'IsarHarvestRecord': IsarHarvestRecordSchema,
    r'IsarCropWateringRecord': IsarCropWateringRecordSchema,
    r'IsarCropHealthRecord': IsarCropHealthRecordSchema,
    r'IsarCropTask': IsarCropTaskSchema,
  },

  getId: _isarCultivationGetId,
  getLinks: _isarCultivationGetLinks,
  attach: _isarCultivationAttach,
  version: '3.3.2',
);

int _isarCultivationEstimateSize(
  IsarCultivation object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.growthStage.length * 3;
  bytesCount += 3 + object.harvests.length * 3;
  {
    final offsets = allOffsets[IsarHarvestRecord]!;
    for (var i = 0; i < object.harvests.length; i++) {
      final value = object.harvests[i];
      bytesCount += IsarHarvestRecordSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.healthRecords.length * 3;
  {
    final offsets = allOffsets[IsarCropHealthRecord]!;
    for (var i = 0; i < object.healthRecords.length; i++) {
      final value = object.healthRecords[i];
      bytesCount += IsarCropHealthRecordSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  {
    final value = object.locationUuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.preferredAreaUnit.length * 3;
  bytesCount += 3 + object.scale.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.tasks.length * 3;
  {
    final offsets = allOffsets[IsarCropTask]!;
    for (var i = 0; i < object.tasks.length; i++) {
      final value = object.tasks[i];
      bytesCount += IsarCropTaskSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.uuid.length * 3;
  bytesCount += 3 + object.variety.length * 3;
  bytesCount += 3 + object.waterings.length * 3;
  {
    final offsets = allOffsets[IsarCropWateringRecord]!;
    for (var i = 0; i < object.waterings.length; i++) {
      final value = object.waterings[i];
      bytesCount += IsarCropWateringRecordSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  return bytesCount;
}

void _isarCultivationSerialize(
  IsarCultivation object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.areaSquareMeters);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeDateTime(offsets[2], object.expectedHarvestDate);
  writer.writeString(offsets[3], object.growthStage);
  writer.writeObjectList<IsarHarvestRecord>(
    offsets[4],
    allOffsets,
    IsarHarvestRecordSchema.serialize,
    object.harvests,
  );
  writer.writeObjectList<IsarCropHealthRecord>(
    offsets[5],
    allOffsets,
    IsarCropHealthRecordSchema.serialize,
    object.healthRecords,
  );
  writer.writeDateTime(offsets[6], object.lastWateredDate);
  writer.writeString(offsets[7], object.locationUuid);
  writer.writeString(offsets[8], object.name);
  writer.writeString(offsets[9], object.notes);
  writer.writeDateTime(offsets[10], object.plantingDate);
  writer.writeString(offsets[11], object.preferredAreaUnit);
  writer.writeLong(offsets[12], object.quantity);
  writer.writeString(offsets[13], object.scale);
  writer.writeString(offsets[14], object.status);
  writer.writeObjectList<IsarCropTask>(
    offsets[15],
    allOffsets,
    IsarCropTaskSchema.serialize,
    object.tasks,
  );
  writer.writeDateTime(offsets[16], object.updatedAt);
  writer.writeString(offsets[17], object.uuid);
  writer.writeString(offsets[18], object.variety);
  writer.writeLong(offsets[19], object.wateringFrequencyDays);
  writer.writeObjectList<IsarCropWateringRecord>(
    offsets[20],
    allOffsets,
    IsarCropWateringRecordSchema.serialize,
    object.waterings,
  );
}

IsarCultivation _isarCultivationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarCultivation();
  object.areaSquareMeters = reader.readDouble(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.expectedHarvestDate = reader.readDateTimeOrNull(offsets[2]);
  object.growthStage = reader.readString(offsets[3]);
  object.harvests =
      reader.readObjectList<IsarHarvestRecord>(
        offsets[4],
        IsarHarvestRecordSchema.deserialize,
        allOffsets,
        IsarHarvestRecord(),
      ) ??
      [];
  object.healthRecords =
      reader.readObjectList<IsarCropHealthRecord>(
        offsets[5],
        IsarCropHealthRecordSchema.deserialize,
        allOffsets,
        IsarCropHealthRecord(),
      ) ??
      [];
  object.id = id;
  object.lastWateredDate = reader.readDateTimeOrNull(offsets[6]);
  object.locationUuid = reader.readStringOrNull(offsets[7]);
  object.name = reader.readString(offsets[8]);
  object.notes = reader.readStringOrNull(offsets[9]);
  object.plantingDate = reader.readDateTime(offsets[10]);
  object.preferredAreaUnit = reader.readString(offsets[11]);
  object.quantity = reader.readLong(offsets[12]);
  object.scale = reader.readString(offsets[13]);
  object.status = reader.readString(offsets[14]);
  object.tasks =
      reader.readObjectList<IsarCropTask>(
        offsets[15],
        IsarCropTaskSchema.deserialize,
        allOffsets,
        IsarCropTask(),
      ) ??
      [];
  object.updatedAt = reader.readDateTime(offsets[16]);
  object.uuid = reader.readString(offsets[17]);
  object.variety = reader.readString(offsets[18]);
  object.wateringFrequencyDays = reader.readLong(offsets[19]);
  object.waterings =
      reader.readObjectList<IsarCropWateringRecord>(
        offsets[20],
        IsarCropWateringRecordSchema.deserialize,
        allOffsets,
        IsarCropWateringRecord(),
      ) ??
      [];
  return object;
}

P _isarCultivationDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readObjectList<IsarHarvestRecord>(
                offset,
                IsarHarvestRecordSchema.deserialize,
                allOffsets,
                IsarHarvestRecord(),
              ) ??
              [])
          as P;
    case 5:
      return (reader.readObjectList<IsarCropHealthRecord>(
                offset,
                IsarCropHealthRecordSchema.deserialize,
                allOffsets,
                IsarCropHealthRecord(),
              ) ??
              [])
          as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readObjectList<IsarCropTask>(
                offset,
                IsarCropTaskSchema.deserialize,
                allOffsets,
                IsarCropTask(),
              ) ??
              [])
          as P;
    case 16:
      return (reader.readDateTime(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readLong(offset)) as P;
    case 20:
      return (reader.readObjectList<IsarCropWateringRecord>(
                offset,
                IsarCropWateringRecordSchema.deserialize,
                allOffsets,
                IsarCropWateringRecord(),
              ) ??
              [])
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarCultivationGetId(IsarCultivation object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarCultivationGetLinks(IsarCultivation object) {
  return [];
}

void _isarCultivationAttach(
  IsarCollection<dynamic> col,
  Id id,
  IsarCultivation object,
) {
  object.id = id;
}

extension IsarCultivationByIndex on IsarCollection<IsarCultivation> {
  Future<IsarCultivation?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  IsarCultivation? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<IsarCultivation?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<IsarCultivation?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(IsarCultivation object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(IsarCultivation object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<IsarCultivation> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(
    List<IsarCultivation> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension IsarCultivationQueryWhereSort
    on QueryBuilder<IsarCultivation, IsarCultivation, QWhere> {
  QueryBuilder<IsarCultivation, IsarCultivation, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarCultivationQueryWhere
    on QueryBuilder<IsarCultivation, IsarCultivation, QWhereClause> {
  QueryBuilder<IsarCultivation, IsarCultivation, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterWhereClause>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterWhereClause> idBetween(
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterWhereClause> uuidEqualTo(
    String uuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uuid', value: [uuid]),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterWhereClause>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterWhereClause>
  locationUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'locationUuid', value: [null]),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterWhereClause>
  locationUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'locationUuid',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterWhereClause>
  locationUuidEqualTo(String? locationUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'locationUuid',
          value: [locationUuid],
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterWhereClause>
  locationUuidNotEqualTo(String? locationUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'locationUuid',
                lower: [],
                upper: [locationUuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'locationUuid',
                lower: [locationUuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'locationUuid',
                lower: [locationUuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'locationUuid',
                lower: [],
                upper: [locationUuid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterWhereClause>
  statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'status', value: [status]),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterWhereClause>
  statusNotEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [],
                upper: [status],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [status],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [status],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [],
                upper: [status],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension IsarCultivationQueryFilter
    on QueryBuilder<IsarCultivation, IsarCultivation, QFilterCondition> {
  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  areaSquareMetersEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'areaSquareMeters',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  areaSquareMetersGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'areaSquareMeters',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  areaSquareMetersLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'areaSquareMeters',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  areaSquareMetersBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'areaSquareMeters',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  expectedHarvestDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'expectedHarvestDate'),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  expectedHarvestDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'expectedHarvestDate'),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  expectedHarvestDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'expectedHarvestDate', value: value),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  expectedHarvestDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'expectedHarvestDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  expectedHarvestDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'expectedHarvestDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  expectedHarvestDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'expectedHarvestDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  growthStageEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'growthStage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  growthStageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'growthStage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  growthStageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'growthStage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  growthStageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'growthStage',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  growthStageStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'growthStage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  growthStageEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'growthStage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  growthStageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'growthStage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  growthStageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'growthStage',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  growthStageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'growthStage', value: ''),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  growthStageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'growthStage', value: ''),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  harvestsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'harvests', length, true, length, true);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  harvestsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'harvests', 0, true, 0, true);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  harvestsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'harvests', 0, false, 999999, true);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  harvestsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'harvests', 0, true, length, include);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  harvestsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'harvests', length, include, 999999, true);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  harvestsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'harvests',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  healthRecordsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'healthRecords', length, true, length, true);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  healthRecordsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'healthRecords', 0, true, 0, true);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  healthRecordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'healthRecords', 0, false, 999999, true);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  healthRecordsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'healthRecords', 0, true, length, include);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  healthRecordsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'healthRecords', length, include, 999999, true);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  healthRecordsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'healthRecords',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  lastWateredDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastWateredDate'),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  lastWateredDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastWateredDate'),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  lastWateredDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastWateredDate', value: value),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  lastWateredDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastWateredDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  lastWateredDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastWateredDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  lastWateredDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastWateredDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  locationUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'locationUuid'),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  locationUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'locationUuid'),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  locationUuidEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'locationUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  locationUuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'locationUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  locationUuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'locationUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  locationUuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'locationUuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  locationUuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'locationUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  locationUuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'locationUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  locationUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'locationUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  locationUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'locationUuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  locationUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'locationUuid', value: ''),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  locationUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'locationUuid', value: ''),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  nameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  plantingDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'plantingDate', value: value),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  plantingDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'plantingDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  plantingDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'plantingDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  plantingDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'plantingDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  preferredAreaUnitEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'preferredAreaUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  preferredAreaUnitGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'preferredAreaUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  preferredAreaUnitLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'preferredAreaUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  preferredAreaUnitBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'preferredAreaUnit',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  preferredAreaUnitStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'preferredAreaUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  preferredAreaUnitEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'preferredAreaUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  preferredAreaUnitContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'preferredAreaUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  preferredAreaUnitMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'preferredAreaUnit',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  preferredAreaUnitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'preferredAreaUnit', value: ''),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  preferredAreaUnitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'preferredAreaUnit', value: ''),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quantity', value: value),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  quantityGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'quantity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  quantityLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'quantity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  quantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'quantity',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  scaleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'scale',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  scaleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'scale',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  scaleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'scale',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  scaleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'scale',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  scaleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'scale',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  scaleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'scale',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  scaleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'scale',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  scaleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'scale',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  scaleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'scale', value: ''),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  scaleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'scale', value: ''),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  statusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  statusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  tasksLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tasks', length, true, length, true);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  tasksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tasks', 0, true, 0, true);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  tasksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tasks', 0, false, 999999, true);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  tasksLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tasks', 0, true, length, include);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  tasksLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tasks', length, include, 999999, true);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  tasksLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tasks',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
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

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  varietyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'variety',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  varietyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'variety',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  varietyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'variety',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  varietyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'variety',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  varietyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'variety',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  varietyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'variety',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  varietyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'variety',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  varietyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'variety',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  varietyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'variety', value: ''),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  varietyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'variety', value: ''),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  wateringFrequencyDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'wateringFrequencyDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  wateringFrequencyDaysGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'wateringFrequencyDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  wateringFrequencyDaysLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'wateringFrequencyDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  wateringFrequencyDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'wateringFrequencyDays',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  wateringsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'waterings', length, true, length, true);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  wateringsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'waterings', 0, true, 0, true);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  wateringsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'waterings', 0, false, 999999, true);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  wateringsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'waterings', 0, true, length, include);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  wateringsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'waterings', length, include, 999999, true);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  wateringsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'waterings',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension IsarCultivationQueryObject
    on QueryBuilder<IsarCultivation, IsarCultivation, QFilterCondition> {
  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  harvestsElement(FilterQuery<IsarHarvestRecord> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'harvests');
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  healthRecordsElement(FilterQuery<IsarCropHealthRecord> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'healthRecords');
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  tasksElement(FilterQuery<IsarCropTask> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'tasks');
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterFilterCondition>
  wateringsElement(FilterQuery<IsarCropWateringRecord> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'waterings');
    });
  }
}

extension IsarCultivationQueryLinks
    on QueryBuilder<IsarCultivation, IsarCultivation, QFilterCondition> {}

extension IsarCultivationQuerySortBy
    on QueryBuilder<IsarCultivation, IsarCultivation, QSortBy> {
  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByAreaSquareMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaSquareMeters', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByAreaSquareMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaSquareMeters', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByExpectedHarvestDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedHarvestDate', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByExpectedHarvestDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedHarvestDate', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByGrowthStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'growthStage', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByGrowthStageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'growthStage', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByLastWateredDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWateredDate', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByLastWateredDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWateredDate', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByLocationUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByLocationUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByPlantingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plantingDate', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByPlantingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plantingDate', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByPreferredAreaUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredAreaUnit', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByPreferredAreaUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredAreaUnit', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy> sortByScale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scale', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByScaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scale', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy> sortByVariety() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variety', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByVarietyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variety', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByWateringFrequencyDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wateringFrequencyDays', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  sortByWateringFrequencyDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wateringFrequencyDays', Sort.desc);
    });
  }
}

extension IsarCultivationQuerySortThenBy
    on QueryBuilder<IsarCultivation, IsarCultivation, QSortThenBy> {
  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByAreaSquareMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaSquareMeters', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByAreaSquareMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaSquareMeters', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByExpectedHarvestDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedHarvestDate', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByExpectedHarvestDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedHarvestDate', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByGrowthStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'growthStage', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByGrowthStageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'growthStage', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByLastWateredDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWateredDate', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByLastWateredDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWateredDate', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByLocationUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByLocationUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByPlantingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plantingDate', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByPlantingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plantingDate', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByPreferredAreaUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredAreaUnit', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByPreferredAreaUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredAreaUnit', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy> thenByScale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scale', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByScaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scale', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy> thenByVariety() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variety', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByVarietyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variety', Sort.desc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByWateringFrequencyDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wateringFrequencyDays', Sort.asc);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QAfterSortBy>
  thenByWateringFrequencyDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wateringFrequencyDays', Sort.desc);
    });
  }
}

extension IsarCultivationQueryWhereDistinct
    on QueryBuilder<IsarCultivation, IsarCultivation, QDistinct> {
  QueryBuilder<IsarCultivation, IsarCultivation, QDistinct>
  distinctByAreaSquareMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'areaSquareMeters');
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QDistinct>
  distinctByExpectedHarvestDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedHarvestDate');
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QDistinct>
  distinctByGrowthStage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'growthStage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QDistinct>
  distinctByLastWateredDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastWateredDate');
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QDistinct>
  distinctByLocationUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QDistinct> distinctByNotes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QDistinct>
  distinctByPlantingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'plantingDate');
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QDistinct>
  distinctByPreferredAreaUnit({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'preferredAreaUnit',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QDistinct>
  distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QDistinct> distinctByScale({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scale', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QDistinct> distinctByStatus({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QDistinct> distinctByUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QDistinct> distinctByVariety({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'variety', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCultivation, IsarCultivation, QDistinct>
  distinctByWateringFrequencyDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wateringFrequencyDays');
    });
  }
}

extension IsarCultivationQueryProperty
    on QueryBuilder<IsarCultivation, IsarCultivation, QQueryProperty> {
  QueryBuilder<IsarCultivation, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarCultivation, double, QQueryOperations>
  areaSquareMetersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'areaSquareMeters');
    });
  }

  QueryBuilder<IsarCultivation, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<IsarCultivation, DateTime?, QQueryOperations>
  expectedHarvestDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedHarvestDate');
    });
  }

  QueryBuilder<IsarCultivation, String, QQueryOperations>
  growthStageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'growthStage');
    });
  }

  QueryBuilder<IsarCultivation, List<IsarHarvestRecord>, QQueryOperations>
  harvestsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'harvests');
    });
  }

  QueryBuilder<IsarCultivation, List<IsarCropHealthRecord>, QQueryOperations>
  healthRecordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'healthRecords');
    });
  }

  QueryBuilder<IsarCultivation, DateTime?, QQueryOperations>
  lastWateredDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastWateredDate');
    });
  }

  QueryBuilder<IsarCultivation, String?, QQueryOperations>
  locationUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationUuid');
    });
  }

  QueryBuilder<IsarCultivation, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<IsarCultivation, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<IsarCultivation, DateTime, QQueryOperations>
  plantingDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'plantingDate');
    });
  }

  QueryBuilder<IsarCultivation, String, QQueryOperations>
  preferredAreaUnitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preferredAreaUnit');
    });
  }

  QueryBuilder<IsarCultivation, int, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<IsarCultivation, String, QQueryOperations> scaleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scale');
    });
  }

  QueryBuilder<IsarCultivation, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<IsarCultivation, List<IsarCropTask>, QQueryOperations>
  tasksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tasks');
    });
  }

  QueryBuilder<IsarCultivation, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<IsarCultivation, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }

  QueryBuilder<IsarCultivation, String, QQueryOperations> varietyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'variety');
    });
  }

  QueryBuilder<IsarCultivation, int, QQueryOperations>
  wateringFrequencyDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wateringFrequencyDays');
    });
  }

  QueryBuilder<IsarCultivation, List<IsarCropWateringRecord>, QQueryOperations>
  wateringsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'waterings');
    });
  }
}
