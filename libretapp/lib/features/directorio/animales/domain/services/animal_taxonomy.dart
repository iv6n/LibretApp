/// Species-aware animal taxonomy used by registration, filters, and cards.
library;

import 'package:libretapp/features/directorio/animales/domain/enums/category.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/life_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/sex.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';

class AnimalTaxonomy {
  const AnimalTaxonomy._();

  static const ranchSpecies = <Species>[
    Species.cattle,
    Species.equine,
    Species.goat,
    Species.sheep,
    Species.pig,
    Species.poultry,
    Species.canine,
  ];

  static Category defaultCategory({
    required Species species,
    required Sex sex,
    required int ageMonths,
    bool neutered = false,
  }) {
    final options = categoriesFor(
      species: species,
      sex: sex,
      ageMonths: ageMonths,
    );
    if (species == Species.cattle) {
      if (ageMonths < 12) return Category.calf;
      if (ageMonths < 24) {
        if (sex == Sex.female) return Category.heifer;
        return neutered ? Category.steer : Category.youngBull;
      }
      if (sex == Sex.female) return Category.cow;
      return neutered ? Category.oxen : Category.bull;
    }
    if (options.contains(Category.juvenile) && ageMonths < 12) {
      return Category.juvenile;
    }
    if (options.contains(Category.grower) && ageMonths < 24) {
      return Category.grower;
    }
    return options.firstWhere(
      (category) => category != Category.other,
      orElse: () => Category.other,
    );
  }

  static List<Category> categoriesFor({
    required Species species,
    required Sex sex,
    required int? ageMonths,
  }) {
    final age = ageMonths ?? 24;
    switch (species) {
      case Species.cattle:
        if (age < 12) {
          return const [Category.calf, Category.weaned, Category.other];
        }
        if (age < 24) {
          return const [
            Category.heifer,
            Category.youngBull,
            Category.steer,
            Category.weaned,
            Category.other,
          ];
        }
        return const [
          Category.cow,
          Category.bull,
          Category.oxen,
          Category.other,
        ];
      case Species.equine:
        if (age < 36) return const [Category.juvenile, Category.grower];
        return const [
          Category.work,
          Category.production,
          Category.reproduction,
        ];
      case Species.goat:
      case Species.sheep:
        if (age < 12) return const [Category.juvenile, Category.grower];
        return const [
          Category.production,
          Category.reproduction,
          Category.fattening,
        ];
      case Species.pig:
        if (age < 6) return const [Category.juvenile, Category.grower];
        return const [
          Category.fattening,
          Category.production,
          Category.reproduction,
        ];
      case Species.poultry:
        if (age < 4) return const [Category.juvenile, Category.grower];
        return const [Category.production, Category.reproduction];
      case Species.canine:
        if (age < 18) return const [Category.juvenile, Category.grower];
        return const [Category.work, Category.guard];
      case Species.other:
        return const [Category.other];
    }
  }

  static LifeStage resolveLifeStage({
    required Species species,
    required Sex sex,
    required int ageMonths,
    Category? category,
    LifeStage? fallback,
  }) {
    switch (species) {
      case Species.cattle:
        if (ageMonths < 12) {
          return sex == Sex.female ? LifeStage.calfFemale : LifeStage.calfMale;
        }
        if (ageMonths < 24) {
          if (category == Category.steer) return LifeStage.steer;
          return sex == Sex.female ? LifeStage.heifer : LifeStage.youngBull;
        }
        if (category == Category.oxen) return LifeStage.steer;
        return sex == Sex.female ? LifeStage.cow : LifeStage.bull;
      case Species.equine:
        if (category == Category.work && ageMonths >= 36) {
          return LifeStage.horse;
        }
        if (ageMonths < 36) {
          return sex == Sex.female ? LifeStage.filly : LifeStage.colt;
        }
        return sex == Sex.female ? LifeStage.mare : LifeStage.horse;
      case Species.goat:
        if (ageMonths < 6) return LifeStage.kid;
        if (ageMonths < 12) return LifeStage.youngGoat;
        return sex == Sex.female ? LifeStage.goat : LifeStage.breedingBuck;
      case Species.sheep:
        if (ageMonths < 6) return LifeStage.lamb;
        if (ageMonths < 12) return LifeStage.youngSheep;
        return sex == Sex.female ? LifeStage.ewe : LifeStage.ram;
      case Species.pig:
        if (ageMonths < 2) return LifeStage.piglet;
        if (ageMonths < 12) return LifeStage.youngPig;
        return sex == Sex.female ? LifeStage.sow : LifeStage.boar;
      case Species.poultry:
        if (ageMonths < 1) return LifeStage.chick;
        if (ageMonths < 4) return LifeStage.pullet;
        return sex == Sex.female ? LifeStage.hen : LifeStage.rooster;
      case Species.canine:
        if (ageMonths < 6) return LifeStage.puppy;
        if (ageMonths < 18) return LifeStage.youngDog;
        return category == Category.guard
            ? LifeStage.guardDog
            : LifeStage.workingDog;
      case Species.other:
        return fallback ?? LifeStage.cow;
    }
  }

  static Category categoryForStage(LifeStage stage) {
    switch (stage) {
      case LifeStage.calf:
      case LifeStage.calfMale:
      case LifeStage.calfFemale:
        return Category.calf;
      case LifeStage.heifer:
        return Category.heifer;
      case LifeStage.youngBull:
        return Category.youngBull;
      case LifeStage.steer:
        return Category.steer;
      case LifeStage.cow:
        return Category.cow;
      case LifeStage.bull:
        return Category.bull;
      case LifeStage.colt:
      case LifeStage.filly:
      case LifeStage.kid:
      case LifeStage.lamb:
      case LifeStage.piglet:
      case LifeStage.chick:
      case LifeStage.puppy:
        return Category.juvenile;
      case LifeStage.youngGoat:
      case LifeStage.youngSheep:
      case LifeStage.youngPig:
      case LifeStage.pullet:
      case LifeStage.youngDog:
        return Category.grower;
      case LifeStage.horse:
      case LifeStage.mare:
      case LifeStage.donkey:
      case LifeStage.donkeyFemale:
      case LifeStage.mule:
      case LifeStage.workingDog:
        return Category.work;
      case LifeStage.goat:
      case LifeStage.ewe:
      case LifeStage.sow:
      case LifeStage.hen:
        return Category.production;
      case LifeStage.breedingBuck:
      case LifeStage.ram:
      case LifeStage.boar:
      case LifeStage.rooster:
        return Category.reproduction;
      case LifeStage.guardDog:
        return Category.guard;
    }
  }

  static String assetForStage(LifeStage stage) {
    switch (stage) {
      case LifeStage.calf:
      case LifeStage.calfMale:
      case LifeStage.calfFemale:
        return 'assets/images/becerro.png';
      case LifeStage.heifer:
        return 'assets/images/vaquilla.png';
      case LifeStage.youngBull:
      case LifeStage.bull:
        return 'assets/images/toro.png';
      case LifeStage.steer:
        return 'assets/images/novillo.png';
      case LifeStage.cow:
        return 'assets/images/vaca.png';
      case LifeStage.colt:
      case LifeStage.filly:
      case LifeStage.horse:
      case LifeStage.mare:
        return 'assets/images/caballo.png';
      case LifeStage.donkey:
      case LifeStage.donkeyFemale:
        return 'assets/images/burro.png';
      case LifeStage.mule:
        return 'assets/images/mula.png';
      case LifeStage.kid:
      case LifeStage.youngGoat:
      case LifeStage.goat:
      case LifeStage.breedingBuck:
        return 'assets/images/cabra.png';
      case LifeStage.lamb:
      case LifeStage.youngSheep:
      case LifeStage.ewe:
      case LifeStage.ram:
        return 'assets/images/oveja.png';
      case LifeStage.piglet:
      case LifeStage.youngPig:
      case LifeStage.sow:
      case LifeStage.boar:
        return 'assets/images/cerdo.png';
      case LifeStage.chick:
      case LifeStage.pullet:
      case LifeStage.hen:
      case LifeStage.rooster:
        return 'assets/images/ave.png';
      case LifeStage.puppy:
      case LifeStage.youngDog:
      case LifeStage.workingDog:
      case LifeStage.guardDog:
        return 'assets/images/canino.png';
    }
  }

  static List<List<LifeStage>> filterStageGroups() {
    return const [
      [LifeStage.calf, LifeStage.calfMale, LifeStage.calfFemale],
      [LifeStage.heifer],
      [LifeStage.youngBull],
      [LifeStage.steer],
      [LifeStage.cow],
      [LifeStage.bull],
      [LifeStage.colt, LifeStage.filly],
      [LifeStage.horse, LifeStage.mare],
      [LifeStage.donkey, LifeStage.donkeyFemale],
      [LifeStage.mule],
      [LifeStage.kid, LifeStage.youngGoat, LifeStage.goat],
      [LifeStage.lamb, LifeStage.youngSheep, LifeStage.ewe],
      [LifeStage.piglet, LifeStage.youngPig, LifeStage.sow, LifeStage.boar],
      [LifeStage.chick, LifeStage.pullet, LifeStage.hen, LifeStage.rooster],
      [LifeStage.puppy, LifeStage.youngDog, LifeStage.workingDog],
      [LifeStage.guardDog],
    ];
  }
}
