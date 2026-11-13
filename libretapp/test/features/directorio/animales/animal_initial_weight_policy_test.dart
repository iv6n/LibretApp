import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_initial_weight_policy.dart';

void main() {
  group('AnimalInitialWeightPolicy', () {
    test('accepts unknown and finite positive weights', () {
      expect(
        AnimalInitialWeightPolicy.allows(proposed: null, persisted: null),
        isTrue,
      );
      expect(
        AnimalInitialWeightPolicy.allows(proposed: 1, persisted: null),
        isTrue,
      );
      expect(
        AnimalInitialWeightPolicy.allows(proposed: 425.75, persisted: 100),
        isTrue,
      );
    });

    test('rejects a new zero, negative, and non-finite weights', () {
      for (final weight in [0.0, -1.0, double.nan, double.infinity]) {
        expect(
          AnimalInitialWeightPolicy.allows(proposed: weight, persisted: null),
          isFalse,
          reason: '$weight must not be stored as a new initial weight',
        );
      }
    });

    test('allows an existing zero to remain while other fields are edited', () {
      expect(
        AnimalInitialWeightPolicy.allows(proposed: 0, persisted: 0),
        isTrue,
      );
      expect(
        AnimalInitialWeightPolicy.allows(proposed: 0, persisted: null),
        isFalse,
      );
    });
  });
}
