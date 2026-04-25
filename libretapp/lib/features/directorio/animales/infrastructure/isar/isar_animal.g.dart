// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_animal.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarAnimalCollection on Isar {
  IsarCollection<IsarAnimal> get isarAnimals => this.collection();
}

const IsarAnimalSchema = CollectionSchema(
  name: r'IsarAnimal',
  id: -8312941717384079697,
  properties: {
    r'ageMonths': PropertySchema(
      id: 0,
      name: r'ageMonths',
      type: IsarType.long,
    ),
    r'animalWaterSource': PropertySchema(
      id: 1,
      name: r'animalWaterSource',
      type: IsarType.string,
    ),
    r'approximateDensity': PropertySchema(
      id: 2,
      name: r'approximateDensity',
      type: IsarType.string,
    ),
    r'batchId': PropertySchema(
      id: 3,
      name: r'batchId',
      type: IsarType.string,
    ),
    r'batchUuid': PropertySchema(
      id: 4,
      name: r'batchUuid',
      type: IsarType.string,
    ),
    r'birthDate': PropertySchema(
      id: 5,
      name: r'birthDate',
      type: IsarType.dateTime,
    ),
    r'bloodPercentage': PropertySchema(
      id: 6,
      name: r'bloodPercentage',
      type: IsarType.long,
    ),
    r'bodyConditionScore': PropertySchema(
      id: 7,
      name: r'bodyConditionScore',
      type: IsarType.long,
    ),
    r'brand': PropertySchema(
      id: 8,
      name: r'brand',
      type: IsarType.string,
    ),
    r'breed': PropertySchema(
      id: 9,
      name: r'breed',
      type: IsarType.string,
    ),
    r'category': PropertySchema(
      id: 10,
      name: r'category',
      type: IsarType.string,
    ),
    r'chronicNotes': PropertySchema(
      id: 11,
      name: r'chronicNotes',
      type: IsarType.string,
    ),
    r'coatColor': PropertySchema(
      id: 12,
      name: r'coatColor',
      type: IsarType.string,
    ),
    r'contentHash': PropertySchema(
      id: 13,
      name: r'contentHash',
      type: IsarType.string,
    ),
    r'creationDate': PropertySchema(
      id: 14,
      name: r'creationDate',
      type: IsarType.dateTime,
    ),
    r'crossBreed': PropertySchema(
      id: 15,
      name: r'crossBreed',
      type: IsarType.string,
    ),
    r'crossBreedType': PropertySchema(
      id: 16,
      name: r'crossBreedType',
      type: IsarType.string,
    ),
    r'currentPaddockId': PropertySchema(
      id: 17,
      name: r'currentPaddockId',
      type: IsarType.string,
    ),
    r'customName': PropertySchema(
      id: 18,
      name: r'customName',
      type: IsarType.string,
    ),
    r'dailyGainEstimate': PropertySchema(
      id: 19,
      name: r'dailyGainEstimate',
      type: IsarType.double,
    ),
    r'damBreed': PropertySchema(
      id: 20,
      name: r'damBreed',
      type: IsarType.string,
    ),
    r'damUuid': PropertySchema(
      id: 21,
      name: r'damUuid',
      type: IsarType.string,
    ),
    r'dewormed': PropertySchema(
      id: 22,
      name: r'dewormed',
      type: IsarType.bool,
    ),
    r'distinguishingMarks': PropertySchema(
      id: 23,
      name: r'distinguishingMarks',
      type: IsarType.string,
    ),
    r'earTagColor': PropertySchema(
      id: 24,
      name: r'earTagColor',
      type: IsarType.string,
    ),
    r'earTagNumber': PropertySchema(
      id: 25,
      name: r'earTagNumber',
      type: IsarType.string,
    ),
    r'expectedCalvingDate': PropertySchema(
      id: 26,
      name: r'expectedCalvingDate',
      type: IsarType.dateTime,
    ),
    r'feedFrequency': PropertySchema(
      id: 27,
      name: r'feedFrequency',
      type: IsarType.string,
    ),
    r'feedNotes': PropertySchema(
      id: 28,
      name: r'feedNotes',
      type: IsarType.string,
    ),
    r'feedSupplements': PropertySchema(
      id: 29,
      name: r'feedSupplements',
      type: IsarType.string,
    ),
    r'feedType': PropertySchema(
      id: 30,
      name: r'feedType',
      type: IsarType.string,
    ),
    r'firstServiceDate': PropertySchema(
      id: 31,
      name: r'firstServiceDate',
      type: IsarType.dateTime,
    ),
    r'gallery': PropertySchema(
      id: 32,
      name: r'gallery',
      type: IsarType.stringList,
    ),
    r'genealogicalRegistry': PropertySchema(
      id: 33,
      name: r'genealogicalRegistry',
      type: IsarType.string,
    ),
    r'generation': PropertySchema(
      id: 34,
      name: r'generation',
      type: IsarType.long,
    ),
    r'hasChronicIssues': PropertySchema(
      id: 35,
      name: r'hasChronicIssues',
      type: IsarType.bool,
    ),
    r'hasVitamins': PropertySchema(
      id: 36,
      name: r'hasVitamins',
      type: IsarType.bool,
    ),
    r'healthStatus': PropertySchema(
      id: 37,
      name: r'healthStatus',
      type: IsarType.string,
    ),
    r'housingType': PropertySchema(
      id: 38,
      name: r'housingType',
      type: IsarType.string,
    ),
    r'initialLocationId': PropertySchema(
      id: 39,
      name: r'initialLocationId',
      type: IsarType.string,
    ),
    r'lastMovementDate': PropertySchema(
      id: 40,
      name: r'lastMovementDate',
      type: IsarType.dateTime,
    ),
    r'lastServiceDate': PropertySchema(
      id: 41,
      name: r'lastServiceDate',
      type: IsarType.dateTime,
    ),
    r'lastUpdateDate': PropertySchema(
      id: 42,
      name: r'lastUpdateDate',
      type: IsarType.dateTime,
    ),
    r'lifeStage': PropertySchema(
      id: 43,
      name: r'lifeStage',
      type: IsarType.string,
    ),
    r'locationNotes': PropertySchema(
      id: 44,
      name: r'locationNotes',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 45,
      name: r'notes',
      type: IsarType.string,
    ),
    r'originNotes': PropertySchema(
      id: 46,
      name: r'originNotes',
      type: IsarType.string,
    ),
    r'originType': PropertySchema(
      id: 47,
      name: r'originType',
      type: IsarType.string,
    ),
    r'owner': PropertySchema(
      id: 48,
      name: r'owner',
      type: IsarType.string,
    ),
    r'productionPurpose': PropertySchema(
      id: 49,
      name: r'productionPurpose',
      type: IsarType.string,
    ),
    r'productionStage': PropertySchema(
      id: 50,
      name: r'productionStage',
      type: IsarType.string,
    ),
    r'productionSystem': PropertySchema(
      id: 51,
      name: r'productionSystem',
      type: IsarType.string,
    ),
    r'profilePhoto': PropertySchema(
      id: 52,
      name: r'profilePhoto',
      type: IsarType.string,
    ),
    r'provenance': PropertySchema(
      id: 53,
      name: r'provenance',
      type: IsarType.string,
    ),
    r'purchasePrice': PropertySchema(
      id: 54,
      name: r'purchasePrice',
      type: IsarType.double,
    ),
    r'remoteId': PropertySchema(
      id: 55,
      name: r'remoteId',
      type: IsarType.string,
    ),
    r'reproductiveStatus': PropertySchema(
      id: 56,
      name: r'reproductiveStatus',
      type: IsarType.string,
    ),
    r'requiresAttention': PropertySchema(
      id: 57,
      name: r'requiresAttention',
      type: IsarType.bool,
    ),
    r'rfidTag': PropertySchema(
      id: 58,
      name: r'rfidTag',
      type: IsarType.string,
    ),
    r'riskLevel': PropertySchema(
      id: 59,
      name: r'riskLevel',
      type: IsarType.string,
    ),
    r'sex': PropertySchema(
      id: 60,
      name: r'sex',
      type: IsarType.string,
    ),
    r'shadingAvailability': PropertySchema(
      id: 61,
      name: r'shadingAvailability',
      type: IsarType.string,
    ),
    r'sireBreed': PropertySchema(
      id: 62,
      name: r'sireBreed',
      type: IsarType.string,
    ),
    r'sireUuid': PropertySchema(
      id: 63,
      name: r'sireUuid',
      type: IsarType.string,
    ),
    r'species': PropertySchema(
      id: 64,
      name: r'species',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 65,
      name: r'status',
      type: IsarType.string,
    ),
    r'syncDate': PropertySchema(
      id: 66,
      name: r'syncDate',
      type: IsarType.dateTime,
    ),
    r'synced': PropertySchema(
      id: 67,
      name: r'synced',
      type: IsarType.bool,
    ),
    r'underObservation': PropertySchema(
      id: 68,
      name: r'underObservation',
      type: IsarType.bool,
    ),
    r'uuid': PropertySchema(
      id: 69,
      name: r'uuid',
      type: IsarType.string,
    ),
    r'vaccinated': PropertySchema(
      id: 70,
      name: r'vaccinated',
      type: IsarType.bool,
    ),
    r'visualId': PropertySchema(
      id: 71,
      name: r'visualId',
      type: IsarType.string,
    ),
    r'weight': PropertySchema(
      id: 72,
      name: r'weight',
      type: IsarType.double,
    )
  },
  estimateSize: _isarAnimalEstimateSize,
  serialize: _isarAnimalSerialize,
  deserialize: _isarAnimalDeserialize,
  deserializeProp: _isarAnimalDeserializeProp,
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
  embeddedSchemas: {},
  getId: _isarAnimalGetId,
  getLinks: _isarAnimalGetLinks,
  attach: _isarAnimalAttach,
  version: '3.1.0+1',
);

int _isarAnimalEstimateSize(
  IsarAnimal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.animalWaterSource;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.approximateDensity;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.batchId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.batchUuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.brand;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.breed.length * 3;
  bytesCount += 3 + object.category.length * 3;
  {
    final value = object.chronicNotes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.coatColor;
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
    final value = object.crossBreed;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.crossBreedType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.currentPaddockId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.customName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.damBreed;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.damUuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.distinguishingMarks;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.earTagColor;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.earTagNumber.length * 3;
  {
    final value = object.feedFrequency;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.feedNotes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.feedSupplements;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.feedType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.gallery.length * 3;
  {
    for (var i = 0; i < object.gallery.length; i++) {
      final value = object.gallery[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.genealogicalRegistry;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.healthStatus.length * 3;
  {
    final value = object.housingType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.initialLocationId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.lifeStage.length * 3;
  {
    final value = object.locationNotes;
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
    final value = object.originNotes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.originType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.owner;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.productionPurpose.length * 3;
  bytesCount += 3 + object.productionStage.length * 3;
  bytesCount += 3 + object.productionSystem.length * 3;
  {
    final value = object.profilePhoto;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.provenance;
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
  bytesCount += 3 + object.reproductiveStatus.length * 3;
  {
    final value = object.rfidTag;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.riskLevel.length * 3;
  bytesCount += 3 + object.sex.length * 3;
  {
    final value = object.shadingAvailability;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sireBreed;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sireUuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.species.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  {
    final value = object.visualId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _isarAnimalSerialize(
  IsarAnimal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.ageMonths);
  writer.writeString(offsets[1], object.animalWaterSource);
  writer.writeString(offsets[2], object.approximateDensity);
  writer.writeString(offsets[3], object.batchId);
  writer.writeString(offsets[4], object.batchUuid);
  writer.writeDateTime(offsets[5], object.birthDate);
  writer.writeLong(offsets[6], object.bloodPercentage);
  writer.writeLong(offsets[7], object.bodyConditionScore);
  writer.writeString(offsets[8], object.brand);
  writer.writeString(offsets[9], object.breed);
  writer.writeString(offsets[10], object.category);
  writer.writeString(offsets[11], object.chronicNotes);
  writer.writeString(offsets[12], object.coatColor);
  writer.writeString(offsets[13], object.contentHash);
  writer.writeDateTime(offsets[14], object.creationDate);
  writer.writeString(offsets[15], object.crossBreed);
  writer.writeString(offsets[16], object.crossBreedType);
  writer.writeString(offsets[17], object.currentPaddockId);
  writer.writeString(offsets[18], object.customName);
  writer.writeDouble(offsets[19], object.dailyGainEstimate);
  writer.writeString(offsets[20], object.damBreed);
  writer.writeString(offsets[21], object.damUuid);
  writer.writeBool(offsets[22], object.dewormed);
  writer.writeString(offsets[23], object.distinguishingMarks);
  writer.writeString(offsets[24], object.earTagColor);
  writer.writeString(offsets[25], object.earTagNumber);
  writer.writeDateTime(offsets[26], object.expectedCalvingDate);
  writer.writeString(offsets[27], object.feedFrequency);
  writer.writeString(offsets[28], object.feedNotes);
  writer.writeString(offsets[29], object.feedSupplements);
  writer.writeString(offsets[30], object.feedType);
  writer.writeDateTime(offsets[31], object.firstServiceDate);
  writer.writeStringList(offsets[32], object.gallery);
  writer.writeString(offsets[33], object.genealogicalRegistry);
  writer.writeLong(offsets[34], object.generation);
  writer.writeBool(offsets[35], object.hasChronicIssues);
  writer.writeBool(offsets[36], object.hasVitamins);
  writer.writeString(offsets[37], object.healthStatus);
  writer.writeString(offsets[38], object.housingType);
  writer.writeString(offsets[39], object.initialLocationId);
  writer.writeDateTime(offsets[40], object.lastMovementDate);
  writer.writeDateTime(offsets[41], object.lastServiceDate);
  writer.writeDateTime(offsets[42], object.lastUpdateDate);
  writer.writeString(offsets[43], object.lifeStage);
  writer.writeString(offsets[44], object.locationNotes);
  writer.writeString(offsets[45], object.notes);
  writer.writeString(offsets[46], object.originNotes);
  writer.writeString(offsets[47], object.originType);
  writer.writeString(offsets[48], object.owner);
  writer.writeString(offsets[49], object.productionPurpose);
  writer.writeString(offsets[50], object.productionStage);
  writer.writeString(offsets[51], object.productionSystem);
  writer.writeString(offsets[52], object.profilePhoto);
  writer.writeString(offsets[53], object.provenance);
  writer.writeDouble(offsets[54], object.purchasePrice);
  writer.writeString(offsets[55], object.remoteId);
  writer.writeString(offsets[56], object.reproductiveStatus);
  writer.writeBool(offsets[57], object.requiresAttention);
  writer.writeString(offsets[58], object.rfidTag);
  writer.writeString(offsets[59], object.riskLevel);
  writer.writeString(offsets[60], object.sex);
  writer.writeString(offsets[61], object.shadingAvailability);
  writer.writeString(offsets[62], object.sireBreed);
  writer.writeString(offsets[63], object.sireUuid);
  writer.writeString(offsets[64], object.species);
  writer.writeString(offsets[65], object.status);
  writer.writeDateTime(offsets[66], object.syncDate);
  writer.writeBool(offsets[67], object.synced);
  writer.writeBool(offsets[68], object.underObservation);
  writer.writeString(offsets[69], object.uuid);
  writer.writeBool(offsets[70], object.vaccinated);
  writer.writeString(offsets[71], object.visualId);
  writer.writeDouble(offsets[72], object.weight);
}

IsarAnimal _isarAnimalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarAnimal();
  object.ageMonths = reader.readLong(offsets[0]);
  object.animalWaterSource = reader.readStringOrNull(offsets[1]);
  object.approximateDensity = reader.readStringOrNull(offsets[2]);
  object.batchId = reader.readStringOrNull(offsets[3]);
  object.batchUuid = reader.readStringOrNull(offsets[4]);
  object.birthDate = reader.readDateTime(offsets[5]);
  object.bloodPercentage = reader.readLongOrNull(offsets[6]);
  object.bodyConditionScore = reader.readLongOrNull(offsets[7]);
  object.brand = reader.readStringOrNull(offsets[8]);
  object.breed = reader.readString(offsets[9]);
  object.category = reader.readString(offsets[10]);
  object.chronicNotes = reader.readStringOrNull(offsets[11]);
  object.coatColor = reader.readStringOrNull(offsets[12]);
  object.contentHash = reader.readStringOrNull(offsets[13]);
  object.creationDate = reader.readDateTime(offsets[14]);
  object.crossBreed = reader.readStringOrNull(offsets[15]);
  object.crossBreedType = reader.readStringOrNull(offsets[16]);
  object.currentPaddockId = reader.readStringOrNull(offsets[17]);
  object.customName = reader.readStringOrNull(offsets[18]);
  object.dailyGainEstimate = reader.readDoubleOrNull(offsets[19]);
  object.damBreed = reader.readStringOrNull(offsets[20]);
  object.damUuid = reader.readStringOrNull(offsets[21]);
  object.dewormed = reader.readBool(offsets[22]);
  object.distinguishingMarks = reader.readStringOrNull(offsets[23]);
  object.earTagColor = reader.readStringOrNull(offsets[24]);
  object.earTagNumber = reader.readString(offsets[25]);
  object.expectedCalvingDate = reader.readDateTimeOrNull(offsets[26]);
  object.feedFrequency = reader.readStringOrNull(offsets[27]);
  object.feedNotes = reader.readStringOrNull(offsets[28]);
  object.feedSupplements = reader.readStringOrNull(offsets[29]);
  object.feedType = reader.readStringOrNull(offsets[30]);
  object.firstServiceDate = reader.readDateTimeOrNull(offsets[31]);
  object.gallery = reader.readStringList(offsets[32]) ?? [];
  object.genealogicalRegistry = reader.readStringOrNull(offsets[33]);
  object.generation = reader.readLongOrNull(offsets[34]);
  object.hasChronicIssues = reader.readBool(offsets[35]);
  object.hasVitamins = reader.readBool(offsets[36]);
  object.healthStatus = reader.readString(offsets[37]);
  object.housingType = reader.readStringOrNull(offsets[38]);
  object.id = id;
  object.initialLocationId = reader.readStringOrNull(offsets[39]);
  object.lastMovementDate = reader.readDateTimeOrNull(offsets[40]);
  object.lastServiceDate = reader.readDateTimeOrNull(offsets[41]);
  object.lastUpdateDate = reader.readDateTime(offsets[42]);
  object.lifeStage = reader.readString(offsets[43]);
  object.locationNotes = reader.readStringOrNull(offsets[44]);
  object.notes = reader.readStringOrNull(offsets[45]);
  object.originNotes = reader.readStringOrNull(offsets[46]);
  object.originType = reader.readStringOrNull(offsets[47]);
  object.owner = reader.readStringOrNull(offsets[48]);
  object.productionPurpose = reader.readString(offsets[49]);
  object.productionStage = reader.readString(offsets[50]);
  object.productionSystem = reader.readString(offsets[51]);
  object.profilePhoto = reader.readStringOrNull(offsets[52]);
  object.provenance = reader.readStringOrNull(offsets[53]);
  object.purchasePrice = reader.readDoubleOrNull(offsets[54]);
  object.remoteId = reader.readStringOrNull(offsets[55]);
  object.reproductiveStatus = reader.readString(offsets[56]);
  object.requiresAttention = reader.readBool(offsets[57]);
  object.rfidTag = reader.readStringOrNull(offsets[58]);
  object.riskLevel = reader.readString(offsets[59]);
  object.sex = reader.readString(offsets[60]);
  object.shadingAvailability = reader.readStringOrNull(offsets[61]);
  object.sireBreed = reader.readStringOrNull(offsets[62]);
  object.sireUuid = reader.readStringOrNull(offsets[63]);
  object.species = reader.readString(offsets[64]);
  object.status = reader.readString(offsets[65]);
  object.syncDate = reader.readDateTimeOrNull(offsets[66]);
  object.synced = reader.readBool(offsets[67]);
  object.underObservation = reader.readBool(offsets[68]);
  object.uuid = reader.readString(offsets[69]);
  object.vaccinated = reader.readBool(offsets[70]);
  object.visualId = reader.readStringOrNull(offsets[71]);
  object.weight = reader.readDoubleOrNull(offsets[72]);
  return object;
}

P _isarAnimalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readDoubleOrNull(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readBool(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readString(offset)) as P;
    case 26:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 27:
      return (reader.readStringOrNull(offset)) as P;
    case 28:
      return (reader.readStringOrNull(offset)) as P;
    case 29:
      return (reader.readStringOrNull(offset)) as P;
    case 30:
      return (reader.readStringOrNull(offset)) as P;
    case 31:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 32:
      return (reader.readStringList(offset) ?? []) as P;
    case 33:
      return (reader.readStringOrNull(offset)) as P;
    case 34:
      return (reader.readLongOrNull(offset)) as P;
    case 35:
      return (reader.readBool(offset)) as P;
    case 36:
      return (reader.readBool(offset)) as P;
    case 37:
      return (reader.readString(offset)) as P;
    case 38:
      return (reader.readStringOrNull(offset)) as P;
    case 39:
      return (reader.readStringOrNull(offset)) as P;
    case 40:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 41:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 42:
      return (reader.readDateTime(offset)) as P;
    case 43:
      return (reader.readString(offset)) as P;
    case 44:
      return (reader.readStringOrNull(offset)) as P;
    case 45:
      return (reader.readStringOrNull(offset)) as P;
    case 46:
      return (reader.readStringOrNull(offset)) as P;
    case 47:
      return (reader.readStringOrNull(offset)) as P;
    case 48:
      return (reader.readStringOrNull(offset)) as P;
    case 49:
      return (reader.readString(offset)) as P;
    case 50:
      return (reader.readString(offset)) as P;
    case 51:
      return (reader.readString(offset)) as P;
    case 52:
      return (reader.readStringOrNull(offset)) as P;
    case 53:
      return (reader.readStringOrNull(offset)) as P;
    case 54:
      return (reader.readDoubleOrNull(offset)) as P;
    case 55:
      return (reader.readStringOrNull(offset)) as P;
    case 56:
      return (reader.readString(offset)) as P;
    case 57:
      return (reader.readBool(offset)) as P;
    case 58:
      return (reader.readStringOrNull(offset)) as P;
    case 59:
      return (reader.readString(offset)) as P;
    case 60:
      return (reader.readString(offset)) as P;
    case 61:
      return (reader.readStringOrNull(offset)) as P;
    case 62:
      return (reader.readStringOrNull(offset)) as P;
    case 63:
      return (reader.readStringOrNull(offset)) as P;
    case 64:
      return (reader.readString(offset)) as P;
    case 65:
      return (reader.readString(offset)) as P;
    case 66:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 67:
      return (reader.readBool(offset)) as P;
    case 68:
      return (reader.readBool(offset)) as P;
    case 69:
      return (reader.readString(offset)) as P;
    case 70:
      return (reader.readBool(offset)) as P;
    case 71:
      return (reader.readStringOrNull(offset)) as P;
    case 72:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarAnimalGetId(IsarAnimal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarAnimalGetLinks(IsarAnimal object) {
  return [];
}

void _isarAnimalAttach(IsarCollection<dynamic> col, Id id, IsarAnimal object) {
  object.id = id;
}

extension IsarAnimalByIndex on IsarCollection<IsarAnimal> {
  Future<IsarAnimal?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  IsarAnimal? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<IsarAnimal?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<IsarAnimal?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(IsarAnimal object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(IsarAnimal object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<IsarAnimal> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<IsarAnimal> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension IsarAnimalQueryWhereSort
    on QueryBuilder<IsarAnimal, IsarAnimal, QWhere> {
  QueryBuilder<IsarAnimal, IsarAnimal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarAnimalQueryWhere
    on QueryBuilder<IsarAnimal, IsarAnimal, QWhereClause> {
  QueryBuilder<IsarAnimal, IsarAnimal, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterWhereClause> idBetween(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterWhereClause> uuidEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterWhereClause> uuidNotEqualTo(
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

extension IsarAnimalQueryFilter
    on QueryBuilder<IsarAnimal, IsarAnimal, QFilterCondition> {
  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> ageMonthsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ageMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      ageMonthsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ageMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> ageMonthsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ageMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> ageMonthsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ageMonths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      animalWaterSourceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'animalWaterSource',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      animalWaterSourceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'animalWaterSource',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      animalWaterSourceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animalWaterSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      animalWaterSourceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'animalWaterSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      animalWaterSourceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'animalWaterSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      animalWaterSourceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'animalWaterSource',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      animalWaterSourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'animalWaterSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      animalWaterSourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'animalWaterSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      animalWaterSourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'animalWaterSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      animalWaterSourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'animalWaterSource',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      animalWaterSourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animalWaterSource',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      animalWaterSourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'animalWaterSource',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      approximateDensityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'approximateDensity',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      approximateDensityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'approximateDensity',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      approximateDensityEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approximateDensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      approximateDensityGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'approximateDensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      approximateDensityLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'approximateDensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      approximateDensityBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'approximateDensity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      approximateDensityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'approximateDensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      approximateDensityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'approximateDensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      approximateDensityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'approximateDensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      approximateDensityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'approximateDensity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      approximateDensityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approximateDensity',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      approximateDensityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'approximateDensity',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> batchIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'batchId',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      batchIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'batchId',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> batchIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      batchIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'batchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> batchIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'batchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> batchIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'batchId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> batchIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'batchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> batchIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'batchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> batchIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'batchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> batchIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'batchId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> batchIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batchId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      batchIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'batchId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      batchUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'batchUuid',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      batchUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'batchUuid',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> batchUuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batchUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      batchUuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'batchUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> batchUuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'batchUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> batchUuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'batchUuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      batchUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'batchUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> batchUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'batchUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> batchUuidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'batchUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> batchUuidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'batchUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      batchUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batchUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      batchUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'batchUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> birthDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'birthDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      birthDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'birthDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> birthDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'birthDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> birthDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'birthDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      bloodPercentageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bloodPercentage',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      bloodPercentageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bloodPercentage',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      bloodPercentageEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bloodPercentage',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      bloodPercentageGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bloodPercentage',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      bloodPercentageLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bloodPercentage',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      bloodPercentageBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bloodPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      bodyConditionScoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bodyConditionScore',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      bodyConditionScoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bodyConditionScore',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      bodyConditionScoreEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bodyConditionScore',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      bodyConditionScoreGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bodyConditionScore',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      bodyConditionScoreLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bodyConditionScore',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      bodyConditionScoreBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bodyConditionScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> brandIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'brand',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> brandIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'brand',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> brandEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> brandGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> brandLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> brandBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'brand',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> brandStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> brandEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> brandContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> brandMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'brand',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> brandIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'brand',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      brandIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'brand',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> breedEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'breed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> breedGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'breed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> breedLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'breed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> breedBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'breed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> breedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'breed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> breedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'breed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> breedContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'breed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> breedMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'breed',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> breedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'breed',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      breedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'breed',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> categoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> categoryContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> categoryMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      chronicNotesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'chronicNotes',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      chronicNotesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'chronicNotes',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      chronicNotesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chronicNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      chronicNotesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chronicNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      chronicNotesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chronicNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      chronicNotesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chronicNotes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      chronicNotesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chronicNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      chronicNotesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chronicNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      chronicNotesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chronicNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      chronicNotesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chronicNotes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      chronicNotesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chronicNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      chronicNotesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chronicNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      coatColorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coatColor',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      coatColorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coatColor',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> coatColorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coatColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      coatColorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coatColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> coatColorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coatColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> coatColorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coatColor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      coatColorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'coatColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> coatColorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'coatColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> coatColorContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'coatColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> coatColorMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'coatColor',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      coatColorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coatColor',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      coatColorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'coatColor',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      contentHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contentHash',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      contentHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contentHash',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      contentHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      contentHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contentHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      contentHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentHash',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      contentHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contentHash',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      creationDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      creationDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'creationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      creationDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'creationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      creationDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'creationDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'crossBreed',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'crossBreed',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> crossBreedEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'crossBreed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'crossBreed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'crossBreed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> crossBreedBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'crossBreed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'crossBreed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'crossBreed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'crossBreed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> crossBreedMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'crossBreed',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'crossBreed',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'crossBreed',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'crossBreedType',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'crossBreedType',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'crossBreedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'crossBreedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'crossBreedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'crossBreedType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'crossBreedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'crossBreedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'crossBreedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'crossBreedType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'crossBreedType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      crossBreedTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'crossBreedType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      currentPaddockIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'currentPaddockId',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      currentPaddockIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'currentPaddockId',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      currentPaddockIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentPaddockId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      currentPaddockIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentPaddockId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      currentPaddockIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentPaddockId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      currentPaddockIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentPaddockId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      currentPaddockIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currentPaddockId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      currentPaddockIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currentPaddockId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      currentPaddockIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currentPaddockId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      currentPaddockIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currentPaddockId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      currentPaddockIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentPaddockId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      currentPaddockIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currentPaddockId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      customNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'customName',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      customNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'customName',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> customNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      customNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      customNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> customNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      customNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      customNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      customNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> customNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      customNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customName',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      customNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customName',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      dailyGainEstimateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dailyGainEstimate',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      dailyGainEstimateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dailyGainEstimate',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      dailyGainEstimateEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyGainEstimate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      dailyGainEstimateGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyGainEstimate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      dailyGainEstimateLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyGainEstimate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      dailyGainEstimateBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyGainEstimate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> damBreedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'damBreed',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      damBreedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'damBreed',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> damBreedEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'damBreed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      damBreedGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'damBreed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> damBreedLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'damBreed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> damBreedBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'damBreed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      damBreedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'damBreed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> damBreedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'damBreed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> damBreedContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'damBreed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> damBreedMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'damBreed',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      damBreedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'damBreed',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      damBreedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'damBreed',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> damUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'damUuid',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      damUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'damUuid',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> damUuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'damUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      damUuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'damUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> damUuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'damUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> damUuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'damUuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> damUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'damUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> damUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'damUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> damUuidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'damUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> damUuidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'damUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> damUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'damUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      damUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'damUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> dewormedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dewormed',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      distinguishingMarksIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'distinguishingMarks',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      distinguishingMarksIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'distinguishingMarks',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      distinguishingMarksEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'distinguishingMarks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      distinguishingMarksGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'distinguishingMarks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      distinguishingMarksLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'distinguishingMarks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      distinguishingMarksBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'distinguishingMarks',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      distinguishingMarksStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'distinguishingMarks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      distinguishingMarksEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'distinguishingMarks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      distinguishingMarksContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'distinguishingMarks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      distinguishingMarksMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'distinguishingMarks',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      distinguishingMarksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'distinguishingMarks',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      distinguishingMarksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'distinguishingMarks',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagColorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'earTagColor',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagColorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'earTagColor',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagColorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earTagColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagColorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'earTagColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagColorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'earTagColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagColorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'earTagColor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagColorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'earTagColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagColorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'earTagColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagColorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'earTagColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagColorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'earTagColor',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagColorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earTagColor',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagColorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earTagColor',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'earTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'earTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'earTagNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'earTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'earTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'earTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'earTagNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earTagNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      earTagNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earTagNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      expectedCalvingDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expectedCalvingDate',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      expectedCalvingDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expectedCalvingDate',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      expectedCalvingDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedCalvingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      expectedCalvingDateGreaterThan(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      expectedCalvingDateLessThan(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      expectedCalvingDateBetween(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedFrequencyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'feedFrequency',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedFrequencyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'feedFrequency',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedFrequencyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'feedFrequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedFrequencyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'feedFrequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedFrequencyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'feedFrequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedFrequencyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'feedFrequency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedFrequencyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'feedFrequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedFrequencyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'feedFrequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedFrequencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'feedFrequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedFrequencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'feedFrequency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedFrequencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'feedFrequency',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedFrequencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'feedFrequency',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedNotesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'feedNotes',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedNotesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'feedNotes',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> feedNotesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'feedNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedNotesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'feedNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> feedNotesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'feedNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> feedNotesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'feedNotes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedNotesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'feedNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> feedNotesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'feedNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> feedNotesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'feedNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> feedNotesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'feedNotes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedNotesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'feedNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedNotesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'feedNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedSupplementsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'feedSupplements',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedSupplementsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'feedSupplements',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedSupplementsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'feedSupplements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedSupplementsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'feedSupplements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedSupplementsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'feedSupplements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedSupplementsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'feedSupplements',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedSupplementsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'feedSupplements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedSupplementsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'feedSupplements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedSupplementsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'feedSupplements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedSupplementsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'feedSupplements',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedSupplementsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'feedSupplements',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedSupplementsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'feedSupplements',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> feedTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'feedType',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'feedType',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> feedTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'feedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'feedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> feedTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'feedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> feedTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'feedType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'feedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> feedTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'feedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> feedTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'feedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> feedTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'feedType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'feedType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      feedTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'feedType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      firstServiceDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'firstServiceDate',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      firstServiceDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'firstServiceDate',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      firstServiceDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firstServiceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      firstServiceDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'firstServiceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      firstServiceDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'firstServiceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      firstServiceDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'firstServiceDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      galleryElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gallery',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      galleryElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gallery',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      galleryElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gallery',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      galleryElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gallery',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      galleryElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gallery',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      galleryElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gallery',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      galleryElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gallery',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      galleryElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gallery',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      galleryElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gallery',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      galleryElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gallery',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      galleryLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'gallery',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> galleryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'gallery',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      galleryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'gallery',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      galleryLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'gallery',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      galleryLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'gallery',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      galleryLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'gallery',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      genealogicalRegistryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'genealogicalRegistry',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      genealogicalRegistryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'genealogicalRegistry',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      genealogicalRegistryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genealogicalRegistry',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      genealogicalRegistryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'genealogicalRegistry',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      genealogicalRegistryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'genealogicalRegistry',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      genealogicalRegistryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'genealogicalRegistry',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      genealogicalRegistryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'genealogicalRegistry',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      genealogicalRegistryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'genealogicalRegistry',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      genealogicalRegistryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'genealogicalRegistry',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      genealogicalRegistryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'genealogicalRegistry',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      genealogicalRegistryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genealogicalRegistry',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      genealogicalRegistryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'genealogicalRegistry',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      generationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'generation',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      generationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'generation',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> generationEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'generation',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      generationGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'generation',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      generationLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'generation',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> generationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'generation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      hasChronicIssuesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasChronicIssues',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      hasVitaminsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasVitamins',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      healthStatusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'healthStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      healthStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'healthStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      healthStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'healthStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      healthStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'healthStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      healthStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'healthStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      healthStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'healthStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      healthStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'healthStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      healthStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'healthStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      healthStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'healthStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      healthStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'healthStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      housingTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'housingType',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      housingTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'housingType',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      housingTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'housingType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      housingTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'housingType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      housingTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'housingType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      housingTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'housingType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      housingTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'housingType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      housingTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'housingType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      housingTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'housingType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      housingTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'housingType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      housingTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'housingType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      housingTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'housingType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> idBetween(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      initialLocationIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'initialLocationId',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      initialLocationIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'initialLocationId',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      initialLocationIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'initialLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      initialLocationIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'initialLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      initialLocationIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'initialLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      initialLocationIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'initialLocationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      initialLocationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'initialLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      initialLocationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'initialLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      initialLocationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'initialLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      initialLocationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'initialLocationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      initialLocationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'initialLocationId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      initialLocationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'initialLocationId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lastMovementDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastMovementDate',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lastMovementDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastMovementDate',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lastMovementDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMovementDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lastMovementDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMovementDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lastMovementDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMovementDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lastMovementDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMovementDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lastServiceDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastServiceDate',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lastServiceDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastServiceDate',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lastServiceDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastServiceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lastServiceDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastServiceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lastServiceDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastServiceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lastServiceDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastServiceDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lastUpdateDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdateDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lastUpdateDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdateDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lastUpdateDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdateDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lastUpdateDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdateDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> lifeStageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lifeStage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lifeStageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lifeStage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> lifeStageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lifeStage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> lifeStageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lifeStage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lifeStageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lifeStage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> lifeStageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lifeStage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> lifeStageContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lifeStage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> lifeStageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lifeStage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lifeStageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lifeStage',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      lifeStageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lifeStage',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      locationNotesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'locationNotes',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      locationNotesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'locationNotes',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      locationNotesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      locationNotesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locationNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      locationNotesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locationNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      locationNotesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locationNotes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      locationNotesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'locationNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      locationNotesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'locationNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      locationNotesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'locationNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      locationNotesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'locationNotes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      locationNotesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      locationNotesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locationNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> notesEqualTo(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> notesGreaterThan(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> notesLessThan(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> notesBetween(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> notesStartsWith(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> notesEndsWith(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originNotesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'originNotes',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originNotesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'originNotes',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originNotesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originNotesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originNotesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originNotesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originNotes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originNotesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'originNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originNotesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'originNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originNotesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originNotesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originNotes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originNotesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originNotesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'originType',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'originType',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> originTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> originTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'originType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'originType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> originTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      originTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> ownerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'owner',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> ownerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'owner',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> ownerEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'owner',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> ownerGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'owner',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> ownerLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'owner',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> ownerBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'owner',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> ownerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'owner',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> ownerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'owner',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> ownerContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'owner',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> ownerMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'owner',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> ownerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'owner',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      ownerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'owner',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionPurposeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productionPurpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionPurposeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productionPurpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionPurposeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productionPurpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionPurposeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productionPurpose',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionPurposeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productionPurpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionPurposeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productionPurpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionPurposeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productionPurpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionPurposeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productionPurpose',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionPurposeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productionPurpose',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionPurposeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productionPurpose',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionStageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productionStage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionStageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productionStage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionStageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productionStage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionStageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productionStage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionStageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productionStage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionStageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productionStage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionStageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productionStage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionStageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productionStage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionStageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productionStage',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionStageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productionStage',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionSystemEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productionSystem',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionSystemGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productionSystem',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionSystemLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productionSystem',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionSystemBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productionSystem',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionSystemStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productionSystem',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionSystemEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productionSystem',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionSystemContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productionSystem',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionSystemMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productionSystem',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionSystemIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productionSystem',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      productionSystemIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productionSystem',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      profilePhotoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profilePhoto',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      profilePhotoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profilePhoto',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      profilePhotoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profilePhoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      profilePhotoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'profilePhoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      profilePhotoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'profilePhoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      profilePhotoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'profilePhoto',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      profilePhotoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'profilePhoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      profilePhotoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'profilePhoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      profilePhotoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'profilePhoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      profilePhotoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'profilePhoto',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      profilePhotoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profilePhoto',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      profilePhotoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'profilePhoto',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      provenanceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'provenance',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      provenanceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'provenance',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> provenanceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'provenance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      provenanceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'provenance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      provenanceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'provenance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> provenanceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'provenance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      provenanceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'provenance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      provenanceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'provenance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      provenanceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'provenance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> provenanceMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'provenance',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      provenanceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'provenance',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      provenanceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'provenance',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      purchasePriceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'purchasePrice',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      purchasePriceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'purchasePrice',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      purchasePriceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purchasePrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      purchasePriceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'purchasePrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      purchasePriceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'purchasePrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      purchasePriceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'purchasePrice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> remoteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'remoteId',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      remoteIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'remoteId',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> remoteIdEqualTo(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> remoteIdLessThan(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> remoteIdBetween(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> remoteIdEndsWith(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> remoteIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> remoteIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'remoteId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      remoteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      remoteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'remoteId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      reproductiveStatusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reproductiveStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      reproductiveStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reproductiveStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      reproductiveStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reproductiveStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      reproductiveStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reproductiveStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      reproductiveStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reproductiveStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      reproductiveStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reproductiveStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      reproductiveStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reproductiveStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      reproductiveStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reproductiveStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      reproductiveStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reproductiveStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      reproductiveStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reproductiveStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      requiresAttentionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requiresAttention',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> rfidTagIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rfidTag',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      rfidTagIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rfidTag',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> rfidTagEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rfidTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      rfidTagGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rfidTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> rfidTagLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rfidTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> rfidTagBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rfidTag',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> rfidTagStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rfidTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> rfidTagEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rfidTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> rfidTagContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rfidTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> rfidTagMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rfidTag',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> rfidTagIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rfidTag',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      rfidTagIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rfidTag',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> riskLevelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'riskLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      riskLevelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'riskLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> riskLevelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'riskLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> riskLevelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'riskLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      riskLevelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'riskLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> riskLevelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'riskLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> riskLevelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'riskLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> riskLevelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'riskLevel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      riskLevelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'riskLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      riskLevelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'riskLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sexEqualTo(
    String value, {
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sexGreaterThan(
    String value, {
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sexLessThan(
    String value, {
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sexBetween(
    String lower,
    String upper, {
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sexStartsWith(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sexEndsWith(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sexContains(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sexMatches(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sex',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sex',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      shadingAvailabilityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'shadingAvailability',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      shadingAvailabilityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'shadingAvailability',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      shadingAvailabilityEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shadingAvailability',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      shadingAvailabilityGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shadingAvailability',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      shadingAvailabilityLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shadingAvailability',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      shadingAvailabilityBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shadingAvailability',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      shadingAvailabilityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'shadingAvailability',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      shadingAvailabilityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'shadingAvailability',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      shadingAvailabilityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'shadingAvailability',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      shadingAvailabilityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'shadingAvailability',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      shadingAvailabilityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shadingAvailability',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      shadingAvailabilityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'shadingAvailability',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      sireBreedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sireBreed',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      sireBreedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sireBreed',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sireBreedEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sireBreed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      sireBreedGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sireBreed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sireBreedLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sireBreed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sireBreedBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sireBreed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      sireBreedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sireBreed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sireBreedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sireBreed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sireBreedContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sireBreed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sireBreedMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sireBreed',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      sireBreedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sireBreed',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      sireBreedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sireBreed',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sireUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sireUuid',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      sireUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sireUuid',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sireUuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sireUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      sireUuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sireUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sireUuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sireUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sireUuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sireUuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      sireUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sireUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sireUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sireUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sireUuidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sireUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> sireUuidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sireUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      sireUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sireUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      sireUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sireUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> speciesEqualTo(
    String value, {
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      speciesGreaterThan(
    String value, {
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> speciesLessThan(
    String value, {
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> speciesBetween(
    String lower,
    String upper, {
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> speciesStartsWith(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> speciesEndsWith(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> speciesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'species',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> speciesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'species',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> speciesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'species',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      speciesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'species',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> statusEqualTo(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> statusGreaterThan(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> statusLessThan(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> statusBetween(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> statusStartsWith(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> statusEndsWith(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> statusContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> statusMatches(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> syncDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncDate',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      syncDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncDate',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> syncDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> syncDateLessThan(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> syncDateBetween(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> syncedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'synced',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      underObservationEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'underObservation',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> uuidEqualTo(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> uuidGreaterThan(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> uuidLessThan(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> uuidBetween(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> uuidStartsWith(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> uuidEndsWith(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> uuidContains(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> uuidMatches(
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

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> vaccinatedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vaccinated',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> visualIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'visualId',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      visualIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'visualId',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> visualIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visualId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      visualIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'visualId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> visualIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'visualId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> visualIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'visualId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      visualIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'visualId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> visualIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'visualId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> visualIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'visualId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> visualIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'visualId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      visualIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visualId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      visualIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'visualId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> weightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weight',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition>
      weightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weight',
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> weightEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> weightGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> weightLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterFilterCondition> weightBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension IsarAnimalQueryObject
    on QueryBuilder<IsarAnimal, IsarAnimal, QFilterCondition> {}

extension IsarAnimalQueryLinks
    on QueryBuilder<IsarAnimal, IsarAnimal, QFilterCondition> {}

extension IsarAnimalQuerySortBy
    on QueryBuilder<IsarAnimal, IsarAnimal, QSortBy> {
  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByAgeMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ageMonths', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByAgeMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ageMonths', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByAnimalWaterSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalWaterSource', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByAnimalWaterSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalWaterSource', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByApproximateDensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approximateDensity', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByApproximateDensityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approximateDensity', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByBatchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchId', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByBatchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchId', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByBatchUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByBatchUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByBirthDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthDate', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByBirthDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthDate', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByBloodPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodPercentage', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByBloodPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodPercentage', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByBodyConditionScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyConditionScore', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByBodyConditionScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyConditionScore', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByBrand() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByBrandDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByBreed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breed', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByBreedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breed', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByChronicNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chronicNotes', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByChronicNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chronicNotes', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByCoatColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coatColor', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByCoatColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coatColor', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByContentHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByContentHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByCreationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creationDate', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByCreationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creationDate', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByCrossBreed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossBreed', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByCrossBreedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossBreed', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByCrossBreedType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossBreedType', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByCrossBreedTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossBreedType', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByCurrentPaddockId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPaddockId', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByCurrentPaddockIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPaddockId', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByCustomName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customName', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByCustomNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customName', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByDailyGainEstimate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyGainEstimate', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByDailyGainEstimateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyGainEstimate', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByDamBreed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'damBreed', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByDamBreedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'damBreed', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByDamUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'damUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByDamUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'damUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByDewormed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dewormed', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByDewormedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dewormed', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByDistinguishingMarks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distinguishingMarks', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByDistinguishingMarksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distinguishingMarks', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByEarTagColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earTagColor', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByEarTagColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earTagColor', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByEarTagNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earTagNumber', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByEarTagNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earTagNumber', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByExpectedCalvingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedCalvingDate', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByExpectedCalvingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedCalvingDate', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByFeedFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedFrequency', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByFeedFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedFrequency', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByFeedNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedNotes', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByFeedNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedNotes', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByFeedSupplements() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedSupplements', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByFeedSupplementsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedSupplements', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByFeedType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedType', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByFeedTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedType', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByFirstServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstServiceDate', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByFirstServiceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstServiceDate', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByGenealogicalRegistry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genealogicalRegistry', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByGenealogicalRegistryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genealogicalRegistry', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByGeneration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generation', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByGenerationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generation', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByHasChronicIssues() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasChronicIssues', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByHasChronicIssuesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasChronicIssues', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByHasVitamins() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasVitamins', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByHasVitaminsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasVitamins', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByHealthStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthStatus', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByHealthStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthStatus', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByHousingType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'housingType', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByHousingTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'housingType', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByInitialLocationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialLocationId', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByInitialLocationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialLocationId', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByLastMovementDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMovementDate', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByLastMovementDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMovementDate', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByLastServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastServiceDate', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByLastServiceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastServiceDate', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByLastUpdateDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateDate', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByLastUpdateDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateDate', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByLifeStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifeStage', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByLifeStageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifeStage', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByLocationNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationNotes', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByLocationNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationNotes', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByOriginNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originNotes', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByOriginNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originNotes', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByOriginType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originType', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByOriginTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originType', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByOwner() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owner', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByOwnerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owner', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByProductionPurpose() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionPurpose', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByProductionPurposeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionPurpose', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByProductionStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionStage', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByProductionStageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionStage', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByProductionSystem() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionSystem', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByProductionSystemDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionSystem', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByProfilePhoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profilePhoto', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByProfilePhotoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profilePhoto', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByProvenance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provenance', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByProvenanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provenance', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByPurchasePrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasePrice', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByPurchasePriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasePrice', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByReproductiveStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reproductiveStatus', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByReproductiveStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reproductiveStatus', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByRequiresAttention() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiresAttention', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByRequiresAttentionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiresAttention', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByRfidTag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rfidTag', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByRfidTagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rfidTag', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByRiskLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'riskLevel', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByRiskLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'riskLevel', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortBySex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sex', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortBySexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sex', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByShadingAvailability() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shadingAvailability', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByShadingAvailabilityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shadingAvailability', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortBySireBreed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sireBreed', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortBySireBreedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sireBreed', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortBySireUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sireUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortBySireUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sireUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortBySpecies() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'species', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortBySpeciesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'species', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortBySyncDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDate', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortBySyncDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDate', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByUnderObservation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'underObservation', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      sortByUnderObservationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'underObservation', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByVaccinated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaccinated', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByVaccinatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaccinated', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByVisualId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visualId', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByVisualIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visualId', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> sortByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension IsarAnimalQuerySortThenBy
    on QueryBuilder<IsarAnimal, IsarAnimal, QSortThenBy> {
  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByAgeMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ageMonths', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByAgeMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ageMonths', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByAnimalWaterSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalWaterSource', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByAnimalWaterSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalWaterSource', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByApproximateDensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approximateDensity', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByApproximateDensityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approximateDensity', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByBatchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchId', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByBatchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchId', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByBatchUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByBatchUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByBirthDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthDate', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByBirthDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthDate', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByBloodPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodPercentage', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByBloodPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodPercentage', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByBodyConditionScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyConditionScore', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByBodyConditionScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyConditionScore', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByBrand() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByBrandDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByBreed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breed', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByBreedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breed', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByChronicNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chronicNotes', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByChronicNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chronicNotes', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByCoatColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coatColor', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByCoatColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coatColor', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByContentHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByContentHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByCreationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creationDate', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByCreationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creationDate', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByCrossBreed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossBreed', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByCrossBreedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossBreed', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByCrossBreedType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossBreedType', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByCrossBreedTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossBreedType', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByCurrentPaddockId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPaddockId', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByCurrentPaddockIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPaddockId', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByCustomName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customName', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByCustomNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customName', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByDailyGainEstimate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyGainEstimate', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByDailyGainEstimateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyGainEstimate', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByDamBreed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'damBreed', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByDamBreedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'damBreed', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByDamUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'damUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByDamUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'damUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByDewormed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dewormed', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByDewormedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dewormed', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByDistinguishingMarks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distinguishingMarks', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByDistinguishingMarksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distinguishingMarks', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByEarTagColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earTagColor', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByEarTagColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earTagColor', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByEarTagNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earTagNumber', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByEarTagNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earTagNumber', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByExpectedCalvingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedCalvingDate', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByExpectedCalvingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedCalvingDate', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByFeedFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedFrequency', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByFeedFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedFrequency', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByFeedNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedNotes', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByFeedNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedNotes', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByFeedSupplements() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedSupplements', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByFeedSupplementsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedSupplements', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByFeedType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedType', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByFeedTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedType', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByFirstServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstServiceDate', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByFirstServiceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstServiceDate', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByGenealogicalRegistry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genealogicalRegistry', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByGenealogicalRegistryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genealogicalRegistry', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByGeneration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generation', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByGenerationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generation', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByHasChronicIssues() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasChronicIssues', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByHasChronicIssuesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasChronicIssues', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByHasVitamins() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasVitamins', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByHasVitaminsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasVitamins', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByHealthStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthStatus', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByHealthStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthStatus', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByHousingType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'housingType', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByHousingTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'housingType', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByInitialLocationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialLocationId', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByInitialLocationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialLocationId', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByLastMovementDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMovementDate', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByLastMovementDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMovementDate', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByLastServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastServiceDate', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByLastServiceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastServiceDate', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByLastUpdateDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateDate', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByLastUpdateDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateDate', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByLifeStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifeStage', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByLifeStageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifeStage', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByLocationNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationNotes', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByLocationNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationNotes', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByOriginNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originNotes', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByOriginNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originNotes', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByOriginType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originType', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByOriginTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originType', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByOwner() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owner', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByOwnerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'owner', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByProductionPurpose() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionPurpose', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByProductionPurposeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionPurpose', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByProductionStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionStage', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByProductionStageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionStage', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByProductionSystem() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionSystem', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByProductionSystemDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionSystem', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByProfilePhoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profilePhoto', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByProfilePhotoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profilePhoto', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByProvenance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provenance', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByProvenanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provenance', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByPurchasePrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasePrice', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByPurchasePriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasePrice', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByReproductiveStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reproductiveStatus', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByReproductiveStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reproductiveStatus', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByRequiresAttention() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiresAttention', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByRequiresAttentionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiresAttention', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByRfidTag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rfidTag', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByRfidTagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rfidTag', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByRiskLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'riskLevel', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByRiskLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'riskLevel', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenBySex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sex', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenBySexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sex', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByShadingAvailability() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shadingAvailability', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByShadingAvailabilityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shadingAvailability', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenBySireBreed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sireBreed', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenBySireBreedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sireBreed', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenBySireUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sireUuid', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenBySireUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sireUuid', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenBySpecies() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'species', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenBySpeciesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'species', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenBySyncDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDate', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenBySyncDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDate', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByUnderObservation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'underObservation', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy>
      thenByUnderObservationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'underObservation', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByVaccinated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaccinated', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByVaccinatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaccinated', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByVisualId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visualId', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByVisualIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visualId', Sort.desc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QAfterSortBy> thenByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension IsarAnimalQueryWhereDistinct
    on QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> {
  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByAgeMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ageMonths');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByAnimalWaterSource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animalWaterSource',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByApproximateDensity(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'approximateDensity',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByBatchId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'batchId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByBatchUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'batchUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByBirthDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'birthDate');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByBloodPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bloodPercentage');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct>
      distinctByBodyConditionScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bodyConditionScore');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByBrand(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'brand', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByBreed(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'breed', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByChronicNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chronicNotes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByCoatColor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coatColor', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByContentHash(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByCreationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'creationDate');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByCrossBreed(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'crossBreed', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByCrossBreedType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'crossBreedType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByCurrentPaddockId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentPaddockId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByCustomName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct>
      distinctByDailyGainEstimate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyGainEstimate');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByDamBreed(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'damBreed', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByDamUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'damUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByDewormed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dewormed');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByDistinguishingMarks(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'distinguishingMarks',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByEarTagColor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earTagColor', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByEarTagNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earTagNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct>
      distinctByExpectedCalvingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedCalvingDate');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByFeedFrequency(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feedFrequency',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByFeedNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feedNotes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByFeedSupplements(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feedSupplements',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByFeedType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feedType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByFirstServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firstServiceDate');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByGallery() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gallery');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct>
      distinctByGenealogicalRegistry({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'genealogicalRegistry',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByGeneration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'generation');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByHasChronicIssues() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasChronicIssues');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByHasVitamins() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasVitamins');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByHealthStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'healthStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByHousingType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'housingType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByInitialLocationId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'initialLocationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByLastMovementDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMovementDate');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByLastServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastServiceDate');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByLastUpdateDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdateDate');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByLifeStage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lifeStage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByLocationNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationNotes',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByOriginNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originNotes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByOriginType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByOwner(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'owner', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByProductionPurpose(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productionPurpose',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByProductionStage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productionStage',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByProductionSystem(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productionSystem',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByProfilePhoto(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profilePhoto', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByProvenance(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'provenance', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByPurchasePrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purchasePrice');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByRemoteId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByReproductiveStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reproductiveStatus',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct>
      distinctByRequiresAttention() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requiresAttention');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByRfidTag(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rfidTag', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByRiskLevel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'riskLevel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctBySex(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sex', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByShadingAvailability(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shadingAvailability',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctBySireBreed(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sireBreed', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctBySireUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sireUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctBySpecies(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'species', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctBySyncDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncDate');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByUnderObservation() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'underObservation');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByVaccinated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vaccinated');
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByVisualId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'visualId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAnimal, IsarAnimal, QDistinct> distinctByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weight');
    });
  }
}

extension IsarAnimalQueryProperty
    on QueryBuilder<IsarAnimal, IsarAnimal, QQueryProperty> {
  QueryBuilder<IsarAnimal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarAnimal, int, QQueryOperations> ageMonthsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ageMonths');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations>
      animalWaterSourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animalWaterSource');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations>
      approximateDensityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'approximateDensity');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> batchIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'batchId');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> batchUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'batchUuid');
    });
  }

  QueryBuilder<IsarAnimal, DateTime, QQueryOperations> birthDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'birthDate');
    });
  }

  QueryBuilder<IsarAnimal, int?, QQueryOperations> bloodPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bloodPercentage');
    });
  }

  QueryBuilder<IsarAnimal, int?, QQueryOperations>
      bodyConditionScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bodyConditionScore');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> brandProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'brand');
    });
  }

  QueryBuilder<IsarAnimal, String, QQueryOperations> breedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'breed');
    });
  }

  QueryBuilder<IsarAnimal, String, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> chronicNotesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chronicNotes');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> coatColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coatColor');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> contentHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentHash');
    });
  }

  QueryBuilder<IsarAnimal, DateTime, QQueryOperations> creationDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'creationDate');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> crossBreedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'crossBreed');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> crossBreedTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'crossBreedType');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations>
      currentPaddockIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentPaddockId');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> customNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customName');
    });
  }

  QueryBuilder<IsarAnimal, double?, QQueryOperations>
      dailyGainEstimateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyGainEstimate');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> damBreedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'damBreed');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> damUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'damUuid');
    });
  }

  QueryBuilder<IsarAnimal, bool, QQueryOperations> dewormedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dewormed');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations>
      distinguishingMarksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'distinguishingMarks');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> earTagColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earTagColor');
    });
  }

  QueryBuilder<IsarAnimal, String, QQueryOperations> earTagNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earTagNumber');
    });
  }

  QueryBuilder<IsarAnimal, DateTime?, QQueryOperations>
      expectedCalvingDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedCalvingDate');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> feedFrequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feedFrequency');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> feedNotesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feedNotes');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations>
      feedSupplementsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feedSupplements');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> feedTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feedType');
    });
  }

  QueryBuilder<IsarAnimal, DateTime?, QQueryOperations>
      firstServiceDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstServiceDate');
    });
  }

  QueryBuilder<IsarAnimal, List<String>, QQueryOperations> galleryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gallery');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations>
      genealogicalRegistryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'genealogicalRegistry');
    });
  }

  QueryBuilder<IsarAnimal, int?, QQueryOperations> generationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'generation');
    });
  }

  QueryBuilder<IsarAnimal, bool, QQueryOperations> hasChronicIssuesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasChronicIssues');
    });
  }

  QueryBuilder<IsarAnimal, bool, QQueryOperations> hasVitaminsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasVitamins');
    });
  }

  QueryBuilder<IsarAnimal, String, QQueryOperations> healthStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'healthStatus');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> housingTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'housingType');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations>
      initialLocationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'initialLocationId');
    });
  }

  QueryBuilder<IsarAnimal, DateTime?, QQueryOperations>
      lastMovementDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMovementDate');
    });
  }

  QueryBuilder<IsarAnimal, DateTime?, QQueryOperations>
      lastServiceDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastServiceDate');
    });
  }

  QueryBuilder<IsarAnimal, DateTime, QQueryOperations>
      lastUpdateDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdateDate');
    });
  }

  QueryBuilder<IsarAnimal, String, QQueryOperations> lifeStageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lifeStage');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> locationNotesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationNotes');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> originNotesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originNotes');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> originTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originType');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> ownerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'owner');
    });
  }

  QueryBuilder<IsarAnimal, String, QQueryOperations>
      productionPurposeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productionPurpose');
    });
  }

  QueryBuilder<IsarAnimal, String, QQueryOperations> productionStageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productionStage');
    });
  }

  QueryBuilder<IsarAnimal, String, QQueryOperations>
      productionSystemProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productionSystem');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> profilePhotoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profilePhoto');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> provenanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'provenance');
    });
  }

  QueryBuilder<IsarAnimal, double?, QQueryOperations> purchasePriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purchasePrice');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<IsarAnimal, String, QQueryOperations>
      reproductiveStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reproductiveStatus');
    });
  }

  QueryBuilder<IsarAnimal, bool, QQueryOperations> requiresAttentionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requiresAttention');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> rfidTagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rfidTag');
    });
  }

  QueryBuilder<IsarAnimal, String, QQueryOperations> riskLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'riskLevel');
    });
  }

  QueryBuilder<IsarAnimal, String, QQueryOperations> sexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sex');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations>
      shadingAvailabilityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shadingAvailability');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> sireBreedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sireBreed');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> sireUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sireUuid');
    });
  }

  QueryBuilder<IsarAnimal, String, QQueryOperations> speciesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'species');
    });
  }

  QueryBuilder<IsarAnimal, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<IsarAnimal, DateTime?, QQueryOperations> syncDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncDate');
    });
  }

  QueryBuilder<IsarAnimal, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<IsarAnimal, bool, QQueryOperations> underObservationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'underObservation');
    });
  }

  QueryBuilder<IsarAnimal, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }

  QueryBuilder<IsarAnimal, bool, QQueryOperations> vaccinatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vaccinated');
    });
  }

  QueryBuilder<IsarAnimal, String?, QQueryOperations> visualIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'visualId');
    });
  }

  QueryBuilder<IsarAnimal, double?, QQueryOperations> weightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weight');
    });
  }
}
