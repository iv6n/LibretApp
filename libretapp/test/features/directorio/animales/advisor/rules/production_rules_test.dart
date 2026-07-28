import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/advisor/rules/production_rules.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_purpose.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';

import 'rule_test_fixtures.dart';

void main() {
  group('evaluateProductionRules — undefined production purpose', () {
    const title = 'Propósito productivo sin definir';

    test('fires when the purpose is undefined', () {
      final tips = evaluateProductionRules(
        buildAnimal(productionPurpose: ProductionPurpose.undefined),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire once a purpose is set', () {
      final tips = evaluateProductionRules(
        buildAnimal(productionPurpose: ProductionPurpose.meat),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateProductionRules — weight monitoring', () {
    const title = 'Sin registro de peso';

    test('fires when no weight is registered', () {
      final tips = evaluateProductionRules(buildAnimal(weight: null));

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire when a weight is registered', () {
      final tips = evaluateProductionRules(buildAnimal(weight: 300));

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateProductionRules — daily gain estimate', () {
    test('fires a warning when gain is below 0.5 kg/day', () {
      final tips = evaluateProductionRules(buildAnimal(dailyGainEstimate: 0.3));

      expect(tips.any((t) => t.title.startsWith('GDP baja')), isTrue);
    });

    test('does not fire when gain is 0.5 kg/day or above', () {
      final tips = evaluateProductionRules(buildAnimal(dailyGainEstimate: 0.5));

      expect(tips.any((t) => t.title.startsWith('GDP baja')), isFalse);
    });

    test('does not fire when no gain estimate is registered', () {
      final tips = evaluateProductionRules(buildAnimal(dailyGainEstimate: null));

      expect(tips.any((t) => t.title.startsWith('GDP baja')), isFalse);
    });
  });

  group('evaluateProductionRules — intensive grazing management', () {
    const title = 'Manejo intensivo — rotación de potreros';

    test('fires for intensive systems', () {
      final tips = evaluateProductionRules(
        buildAnimal(productionSystem: ProductionSystem.intensive),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('fires for feedlot systems', () {
      final tips = evaluateProductionRules(
        buildAnimal(productionSystem: ProductionSystem.feedlot),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire for extensive systems', () {
      final tips = evaluateProductionRules(
        buildAnimal(productionSystem: ProductionSystem.extensive),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });

    test('does not fire for poultry even if the system is intensive', () {
      final tips = evaluateProductionRules(
        buildAnimal(
          productionSystem: ProductionSystem.intensive,
          species: Species.poultry,
        ),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateProductionRules — dual purpose management', () {
    const title = 'Doble propósito — balance leche/carne';

    test('fires for dual purpose animals', () {
      final tips = evaluateProductionRules(
        buildAnimal(productionPurpose: ProductionPurpose.dual),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire for single purpose animals', () {
      final tips = evaluateProductionRules(
        buildAnimal(productionPurpose: ProductionPurpose.meat),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateProductionRules — finishing readiness', () {
    test('fires for a beef bovine within the entry weight range', () {
      final tips = evaluateProductionRules(
        buildAnimal(
          species: Species.cattle,
          productionPurpose: ProductionPurpose.meat,
          productionStage: ProductionStage.growth,
          weight: 300,
        ),
      );

      expect(tips.any((t) => t.title.startsWith('Peso para ingreso a engorde')), isTrue);
    });

    test('does not fire when already in the finishing stage', () {
      final tips = evaluateProductionRules(
        buildAnimal(
          species: Species.cattle,
          productionPurpose: ProductionPurpose.meat,
          productionStage: ProductionStage.finishing,
          weight: 300,
        ),
      );

      expect(tips.any((t) => t.title.startsWith('Peso para ingreso a engorde')), isFalse);
    });

    test('does not fire for weight outside the 280-350 kg range', () {
      final tips = evaluateProductionRules(
        buildAnimal(
          species: Species.cattle,
          productionPurpose: ProductionPurpose.meat,
          productionStage: ProductionStage.growth,
          weight: 200,
        ),
      );

      expect(tips.any((t) => t.title.startsWith('Peso para ingreso a engorde')), isFalse);
    });

    test('does not fire for non-meat purpose', () {
      final tips = evaluateProductionRules(
        buildAnimal(
          species: Species.cattle,
          productionPurpose: ProductionPurpose.dairy,
          productionStage: ProductionStage.growth,
          weight: 300,
        ),
      );

      expect(tips.any((t) => t.title.startsWith('Peso para ingreso a engorde')), isFalse);
    });

    test('does not fire for non-cattle species', () {
      final tips = evaluateProductionRules(
        buildAnimal(
          species: Species.sheep,
          productionPurpose: ProductionPurpose.meat,
          productionStage: ProductionStage.growth,
          weight: 300,
        ),
      );

      expect(tips.any((t) => t.title.startsWith('Peso para ingreso a engorde')), isFalse);
    });
  });

  group('evaluateProductionRules — idle stage review', () {
    const title = 'Etapa productiva sin definir';

    test('fires when the production stage is idle', () {
      final tips = evaluateProductionRules(
        buildAnimal(productionStage: ProductionStage.idle),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire for an active production stage', () {
      final tips = evaluateProductionRules(
        buildAnimal(productionStage: ProductionStage.growth),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });
}
