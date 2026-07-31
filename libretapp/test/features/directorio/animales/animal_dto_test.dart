import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_dto.dart';

AnimalEntity _fullyPopulatedAnimal() {
  // AnimalDto.fromEntity recomputes ageMonths/lifeStage from birthDate via
  // AnimalLifecycleCalculator on every serialize, so birthDate must be
  // exactly 60 calendar months before "now" for the round trip to be
  // self-consistent regardless of which day the test runs on.
  final now = DateTime.now();
  final birthDate = DateTime(now.year - 5, now.month, now.day);

  return AnimalEntity(
    id: 7,
    uuid: 'animal-1',
    earTagNumber: '001',
    customName: 'Lola',
    visualId: 'v-1',
    brand: 'B1',
    rfidTag: 'rfid-1',
    batchUuid: 'lote-1',
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: 'Holstein',
    crossBreed: 'Jersey',
    birthDate: birthDate,
    ageMonths: 60,
    weight: 480.5,
    sireUuid: 'sire-1',
    damUuid: 'dam-1',
    generation: 2,
    healthStatus: HealthStatus.good,
    bodyConditionScore: 4,
    vaccinated: true,
    dewormed: true,
    hasVitamins: true,
    hasChronicIssues: true,
    chronicNotes: 'Cojera leve',
    reproductiveStatus: ReproductiveStatus.pregnant,
    firstServiceDate: DateTime(2023, 1, 1),
    lastServiceDate: DateTime(2024, 1, 1),
    expectedCalvingDate: DateTime(2024, 10, 1),
    productionPurpose: ProductionPurpose.dairy,
    productionStage: ProductionStage.lactating,
    productionSystem: ProductionSystem.intensive,
    feedType: 'Concentrado',
    dailyGainEstimate: 0.8,
    coatColor: 'Negro',
    distinguishingMarks: 'Mancha blanca en frente',
    notes: 'Animal tranquilo',
    originType: OriginType.purchased,
    provenance: 'Rancho vecino',
    crossBreedType: 'F1',
    sireBreed: 'Holstein',
    damBreed: 'Jersey',
    bloodPercentage: 50,
    genealogicalRegistry: 'REG-123',
    originNotes: 'Comprado en subasta',
    housingType: 'Corral',
    shadingAvailability: 'Si',
    animalWaterSource: 'Bebedero automatico',
    approximateDensity: 'Baja',
    locationNotes: 'Cerca del establo',
    feedFrequency: '2 veces al dia',
    feedSupplements: 'Sal mineral',
    feedNotes: 'Buen apetito',
    earTagColor: 'Amarillo',
    currentLocationId: 'loc-1',
    initialLocationId: 'loc-0',
    lastMovementDate: DateTime(2024, 6, 1),
    underObservation: true,
    requiresAttention: true,
    riskLevel: RiskLevel.medium,
    profilePhoto: 'photo.jpg',
    gallery: const ['g1.jpg', 'g2.jpg'],
    owner: 'Juan Perez',
    purchasePrice: 15000.0,
    status: AnimalStatus.sold,
    synced: true,
    remoteId: 'remote-1',
    syncDate: DateTime(2024, 6, 2),
    contentHash: 'hash-1',
    creationDate: DateTime(2020, 1, 2),
    lastUpdateDate: DateTime(2024, 6, 2),
  );
}

void main() {
  group('AnimalDto backup/restore round trip', () {
    test('preserves every field of a fully populated animal', () {
      final original = _fullyPopulatedAnimal();

      final restored = AnimalDto.fromJson(
        AnimalDto.fromEntity(original).toJson(),
      ).toEntity();

      expect(restored, equals(original));
    });

    test('preserves status of a sold animal specifically', () {
      final soldAnimal = _fullyPopulatedAnimal().copyWith(
        status: AnimalStatus.sold,
      );

      final restored = AnimalDto.fromJson(
        AnimalDto.fromEntity(soldAnimal).toJson(),
      ).toEntity();

      expect(restored.status, AnimalStatus.sold);
    });

    test('preserves batchUuid (lote assignment)', () {
      final animal = _fullyPopulatedAnimal().copyWith(batchUuid: 'lote-42');

      final restored = AnimalDto.fromJson(
        AnimalDto.fromEntity(animal).toJson(),
      ).toEntity();

      expect(restored.batchUuid, 'lote-42');
    });

    test('defaults status to active when reading legacy JSON without it', () {
      final json = AnimalDto.fromEntity(_fullyPopulatedAnimal()).toJson()
        ..remove('status');

      final restored = AnimalDto.fromJson(json).toEntity();

      expect(restored.status, AnimalStatus.active);
    });

    test(
      'round-trips every production purpose including adaptive additions',
      () {
        for (final purpose in ProductionPurpose.values) {
          final animal = _fullyPopulatedAnimal().copyWith(
            productionPurpose: purpose,
          );

          final restored = AnimalDto.fromJson(
            AnimalDto.fromEntity(animal).toJson(),
          ).toEntity();

          expect(restored.productionPurpose, purpose, reason: purpose.name);
        }
      },
    );
  });
}
