/// features \u203a directorio \u203a animales \u203a infrastructure \u203a isar \u203a isar_animal \u2014 Isar schema for the Animal model.
library;

import 'package:isar/isar.dart';
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

part 'isar_animal.g.dart';

/// Modelo de persistencia Isar para animales.
///
/// Almacena la información completa del animal de forma eficiente en Isar.
/// Los campos están organizados por categoría para mejor mantenibilidad.
///
/// **Campos por Categoría:**
/// - Identificación: uuid, earTagNumber, customName, visualId, brand, rfidTag, batchUuid
/// - Biológica: species, category, lifeStage, sex, breed, generation, sireUuid, damUuid
/// - Vital: birthDate, ageMonths, weight, status
/// - Salud: healthStatus, bodyConditionScore, vaccinated, dewormed, hasVitamins, hasChronicIssues, chronicNotes
/// - Reproductiva: reproductiveStatus, firstServiceDate, lastServiceDate, expectedCalvingDate
/// - Producción: productionPurpose, productionStage, productionSystem, feedType, dailyGainEstimate
/// - Registro: coatColor, distinguishingMarks, notes, originType, provenance,
///   crossBreedType, sireBreed, damBreed, bloodPercentage, genealogicalRegistry,
///   originNotes, housingType, shadingAvailability, animalWaterSource,
///   approximateDensity, locationNotes, feedFrequency, feedSupplements,
///   feedNotes, earTagColor
/// - Ubicación: currentPaddockId, initialLocationId, lastMovementDate
/// - Monitoreo: underObservation, requiresAttention, riskLevel
/// - Multimedia: profilePhoto, gallery
/// - Propietario: owner, purchasePrice
/// - Sincronización: synced, remoteId, syncDate, contentHash, creationDate, lastUpdateDate
@collection
class IsarAnimal {
  Id id = Isar.autoIncrement;

  // ─── IDENTIFICATION ────────────────────────────────────────────────
  @Index(unique: true)
  late String uuid;

  late String earTagNumber;
  String? customName;
  String? visualId;
  String? brand;
  String? rfidTag;
  String? batchUuid;
  @Deprecated('Use batchUuid instead')
  String? batchId; // Always null - kept for backwards compatibility

  // ─── BIOLOGICAL ────────────────────────────────────────────────────
  late String species;
  late String category;
  late String lifeStage;
  late String sex;
  late String breed;
  String? crossBreed;
  String? sireUuid;
  String? damUuid;
  int? generation;

  // ─── VITAL ─────────────────────────────────────────────────────────
  late DateTime birthDate;
  late int ageMonths;
  double? weight;
  late String status;

  // ─── HEALTH ────────────────────────────────────────────────────────
  late String healthStatus;
  int? bodyConditionScore;
  late bool vaccinated;
  late bool dewormed;
  late bool hasVitamins;
  late bool hasChronicIssues;
  String? chronicNotes;

  // ─── REPRODUCTIVE ──────────────────────────────────────────────────
  late String reproductiveStatus;
  DateTime? firstServiceDate;
  DateTime? lastServiceDate;
  DateTime? expectedCalvingDate;

  // ─── PRODUCTION ────────────────────────────────────────────────────
  late String productionPurpose = 'undefined';
  late String productionStage = 'unknown';
  late String productionSystem = 'unknown';
  String? feedType;
  double? dailyGainEstimate;

  // ─── REGISTRATION FLOW ────────────────────────────────────────────
  String? coatColor;
  String? distinguishingMarks;
  String? notes;
  String? originType;
  String? provenance;
  String? crossBreedType;
  String? sireBreed;
  String? damBreed;
  int? bloodPercentage;
  String? genealogicalRegistry;
  String? originNotes;
  String? housingType;
  String? shadingAvailability;
  String? animalWaterSource;
  String? approximateDensity;
  String? locationNotes;
  String? feedFrequency;
  String? feedSupplements;
  String? feedNotes;
  String? earTagColor;

  // ─── LOCATION ──────────────────────────────────────────────────────
  String? currentPaddockId;
  String? initialLocationId;
  DateTime? lastMovementDate;

  // ─── MONITORING ────────────────────────────────────────────────────
  late bool underObservation;
  late bool requiresAttention;
  late String riskLevel;

  // ─── MULTIMEDIA ────────────────────────────────────────────────────
  String? profilePhoto;
  List<String> gallery = [];

  // ─── OWNER ─────────────────────────────────────────────────────────
  String? owner;
  double? purchasePrice;

  // ─── SYNCHRONIZATION ───────────────────────────────────────────────
  late bool synced;
  String? remoteId;
  DateTime? syncDate;
  String? contentHash;
  late DateTime creationDate;
  late DateTime lastUpdateDate;
}

extension IsarAnimalMapper on IsarAnimal {
  /// Convierte el modelo Isar a entidad de dominio.
  ///
  /// Maneja la conversión de campos de string a enums y la deserialización
  /// de datos completos para usar en la lógica de negocio.
  /// Lanza excepción si un enum string no es válido.
  AnimalEntity toEntity() {
    return AnimalEntity(
      id: id.isarId,
      uuid: uuid,
      earTagNumber: earTagNumber,
      customName: customName,
      visualId: visualId,
      brand: brand,
      rfidTag: rfidTag,
      batchUuid: batchUuid,
      // batchId is deprecated and always null
      species: _enumByName(Species.values, species),
      category: _enumByName(Category.values, category),
      lifeStage: _enumByName(LifeStage.values, lifeStage),
      sex: _enumByName(Sex.values, sex),
      breed: breed,
      crossBreed: crossBreed,
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
  /// Convierte la entidad de dominio a modelo Isar para persistencia.
  ///
  /// Maneja la serialización de enums a string y prepara los datos
  /// para almacenamiento eficiente en la base de datos Isar.
  IsarAnimal toIsar() {
    final model = IsarAnimal()
      // ─── IDENTIFICATION ────────────────────────────────────────────
      ..uuid = uuid
      ..earTagNumber = earTagNumber
      ..customName = customName
      ..visualId = visualId
      ..brand = brand
      ..rfidTag = rfidTag
      ..batchUuid = batchUuid
      // ─── BIOLOGICAL ────────────────────────────────────────────────
      ..species = species.name
      ..category = category.name
      ..lifeStage = lifeStage.name
      ..sex = sex.name
      ..breed = breed
      ..crossBreed = crossBreed
      ..sireUuid = sireUuid
      ..damUuid = damUuid
      ..generation = generation
      // ─── VITAL ─────────────────────────────────────────────────────
      ..birthDate = birthDate
      ..ageMonths = ageMonths
      ..weight = weight
      ..status = status.name
      // ─── HEALTH ────────────────────────────────────────────────────
      ..healthStatus = healthStatus.name
      ..bodyConditionScore = bodyConditionScore
      ..vaccinated = vaccinated
      ..dewormed = dewormed
      ..hasVitamins = hasVitamins
      ..hasChronicIssues = hasChronicIssues
      ..chronicNotes = chronicNotes
      // ─── REPRODUCTIVE ──────────────────────────────────────────────
      ..reproductiveStatus = reproductiveStatus.name
      ..firstServiceDate = firstServiceDate
      ..lastServiceDate = lastServiceDate
      ..expectedCalvingDate = expectedCalvingDate
      // ─── PRODUCTION ────────────────────────────────────────────────
      ..productionPurpose = productionPurpose.name
      ..productionStage = productionStage.name
      ..productionSystem = productionSystem.name
      ..feedType = feedType
      ..dailyGainEstimate = dailyGainEstimate
      // ─── REGISTRATION FLOW ────────────────────────────────────────
      ..coatColor = coatColor
      ..distinguishingMarks = distinguishingMarks
      ..notes = notes
      ..originType = originType
      ..provenance = provenance
      ..crossBreedType = crossBreedType
      ..sireBreed = sireBreed
      ..damBreed = damBreed
      ..bloodPercentage = bloodPercentage
      ..genealogicalRegistry = genealogicalRegistry
      ..originNotes = originNotes
      ..housingType = housingType
      ..shadingAvailability = shadingAvailability
      ..animalWaterSource = animalWaterSource
      ..approximateDensity = approximateDensity
      ..locationNotes = locationNotes
      ..feedFrequency = feedFrequency
      ..feedSupplements = feedSupplements
      ..feedNotes = feedNotes
      ..earTagColor = earTagColor
      // ─── LOCATION ──────────────────────────────────────────────────
      ..currentPaddockId = currentPaddockId
      ..initialLocationId = initialLocationId
      ..lastMovementDate = lastMovementDate
      // ─── MONITORING ────────────────────────────────────────────────
      ..underObservation = underObservation
      ..requiresAttention = requiresAttention
      ..riskLevel = riskLevel.name
      // ─── MULTIMEDIA ────────────────────────────────────────────────
      ..profilePhoto = profilePhoto
      ..gallery = List<String>.from(gallery)
      // ─── OWNER ─────────────────────────────────────────────────────
      ..owner = owner
      ..purchasePrice = purchasePrice
      // ─── SYNCHRONIZATION ───────────────────────────────────────────
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

T _enumByName<T extends Enum>(List<T> values, String name) {
  if (name.isEmpty) {
    // Return default based on enum type
    if (T == ProductionStage) {
      return values.firstWhere(
        (e) => e.name == 'unknown',
        orElse: () => values.first,
      );
    } else if (T == ProductionSystem) {
      return values.firstWhere(
        (e) => e.name == 'unknown',
        orElse: () => values.first,
      );
    } else if (T == ProductionPurpose) {
      return values.firstWhere(
        (e) => e.name == 'undefined',
        orElse: () => values.first,
      );
    }
    // For other enums, return first available value
    return values.first;
  }
  return values.byName(name);
}

extension on Id {
  int? get isarId => this == Isar.autoIncrement ? null : this;
}
