import 'package:isar/isar.dart';
import 'package:libretapp/features/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/animales/domain/enums/animal_status.dart';
import 'package:libretapp/features/animales/domain/enums/category.dart';
import 'package:libretapp/features/animales/domain/enums/health_status.dart';
import 'package:libretapp/features/animales/domain/enums/life_stage.dart';
import 'package:libretapp/features/animales/domain/enums/production_purpose.dart';
import 'package:libretapp/features/animales/domain/enums/reproductive_status.dart';
import 'package:libretapp/features/animales/domain/enums/risk_level.dart';
import 'package:libretapp/features/animales/domain/enums/sex.dart';
import 'package:libretapp/features/animales/domain/enums/species.dart';

part 'isar_animal.g.dart';

/// Modelo de persistencia Isar para animales.
@collection
class IsarAnimal {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String earTagNumber;
  String? customName;
  String? visualId;
  String? brand;
  String? rfidTag;
  String? batchId;

  late String species;
  late String category;
  late String lifeStage;
  late String sex;
  late String breed;
  late DateTime birthDate;
  late int ageMonths;
  double? weight;
  String? sireUuid;
  String? damUuid;
  int? generation;

  late String healthStatus;
  int? bodyConditionScore;
  late bool vaccinated;
  late bool dewormed;
  late bool hasVitamins;
  late bool hasChronicIssues;
  String? chronicNotes;

  late String reproductiveStatus;
  DateTime? firstServiceDate;
  DateTime? lastServiceDate;
  DateTime? expectedCalvingDate;

  late String productionPurpose;
  String? feedType;
  double? dailyGainEstimate;

  String? currentPaddockId;
  String? initialLocationId;
  DateTime? lastMovementDate;

  late bool underObservation;
  late bool requiresAttention;
  late String riskLevel;

  String? profilePhoto;
  List<String> gallery = [];
  String? owner;
  double? purchasePrice;
  late String status;

  late bool synced;
  String? remoteId;
  DateTime? syncDate;
  String? contentHash;

  late DateTime creationDate;
  late DateTime lastUpdateDate;
}

extension IsarAnimalMapper on IsarAnimal {
  AnimalEntity toEntity() {
    return AnimalEntity(
      id: id.isarId,
      uuid: uuid,
      earTagNumber: earTagNumber,
      customName: customName,
      visualId: visualId,
      brand: brand,
      rfidTag: rfidTag,
      batchId: batchId,
      species: _enumByName(Species.values, species),
      category: _enumByName(Category.values, category),
      lifeStage: _enumByName(LifeStage.values, lifeStage),
      sex: _enumByName(Sex.values, sex),
      breed: breed,
      birthDate: birthDate,
      ageMonths: ageMonths,
      weight: weight,
      sireUuid: sireUuid,
      damUuid: damUuid,
      generation: generation,
      healthStatus: _enumByName(HealthStatus.values, healthStatus),
      bodyConditionScore: bodyConditionScore,
      vaccinated: vaccinated,
      dewormed: dewormed,
      hasVitamins: hasVitamins,
      hasChronicIssues: hasChronicIssues,
      chronicNotes: chronicNotes,
      reproductiveStatus: _enumByName(
        ReproductiveStatus.values,
        reproductiveStatus,
      ),
      firstServiceDate: firstServiceDate,
      lastServiceDate: lastServiceDate,
      expectedCalvingDate: expectedCalvingDate,
      productionPurpose: _enumByName(
        ProductionPurpose.values,
        productionPurpose,
      ),
      feedType: feedType,
      dailyGainEstimate: dailyGainEstimate,
      currentPaddockId: currentPaddockId,
      initialLocationId: initialLocationId,
      lastMovementDate: lastMovementDate,
      underObservation: underObservation,
      requiresAttention: requiresAttention,
      riskLevel: _enumByName(RiskLevel.values, riskLevel),
      profilePhoto: profilePhoto,
      gallery: List.unmodifiable(gallery),
      owner: owner,
      purchasePrice: purchasePrice,
      status: _enumByName(AnimalStatus.values, status),
      synced: synced,
      remoteId: remoteId,
      syncDate: syncDate,
      contentHash: contentHash,
      creationDate: creationDate,
      lastUpdateDate: lastUpdateDate,
    );
  }
}

extension AnimalEntityToIsar on AnimalEntity {
  IsarAnimal toIsar() {
    final model = IsarAnimal()
      ..uuid = uuid
      ..earTagNumber = earTagNumber
      ..customName = customName
      ..visualId = visualId
      ..brand = brand
      ..rfidTag = rfidTag
      ..batchId = batchId
      ..species = species.name
      ..category = category.name
      ..lifeStage = lifeStage.name
      ..sex = sex.name
      ..breed = breed
      ..birthDate = birthDate
      ..ageMonths = ageMonths
      ..weight = weight
      ..sireUuid = sireUuid
      ..damUuid = damUuid
      ..generation = generation
      ..healthStatus = healthStatus.name
      ..bodyConditionScore = bodyConditionScore
      ..vaccinated = vaccinated
      ..dewormed = dewormed
      ..hasVitamins = hasVitamins
      ..hasChronicIssues = hasChronicIssues
      ..chronicNotes = chronicNotes
      ..reproductiveStatus = reproductiveStatus.name
      ..firstServiceDate = firstServiceDate
      ..lastServiceDate = lastServiceDate
      ..expectedCalvingDate = expectedCalvingDate
      ..productionPurpose = productionPurpose.name
      ..feedType = feedType
      ..dailyGainEstimate = dailyGainEstimate
      ..currentPaddockId = currentPaddockId
      ..initialLocationId = initialLocationId
      ..lastMovementDate = lastMovementDate
      ..underObservation = underObservation
      ..requiresAttention = requiresAttention
      ..riskLevel = riskLevel.name
      ..profilePhoto = profilePhoto
      ..gallery = List<String>.from(gallery)
      ..owner = owner
      ..purchasePrice = purchasePrice
      ..status = status.name
      ..synced = synced
      ..remoteId = remoteId
      ..syncDate = syncDate
      ..contentHash = contentHash
      ..creationDate = creationDate
      ..lastUpdateDate = lastUpdateDate;

    if (id != null) {
      model.id = id!;
    }
    return model;
  }
}

T _enumByName<T extends Enum>(List<T> values, String name) =>
    values.byName(name);

extension on Id {
  int? get isarId => this == Isar.autoIncrement ? null : this;
}
