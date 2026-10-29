import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/experience/care_profile.dart';
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

AnimalEntity _animal({
  required String uuid,
  required Species species,
  required ProductionPurpose purpose,
}) {
  final now = DateTime(2026);
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: '',
    species: species,
    category: Category.other,
    lifeStage: LifeStage.unknown,
    sex: Sex.unknown,
    breed: '',
    birthDate: now,
    ageMonths: -1,
    healthStatus: HealthStatus.good,
    vaccinated: false,
    dewormed: false,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: purpose,
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

void main() {
  test('pet grouping keeps working dogs and companion horses with pets', () {
    final dog = _animal(
      uuid: 'dog',
      species: Species.canine,
      purpose: ProductionPurpose.guard,
    );
    final horse = _animal(
      uuid: 'horse',
      species: Species.equine,
      purpose: ProductionPurpose.companion,
    );
    final workingHorse = _animal(
      uuid: 'working-horse',
      species: Species.equine,
      purpose: ProductionPurpose.work,
    );

    expect(isPetAnimal(dog), isTrue);
    expect(isPetAnimal(horse), isTrue);
    expect(isPetAnimal(workingHorse), isFalse);
    expect(inferCareProfileFromAnimals([dog, workingHorse]), CareProfile.mixed);
    expect(inferCareProfileFromAnimals([horse]), CareProfile.pets);
  });

  test(
    'profile resolution prefers explicit choice, then records, then species',
    () {
      expect(
        resolveCareProfileFromCounts(
          selected: CareProfile.pets,
          pets: 0,
          livestock: 4,
          preferredSpecies: const [Species.cattle],
        ),
        CareProfile.pets,
      );
      expect(
        resolveCareProfileFromCounts(
          selected: null,
          pets: 1,
          livestock: 2,
          preferredSpecies: const [],
        ),
        CareProfile.mixed,
      );
      expect(
        resolveCareProfileFromCounts(
          selected: null,
          pets: 0,
          livestock: 0,
          preferredSpecies: const [Species.canine],
        ),
        CareProfile.pets,
      );
    },
  );
}
