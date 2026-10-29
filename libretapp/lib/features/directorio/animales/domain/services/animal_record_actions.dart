/// Operations that can be started from an animal profile.
library;

import '../animal_domain.dart';

enum AnimalRecordAction {
  weight,
  weaning,
  health,
  reproduction,
  production,
  milking,
  commercial,
  movement,
  cost,
}

/// Historical records remain editable; this policy governs new operations.
List<AnimalRecordAction> recordActionsFor(AnimalEntity animal) {
  if (!animal.status.isInActiveHerd) return const [];
  final policy = AnimalRegistrationPolicy.forSpecies(animal.species);
  return [
    AnimalRecordAction.weight,
    if (animal.species == Species.cattle && {Category.calf, Category.weaned}.contains(animal.category)) AnimalRecordAction.weaning,
    AnimalRecordAction.health,
    if (policy.supportsReproduction &&
        animal.sex == Sex.female &&
        animal.reproductiveStatus != ReproductiveStatus.neutered &&
        animal.reproductiveStatus != ReproductiveStatus.retired)
      AnimalRecordAction.reproduction,
    if ({
      ProductionPurpose.meat,
      ProductionPurpose.dairy,
      ProductionPurpose.dual,
      ProductionPurpose.eggs,
      ProductionPurpose.fiber,
    }.contains(animal.productionPurpose))
      AnimalRecordAction.production,
    if ({
          Species.cattle,
          Species.goat,
          Species.sheep,
        }.contains(animal.species) &&
        animal.sex == Sex.female &&
        {
          ProductionPurpose.dairy,
          ProductionPurpose.dual,
        }.contains(animal.productionPurpose) &&
        animal.reproductiveStatus == ReproductiveStatus.lactating)
      AnimalRecordAction.milking,
    AnimalRecordAction.movement,
    AnimalRecordAction.commercial,
    AnimalRecordAction.cost,
  ];
}
