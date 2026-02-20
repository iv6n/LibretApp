import 'dart:convert';

import 'package:libretapp/features/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/animales/domain/enums/category.dart';
import 'package:libretapp/features/animales/domain/enums/health_status.dart';
import 'package:libretapp/features/animales/domain/enums/production_purpose.dart';
import 'package:libretapp/features/animales/domain/enums/reproductive_status.dart';
import 'package:libretapp/features/animales/domain/enums/risk_level.dart';
import 'package:libretapp/features/animales/domain/enums/sex.dart';
import 'package:libretapp/features/animales/domain/enums/species.dart';
import 'package:libretapp/features/animales/domain/services/animal_lifecycle_calculator.dart';
import 'package:libretapp/features/animales/infrastructure/animal_dto.dart';

abstract class AnimalRemoteDataSource {
  Future<RemoteAnimalPayload> fetchAnimals();
}

class RemoteAnimalPayload {
  RemoteAnimalPayload({
    required this.animals,
    required this.hash,
    required this.lastUpdated,
  });

  final List<AnimalDto> animals;
  final String hash;
  final DateTime lastUpdated;
}

class AnimalApiMock implements AnimalRemoteDataSource {
  @override
  Future<RemoteAnimalPayload> fetchAnimals() async {
    // Simulate network latency
    await Future<void>.delayed(const Duration(milliseconds: 220));

    final now = DateTime.now();
    final seeds = _mockEntities(referenceDate: now);
    final dtos = seeds.map(AnimalDto.fromEntity).toList(growable: false);
    final hash = jsonEncode(
      dtos.map((e) => e.toJson()).toList(),
    ).hashCode.toRadixString(16);

    return RemoteAnimalPayload(animals: dtos, hash: hash, lastUpdated: now);
  }

  List<AnimalEntity> _mockEntities({required DateTime referenceDate}) {
    return [
      _buildMockAnimal(
        uuid: 'remote-bessie',
        earTagNumber: 'R-100',
        visualId: 'Bessie R',
        species: Species.cattle,
        sex: Sex.female,
        breed: 'Holstein',
        birthDate: DateTime(
          referenceDate.year - 5,
          referenceDate.month - 2,
          15,
        ),
        category: Category.cow,
        productionPurpose: ProductionPurpose.dairy,
        reproductiveStatus: ReproductiveStatus.lactating,
        paddockId: 'potrero-a',
        riskLevel: RiskLevel.low,
        bodyConditionScore: 6,
        lastMovementDate: referenceDate.subtract(const Duration(days: 2)),
        referenceDate: referenceDate,
      ),
      _buildMockAnimal(
        uuid: 'remote-mateo',
        earTagNumber: 'R-055',
        visualId: 'Mateo R',
        species: Species.cattle,
        sex: Sex.male,
        breed: 'Brahman',
        birthDate: DateTime(
          referenceDate.year - 4,
          referenceDate.month - 1,
          10,
        ),
        category: Category.bull,
        productionPurpose: ProductionPurpose.breeding,
        reproductiveStatus: ReproductiveStatus.active,
        paddockId: 'potrero-c',
        riskLevel: RiskLevel.low,
        dailyGainEstimate: 0.9,
        lastMovementDate: referenceDate.subtract(const Duration(days: 4)),
        referenceDate: referenceDate,
      ),
      _buildMockAnimal(
        uuid: 'remote-nina',
        earTagNumber: 'R-015',
        visualId: 'Nina R',
        species: Species.cattle,
        sex: Sex.female,
        breed: 'Gyr',
        birthDate: DateTime(referenceDate.year, referenceDate.month - 7, 1),
        category: Category.calf,
        productionPurpose: ProductionPurpose.dual,
        reproductiveStatus: ReproductiveStatus.virgin,
        paddockId: 'corral-crias',
        dailyGainEstimate: 0.52,
        riskLevel: RiskLevel.low,
        referenceDate: referenceDate,
      ),
    ];
  }

  AnimalEntity _buildMockAnimal({
    required String uuid,
    required String earTagNumber,
    required String visualId,
    required Species species,
    required Sex sex,
    required String breed,
    required DateTime birthDate,
    required Category category,
    required ProductionPurpose productionPurpose,
    ReproductiveStatus reproductiveStatus = ReproductiveStatus.virgin,
    HealthStatus healthStatus = HealthStatus.good,
    RiskLevel riskLevel = RiskLevel.low,
    bool vaccinated = true,
    bool dewormed = true,
    bool hasVitamins = true,
    bool hasChronicIssues = false,
    String? chronicNotes,
    bool underObservation = false,
    bool requiresAttention = false,
    String? batchId,
    String? paddockId,
    double? dailyGainEstimate,
    int bodyConditionScore = 5,
    String feedType = 'Pasto y concentrado',
    DateTime? lastMovementDate,
    DateTime? expectedCalvingDate,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final lifecycle = AnimalLifecycleCalculator.calculate(
      birthDate: birthDate,
      species: species,
      sex: sex,
      now: now,
    );

    return AnimalEntity(
      id: null,
      uuid: uuid,
      earTagNumber: earTagNumber,
      visualId: visualId,
      brand: null,
      rfidTag: null,
      batchId: batchId ?? 'lote-remote',
      species: species,
      category: category,
      lifeStage: lifecycle.lifeStage,
      sex: sex,
      breed: breed,
      birthDate: birthDate,
      ageMonths: lifecycle.ageMonths,
      sireUuid: null,
      damUuid: null,
      generation: 1,
      healthStatus: healthStatus,
      bodyConditionScore: bodyConditionScore,
      vaccinated: vaccinated,
      dewormed: dewormed,
      hasVitamins: hasVitamins,
      hasChronicIssues: hasChronicIssues,
      chronicNotes: chronicNotes,
      reproductiveStatus: reproductiveStatus,
      firstServiceDate: null,
      lastServiceDate: null,
      expectedCalvingDate: expectedCalvingDate,
      productionPurpose: productionPurpose,
      feedType: feedType,
      dailyGainEstimate: dailyGainEstimate,
      currentPaddockId: paddockId,
      lastMovementDate:
          lastMovementDate ?? now.subtract(const Duration(days: 5)),
      underObservation: underObservation,
      requiresAttention: requiresAttention,
      riskLevel: riskLevel,
      profilePhoto: null,
      gallery: const [],
      synced: true,
      remoteId: uuid,
      syncDate: now,
      contentHash: null,
      creationDate: birthDate,
      lastUpdateDate: now,
    );
  }
}
