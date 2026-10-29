import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_record_actions.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_indicator_snapshot.dart';

import 'advisor/rules/rule_test_fixtures.dart';

void main() {
  for (final species in Species.values) {
    for (final sex in Sex.values) {
      test('$species $sex offers only applicable reproduction and milking', () {
        final animal = buildAnimal(species: species, sex: sex);
        final actions = recordActionsFor(animal);
        expect(actions, contains(AnimalRecordAction.health));
        expect(actions, contains(AnimalRecordAction.weight));
        expect(actions, isNot(contains(AnimalRecordAction.milking)));
        if (sex != Sex.female ||
            !AnimalRegistrationPolicy.forSpecies(
              species,
            ).supportsReproduction) {
          expect(actions, isNot(contains(AnimalRecordAction.reproduction)));
        }
      });
    }
  }
  test('milking requires a lactating dairy female of a supported species', () {
    for (final species in Species.values) {
      final female = buildAnimal(
        species: species,
        sex: Sex.female,
        productionPurpose: ProductionPurpose.dairy,
        reproductiveStatus: ReproductiveStatus.lactating,
      );
      expect(
        recordActionsFor(female).contains(AnimalRecordAction.milking),
        {Species.cattle, Species.goat, Species.sheep}.contains(species),
      );
      expect(
        recordActionsFor(female.copyWith(sex: Sex.male)),
        isNot(contains(AnimalRecordAction.milking)),
      );
    }
  });
  test('sold and deceased animals retain history without new operations', () {
    for (final status in AnimalStatus.values.where((s) => !s.isInActiveHerd)) {
      expect(recordActionsFor(buildAnimal().copyWith(status: status)), isEmpty);
    }
  });
  test('companions and work animals have no production entry', () {
    for (final purpose in [
      ProductionPurpose.companion,
      ProductionPurpose.work,
      ProductionPurpose.guard,
      ProductionPurpose.sport,
    ]) {
      expect(
        recordActionsFor(buildAnimal(productionPurpose: purpose)),
        isNot(contains(AnimalRecordAction.production)),
      );
    }
  });
  test('missing records never become measured zeroes', () {
    final snapshot = buildAnimalIndicatorSnapshot(animal: buildAnimal());
    expect(snapshot.lastWeightKg, isNull);
    expect(snapshot.averageDailyGainKg, isNull);
    expect(snapshot.milkLitersPerDay, isNull);
    expect(snapshot.reproductiveKpis, isNull);
  });
}
