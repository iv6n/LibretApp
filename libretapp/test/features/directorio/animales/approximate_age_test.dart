import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';

void main() {
  group('ApproximateAge', () {
    test('converts years and months to one canonical monthly value', () {
      const age = ApproximateAge(years: 3, months: 7);

      expect(age.totalMonths, 43);
      expect(ApproximateAge.fromTotalMonths(43), age);
      expect(age.displayLabel, '3 años 7 meses');
    });

    test(
      'clamps values restored from an external source to carousel limits',
      () {
        expect(
          ApproximateAge.fromTotalMonths(-10),
          const ApproximateAge.unknown(),
        );
        expect(ApproximateAge.fromTotalMonths(-1).totalMonths, -1);
        expect(ApproximateAge.fromTotalMonths(-1).displayLabel, 'No lo sé');
        expect(ApproximateAge.fromTotalMonths(0).displayLabel, 'Recién nacido');
        expect(
          ApproximateAge.fromTotalMonths(999),
          const ApproximateAge(years: 30, months: 11),
        );
      },
    );

    test('estimates a valid date at month ends', () {
      const age = ApproximateAge(years: 0, months: 1);

      expect(
        age.estimatedBirthDate(DateTime(2025, 3, 31)),
        DateTime(2025, 2, 28),
      );
    });
  });

  test('unknown sex and age do not imply a sexed category or life stage', () {
    expect(
      AnimalTaxonomy.defaultCategory(
        species: Species.cattle,
        sex: Sex.unknown,
        ageMonths: 36,
      ),
      Category.other,
    );
    expect(
      AnimalTaxonomy.resolveLifeStage(
        species: Species.equine,
        sex: Sex.unknown,
        ageMonths: 48,
      ),
      LifeStage.unknown,
    );
    expect(
      AnimalTaxonomy.defaultCategory(
        species: Species.cattle,
        sex: Sex.female,
        ageMonths: -1,
      ),
      Category.other,
    );
  });
}
