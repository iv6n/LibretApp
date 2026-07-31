/// Basic registration data transferred from quick entry to the full wizard.
library;

import '../enums/production_purpose.dart';
import '../enums/sex.dart';
import '../enums/species.dart';

class AnimalRegistrationSeed {
  const AnimalRegistrationSeed({
    required this.species,
    required this.sex,
    required this.ageMonths,
    this.identification,
    this.name,
    this.breed,
    this.weight,
    this.productionPurpose,
    this.sireUuid,
    this.damUuid,
    this.birthDate,
  });

  final Species species;
  final Sex sex;
  final int ageMonths;
  final String? identification;
  final String? name;
  final String? breed;
  final double? weight;
  final ProductionPurpose? productionPurpose;

  /// Parents, pre-filled when the animal is registered from its dam's calving
  /// event so the pedigree link is created at birth rather than retrofitted.
  final String? sireUuid;
  final String? damUuid;

  /// Known exactly when seeded from a calving; otherwise the wizard derives it
  /// from [ageMonths].
  final DateTime? birthDate;
}
