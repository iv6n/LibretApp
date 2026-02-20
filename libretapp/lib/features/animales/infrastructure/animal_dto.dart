import 'dart:convert';

import 'package:libretapp/features/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/animales/domain/enums/category.dart';
import 'package:libretapp/features/animales/domain/enums/health_status.dart';
import 'package:libretapp/features/animales/domain/enums/life_stage.dart';
import 'package:libretapp/features/animales/domain/enums/production_purpose.dart';
import 'package:libretapp/features/animales/domain/enums/reproductive_status.dart';
import 'package:libretapp/features/animales/domain/enums/risk_level.dart';
import 'package:libretapp/features/animales/domain/enums/sex.dart';
import 'package:libretapp/features/animales/domain/enums/species.dart';
import 'package:libretapp/features/animales/domain/services/animal_lifecycle_calculator.dart';

class AnimalDto {
  final int? id;
  final String uuid;
  final String earTagNumber;
  final String? visualId;
  final String? brand;
  final String? rfidTag;
  final String? batchId;
  final String species;
  final String category;
  final String lifeStage;
  final String sex;
  final String breed;
  final String birthDate;
  final int ageMonths;
  final String? sireUuid;
  final String? damUuid;
  final int? generation;
  final String healthStatus;
  final int? bodyConditionScore;
  final bool vaccinated;
  final bool dewormed;
  final bool hasVitamins;
  final bool hasChronicIssues;
  final String? chronicNotes;
  final String reproductiveStatus;
  final String? firstServiceDate;
  final String? lastServiceDate;
  final String? expectedCalvingDate;
  final String productionPurpose;
  final String? feedType;
  final double? dailyGainEstimate;
  final String? currentPaddockId;
  final String? lastMovementDate;
  final bool underObservation;
  final bool requiresAttention;
  final String riskLevel;
  final String? profilePhoto;
  final List<String> gallery;
  final bool synced;
  final String? remoteId;
  final String? syncDate;
  final String? contentHash;
  final String creationDate;
  final String lastUpdateDate;

  AnimalDto({
    this.id,
    required this.uuid,
    required this.earTagNumber,
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
    this.lastMovementDate,
    required this.underObservation,
    required this.requiresAttention,
    required this.riskLevel,
    this.profilePhoto,
    required List<String> gallery,
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
      visualId: entity.visualId,
      brand: entity.brand,
      rfidTag: entity.rfidTag,
      batchId: entity.batchId,
      species: entity.species.name,
      category: entity.category.name,
      lifeStage: lifecycle.lifeStage.name,
      sex: entity.sex.name,
      breed: entity.breed,
      birthDate: entity.birthDate.toIso8601String(),
      ageMonths: lifecycle.ageMonths,
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
      feedType: entity.feedType,
      dailyGainEstimate: entity.dailyGainEstimate,
      currentPaddockId: entity.currentPaddockId,
      lastMovementDate: entity.lastMovementDate?.toIso8601String(),
      underObservation: entity.underObservation,
      requiresAttention: entity.requiresAttention,
      riskLevel: entity.riskLevel.name,
      profilePhoto: entity.profilePhoto,
      gallery: entity.gallery,
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
      visualId: json['visualId'] as String?,
      brand: json['brand'] as String?,
      rfidTag: json['rfidTag'] as String?,
      batchId: json['batchId'] as String?,
      species: json['species'] as String,
      category: json['category'] as String,
      lifeStage: json['lifeStage'] as String,
      sex: json['sex'] as String,
      breed: json['breed'] as String,
      birthDate: json['birthDate'] as String,
      ageMonths: json['ageMonths'] as int,
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
      feedType: json['feedType'] as String?,
      dailyGainEstimate: (json['dailyGainEstimate'] as num?)?.toDouble(),
      currentPaddockId: json['currentPaddockId'] as String?,
      lastMovementDate: json['lastMovementDate'] as String?,
      underObservation: json['underObservation'] as bool,
      requiresAttention: json['requiresAttention'] as bool,
      riskLevel: json['riskLevel'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      gallery: _safeGallery(json['gallery']),
      synced: json['synced'] as bool? ?? false,
      remoteId: json['remoteId'] as String?,
      syncDate: json['syncDate'] as String?,
      contentHash: json['contentHash'] as String?,
      creationDate: json['creationDate'] as String,
      lastUpdateDate: json['lastUpdateDate'] as String,
    );
  }

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
      visualId: visualId,
      brand: brand,
      rfidTag: rfidTag,
      batchId: batchId,
      species: speciesEnum,
      category: _enumByName(Category.values, category),
      lifeStage: lifecycle.lifeStage,
      sex: sexEnum,
      breed: breed,
      birthDate: parsedBirthDate,
      ageMonths: lifecycle.ageMonths,
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
      feedType: feedType,
      dailyGainEstimate: dailyGainEstimate,
      currentPaddockId: currentPaddockId,
      lastMovementDate: _parseDate(lastMovementDate),
      underObservation: underObservation,
      requiresAttention: requiresAttention,
      riskLevel: _enumByName(RiskLevel.values, riskLevel),
      profilePhoto: profilePhoto,
      gallery: gallery,
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
      'visualId': visualId,
      'brand': brand,
      'rfidTag': rfidTag,
      'batchId': batchId,
      'species': species,
      'category': category,
      'lifeStage': lifeStage,
      'sex': sex,
      'breed': breed,
      'birthDate': birthDate,
      'ageMonths': ageMonths,
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
      'feedType': feedType,
      'dailyGainEstimate': dailyGainEstimate,
      'currentPaddockId': currentPaddockId,
      'lastMovementDate': lastMovementDate,
      'underObservation': underObservation,
      'requiresAttention': requiresAttention,
      'riskLevel': riskLevel,
      'profilePhoto': profilePhoto,
      'gallery': gallery,
      'synced': synced,
      'remoteId': remoteId,
      'syncDate': syncDate,
      'contentHash': contentHash,
      'creationDate': creationDate,
      'lastUpdateDate': lastUpdateDate,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory AnimalDto.fromJsonString(String jsonString) =>
      AnimalDto.fromJson(jsonDecode(jsonString));

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.parse(value);
  }

  static String? _isoOrNull(DateTime? value) => value?.toIso8601String();

  static T _enumByName<T extends Enum>(List<T> values, String name) =>
      values.byName(name);

  static List<String> _safeGallery(dynamic raw) {
    if (raw is List) {
      return List.unmodifiable(raw.cast<String>());
    }
    return const [];
  }
}
