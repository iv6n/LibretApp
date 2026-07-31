/// features \u203a directorio \u203a animales \u203a domain \u203a entities \u203a animal_entity \u2014 Animal domain entity.
library;

import 'package:equatable/equatable.dart';

import '../enums/animal_status.dart';
import '../enums/category.dart';
import '../enums/health_status.dart';
import '../enums/life_stage.dart';
import '../enums/origin_type.dart';
import '../enums/production_purpose.dart';
import '../enums/production_stage.dart';
import '../enums/production_system.dart';
import '../enums/reproductive_status.dart';
import '../enums/risk_level.dart';
import '../enums/sex.dart';
import '../enums/species.dart';

const Object _copyWithUnset = Object();

/// Entidad principal que representa un animal del rebaño.
///
/// Diseñada para soportar múltiples especies: bovino, equino, ovino, y más.
/// Extensible para agregar nuevas especies sin modificar la estructura base.
///
/// **Campos Organizados por Categoría:**
/// - **Identificación**: id, uuid, earTagNumber, customName, visualId, brand, rfidTag, batchUuid
/// - **Biológica**: species, category, lifeStage, sex, breed, crossBreed, generation, sireUuid, damUuid
/// - **Vital**: birthDate, ageMonths, weight, status
/// - **Salud**: healthStatus, bodyConditionScore, vaccinated, dewormed, hasVitamins,
///   hasChronicIssues, chronicNotes, underObservation, requiresAttention, riskLevel
/// - **Reproductiva**: reproductiveStatus, firstServiceDate, lastServiceDate, expectedCalvingDate
/// - **Producción**: productionPurpose, productionStage, productionSystem, feedType, dailyGainEstimate
/// - **Registro**: coatColor, distinguishingMarks, notes, originType, provenance,
///   crossBreedType, sireBreed, damBreed, bloodPercentage, genealogicalRegistry,
///   originNotes, housingType, shadingAvailability, animalWaterSource,
///   approximateDensity, locationNotes, feedFrequency, feedSupplements,
///   feedNotes, earTagColor
/// - **Ubicación**: currentLocationId, initialLocationId, lastMovementDate
/// - **Multimedia**: profilePhoto, gallery
/// - **Propietario**: owner, purchasePrice
/// - **Sincronización**: synced, remoteId, syncDate, contentHash, creationDate, lastUpdateDate
///
/// **Extensibilidad por Especie:**
/// - Bovino (cattle): Todos los campos son relevantes
/// - Equino (equine): Similar a bovino, con adaptaciones en reproductiva
/// - Ovino (sheep): Similar a bovino, con adaptaciones menores
/// - Nuevas especies: Agregar a enum Species y documentar campos relevantes
class AnimalEntity extends Equatable {
  const AnimalEntity({
    this.id,
    required this.uuid,
    required this.earTagNumber,
    this.customName,
    this.visualId,
    this.brand,
    this.rfidTag,
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
  final int? id;
  final String uuid;
  final String earTagNumber;
  final String? customName;
  final String? visualId;
  final String? brand;
  final String? rfidTag;
  final String? batchUuid;
  @Deprecated('Use batchUuid instead. This field is always null.')
  final String? batchId = null;
  final Species species;
  final Category category;
  final LifeStage lifeStage;
  final Sex sex;
  final String breed;
  final String? crossBreed;
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
  final ProductionStage productionStage;
  final ProductionSystem productionSystem;
  final String? feedType;
  final double? dailyGainEstimate;
  final String? coatColor;
  final String? distinguishingMarks;
  final String? notes;
  final OriginType? originType;
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
  final String? currentLocationId;
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

  AnimalEntity copyWith({
    int? id,
    String? uuid,
    String? earTagNumber,
    Object? customName = _copyWithUnset,
    Object? visualId = _copyWithUnset,
    Object? brand = _copyWithUnset,
    Object? rfidTag = _copyWithUnset,
    Object? batchUuid = _copyWithUnset,
    @Deprecated('Use batchUuid instead. This parameter is ignored.')
    String? batchId,
    Species? species,
    Category? category,
    LifeStage? lifeStage,
    Sex? sex,
    String? breed,
    Object? crossBreed = _copyWithUnset,
    DateTime? birthDate,
    int? ageMonths,
    Object? weight = _copyWithUnset,
    Object? sireUuid = _copyWithUnset,
    Object? damUuid = _copyWithUnset,
    Object? generation = _copyWithUnset,
    HealthStatus? healthStatus,
    Object? bodyConditionScore = _copyWithUnset,
    bool? vaccinated,
    bool? dewormed,
    bool? hasVitamins,
    bool? hasChronicIssues,
    Object? chronicNotes = _copyWithUnset,
    ReproductiveStatus? reproductiveStatus,
    Object? firstServiceDate = _copyWithUnset,
    Object? lastServiceDate = _copyWithUnset,
    Object? expectedCalvingDate = _copyWithUnset,
    ProductionPurpose? productionPurpose,
    ProductionStage? productionStage,
    ProductionSystem? productionSystem,
    Object? feedType = _copyWithUnset,
    Object? dailyGainEstimate = _copyWithUnset,
    Object? coatColor = _copyWithUnset,
    Object? distinguishingMarks = _copyWithUnset,
    Object? notes = _copyWithUnset,
    Object? originType = _copyWithUnset,
    Object? provenance = _copyWithUnset,
    Object? crossBreedType = _copyWithUnset,
    Object? sireBreed = _copyWithUnset,
    Object? damBreed = _copyWithUnset,
    Object? bloodPercentage = _copyWithUnset,
    Object? genealogicalRegistry = _copyWithUnset,
    Object? originNotes = _copyWithUnset,
    Object? housingType = _copyWithUnset,
    Object? shadingAvailability = _copyWithUnset,
    Object? animalWaterSource = _copyWithUnset,
    Object? approximateDensity = _copyWithUnset,
    Object? locationNotes = _copyWithUnset,
    Object? feedFrequency = _copyWithUnset,
    Object? feedSupplements = _copyWithUnset,
    Object? feedNotes = _copyWithUnset,
    Object? earTagColor = _copyWithUnset,
    Object? currentLocationId = _copyWithUnset,
    Object? initialLocationId = _copyWithUnset,
    Object? lastMovementDate = _copyWithUnset,
    bool? underObservation,
    bool? requiresAttention,
    RiskLevel? riskLevel,
    Object? profilePhoto = _copyWithUnset,
    List<String>? gallery,
    Object? owner = _copyWithUnset,
    Object? purchasePrice = _copyWithUnset,
    AnimalStatus? status,
    bool? synced,
    Object? remoteId = _copyWithUnset,
    Object? syncDate = _copyWithUnset,
    Object? contentHash = _copyWithUnset,
    DateTime? creationDate,
    DateTime? lastUpdateDate,
  }) {
    T? nullable<T>(Object? value, T? current) {
      return identical(value, _copyWithUnset) ? current : value as T?;
    }

    return AnimalEntity(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      earTagNumber: earTagNumber ?? this.earTagNumber,
      customName: nullable<String>(customName, this.customName),
      visualId: nullable<String>(visualId, this.visualId),
      brand: nullable<String>(brand, this.brand),
      rfidTag: nullable<String>(rfidTag, this.rfidTag),
      batchUuid: nullable<String>(batchUuid, this.batchUuid),
      species: species ?? this.species,
      category: category ?? this.category,
      lifeStage: lifeStage ?? this.lifeStage,
      sex: sex ?? this.sex,
      breed: breed ?? this.breed,
      crossBreed: nullable<String>(crossBreed, this.crossBreed),
      birthDate: birthDate ?? this.birthDate,
      ageMonths: ageMonths ?? this.ageMonths,
      weight: nullable<double>(weight, this.weight),
      sireUuid: nullable<String>(sireUuid, this.sireUuid),
      damUuid: nullable<String>(damUuid, this.damUuid),
      generation: nullable<int>(generation, this.generation),
      healthStatus: healthStatus ?? this.healthStatus,
      bodyConditionScore: nullable<int>(
        bodyConditionScore,
        this.bodyConditionScore,
      ),
      vaccinated: vaccinated ?? this.vaccinated,
      dewormed: dewormed ?? this.dewormed,
      hasVitamins: hasVitamins ?? this.hasVitamins,
      hasChronicIssues: hasChronicIssues ?? this.hasChronicIssues,
      chronicNotes: nullable<String>(chronicNotes, this.chronicNotes),
      reproductiveStatus: reproductiveStatus ?? this.reproductiveStatus,
      firstServiceDate: nullable<DateTime>(
        firstServiceDate,
        this.firstServiceDate,
      ),
      lastServiceDate: nullable<DateTime>(
        lastServiceDate,
        this.lastServiceDate,
      ),
      expectedCalvingDate: nullable<DateTime>(
        expectedCalvingDate,
        this.expectedCalvingDate,
      ),
      productionPurpose: productionPurpose ?? this.productionPurpose,
      productionStage: productionStage ?? this.productionStage,
      productionSystem: productionSystem ?? this.productionSystem,
      feedType: nullable<String>(feedType, this.feedType),
      dailyGainEstimate: nullable<double>(
        dailyGainEstimate,
        this.dailyGainEstimate,
      ),
      coatColor: nullable<String>(coatColor, this.coatColor),
      distinguishingMarks: nullable<String>(
        distinguishingMarks,
        this.distinguishingMarks,
      ),
      notes: nullable<String>(notes, this.notes),
      originType: nullable<OriginType>(originType, this.originType),
      provenance: nullable<String>(provenance, this.provenance),
      crossBreedType: nullable<String>(crossBreedType, this.crossBreedType),
      sireBreed: nullable<String>(sireBreed, this.sireBreed),
      damBreed: nullable<String>(damBreed, this.damBreed),
      bloodPercentage: nullable<int>(bloodPercentage, this.bloodPercentage),
      genealogicalRegistry: nullable<String>(
        genealogicalRegistry,
        this.genealogicalRegistry,
      ),
      originNotes: nullable<String>(originNotes, this.originNotes),
      housingType: nullable<String>(housingType, this.housingType),
      shadingAvailability: nullable<String>(
        shadingAvailability,
        this.shadingAvailability,
      ),
      animalWaterSource: nullable<String>(
        animalWaterSource,
        this.animalWaterSource,
      ),
      approximateDensity: nullable<String>(
        approximateDensity,
        this.approximateDensity,
      ),
      locationNotes: nullable<String>(locationNotes, this.locationNotes),
      feedFrequency: nullable<String>(feedFrequency, this.feedFrequency),
      feedSupplements: nullable<String>(
        feedSupplements,
        this.feedSupplements,
      ),
      feedNotes: nullable<String>(feedNotes, this.feedNotes),
      earTagColor: nullable<String>(earTagColor, this.earTagColor),
      currentLocationId: nullable<String>(
        currentLocationId,
        this.currentLocationId,
      ),
      initialLocationId: nullable<String>(
        initialLocationId,
        this.initialLocationId,
      ),
      lastMovementDate: nullable<DateTime>(
        lastMovementDate,
        this.lastMovementDate,
      ),
      underObservation: underObservation ?? this.underObservation,
      requiresAttention: requiresAttention ?? this.requiresAttention,
      riskLevel: riskLevel ?? this.riskLevel,
      profilePhoto: nullable<String>(profilePhoto, this.profilePhoto),
      gallery: gallery ?? this.gallery,
      owner: nullable<String>(owner, this.owner),
      purchasePrice: nullable<double>(purchasePrice, this.purchasePrice),
      status: status ?? this.status,
      synced: synced ?? this.synced,
      remoteId: nullable<String>(remoteId, this.remoteId),
      syncDate: nullable<DateTime>(syncDate, this.syncDate),
      contentHash: nullable<String>(contentHash, this.contentHash),
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
    batchUuid,
    species,
    category,
    lifeStage,
    sex,
    breed,
    crossBreed,
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
    productionStage,
    productionSystem,
    feedType,
    dailyGainEstimate,
    coatColor,
    distinguishingMarks,
    notes,
    originType,
    provenance,
    crossBreedType,
    sireBreed,
    damBreed,
    bloodPercentage,
    genealogicalRegistry,
    originNotes,
    housingType,
    shadingAvailability,
    animalWaterSource,
    approximateDensity,
    locationNotes,
    feedFrequency,
    feedSupplements,
    feedNotes,
    earTagColor,
    currentLocationId,
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

  // ==================== HEALTH INFORMATION ====================

  /// Resumen de información de salud del animal.
  Map<String, dynamic> get healthSummary => {
    'status': healthStatus.name,
    'vaccinated': vaccinated,
    'dewormed': dewormed,
    'hasVitamins': hasVitamins,
    'hasChronicIssues': hasChronicIssues,
    'chronicNotes': chronicNotes,
    'bodyConditionScore': bodyConditionScore,
    'underObservation': underObservation,
    'requiresAttention': requiresAttention,
    'riskLevel': riskLevel.name,
  };

  /// Verifica si el animal requiere atención inmediata.
  bool get needsImmediateAttention =>
      requiresAttention ||
      underObservation ||
      riskLevel.index > 1; // index > 1 para riesgos alto/crítico

  /// Conteo de problemas de salud detectados.
  int get healthIssueCount {
    int count = 0;
    if (!vaccinated) count++;
    if (!dewormed) count++;
    if (!hasVitamins) count++;
    if (hasChronicIssues) count++;
    if (underObservation) count++;
    return count;
  }

  // ==================== PRODUCTION INFORMATION ====================

  /// Resumen de información de producción del animal.
  Map<String, dynamic> get productionSummary => {
    'purpose': productionPurpose.name,
    'stage': productionStage.name,
    'system': productionSystem.name,
    'feedType': feedType,
    'dailyGainEstimate': dailyGainEstimate,
  };

  /// Verifica si el animal está en etapa productiva activa.
  bool get isInProductiveStage =>
      productionStage != ProductionStage.idle && status == AnimalStatus.active;

  // ==================== REPRODUCTIVE INFORMATION ====================

  /// Resumen de información reproductiva.
  Map<String, dynamic> get reproductiveSummary => {
    'status': reproductiveStatus.name,
    'firstServiceDate': firstServiceDate,
    'lastServiceDate': lastServiceDate,
    'expectedCalvingDate': expectedCalvingDate,
  };

  /// Verifica si el animal está gestante.
  bool get isPregnant => reproductiveStatus == ReproductiveStatus.pregnant;

  /// Verifica si el animal está en lactación.
  bool get isLactating => reproductiveStatus == ReproductiveStatus.lactating;

  // ==================== IDENTIFICATION INFORMATION ====================

  /// Identificador único prioritario del animal (customName > earTagNumber).
  String get primaryIdentifier => customName ?? earTagNumber;

  /// Obtiene todas las formas de identificación disponibles.
  List<String> get identifiers {
    final ids = <String>[uuid];
    if (customName != null && customName!.isNotEmpty) ids.add(customName!);
    if (earTagNumber.isNotEmpty) ids.add(earTagNumber);
    if (visualId != null && visualId!.isNotEmpty) ids.add(visualId!);
    if (brand != null && brand!.isNotEmpty) ids.add(brand!);
    if (rfidTag != null && rfidTag!.isNotEmpty) ids.add(rfidTag!);
    return ids;
  }

  // ==================== LOCATION INFORMATION ====================

  /// Verifica si el animal ha sido movido desde su ubicación inicial.
  bool get hasMoved =>
      currentLocationId != null &&
      currentLocationId != initialLocationId &&
      lastMovementDate != null;

  // ==================== SYNC STATUS ====================

  /// Verifica si el animal necesita sincronización.
  bool get needsSync => !synced;

  /// Información de estado de sincronización.
  Map<String, dynamic> get syncStatus => {
    'synced': synced,
    'remoteId': remoteId,
    'syncDate': syncDate,
    'contentHash': contentHash,
  };

  // ==================== SPECIES-SPECIFIC VALIDATION ====================

  /// Valida que los campos necesarios para la especie están configurados.
  /// Retorna lista de campos faltantes. Lista vacía si todo es válido.
  List<String> validateSpeciesRequirements() {
    final missing = <String>[];

    // Validaciones comunes a todas las especies
    if (breed.isEmpty) missing.add('breed');
    if (weight == null) missing.add('weight');

    // Validaciones específicas por especie
    switch (species) {
      case Species.cattle:
        // Bovinos requieren información de producción completa
        if (productionPurpose == ProductionPurpose.undefined) {
          missing.add('productionPurpose');
        }
        break;
      case Species.equine:
        // Equinos pueden prescindir de algunos campos de producción
        break;
      case Species.sheep:
        // Ovinos requieren atención a reproducción
        if (reproductiveStatus == ReproductiveStatus.unknown) {
          missing.add('reproductiveStatus');
        }
        break;
      default:
        break;
    }

    return missing;
  }

  /// Obtiene una representación legible de la especie.
  String get speciesDisplayName => species.displayName;
}
