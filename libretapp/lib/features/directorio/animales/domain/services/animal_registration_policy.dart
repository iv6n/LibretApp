/// Species-aware configuration shared by animal registration experiences.
library;

import '../entities/animal_entity.dart';
import '../enums/production_purpose.dart';
import '../enums/production_system.dart';
import '../enums/species.dart';

enum AnimalIdentificationKind {
  earTag,
  microchipOrPassport,
  legBand,
  microchipOrPlate,
  generic,
}

class AnimalRegistrationPolicy {
  const AnimalRegistrationPolicy({
    required this.species,
    required this.identificationKind,
    required this.identificationLabel,
    required this.identificationHint,
    required this.tracksPendingEarTag,
    required this.purposeOptions,
    required this.productionSystems,
    required this.housingOptions,
    required this.coatLabel,
    required this.supportsEarTagColor,
    required this.supportsBodyConditionScore,
    required this.supportsCastration,
    required this.supportsReproduction,
  });

  factory AnimalRegistrationPolicy.forSpecies(Species species) {
    switch (species) {
      case Species.cattle:
        return AnimalRegistrationPolicy(
          species: species,
          identificationKind: AnimalIdentificationKind.earTag,
          identificationLabel: 'N.º de arete / caravana',
          identificationHint: 'Ej. 1042',
          tracksPendingEarTag: true,
          purposeOptions: const [
            ProductionPurpose.dairy,
            ProductionPurpose.meat,
            ProductionPurpose.dual,
            ProductionPurpose.breeding,
            ProductionPurpose.work,
          ],
          productionSystems: const [
            ProductionSystem.extensive,
            ProductionSystem.intensive,
            ProductionSystem.feedlot,
            ProductionSystem.mixed,
            ProductionSystem.organic,
            ProductionSystem.rotational,
          ],
          housingOptions: const ['Libre en potrero', 'Corral', 'Mixto'],
          coatLabel: 'Color / pelaje',
          supportsEarTagColor: true,
          supportsBodyConditionScore: true,
          supportsCastration: true,
          supportsReproduction: true,
        );
      case Species.equine:
        return AnimalRegistrationPolicy(
          species: species,
          identificationKind: AnimalIdentificationKind.microchipOrPassport,
          identificationLabel: 'Microchip, pasaporte o identificación',
          identificationHint: 'Ej. pasaporte, microchip o registro',
          tracksPendingEarTag: false,
          purposeOptions: const [
            ProductionPurpose.work,
            ProductionPurpose.sport,
            ProductionPurpose.breeding,
            ProductionPurpose.companion,
          ],
          productionSystems: const [
            ProductionSystem.extensive,
            ProductionSystem.intensive,
            ProductionSystem.mixed,
            ProductionSystem.rotational,
          ],
          housingOptions: const ['Potrero', 'Establo', 'Mixto'],
          coatLabel: 'Capa / color',
          supportsEarTagColor: false,
          supportsBodyConditionScore: true,
          supportsCastration: true,
          supportsReproduction: true,
        );
      case Species.sheep:
        return AnimalRegistrationPolicy(
          species: species,
          identificationKind: AnimalIdentificationKind.earTag,
          identificationLabel: 'N.º de arete',
          identificationHint: 'Ej. OV-1042',
          tracksPendingEarTag: true,
          purposeOptions: const [
            ProductionPurpose.meat,
            ProductionPurpose.dairy,
            ProductionPurpose.fiber,
            ProductionPurpose.breeding,
            ProductionPurpose.dual,
          ],
          productionSystems: const [
            ProductionSystem.extensive,
            ProductionSystem.intensive,
            ProductionSystem.mixed,
            ProductionSystem.organic,
            ProductionSystem.rotational,
          ],
          housingOptions: const ['Pastoreo', 'Corral', 'Mixto'],
          coatLabel: 'Color / vellón',
          supportsEarTagColor: true,
          supportsBodyConditionScore: true,
          supportsCastration: true,
          supportsReproduction: true,
        );
      case Species.goat:
        return AnimalRegistrationPolicy(
          species: species,
          identificationKind: AnimalIdentificationKind.earTag,
          identificationLabel: 'N.º de arete',
          identificationHint: 'Ej. CAP-1042',
          tracksPendingEarTag: true,
          purposeOptions: const [
            ProductionPurpose.dairy,
            ProductionPurpose.meat,
            ProductionPurpose.fiber,
            ProductionPurpose.breeding,
            ProductionPurpose.dual,
          ],
          productionSystems: const [
            ProductionSystem.extensive,
            ProductionSystem.intensive,
            ProductionSystem.mixed,
            ProductionSystem.organic,
            ProductionSystem.rotational,
          ],
          housingOptions: const ['Pastoreo', 'Corral', 'Mixto'],
          coatLabel: 'Color / pelaje',
          supportsEarTagColor: true,
          supportsBodyConditionScore: true,
          supportsCastration: true,
          supportsReproduction: true,
        );
      case Species.pig:
        return AnimalRegistrationPolicy(
          species: species,
          identificationKind: AnimalIdentificationKind.earTag,
          identificationLabel: 'Arete o identificación',
          identificationHint: 'Ej. POR-1042',
          tracksPendingEarTag: true,
          purposeOptions: const [
            ProductionPurpose.meat,
            ProductionPurpose.breeding,
          ],
          productionSystems: const [
            ProductionSystem.intensive,
            ProductionSystem.extensive,
            ProductionSystem.mixed,
            ProductionSystem.organic,
          ],
          housingOptions: const ['Corral', 'Confinamiento', 'Mixto'],
          coatLabel: 'Color / pelaje',
          supportsEarTagColor: true,
          supportsBodyConditionScore: true,
          supportsCastration: true,
          supportsReproduction: true,
        );
      case Species.poultry:
        return AnimalRegistrationPolicy(
          species: species,
          identificationKind: AnimalIdentificationKind.legBand,
          identificationLabel: 'Anillo o identificación',
          identificationHint: 'Ej. AV-1042',
          tracksPendingEarTag: false,
          purposeOptions: const [
            ProductionPurpose.eggs,
            ProductionPurpose.meat,
            ProductionPurpose.dual,
            ProductionPurpose.breeding,
          ],
          productionSystems: const [
            ProductionSystem.intensive,
            ProductionSystem.extensive,
            ProductionSystem.mixed,
            ProductionSystem.organic,
          ],
          housingOptions: const ['Gallinero', 'Libre', 'Mixto'],
          coatLabel: 'Color / plumaje',
          supportsEarTagColor: false,
          supportsBodyConditionScore: false,
          supportsCastration: false,
          supportsReproduction: false,
        );
      case Species.canine:
        return AnimalRegistrationPolicy(
          species: species,
          identificationKind: AnimalIdentificationKind.microchipOrPlate,
          identificationLabel: 'Microchip o placa',
          identificationHint: 'Ej. microchip o número de placa',
          tracksPendingEarTag: false,
          purposeOptions: const [
            ProductionPurpose.companion,
            ProductionPurpose.work,
            ProductionPurpose.guard,
            ProductionPurpose.breeding,
          ],
          productionSystems: const [],
          housingOptions: const ['Casa', 'Perrera', 'Libre', 'Mixto'],
          coatLabel: 'Color / pelaje',
          supportsEarTagColor: false,
          supportsBodyConditionScore: true,
          supportsCastration: true,
          supportsReproduction: true,
        );
      case Species.other:
        return AnimalRegistrationPolicy(
          species: species,
          identificationKind: AnimalIdentificationKind.generic,
          identificationLabel: 'Identificación',
          identificationHint: 'Código o referencia opcional',
          tracksPendingEarTag: false,
          purposeOptions: const [ProductionPurpose.other],
          productionSystems: const [],
          housingOptions: const ['Libre', 'Confinado', 'Mixto'],
          coatLabel: 'Color / características',
          supportsEarTagColor: false,
          supportsBodyConditionScore: false,
          supportsCastration: false,
          supportsReproduction: false,
        );
    }
  }

  final Species species;
  final AnimalIdentificationKind identificationKind;
  final String identificationLabel;
  final String identificationHint;
  final bool tracksPendingEarTag;
  final List<ProductionPurpose> purposeOptions;
  final List<ProductionSystem> productionSystems;
  final List<String> housingOptions;
  final String coatLabel;
  final bool supportsEarTagColor;
  final bool supportsBodyConditionScore;
  final bool supportsCastration;
  final bool supportsReproduction;

  bool hasPendingEarTag(AnimalEntity animal) =>
      tracksPendingEarTag && animal.earTagNumber.trim().isEmpty;
}
