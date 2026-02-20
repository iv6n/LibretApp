// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_location.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarLocationCollection on Isar {
  IsarCollection<IsarLocation> get isarLocations => this.collection();
}

const IsarLocationSchema = CollectionSchema(
  name: r'IsarLocation',
  id: -7713579883890428508,
  properties: {
    r'capacity': PropertySchema(
      id: 0,
      name: r'capacity',
      type: IsarType.long,
    ),
    r'costs': PropertySchema(
      id: 1,
      name: r'costs',
      type: IsarType.objectList,
      target: r'IsarLocationCostRecord',
    ),
    r'irrigations': PropertySchema(
      id: 2,
      name: r'irrigations',
      type: IsarType.objectList,
      target: r'IsarIrrigationRecord',
    ),
    r'name': PropertySchema(
      id: 3,
      name: r'name',
      type: IsarType.string,
    ),
    r'pastures': PropertySchema(
      id: 4,
      name: r'pastures',
      type: IsarType.objectList,
      target: r'IsarPastureRecord',
    ),
    r'rains': PropertySchema(
      id: 5,
      name: r'rains',
      type: IsarType.objectList,
      target: r'IsarRainRecord',
    ),
    r'seedings': PropertySchema(
      id: 6,
      name: r'seedings',
      type: IsarType.objectList,
      target: r'IsarSeedingRecord',
    ),
    r'status': PropertySchema(
      id: 7,
      name: r'status',
      type: IsarType.string,
    ),
    r'surfaceArea': PropertySchema(
      id: 8,
      name: r'surfaceArea',
      type: IsarType.double,
    ),
    r'terrainType': PropertySchema(
      id: 9,
      name: r'terrainType',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 10,
      name: r'type',
      type: IsarType.string,
    ),
    r'uuid': PropertySchema(
      id: 11,
      name: r'uuid',
      type: IsarType.string,
    ),
    r'visits': PropertySchema(
      id: 12,
      name: r'visits',
      type: IsarType.objectList,
      target: r'IsarVisitRecord',
    ),
    r'waterSource': PropertySchema(
      id: 13,
      name: r'waterSource',
      type: IsarType.string,
    ),
    r'waters': PropertySchema(
      id: 14,
      name: r'waters',
      type: IsarType.objectList,
      target: r'IsarWaterRecord',
    )
  },
  estimateSize: _isarLocationEstimateSize,
  serialize: _isarLocationSerialize,
  deserialize: _isarLocationDeserialize,
  deserializeProp: _isarLocationDeserializeProp,
  idName: r'id',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {
    r'IsarVisitRecord': IsarVisitRecordSchema,
    r'IsarWaterRecord': IsarWaterRecordSchema,
    r'IsarPastureRecord': IsarPastureRecordSchema,
    r'IsarSeedingRecord': IsarSeedingRecordSchema,
    r'IsarIrrigationRecord': IsarIrrigationRecordSchema,
    r'IsarRainRecord': IsarRainRecordSchema,
    r'IsarLocationCostRecord': IsarLocationCostRecordSchema
  },
  getId: _isarLocationGetId,
  getLinks: _isarLocationGetLinks,
  attach: _isarLocationAttach,
  version: '3.1.0+1',
);

int _isarLocationEstimateSize(
  IsarLocation object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.costs.length * 3;
  {
    final offsets = allOffsets[IsarLocationCostRecord]!;
    for (var i = 0; i < object.costs.length; i++) {
      final value = object.costs[i];
      bytesCount +=
          IsarLocationCostRecordSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.irrigations.length * 3;
  {
    final offsets = allOffsets[IsarIrrigationRecord]!;
    for (var i = 0; i < object.irrigations.length; i++) {
      final value = object.irrigations[i];
      bytesCount +=
          IsarIrrigationRecordSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.pastures.length * 3;
  {
    final offsets = allOffsets[IsarPastureRecord]!;
    for (var i = 0; i < object.pastures.length; i++) {
      final value = object.pastures[i];
      bytesCount +=
          IsarPastureRecordSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.rains.length * 3;
  {
    final offsets = allOffsets[IsarRainRecord]!;
    for (var i = 0; i < object.rains.length; i++) {
      final value = object.rains[i];
      bytesCount +=
          IsarRainRecordSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.seedings.length * 3;
  {
    final offsets = allOffsets[IsarSeedingRecord]!;
    for (var i = 0; i < object.seedings.length; i++) {
      final value = object.seedings[i];
      bytesCount +=
          IsarSeedingRecordSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.terrainType.length * 3;
  bytesCount += 3 + object.type.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  bytesCount += 3 + object.visits.length * 3;
  {
    final offsets = allOffsets[IsarVisitRecord]!;
    for (var i = 0; i < object.visits.length; i++) {
      final value = object.visits[i];
      bytesCount +=
          IsarVisitRecordSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.waterSource.length * 3;
  bytesCount += 3 + object.waters.length * 3;
  {
    final offsets = allOffsets[IsarWaterRecord]!;
    for (var i = 0; i < object.waters.length; i++) {
      final value = object.waters[i];
      bytesCount +=
          IsarWaterRecordSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _isarLocationSerialize(
  IsarLocation object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.capacity);
  writer.writeObjectList<IsarLocationCostRecord>(
    offsets[1],
    allOffsets,
    IsarLocationCostRecordSchema.serialize,
    object.costs,
  );
  writer.writeObjectList<IsarIrrigationRecord>(
    offsets[2],
    allOffsets,
    IsarIrrigationRecordSchema.serialize,
    object.irrigations,
  );
  writer.writeString(offsets[3], object.name);
  writer.writeObjectList<IsarPastureRecord>(
    offsets[4],
    allOffsets,
    IsarPastureRecordSchema.serialize,
    object.pastures,
  );
  writer.writeObjectList<IsarRainRecord>(
    offsets[5],
    allOffsets,
    IsarRainRecordSchema.serialize,
    object.rains,
  );
  writer.writeObjectList<IsarSeedingRecord>(
    offsets[6],
    allOffsets,
    IsarSeedingRecordSchema.serialize,
    object.seedings,
  );
  writer.writeString(offsets[7], object.status);
  writer.writeDouble(offsets[8], object.surfaceArea);
  writer.writeString(offsets[9], object.terrainType);
  writer.writeString(offsets[10], object.type);
  writer.writeString(offsets[11], object.uuid);
  writer.writeObjectList<IsarVisitRecord>(
    offsets[12],
    allOffsets,
    IsarVisitRecordSchema.serialize,
    object.visits,
  );
  writer.writeString(offsets[13], object.waterSource);
  writer.writeObjectList<IsarWaterRecord>(
    offsets[14],
    allOffsets,
    IsarWaterRecordSchema.serialize,
    object.waters,
  );
}

IsarLocation _isarLocationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarLocation();
  object.capacity = reader.readLong(offsets[0]);
  object.costs = reader.readObjectList<IsarLocationCostRecord>(
        offsets[1],
        IsarLocationCostRecordSchema.deserialize,
        allOffsets,
        IsarLocationCostRecord(),
      ) ??
      [];
  object.id = id;
  object.irrigations = reader.readObjectList<IsarIrrigationRecord>(
        offsets[2],
        IsarIrrigationRecordSchema.deserialize,
        allOffsets,
        IsarIrrigationRecord(),
      ) ??
      [];
  object.name = reader.readString(offsets[3]);
  object.pastures = reader.readObjectList<IsarPastureRecord>(
        offsets[4],
        IsarPastureRecordSchema.deserialize,
        allOffsets,
        IsarPastureRecord(),
      ) ??
      [];
  object.rains = reader.readObjectList<IsarRainRecord>(
        offsets[5],
        IsarRainRecordSchema.deserialize,
        allOffsets,
        IsarRainRecord(),
      ) ??
      [];
  object.seedings = reader.readObjectList<IsarSeedingRecord>(
        offsets[6],
        IsarSeedingRecordSchema.deserialize,
        allOffsets,
        IsarSeedingRecord(),
      ) ??
      [];
  object.status = reader.readString(offsets[7]);
  object.surfaceArea = reader.readDouble(offsets[8]);
  object.terrainType = reader.readString(offsets[9]);
  object.type = reader.readString(offsets[10]);
  object.uuid = reader.readString(offsets[11]);
  object.visits = reader.readObjectList<IsarVisitRecord>(
        offsets[12],
        IsarVisitRecordSchema.deserialize,
        allOffsets,
        IsarVisitRecord(),
      ) ??
      [];
  object.waterSource = reader.readString(offsets[13]);
  object.waters = reader.readObjectList<IsarWaterRecord>(
        offsets[14],
        IsarWaterRecordSchema.deserialize,
        allOffsets,
        IsarWaterRecord(),
      ) ??
      [];
  return object;
}

P _isarLocationDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readObjectList<IsarLocationCostRecord>(
            offset,
            IsarLocationCostRecordSchema.deserialize,
            allOffsets,
            IsarLocationCostRecord(),
          ) ??
          []) as P;
    case 2:
      return (reader.readObjectList<IsarIrrigationRecord>(
            offset,
            IsarIrrigationRecordSchema.deserialize,
            allOffsets,
            IsarIrrigationRecord(),
          ) ??
          []) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readObjectList<IsarPastureRecord>(
            offset,
            IsarPastureRecordSchema.deserialize,
            allOffsets,
            IsarPastureRecord(),
          ) ??
          []) as P;
    case 5:
      return (reader.readObjectList<IsarRainRecord>(
            offset,
            IsarRainRecordSchema.deserialize,
            allOffsets,
            IsarRainRecord(),
          ) ??
          []) as P;
    case 6:
      return (reader.readObjectList<IsarSeedingRecord>(
            offset,
            IsarSeedingRecordSchema.deserialize,
            allOffsets,
            IsarSeedingRecord(),
          ) ??
          []) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readObjectList<IsarVisitRecord>(
            offset,
            IsarVisitRecordSchema.deserialize,
            allOffsets,
            IsarVisitRecord(),
          ) ??
          []) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readObjectList<IsarWaterRecord>(
            offset,
            IsarWaterRecordSchema.deserialize,
            allOffsets,
            IsarWaterRecord(),
          ) ??
          []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarLocationGetId(IsarLocation object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarLocationGetLinks(IsarLocation object) {
  return [];
}

void _isarLocationAttach(
    IsarCollection<dynamic> col, Id id, IsarLocation object) {
  object.id = id;
}

extension IsarLocationByIndex on IsarCollection<IsarLocation> {
  Future<IsarLocation?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  IsarLocation? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<IsarLocation?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<IsarLocation?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(IsarLocation object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(IsarLocation object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<IsarLocation> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<IsarLocation> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension IsarLocationQueryWhereSort
    on QueryBuilder<IsarLocation, IsarLocation, QWhere> {
  QueryBuilder<IsarLocation, IsarLocation, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarLocationQueryWhere
    on QueryBuilder<IsarLocation, IsarLocation, QWhereClause> {
  QueryBuilder<IsarLocation, IsarLocation, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterWhereClause> idBetween(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterWhereClause> uuidEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterWhereClause> uuidNotEqualTo(
      String uuid) {
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
}

extension IsarLocationQueryFilter
    on QueryBuilder<IsarLocation, IsarLocation, QFilterCondition> {
  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      capacityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'capacity',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      capacityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'capacity',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      capacityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'capacity',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      capacityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'capacity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      costsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'costs',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      costsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'costs',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      costsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'costs',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      costsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'costs',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      costsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'costs',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      costsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'costs',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> idBetween(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      irrigationsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'irrigations',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      irrigationsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'irrigations',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      irrigationsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'irrigations',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      irrigationsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'irrigations',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      irrigationsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'irrigations',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      irrigationsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'irrigations',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> nameContains(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      pasturesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pastures',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      pasturesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pastures',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      pasturesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pastures',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      pasturesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pastures',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      pasturesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pastures',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      pasturesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pastures',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      rainsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rains',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      rainsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rains',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      rainsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rains',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      rainsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rains',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      rainsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rains',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      rainsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rains',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      seedingsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'seedings',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      seedingsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'seedings',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      seedingsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'seedings',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      seedingsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'seedings',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      seedingsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'seedings',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      seedingsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'seedings',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> statusEqualTo(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> statusBetween(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      surfaceAreaEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'surfaceArea',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      surfaceAreaGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'surfaceArea',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      surfaceAreaLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'surfaceArea',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      surfaceAreaBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'surfaceArea',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      terrainTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'terrainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      terrainTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'terrainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      terrainTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'terrainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      terrainTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'terrainType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      terrainTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'terrainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      terrainTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'terrainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      terrainTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'terrainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      terrainTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'terrainType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      terrainTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'terrainType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      terrainTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'terrainType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> typeEqualTo(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> typeLessThan(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> typeBetween(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> typeEndsWith(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> typeContains(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> typeMatches(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> uuidEqualTo(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> uuidLessThan(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> uuidBetween(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> uuidEndsWith(
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

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> uuidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> uuidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      visitsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visits',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      visitsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visits',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      visitsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visits',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      visitsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visits',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      visitsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visits',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      visitsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visits',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      waterSourceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'waterSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      waterSourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'waterSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      waterSourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'waterSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      waterSourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'waterSource',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      waterSourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'waterSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      waterSourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'waterSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      waterSourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'waterSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      waterSourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'waterSource',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      waterSourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'waterSource',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      waterSourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'waterSource',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      watersLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'waters',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      watersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'waters',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      watersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'waters',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      watersLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'waters',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      watersLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'waters',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      watersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'waters',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension IsarLocationQueryObject
    on QueryBuilder<IsarLocation, IsarLocation, QFilterCondition> {
  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> costsElement(
      FilterQuery<IsarLocationCostRecord> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'costs');
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      irrigationsElement(FilterQuery<IsarIrrigationRecord> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'irrigations');
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      pasturesElement(FilterQuery<IsarPastureRecord> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'pastures');
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> rainsElement(
      FilterQuery<IsarRainRecord> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'rains');
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition>
      seedingsElement(FilterQuery<IsarSeedingRecord> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'seedings');
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> visitsElement(
      FilterQuery<IsarVisitRecord> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'visits');
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterFilterCondition> watersElement(
      FilterQuery<IsarWaterRecord> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'waters');
    });
  }
}

extension IsarLocationQueryLinks
    on QueryBuilder<IsarLocation, IsarLocation, QFilterCondition> {}

extension IsarLocationQuerySortBy
    on QueryBuilder<IsarLocation, IsarLocation, QSortBy> {
  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> sortByCapacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capacity', Sort.asc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> sortByCapacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capacity', Sort.desc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> sortBySurfaceArea() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surfaceArea', Sort.asc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy>
      sortBySurfaceAreaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surfaceArea', Sort.desc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> sortByTerrainType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terrainType', Sort.asc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy>
      sortByTerrainTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terrainType', Sort.desc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> sortByWaterSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterSource', Sort.asc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy>
      sortByWaterSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterSource', Sort.desc);
    });
  }
}

extension IsarLocationQuerySortThenBy
    on QueryBuilder<IsarLocation, IsarLocation, QSortThenBy> {
  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> thenByCapacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capacity', Sort.asc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> thenByCapacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capacity', Sort.desc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> thenBySurfaceArea() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surfaceArea', Sort.asc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy>
      thenBySurfaceAreaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surfaceArea', Sort.desc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> thenByTerrainType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terrainType', Sort.asc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy>
      thenByTerrainTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terrainType', Sort.desc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy> thenByWaterSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterSource', Sort.asc);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QAfterSortBy>
      thenByWaterSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterSource', Sort.desc);
    });
  }
}

extension IsarLocationQueryWhereDistinct
    on QueryBuilder<IsarLocation, IsarLocation, QDistinct> {
  QueryBuilder<IsarLocation, IsarLocation, QDistinct> distinctByCapacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'capacity');
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QDistinct> distinctBySurfaceArea() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'surfaceArea');
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QDistinct> distinctByTerrainType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'terrainType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarLocation, IsarLocation, QDistinct> distinctByWaterSource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'waterSource', caseSensitive: caseSensitive);
    });
  }
}

extension IsarLocationQueryProperty
    on QueryBuilder<IsarLocation, IsarLocation, QQueryProperty> {
  QueryBuilder<IsarLocation, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarLocation, int, QQueryOperations> capacityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'capacity');
    });
  }

  QueryBuilder<IsarLocation, List<IsarLocationCostRecord>, QQueryOperations>
      costsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'costs');
    });
  }

  QueryBuilder<IsarLocation, List<IsarIrrigationRecord>, QQueryOperations>
      irrigationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'irrigations');
    });
  }

  QueryBuilder<IsarLocation, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<IsarLocation, List<IsarPastureRecord>, QQueryOperations>
      pasturesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pastures');
    });
  }

  QueryBuilder<IsarLocation, List<IsarRainRecord>, QQueryOperations>
      rainsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rains');
    });
  }

  QueryBuilder<IsarLocation, List<IsarSeedingRecord>, QQueryOperations>
      seedingsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seedings');
    });
  }

  QueryBuilder<IsarLocation, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<IsarLocation, double, QQueryOperations> surfaceAreaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'surfaceArea');
    });
  }

  QueryBuilder<IsarLocation, String, QQueryOperations> terrainTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'terrainType');
    });
  }

  QueryBuilder<IsarLocation, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<IsarLocation, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }

  QueryBuilder<IsarLocation, List<IsarVisitRecord>, QQueryOperations>
      visitsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'visits');
    });
  }

  QueryBuilder<IsarLocation, String, QQueryOperations> waterSourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'waterSource');
    });
  }

  QueryBuilder<IsarLocation, List<IsarWaterRecord>, QQueryOperations>
      watersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'waters');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const IsarVisitRecordSchema = Schema(
  name: r'IsarVisitRecord',
  id: 4477344286070081064,
  properties: {
    r'animals': PropertySchema(
      id: 0,
      name: r'animals',
      type: IsarType.long,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'notes': PropertySchema(
      id: 2,
      name: r'notes',
      type: IsarType.string,
    ),
    r'user': PropertySchema(
      id: 3,
      name: r'user',
      type: IsarType.string,
    )
  },
  estimateSize: _isarVisitRecordEstimateSize,
  serialize: _isarVisitRecordSerialize,
  deserialize: _isarVisitRecordDeserialize,
  deserializeProp: _isarVisitRecordDeserializeProp,
);

int _isarVisitRecordEstimateSize(
  IsarVisitRecord object,
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
  {
    final value = object.user;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _isarVisitRecordSerialize(
  IsarVisitRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.animals);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeString(offsets[2], object.notes);
  writer.writeString(offsets[3], object.user);
}

IsarVisitRecord _isarVisitRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarVisitRecord();
  object.animals = reader.readLong(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.notes = reader.readStringOrNull(offsets[2]);
  object.user = reader.readStringOrNull(offsets[3]);
  return object;
}

P _isarVisitRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension IsarVisitRecordQueryFilter
    on QueryBuilder<IsarVisitRecord, IsarVisitRecord, QFilterCondition> {
  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      animalsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animals',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      animalsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'animals',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      animalsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'animals',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      animalsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'animals',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      userIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'user',
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      userIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'user',
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      userEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'user',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      userGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'user',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      userLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'user',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      userBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'user',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      userStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'user',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      userEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'user',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      userContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'user',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      userMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'user',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      userIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'user',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarVisitRecord, IsarVisitRecord, QAfterFilterCondition>
      userIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'user',
        value: '',
      ));
    });
  }
}

extension IsarVisitRecordQueryObject
    on QueryBuilder<IsarVisitRecord, IsarVisitRecord, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const IsarWaterRecordSchema = Schema(
  name: r'IsarWaterRecord',
  id: 5596879096050494867,
  properties: {
    r'date': PropertySchema(
      id: 0,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'level': PropertySchema(
      id: 1,
      name: r'level',
      type: IsarType.double,
    ),
    r'notes': PropertySchema(
      id: 2,
      name: r'notes',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 3,
      name: r'type',
      type: IsarType.string,
    )
  },
  estimateSize: _isarWaterRecordEstimateSize,
  serialize: _isarWaterRecordSerialize,
  deserialize: _isarWaterRecordDeserialize,
  deserializeProp: _isarWaterRecordDeserializeProp,
);

int _isarWaterRecordEstimateSize(
  IsarWaterRecord object,
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
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _isarWaterRecordSerialize(
  IsarWaterRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeDouble(offsets[1], object.level);
  writer.writeString(offsets[2], object.notes);
  writer.writeString(offsets[3], object.type);
}

IsarWaterRecord _isarWaterRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarWaterRecord();
  object.date = reader.readDateTime(offsets[0]);
  object.level = reader.readDouble(offsets[1]);
  object.notes = reader.readStringOrNull(offsets[2]);
  object.type = reader.readString(offsets[3]);
  return object;
}

P _isarWaterRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension IsarWaterRecordQueryFilter
    on QueryBuilder<IsarWaterRecord, IsarWaterRecord, QFilterCondition> {
  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
      levelEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'level',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
      levelGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'level',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
      levelLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'level',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
      levelBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'level',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarWaterRecord, IsarWaterRecord, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension IsarWaterRecordQueryObject
    on QueryBuilder<IsarWaterRecord, IsarWaterRecord, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const IsarPastureRecordSchema = Schema(
  name: r'IsarPastureRecord',
  id: -6108225406548735305,
  properties: {
    r'carryingCapacity': PropertySchema(
      id: 0,
      name: r'carryingCapacity',
      type: IsarType.double,
    ),
    r'condition': PropertySchema(
      id: 1,
      name: r'condition',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'grassType': PropertySchema(
      id: 3,
      name: r'grassType',
      type: IsarType.string,
    )
  },
  estimateSize: _isarPastureRecordEstimateSize,
  serialize: _isarPastureRecordSerialize,
  deserialize: _isarPastureRecordDeserialize,
  deserializeProp: _isarPastureRecordDeserializeProp,
);

int _isarPastureRecordEstimateSize(
  IsarPastureRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.condition.length * 3;
  bytesCount += 3 + object.grassType.length * 3;
  return bytesCount;
}

void _isarPastureRecordSerialize(
  IsarPastureRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.carryingCapacity);
  writer.writeString(offsets[1], object.condition);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeString(offsets[3], object.grassType);
}

IsarPastureRecord _isarPastureRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarPastureRecord();
  object.carryingCapacity = reader.readDouble(offsets[0]);
  object.condition = reader.readString(offsets[1]);
  object.date = reader.readDateTime(offsets[2]);
  object.grassType = reader.readString(offsets[3]);
  return object;
}

P _isarPastureRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension IsarPastureRecordQueryFilter
    on QueryBuilder<IsarPastureRecord, IsarPastureRecord, QFilterCondition> {
  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      carryingCapacityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carryingCapacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      carryingCapacityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'carryingCapacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      carryingCapacityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'carryingCapacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      carryingCapacityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'carryingCapacity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      conditionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'condition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      conditionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'condition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      conditionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'condition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      conditionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'condition',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      conditionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'condition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      conditionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'condition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      conditionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'condition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      conditionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'condition',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      conditionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'condition',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      conditionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'condition',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      grassTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grassType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      grassTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'grassType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      grassTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'grassType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      grassTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'grassType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      grassTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'grassType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      grassTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'grassType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      grassTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'grassType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      grassTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'grassType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      grassTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grassType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarPastureRecord, IsarPastureRecord, QAfterFilterCondition>
      grassTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'grassType',
        value: '',
      ));
    });
  }
}

extension IsarPastureRecordQueryObject
    on QueryBuilder<IsarPastureRecord, IsarPastureRecord, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const IsarSeedingRecordSchema = Schema(
  name: r'IsarSeedingRecord',
  id: 4945227194627638813,
  properties: {
    r'cost': PropertySchema(
      id: 0,
      name: r'cost',
      type: IsarType.double,
    ),
    r'crop': PropertySchema(
      id: 1,
      name: r'crop',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'surface': PropertySchema(
      id: 3,
      name: r'surface',
      type: IsarType.double,
    )
  },
  estimateSize: _isarSeedingRecordEstimateSize,
  serialize: _isarSeedingRecordSerialize,
  deserialize: _isarSeedingRecordDeserialize,
  deserializeProp: _isarSeedingRecordDeserializeProp,
);

int _isarSeedingRecordEstimateSize(
  IsarSeedingRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.crop.length * 3;
  return bytesCount;
}

void _isarSeedingRecordSerialize(
  IsarSeedingRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.cost);
  writer.writeString(offsets[1], object.crop);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeDouble(offsets[3], object.surface);
}

IsarSeedingRecord _isarSeedingRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarSeedingRecord();
  object.cost = reader.readDouble(offsets[0]);
  object.crop = reader.readString(offsets[1]);
  object.date = reader.readDateTime(offsets[2]);
  object.surface = reader.readDouble(offsets[3]);
  return object;
}

P _isarSeedingRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension IsarSeedingRecordQueryFilter
    on QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QFilterCondition> {
  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      costEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      costGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      costLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      costBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      cropEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'crop',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      cropGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'crop',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      cropLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'crop',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      cropBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'crop',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      cropStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'crop',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      cropEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'crop',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      cropContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'crop',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      cropMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'crop',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      cropIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'crop',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      cropIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'crop',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      surfaceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'surface',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      surfaceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'surface',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      surfaceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'surface',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QAfterFilterCondition>
      surfaceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'surface',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension IsarSeedingRecordQueryObject
    on QueryBuilder<IsarSeedingRecord, IsarSeedingRecord, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const IsarIrrigationRecordSchema = Schema(
  name: r'IsarIrrigationRecord',
  id: -8770043845688742475,
  properties: {
    r'cost': PropertySchema(
      id: 0,
      name: r'cost',
      type: IsarType.double,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'durationMinutes': PropertySchema(
      id: 2,
      name: r'durationMinutes',
      type: IsarType.long,
    ),
    r'type': PropertySchema(
      id: 3,
      name: r'type',
      type: IsarType.string,
    )
  },
  estimateSize: _isarIrrigationRecordEstimateSize,
  serialize: _isarIrrigationRecordSerialize,
  deserialize: _isarIrrigationRecordDeserialize,
  deserializeProp: _isarIrrigationRecordDeserializeProp,
);

int _isarIrrigationRecordEstimateSize(
  IsarIrrigationRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _isarIrrigationRecordSerialize(
  IsarIrrigationRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.cost);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeLong(offsets[2], object.durationMinutes);
  writer.writeString(offsets[3], object.type);
}

IsarIrrigationRecord _isarIrrigationRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarIrrigationRecord();
  object.cost = reader.readDouble(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.durationMinutes = reader.readLong(offsets[2]);
  object.type = reader.readString(offsets[3]);
  return object;
}

P _isarIrrigationRecordDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension IsarIrrigationRecordQueryFilter on QueryBuilder<IsarIrrigationRecord,
    IsarIrrigationRecord, QFilterCondition> {
  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> costEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> costGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> costLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> costBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> dateGreaterThan(
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

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> dateLessThan(
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

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> dateBetween(
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

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> durationMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> durationMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> durationMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> durationMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> typeEqualTo(
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

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> typeGreaterThan(
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

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> typeLessThan(
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

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> typeBetween(
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

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> typeStartsWith(
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

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> typeEndsWith(
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

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
          QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
          QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarIrrigationRecord, IsarIrrigationRecord,
      QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension IsarIrrigationRecordQueryObject on QueryBuilder<IsarIrrigationRecord,
    IsarIrrigationRecord, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const IsarRainRecordSchema = Schema(
  name: r'IsarRainRecord',
  id: 3266381153438004508,
  properties: {
    r'date': PropertySchema(
      id: 0,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'location': PropertySchema(
      id: 1,
      name: r'location',
      type: IsarType.string,
    ),
    r'millimeters': PropertySchema(
      id: 2,
      name: r'millimeters',
      type: IsarType.double,
    )
  },
  estimateSize: _isarRainRecordEstimateSize,
  serialize: _isarRainRecordSerialize,
  deserialize: _isarRainRecordDeserialize,
  deserializeProp: _isarRainRecordDeserializeProp,
);

int _isarRainRecordEstimateSize(
  IsarRainRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.location.length * 3;
  return bytesCount;
}

void _isarRainRecordSerialize(
  IsarRainRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeString(offsets[1], object.location);
  writer.writeDouble(offsets[2], object.millimeters);
}

IsarRainRecord _isarRainRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarRainRecord();
  object.date = reader.readDateTime(offsets[0]);
  object.location = reader.readString(offsets[1]);
  object.millimeters = reader.readDouble(offsets[2]);
  return object;
}

P _isarRainRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension IsarRainRecordQueryFilter
    on QueryBuilder<IsarRainRecord, IsarRainRecord, QFilterCondition> {
  QueryBuilder<IsarRainRecord, IsarRainRecord, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRainRecord, IsarRainRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarRainRecord, IsarRainRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarRainRecord, IsarRainRecord, QAfterFilterCondition>
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

  QueryBuilder<IsarRainRecord, IsarRainRecord, QAfterFilterCondition>
      locationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRainRecord, IsarRainRecord, QAfterFilterCondition>
      locationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRainRecord, IsarRainRecord, QAfterFilterCondition>
      locationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRainRecord, IsarRainRecord, QAfterFilterCondition>
      locationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'location',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRainRecord, IsarRainRecord, QAfterFilterCondition>
      locationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRainRecord, IsarRainRecord, QAfterFilterCondition>
      locationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRainRecord, IsarRainRecord, QAfterFilterCondition>
      locationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRainRecord, IsarRainRecord, QAfterFilterCondition>
      locationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'location',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRainRecord, IsarRainRecord, QAfterFilterCondition>
      locationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRainRecord, IsarRainRecord, QAfterFilterCondition>
      locationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRainRecord, IsarRainRecord, QAfterFilterCondition>
      millimetersEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'millimeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarRainRecord, IsarRainRecord, QAfterFilterCondition>
      millimetersGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'millimeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarRainRecord, IsarRainRecord, QAfterFilterCondition>
      millimetersLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'millimeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarRainRecord, IsarRainRecord, QAfterFilterCondition>
      millimetersBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'millimeters',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension IsarRainRecordQueryObject
    on QueryBuilder<IsarRainRecord, IsarRainRecord, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const IsarLocationCostRecordSchema = Schema(
  name: r'IsarLocationCostRecord',
  id: -5790713727736426436,
  properties: {
    r'date': PropertySchema(
      id: 0,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'fences': PropertySchema(
      id: 1,
      name: r'fences',
      type: IsarType.double,
    ),
    r'labor': PropertySchema(
      id: 2,
      name: r'labor',
      type: IsarType.double,
    ),
    r'maintenance': PropertySchema(
      id: 3,
      name: r'maintenance',
      type: IsarType.double,
    ),
    r'repairs': PropertySchema(
      id: 4,
      name: r'repairs',
      type: IsarType.double,
    ),
    r'total': PropertySchema(
      id: 5,
      name: r'total',
      type: IsarType.double,
    )
  },
  estimateSize: _isarLocationCostRecordEstimateSize,
  serialize: _isarLocationCostRecordSerialize,
  deserialize: _isarLocationCostRecordDeserialize,
  deserializeProp: _isarLocationCostRecordDeserializeProp,
);

int _isarLocationCostRecordEstimateSize(
  IsarLocationCostRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _isarLocationCostRecordSerialize(
  IsarLocationCostRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeDouble(offsets[1], object.fences);
  writer.writeDouble(offsets[2], object.labor);
  writer.writeDouble(offsets[3], object.maintenance);
  writer.writeDouble(offsets[4], object.repairs);
  writer.writeDouble(offsets[5], object.total);
}

IsarLocationCostRecord _isarLocationCostRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarLocationCostRecord();
  object.date = reader.readDateTime(offsets[0]);
  object.fences = reader.readDouble(offsets[1]);
  object.labor = reader.readDouble(offsets[2]);
  object.maintenance = reader.readDouble(offsets[3]);
  object.repairs = reader.readDouble(offsets[4]);
  object.total = reader.readDouble(offsets[5]);
  return object;
}

P _isarLocationCostRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension IsarLocationCostRecordQueryFilter on QueryBuilder<
    IsarLocationCostRecord, IsarLocationCostRecord, QFilterCondition> {
  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> dateGreaterThan(
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

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> dateLessThan(
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

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> dateBetween(
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

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> fencesEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fences',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> fencesGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fences',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> fencesLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fences',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> fencesBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fences',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> laborEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'labor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> laborGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'labor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> laborLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'labor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> laborBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'labor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> maintenanceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maintenance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> maintenanceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maintenance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> maintenanceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maintenance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> maintenanceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maintenance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> repairsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repairs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> repairsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'repairs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> repairsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'repairs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> repairsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'repairs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> totalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'total',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> totalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'total',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> totalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'total',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarLocationCostRecord, IsarLocationCostRecord,
      QAfterFilterCondition> totalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'total',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension IsarLocationCostRecordQueryObject on QueryBuilder<
    IsarLocationCostRecord, IsarLocationCostRecord, QFilterCondition> {}
