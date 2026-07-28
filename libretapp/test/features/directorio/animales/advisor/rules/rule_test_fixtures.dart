/// Shared builders for advisor rule tests.
///
/// Every field defaults to a value that keeps rule functions in their
/// "not triggered" branch, so each test only has to override the field(s)
/// relevant to the condition under test.
library;

import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
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

final _referenceDate = DateTime(2024, 6, 1);

AnimalEntity buildAnimal({
  Species species = Species.cattle,
  Category category = Category.cow,
  LifeStage lifeStage = LifeStage.cow,
  Sex sex = Sex.male,
  int ageMonths = 36,
  double? weight = 300,
  String? sireUuid,
  String? damUuid,
  HealthStatus healthStatus = HealthStatus.good,
  int? bodyConditionScore = 4,
  bool vaccinated = true,
  bool dewormed = true,
  bool hasVitamins = true,
  bool hasChronicIssues = false,
  String? chronicNotes,
  ReproductiveStatus reproductiveStatus = ReproductiveStatus.active,
  DateTime? firstServiceDate,
  DateTime? lastServiceDate,
  DateTime? expectedCalvingDate,
  ProductionPurpose productionPurpose = ProductionPurpose.meat,
  ProductionStage productionStage = ProductionStage.growth,
  ProductionSystem productionSystem = ProductionSystem.extensive,
  String? feedType,
  double? dailyGainEstimate,
  String? currentLocationId,
  String? initialLocationId,
  DateTime? lastMovementDate,
  bool underObservation = false,
  bool requiresAttention = false,
  RiskLevel riskLevel = RiskLevel.none,
}) {
  return AnimalEntity(
    uuid: 'animal-under-test',
    earTagNumber: '001',
    species: species,
    category: category,
    lifeStage: lifeStage,
    sex: sex,
    breed: 'Test Breed',
    birthDate: _referenceDate.subtract(Duration(days: ageMonths * 30)),
    ageMonths: ageMonths,
    weight: weight,
    sireUuid: sireUuid,
    damUuid: damUuid,
    healthStatus: healthStatus,
    bodyConditionScore: bodyConditionScore,
    vaccinated: vaccinated,
    dewormed: dewormed,
    hasVitamins: hasVitamins,
    hasChronicIssues: hasChronicIssues,
    chronicNotes: chronicNotes,
    reproductiveStatus: reproductiveStatus,
    firstServiceDate: firstServiceDate,
    lastServiceDate: lastServiceDate,
    expectedCalvingDate: expectedCalvingDate,
    productionPurpose: productionPurpose,
    productionStage: productionStage,
    productionSystem: productionSystem,
    feedType: feedType,
    dailyGainEstimate: dailyGainEstimate,
    currentLocationId: currentLocationId,
    initialLocationId: initialLocationId,
    lastMovementDate: lastMovementDate,
    underObservation: underObservation,
    requiresAttention: requiresAttention,
    riskLevel: riskLevel,
    gallery: const [],
    status: AnimalStatus.active,
    synced: true,
    creationDate: _referenceDate,
    lastUpdateDate: _referenceDate,
  );
}

HealthRecord buildHealthRecord({
  HealthRecordType type = HealthRecordType.checkup,
  DateTime? date,
  String product = 'Producto de prueba',
}) {
  return HealthRecord(date: date ?? _referenceDate, type: type, product: product);
}

MovementRecord buildMovementRecord({
  MovementReason reason = MovementReason.other,
  DateTime? date,
  String toLocation = 'potrero-2',
}) {
  return MovementRecord(
    toLocation: toLocation,
    date: date ?? _referenceDate,
    reason: reason,
  );
}

ReproductionRecord buildReproductionRecord({
  ServiceType serviceType = ServiceType.naturalService,
  DateTime? serviceDate,
  String? maleSireUuid,
  PregnancyCheckResult? pregnancyResult,
}) {
  return ReproductionRecord(
    serviceDate: serviceDate ?? _referenceDate,
    serviceType: serviceType,
    maleSireUuid: maleSireUuid,
    pregnancyResult: pregnancyResult,
  );
}
