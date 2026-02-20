import 'package:equatable/equatable.dart';

import '../enums/animal_status.dart';
import '../enums/category.dart';
import '../enums/health_status.dart';
import '../enums/life_stage.dart';
import '../enums/production_purpose.dart';
import '../enums/reproductive_status.dart';
import '../enums/risk_level.dart';
import '../enums/sex.dart';
import '../enums/species.dart';

/// Entidad principal que representa un animal del rebaño.
/// Mantiene el contrato detallado para sincronización y operaciones.
class AnimalEntity extends Equatable {
  final int? id;
  final String uuid;
  final String earTagNumber;
  final String? customName;
  final String? visualId;
  final String? brand;
  final String? rfidTag;
  final String? batchId;
  final Species species;
  final Category category;
  final LifeStage lifeStage;
  final Sex sex;
  final String breed;
  final DateTime birthDate;
  final int ageMonths;
  final double? weight;
  final String? sireUuid;
  final String? damUuid;
  final int? generation;
  final HealthStatus healthStatus;
  final int? bodyConditionScore;
  final bool vaccinated;
  final bool dewormed;
  final bool hasVitamins;
  final bool hasChronicIssues;
  final String? chronicNotes;
  final ReproductiveStatus reproductiveStatus;
  final DateTime? firstServiceDate;
  final DateTime? lastServiceDate;
  final DateTime? expectedCalvingDate;
  final ProductionPurpose productionPurpose;
  final String? feedType;
  final double? dailyGainEstimate;
  final String? currentPaddockId;
  final String? initialLocationId;
  final DateTime? lastMovementDate;
  final bool underObservation;
  final bool requiresAttention;
  final RiskLevel riskLevel;
  final String? profilePhoto;
  final List<String> gallery;
  final String? owner;
  final double? purchasePrice;
  final AnimalStatus status;
  final bool synced;
  final String? remoteId;
  final DateTime? syncDate;
  final String? contentHash;
  final DateTime creationDate;
  final DateTime lastUpdateDate;

  const AnimalEntity({
    this.id,
    required this.uuid,
    required this.earTagNumber,
    this.customName,
    this.visualId,
    this.brand,
    this.rfidTag,
    this.batchId,
    required this.species,
    required this.category,
    required this.lifeStage,
    required this.sex,
    required this.breed,
    required this.birthDate,
    required this.ageMonths,
    this.weight,
    this.sireUuid,
    this.damUuid,
    this.generation,
    required this.healthStatus,
    this.bodyConditionScore,
    required this.vaccinated,
    required this.dewormed,
    required this.hasVitamins,
    required this.hasChronicIssues,
    this.chronicNotes,
    required this.reproductiveStatus,
    this.firstServiceDate,
    this.lastServiceDate,
    this.expectedCalvingDate,
    required this.productionPurpose,
    this.feedType,
    this.dailyGainEstimate,
    this.currentPaddockId,
    this.initialLocationId,
    this.lastMovementDate,
    required this.underObservation,
    required this.requiresAttention,
    required this.riskLevel,
    this.profilePhoto,
    required this.gallery,
    this.owner,
    this.purchasePrice,
    this.status = AnimalStatus.active,
    required this.synced,
    this.remoteId,
    this.syncDate,
    this.contentHash,
    required this.creationDate,
    required this.lastUpdateDate,
  });

  AnimalEntity copyWith({
    int? id,
    String? uuid,
    String? earTagNumber,
    String? customName,
    String? visualId,
    String? brand,
    String? rfidTag,
    String? batchId,
    Species? species,
    Category? category,
    LifeStage? lifeStage,
    Sex? sex,
    String? breed,
    DateTime? birthDate,
    int? ageMonths,
    double? weight,
    String? sireUuid,
    String? damUuid,
    int? generation,
    HealthStatus? healthStatus,
    int? bodyConditionScore,
    bool? vaccinated,
    bool? dewormed,
    bool? hasVitamins,
    bool? hasChronicIssues,
    String? chronicNotes,
    ReproductiveStatus? reproductiveStatus,
    DateTime? firstServiceDate,
    DateTime? lastServiceDate,
    DateTime? expectedCalvingDate,
    ProductionPurpose? productionPurpose,
    String? feedType,
    double? dailyGainEstimate,
    String? currentPaddockId,
    String? initialLocationId,
    DateTime? lastMovementDate,
    bool? underObservation,
    bool? requiresAttention,
    RiskLevel? riskLevel,
    String? profilePhoto,
    List<String>? gallery,
    String? owner,
    double? purchasePrice,
    AnimalStatus? status,
    bool? synced,
    String? remoteId,
    DateTime? syncDate,
    String? contentHash,
    DateTime? creationDate,
    DateTime? lastUpdateDate,
  }) {
    return AnimalEntity(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      earTagNumber: earTagNumber ?? this.earTagNumber,
      customName: customName ?? this.customName,
      visualId: visualId ?? this.visualId,
      brand: brand ?? this.brand,
      rfidTag: rfidTag ?? this.rfidTag,
      batchId: batchId ?? this.batchId,
      species: species ?? this.species,
      category: category ?? this.category,
      lifeStage: lifeStage ?? this.lifeStage,
      sex: sex ?? this.sex,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      ageMonths: ageMonths ?? this.ageMonths,
      weight: weight ?? this.weight,
      sireUuid: sireUuid ?? this.sireUuid,
      damUuid: damUuid ?? this.damUuid,
      generation: generation ?? this.generation,
      healthStatus: healthStatus ?? this.healthStatus,
      bodyConditionScore: bodyConditionScore ?? this.bodyConditionScore,
      vaccinated: vaccinated ?? this.vaccinated,
      dewormed: dewormed ?? this.dewormed,
      hasVitamins: hasVitamins ?? this.hasVitamins,
      hasChronicIssues: hasChronicIssues ?? this.hasChronicIssues,
      chronicNotes: chronicNotes ?? this.chronicNotes,
      reproductiveStatus: reproductiveStatus ?? this.reproductiveStatus,
      firstServiceDate: firstServiceDate ?? this.firstServiceDate,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      expectedCalvingDate: expectedCalvingDate ?? this.expectedCalvingDate,
      productionPurpose: productionPurpose ?? this.productionPurpose,
      feedType: feedType ?? this.feedType,
      dailyGainEstimate: dailyGainEstimate ?? this.dailyGainEstimate,
      currentPaddockId: currentPaddockId ?? this.currentPaddockId,
      initialLocationId: initialLocationId ?? this.initialLocationId,
      lastMovementDate: lastMovementDate ?? this.lastMovementDate,
      underObservation: underObservation ?? this.underObservation,
      requiresAttention: requiresAttention ?? this.requiresAttention,
      riskLevel: riskLevel ?? this.riskLevel,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      gallery: gallery ?? this.gallery,
      owner: owner ?? this.owner,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      status: status ?? this.status,
      synced: synced ?? this.synced,
      remoteId: remoteId ?? this.remoteId,
      syncDate: syncDate ?? this.syncDate,
      contentHash: contentHash ?? this.contentHash,
      creationDate: creationDate ?? this.creationDate,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    uuid,
    earTagNumber,
    customName,
    visualId,
    brand,
    rfidTag,
    batchId,
    species,
    category,
    lifeStage,
    sex,
    breed,
    birthDate,
    ageMonths,
    weight,
    sireUuid,
    damUuid,
    generation,
    healthStatus,
    bodyConditionScore,
    vaccinated,
    dewormed,
    hasVitamins,
    hasChronicIssues,
    chronicNotes,
    reproductiveStatus,
    firstServiceDate,
    lastServiceDate,
    expectedCalvingDate,
    productionPurpose,
    feedType,
    dailyGainEstimate,
    currentPaddockId,
    initialLocationId,
    lastMovementDate,
    underObservation,
    requiresAttention,
    riskLevel,
    profilePhoto,
    gallery,
    owner,
    purchasePrice,
    status,
    synced,
    remoteId,
    syncDate,
    contentHash,
    creationDate,
    lastUpdateDate,
  ];
}
