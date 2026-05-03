import 'dart:math';

import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
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
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';

String _newUuid() {
  final rng = Random.secure();
  String hex(int bytes) => List.generate(
    bytes,
    (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  return '${hex(4)}-${hex(2)}-4${hex(1).substring(1)}${hex(1)}'
      '-${(0x80 | (rng.nextInt(0x40))).toRadixString(16)}${hex(1)}'
      '-${hex(6)}';
}

AnimalEntity _cow(String name, String arete) {
  final now = DateTime.now();
  return AnimalEntity(
    uuid: _newUuid(),
    customName: name,
    earTagNumber: arete,
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: 'Criollo',
    birthDate: DateTime(2022, 4, 1),
    ageMonths: 48,
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
    riskLevel: RiskLevel.none,
    gallery: const [],
    synced: false,
    creationDate: now,
    lastUpdateDate: now,
  );
}

AnimalEntity _heifer(String name, String arete) {
  final now = DateTime.now();
  return AnimalEntity(
    uuid: _newUuid(),
    customName: name,
    earTagNumber: arete,
    species: Species.cattle,
    category: Category.heifer,
    lifeStage: LifeStage.heifer,
    sex: Sex.female,
    breed: 'Criollo',
    birthDate: DateTime(2024, 10, 1),
    ageMonths: 18,
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
    riskLevel: RiskLevel.none,
    gallery: const [],
    synced: false,
    creationDate: now,
    lastUpdateDate: now,
  );
}

AnimalEntity _bull(String name, String arete) {
  final now = DateTime.now();
  return AnimalEntity(
    uuid: _newUuid(),
    customName: name,
    earTagNumber: arete,
    species: Species.cattle,
    category: Category.bull,
    lifeStage: LifeStage.bull,
    sex: Sex.male,
    breed: 'Criollo',
    birthDate: DateTime(2021, 4, 1),
    ageMonths: 60,
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
    riskLevel: RiskLevel.none,
    gallery: const [],
    synced: false,
    creationDate: now,
    lastUpdateDate: now,
  );
}

List<AnimalEntity> _buildMockAnimals() => [
  // Vacas
  _cow('Gorda', '002659025593'),
  _cow('Cuernitos', '002658450125'),
  _cow('Pelona', '002658459533'),
  _cow('Waka', '002657131503'),
  _cow('Nancy', '002656761475'),
  _cow('Amarilla grande', '002653311842'),
  _cow('Alazana', '002656726687'),
  _cow('Cuernos mochos', '002657293981'),
  _cow('3-chichis', '002654690193'),
  _cow('Cuernos Unidos', '002658459717'),
  // Toro
  _bull('Saso', '002658579527'),
  // Vaquillas
  _heifer('Prieta', '002657494576'),
  _heifer('Wera', '002658324576'),
  _heifer('Prietita', '002657492598'),
  _heifer('Pinta', '002659002259'),
  _heifer('Miguelita', '002654825714'),
  _heifer('Blanquita', '002658976849'),
];

Future<void> seedMockAnimals() async {
  final repo = locator<AnimalRepository>();
  final existing = await repo.getAll();
  if (existing.isNotEmpty) return;

  for (final animal in _buildMockAnimals()) {
    await repo.save(animal);
  }
}
