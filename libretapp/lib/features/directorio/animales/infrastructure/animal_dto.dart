/// features \u203a directorio \u203a animales \u203a infrastructure \u203a animal_dto \u2014 Data Transfer Object for Animal.
library;

import 'dart:convert';

import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/animal_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/category.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/health_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/life_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_purpose.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/reproductive_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/risk_level.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/sex.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_lifecycle_calculator.dart';

/// DTO para transferencia de datos de animales entre capas.
///
/// Utiliza strings para valores de fecha y enums para permitir serialización
/// eficiente en JSON y facilitar la sincronización remota.
class AnimalDto {
  AnimalDto({
    this.id,
    required this.uuid,
    required this.earTagNumber,
    this.customName,
    this.visualId,
    this.brand,
    this.rfidTag,
    this.batchId,
    this.batchUuid,
    required this.species,
    required this.category,
    required this.lifeStage,
    required this.sex,
    required this.breed,
    this.crossBreed,
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
    required this.productionStage,
    required this.productionSystem,
    this.feedType,
    this.dailyGainEstimate,
    this.coatColor,
    this.distinguishingMarks,
    this.notes,
    this.originType,
    this.provenance,
    this.crossBreedType,
    this.sireBreed,
    this.damBreed,
    this.bloodPercentage,
    this.genealogicalRegistry,
    this.originNotes,
    this.housingType,
    this.shadingAvailability,
    this.animalWaterSource,
    this.approximateDensity,
    this.locationNotes,
    this.feedFrequency,
    this.feedSupplements,
    this.feedNotes,
    this.earTagColor,
    this.currentLocationId,
    this.initialLocationId,
    this.lastMovementDate,
    required this.underObservation,
    required this.requiresAttention,
    required this.riskLevel,
    this.profilePhoto,
    required List<String> gallery,
    this.owner,
    this.purchasePrice,
    this.status = AnimalStatus.active,
    required this.synced,
    this.remoteId,
    this.syncDate,
    this.contentHash,
    required this.creationDate,
    required this.lastUpdateDate,
  }) : gallery = List.unmodifiable(gallery);

  factory AnimalDto.fromEntity(AnimalEntity entity) {
    final lifecycle = AnimalLifecycleCalculator.calculate(
      birthDate: entity.birthDate,
      species: entity.species,
      sex: entity.sex,
      currentLifeStage: entity.lifeStage,
    );

    return AnimalDto(
      id: entity.id,
      uuid: entity.uuid,
      earTagNumber: entity.earTagNumber,
      customName: entity.customName,
      visualId: entity.visualId,
      brand: entity.brand,
      rfidTag: entity.rfidTag,
      batchId: entity.batchId,
      batchUuid: entity.batchUuid,
      species: entity.species.name,
      category: entity.category.name,
      lifeStage: lifecycle.lifeStage.name,
      sex: entity.sex.name,
      breed: entity.breed,
      crossBreed: entity.crossBreed,
      birthDate: entity.birthDate.toIso8601String(),
      ageMonths: lifecycle.ageMonths,
      weight: entity.weight,
      sireUuid: entity.sireUuid,
      damUuid: entity.damUuid,
      generation: entity.generation,
      healthStatus: entity.healthStatus.name,
      bodyConditionScore: entity.bodyConditionScore,
      vaccinated: entity.vaccinated,
      dewormed: entity.dewormed,
      hasVitamins: entity.hasVitamins,
      hasChronicIssues: entity.hasChronicIssues,
      chronicNotes: entity.chronicNotes,
      reproductiveStatus: entity.reproductiveStatus.name,
      firstServiceDate: entity.firstServiceDate?.toIso8601String(),
      lastServiceDate: entity.lastServiceDate?.toIso8601String(),
      expectedCalvingDate: entity.expectedCalvingDate?.toIso8601String(),
      productionPurpose: entity.productionPurpose.name,
      productionStage: entity.productionStage.name,
      productionSystem: entity.productionSystem.name,
      feedType: entity.feedType,
      dailyGainEstimate: entity.dailyGainEstimate,
      coatColor: entity.coatColor,
      distinguishingMarks: entity.distinguishingMarks,
      notes: entity.notes,
      originType: entity.originType,
      provenance: entity.provenance,
      crossBreedType: entity.crossBreedType,
      sireBreed: entity.sireBreed,
      damBreed: entity.damBreed,
      bloodPercentage: entity.bloodPercentage,
      genealogicalRegistry: entity.genealogicalRegistry,
      originNotes: entity.originNotes,
      housingType: entity.housingType,
      shadingAvailability: entity.shadingAvailability,
      animalWaterSource: entity.animalWaterSource,
      approximateDensity: entity.approximateDensity,
      locationNotes: entity.locationNotes,
      feedFrequency: entity.feedFrequency,
      feedSupplements: entity.feedSupplements,
      feedNotes: entity.feedNotes,
      earTagColor: entity.earTagColor,
      currentLocationId: entity.currentLocationId,
      initialLocationId: entity.initialLocationId,
      lastMovementDate: entity.lastMovementDate?.toIso8601String(),
      underObservation: entity.underObservation,
      requiresAttention: entity.requiresAttention,
      riskLevel: entity.riskLevel.name,
      profilePhoto: entity.profilePhoto,
      gallery: entity.gallery,
      owner: entity.owner,
      purchasePrice: entity.purchasePrice,
      status: entity.status,
      synced: entity.synced,
      remoteId: entity.remoteId,
      syncDate: _isoOrNull(entity.syncDate),
      contentHash: entity.contentHash,
      creationDate: entity.creationDate.toIso8601String(),
      lastUpdateDate: entity.lastUpdateDate.toIso8601String(),
    );
  }

  factory AnimalDto.fromJson(Map<String, dynamic> json) {
    return AnimalDto(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      earTagNumber: json['earTagNumber'] as String,
      customName: json['customName'] as String?,
      visualId: json['visualId'] as String?,
      brand: json['brand'] as String?,
      rfidTag: json['rfidTag'] as String?,
      batchId: json['batchId'] as String?,
      batchUuid: json['batchUuid'] as String?,
      species: json['species'] as String,
      category: json['category'] as String,
      lifeStage: json['lifeStage'] as String,
      sex: json['sex'] as String,
      breed: json['breed'] as String,
      crossBreed: json['crossBreed'] as String?,
      birthDate: json['birthDate'] as String,
      ageMonths: json['ageMonths'] as int,
      weight: (json['weight'] as num?)?.toDouble(),
      sireUuid: json['sireUuid'] as String?,
      damUuid: json['damUuid'] as String?,
      generation: json['generation'] as int?,
      healthStatus: json['healthStatus'] as String,
      bodyConditionScore: json['bodyConditionScore'] as int?,
      vaccinated: json['vaccinated'] as bool,
      dewormed: json['dewormed'] as bool,
      hasVitamins: json['hasVitamins'] as bool,
      hasChronicIssues: json['hasChronicIssues'] as bool,
      chronicNotes: json['chronicNotes'] as String?,
      reproductiveStatus: json['reproductiveStatus'] as String,
      firstServiceDate: json['firstServiceDate'] as String?,
      lastServiceDate: json['lastServiceDate'] as String?,
      expectedCalvingDate: json['expectedCalvingDate'] as String?,
      productionPurpose: json['productionPurpose'] as String,
      productionStage: json['productionStage'] as String? ?? 'unknown',
      productionSystem: json['productionSystem'] as String? ?? 'unknown',
      feedType: json['feedType'] as String?,
      dailyGainEstimate: (json['dailyGainEstimate'] as num?)?.toDouble(),
      coatColor: json['coatColor'] as String?,
      distinguishingMarks: json['distinguishingMarks'] as String?,
      notes: json['notes'] as String?,
      originType: json['originType'] as String?,
      provenance: json['provenance'] as String?,
      crossBreedType: json['crossBreedType'] as String?,
      sireBreed: json['sireBreed'] as String?,
      damBreed: json['damBreed'] as String?,
      bloodPercentage: json['bloodPercentage'] as int?,
      genealogicalRegistry: json['genealogicalRegistry'] as String?,
      originNotes: json['originNotes'] as String?,
      housingType: json['housingType'] as String?,
      shadingAvailability: json['shadingAvailability'] as String?,
      animalWaterSource: json['animalWaterSource'] as String?,
      approximateDensity: json['approximateDensity'] as String?,
      locationNotes: json['locationNotes'] as String?,
      feedFrequency: json['feedFrequency'] as String?,
      feedSupplements: json['feedSupplements'] as String?,
      feedNotes: json['feedNotes'] as String?,
      earTagColor: json['earTagColor'] as String?,
      currentLocationId:
          (json['currentPaddockId'] ?? json['currentLocationId']) as String?,
      initialLocationId: json['initialLocationId'] as String?,
      lastMovementDate: json['lastMovementDate'] as String?,
      underObservation: json['underObservation'] as bool,
      requiresAttention: json['requiresAttention'] as bool,
      riskLevel: json['riskLevel'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      gallery: _safeGallery(json['gallery']),
      owner: json['owner'] as String?,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      status: _statusOrDefault(json['status'] as String?),
      synced: json['synced'] as bool? ?? false,
      remoteId: json['remoteId'] as String?,
      syncDate: json['syncDate'] as String?,
      contentHash: json['contentHash'] as String?,
      creationDate: json['creationDate'] as String,
      lastUpdateDate: json['lastUpdateDate'] as String,
    );
  }

  factory AnimalDto.fromJsonString(String jsonString) =>
      AnimalDto.fromJson(jsonDecode(jsonString));
  // ─── IDENTIFICATION ────────────────────────────────────────────────
  final int? id;
  final String uuid;
  final String earTagNumber;
  final String? customName;
  final String? visualId;
  final String? brand;
  final String? rfidTag;
  final String? batchId;
  final String? batchUuid;

  // ─── BIOLOGICAL ────────────────────────────────────────────────────
  final String species;
  final String category;
  final String lifeStage;
  final String sex;
  final String breed;
  final String? crossBreed;
  final String? sireUuid;
  final String? damUuid;
  final int? generation;

  // ─── VITAL ─────────────────────────────────────────────────────────
  final String birthDate;
  final int ageMonths;
  final double? weight;

  // ─── HEALTH ────────────────────────────────────────────────────────
  final String healthStatus;
  final int? bodyConditionScore;
  final bool vaccinated;
  final bool dewormed;
  final bool hasVitamins;
  final bool hasChronicIssues;
  final String? chronicNotes;

  // ─── REPRODUCTIVE ──────────────────────────────────────────────────
  final String reproductiveStatus;
  final String? firstServiceDate;
  final String? lastServiceDate;
  final String? expectedCalvingDate;

  // ─── PRODUCTION ────────────────────────────────────────────────────
  final String productionPurpose;
  final String productionStage;
  final String productionSystem;
  final String? feedType;
  final double? dailyGainEstimate;

  // ─── REGISTRO ──────────────────────────────────────────────────────
  final String? coatColor;
  final String? distinguishingMarks;
  final String? notes;
  final String? originType;
  final String? provenance;
  final String? crossBreedType;
  final String? sireBreed;
  final String? damBreed;
  final int? bloodPercentage;
  final String? genealogicalRegistry;
  final String? originNotes;
  final String? housingType;
  final String? shadingAvailability;
  final String? animalWaterSource;
  final String? approximateDensity;
  final String? locationNotes;
  final String? feedFrequency;
  final String? feedSupplements;
  final String? feedNotes;
  final String? earTagColor;

  // ─── LOCATION ──────────────────────────────────────────────────────
  final String? currentLocationId;
  final String? initialLocationId;
  final String? lastMovementDate;

  // ─── MONITORING ────────────────────────────────────────────────────
  final bool underObservation;
  final bool requiresAttention;
  final String riskLevel;

  // ─── MULTIMEDIA ────────────────────────────────────────────────────
  final String? profilePhoto;
  final List<String> gallery;

  // ─── OWNER ─────────────────────────────────────────────────────────
  final String? owner;
  final double? purchasePrice;
  final AnimalStatus status;

  // ─── SYNCHRONIZATION ───────────────────────────────────────────────
  final bool synced;
  final String? remoteId;
  final String? syncDate;
  final String? contentHash;
  final String creationDate;
  final String lastUpdateDate;

  AnimalEntity toEntity() {
    final parsedBirthDate = DateTime.parse(birthDate);
    final speciesEnum = _enumByName(Species.values, species);
    final sexEnum = _enumByName(Sex.values, sex);
    final fallbackLifeStage = _enumByName(LifeStage.values, lifeStage);
    final lifecycle = AnimalLifecycleCalculator.calculate(
      birthDate: parsedBirthDate,
      species: speciesEnum,
      sex: sexEnum,
      currentLifeStage: fallbackLifeStage,
    );

    return AnimalEntity(
      id: id,
      uuid: uuid,
      earTagNumber: earTagNumber,
      customName: customName,
      visualId: visualId,
      brand: brand,
      rfidTag: rfidTag,
      batchUuid: batchUuid,
      species: speciesEnum,
      category: _enumByName(Category.values, category),
      lifeStage: lifecycle.lifeStage,
      sex: sexEnum,
      breed: breed,
      crossBreed: crossBreed,
      birthDate: parsedBirthDate,
      ageMonths: lifecycle.ageMonths,
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
      firstServiceDate: _parseDate(firstServiceDate),
      lastServiceDate: _parseDate(lastServiceDate),
      expectedCalvingDate: _parseDate(expectedCalvingDate),
      productionPurpose: _enumByName(
        ProductionPurpose.values,
        productionPurpose,
      ),
      productionStage: _enumByName(ProductionStage.values, productionStage),
      productionSystem: _enumByName(ProductionSystem.values, productionSystem),
      feedType: feedType,
      dailyGainEstimate: dailyGainEstimate,
      coatColor: coatColor,
      distinguishingMarks: distinguishingMarks,
      notes: notes,
      originType: originType,
      provenance: provenance,
      crossBreedType: crossBreedType,
      sireBreed: sireBreed,
      damBreed: damBreed,
      bloodPercentage: bloodPercentage,
      genealogicalRegistry: genealogicalRegistry,
      originNotes: originNotes,
      housingType: housingType,
      shadingAvailability: shadingAvailability,
      animalWaterSource: animalWaterSource,
      approximateDensity: approximateDensity,
      locationNotes: locationNotes,
      feedFrequency: feedFrequency,
      feedSupplements: feedSupplements,
      feedNotes: feedNotes,
      earTagColor: earTagColor,
      currentLocationId: currentLocationId,
      initialLocationId: initialLocationId,
      lastMovementDate: _parseDate(lastMovementDate),
      underObservation: underObservation,
      requiresAttention: requiresAttention,
      riskLevel: _enumByName(RiskLevel.values, riskLevel),
      profilePhoto: profilePhoto,
      gallery: gallery,
      owner: owner,
      purchasePrice: purchasePrice,
      status: status,
      synced: synced,
      remoteId: remoteId,
      syncDate: _parseDate(syncDate),
      contentHash: contentHash,
      creationDate: DateTime.parse(creationDate),
      lastUpdateDate: DateTime.parse(lastUpdateDate),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'earTagNumber': earTagNumber,
      'customName': customName,
      'visualId': visualId,
      'brand': brand,
      'rfidTag': rfidTag,
      'batchId': batchId,
      'batchUuid': batchUuid,
      'species': species,
      'category': category,
      'lifeStage': lifeStage,
      'sex': sex,
      'breed': breed,
      'crossBreed': crossBreed,
      'birthDate': birthDate,
      'ageMonths': ageMonths,
      'weight': weight,
      'sireUuid': sireUuid,
      'damUuid': damUuid,
      'generation': generation,
      'healthStatus': healthStatus,
      'bodyConditionScore': bodyConditionScore,
      'vaccinated': vaccinated,
      'dewormed': dewormed,
      'hasVitamins': hasVitamins,
      'hasChronicIssues': hasChronicIssues,
      'chronicNotes': chronicNotes,
      'reproductiveStatus': reproductiveStatus,
      'firstServiceDate': firstServiceDate,
      'lastServiceDate': lastServiceDate,
      'expectedCalvingDate': expectedCalvingDate,
      'productionPurpose': productionPurpose,
      'productionStage': productionStage,
      'productionSystem': productionSystem,
      'feedType': feedType,
      'dailyGainEstimate': dailyGainEstimate,
      'coatColor': coatColor,
      'distinguishingMarks': distinguishingMarks,
      'notes': notes,
      'originType': originType,
      'provenance': provenance,
      'crossBreedType': crossBreedType,
      'sireBreed': sireBreed,
      'damBreed': damBreed,
      'bloodPercentage': bloodPercentage,
      'genealogicalRegistry': genealogicalRegistry,
      'originNotes': originNotes,
      'housingType': housingType,
      'shadingAvailability': shadingAvailability,
      'animalWaterSource': animalWaterSource,
      'approximateDensity': approximateDensity,
      'locationNotes': locationNotes,
      'feedFrequency': feedFrequency,
      'feedSupplements': feedSupplements,
      'feedNotes': feedNotes,
      'earTagColor': earTagColor,
      'currentPaddockId': currentLocationId, // keep old JSON key for compat
      'initialLocationId': initialLocationId,
      'lastMovementDate': lastMovementDate,
      'underObservation': underObservation,
      'requiresAttention': requiresAttention,
      'riskLevel': riskLevel,
      'profilePhoto': profilePhoto,
      'gallery': gallery,
      'owner': owner,
      'purchasePrice': purchasePrice,
      'status': status.name,
      'synced': synced,
      'remoteId': remoteId,
      'syncDate': syncDate,
      'contentHash': contentHash,
      'creationDate': creationDate,
      'lastUpdateDate': lastUpdateDate,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.parse(value);
  }

  static String? _isoOrNull(DateTime? value) => value?.toIso8601String();

  static T _enumByName<T extends Enum>(List<T> values, String name) =>
      values.byName(name);

  static AnimalStatus _statusOrDefault(String? name) {
    if (name == null) return AnimalStatus.active;
    return AnimalStatus.values.asNameMap()[name] ?? AnimalStatus.active;
  }

  static List<String> _safeGallery(dynamic raw) {
    if (raw is List) {
      return List.unmodifiable(raw.cast<String>());
    }
    return const [];
  }
}
