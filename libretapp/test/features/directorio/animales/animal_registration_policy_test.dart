import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_lifecycle_calculator.dart';

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

    test('resolves cattle stages at 11/12 and 23/24 months', () {
      final reference = DateTime(2026, 1, 1);

      AnimalLifecycleResult calculate({
        required Sex sex,
        required DateTime birthDate,
        Category? category,
      }) => AnimalLifecycleCalculator.calculate(
        birthDate: birthDate,
        species: Species.cattle,
        sex: sex,
        category: category,
        now: reference,
      );

      expect(
        calculate(sex: Sex.female, birthDate: DateTime(2025, 2, 1)).lifeStage,
        LifeStage.calfFemale,
      );
      expect(
        calculate(sex: Sex.female, birthDate: DateTime(2025, 1, 1)).lifeStage,
        LifeStage.heifer,
      );
      expect(
        calculate(sex: Sex.female, birthDate: DateTime(2024, 2, 1)).lifeStage,
        LifeStage.heifer,
      );
      expect(
        calculate(sex: Sex.female, birthDate: DateTime(2024, 1, 1)).lifeStage,
        LifeStage.cow,
      );
      expect(
        calculate(sex: Sex.male, birthDate: DateTime(2025, 1, 1)).lifeStage,
        LifeStage.youngBull,
      );
      expect(
        calculate(
          sex: Sex.male,
          birthDate: DateTime(2025, 1, 1),
          category: Category.steer,
        ).lifeStage,
        LifeStage.steer,
      );
      expect(
        calculate(
          sex: Sex.male,
          birthDate: DateTime(2024, 1, 1),
          category: Category.oxen,
        ).lifeStage,
        LifeStage.steer,
      );
    });
  });
}
