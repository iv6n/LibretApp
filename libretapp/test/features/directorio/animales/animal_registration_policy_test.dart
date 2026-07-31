import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';

void main() {
  group('AnimalRegistrationPolicy', () {
    test('defines an adaptive policy for every supported species', () {
      for (final species in Species.values) {
        final policy = AnimalRegistrationPolicy.forSpecies(species);

        expect(policy.species, species);
        expect(policy.identificationLabel, isNotEmpty);
        expect(policy.identificationHint, isNotEmpty);
        expect(policy.purposeOptions, isNotEmpty);
        expect(policy.housingOptions, isNotEmpty);
      }
    });

    test('tracks pending tags only for compatible livestock species', () {
      const tracked = {
        Species.cattle,
        Species.sheep,
        Species.goat,
        Species.pig,
      };

      for (final species in Species.values) {
        expect(
          AnimalRegistrationPolicy.forSpecies(species).tracksPendingEarTag,
          tracked.contains(species),
          reason: species.name,
        );
      }
    });

    test('offers the purposes specified for representative species', () {
      expect(
        AnimalRegistrationPolicy.forSpecies(Species.equine).purposeOptions,
        containsAll([
          ProductionPurpose.work,
          ProductionPurpose.sport,
          ProductionPurpose.breeding,
          ProductionPurpose.companion,
        ]),
      );
      expect(
        AnimalRegistrationPolicy.forSpecies(Species.poultry).purposeOptions,
        containsAll([
          ProductionPurpose.eggs,
          ProductionPurpose.meat,
          ProductionPurpose.dual,
          ProductionPurpose.breeding,
        ]),
      );
      expect(
        AnimalRegistrationPolicy.forSpecies(Species.canine).purposeOptions,
        contains(ProductionPurpose.guard),
      );
    });
  });

  group('AnimalTaxonomy', () {
    test('filters cattle categories by sex, age and castration', () {
      expect(
        AnimalTaxonomy.categoriesFor(
          species: Species.cattle,
          sex: Sex.male,
          ageMonths: 18,
        ),
        contains(Category.youngBull),
      );
      expect(
        AnimalTaxonomy.categoriesFor(
          species: Species.cattle,
          sex: Sex.male,
          ageMonths: 18,
          neutered: true,
        ),
        contains(Category.steer),
      );
      expect(
        AnimalTaxonomy.categoriesFor(
          species: Species.cattle,
          sex: Sex.female,
          ageMonths: 30,
        ),
        contains(Category.cow),
      );
    });
  });
}
