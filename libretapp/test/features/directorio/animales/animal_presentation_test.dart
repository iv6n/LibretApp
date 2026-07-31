import 'package:flutter_test/flutter_test.dart';
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
import 'package:libretapp/features/directorio/animales/domain/services/animal_presentation.dart';

void main() {
  group('animal presentation helpers', () {
    test('summarizes known cross breeds with abbreviations', () {
      final animal = _animal(breed: 'Simmental', crossBreed: 'Charolais');

      expect(breedSummary(animal), 'Simmental x Charolais');
      expect(breedSummary(animal, abbreviated: true), 'sim x char');
    });

    test('summarizes a single breed', () {
      final animal = _animal(breed: 'Brahman');

      expect(breedSummary(animal), 'Brahman');
      expect(breedSummary(animal, abbreviated: true), 'Brahman');
    });

    test('normalizes accents and casing', () {
      expect(abbreviateBreed(' CEBU '), 'cebu');
      expect(abbreviateBreed('Cebú'), 'cebu');
      expect(abbreviateBreed('Criolla'), 'crio');
    });

    test('uses first four normalized letters as fallback', () {
      expect(abbreviateBreed('Raza Nueva'), 'raza');
    });

    test('uses a readable ear tag fallback', () {
      final animal = _animal(earTag: '');

      expect(earTagDisplay(animal), 'Arete pendiente');
      expect(primaryAnimalLabel(animal), Species.cattle.displayName);
    });
  });
}

AnimalEntity _animal({
  String earTag = 'TAG-1',
  String breed = 'Criolla',
  String? crossBreed,
}) {
  final now = DateTime(2025, 1, 1);
  return AnimalEntity(
    uuid: 'animal-1',
    earTagNumber: earTag,
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: breed,
    crossBreed: crossBreed,
    birthDate: now.subtract(const Duration(days: 900)),
    ageMonths: 30,
    healthStatus: HealthStatus.good,
    vaccinated: false,
    dewormed: false,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.undefined,
    productionStage: ProductionStage.unknown,
    productionSystem: ProductionSystem.unknown,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.low,
    gallery: const [],
    status: AnimalStatus.active,
    synced: false,
    creationDate: now,
    lastUpdateDate: now,
  );
}
