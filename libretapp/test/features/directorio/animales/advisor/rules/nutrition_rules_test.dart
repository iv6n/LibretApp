import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/advisor/livestock_tip.dart';
import 'package:libretapp/features/directorio/animales/advisor/rules/nutrition_rules.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/life_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_purpose.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/reproductive_status.dart';

import 'rule_test_fixtures.dart';

void main() {
  group('evaluateNutritionRules — body condition alert', () {
    test('warns with "no record" tip when body condition score is missing', () {
      final tips = evaluateNutritionRules(buildAnimal(bodyConditionScore: null));

      expect(
        tips.map((t) => t.title),
        contains('Sin registro de condición corporal'),
      );
    });

    test('fires as warning for a low but not critical score', () {
      final tips = evaluateNutritionRules(buildAnimal(bodyConditionScore: 2));

      final tip = tips.firstWhere((t) => t.title.startsWith('Condición corporal baja'));
      expect(tip.severity, TipSeverity.warning);
    });

    test('fires as critical for an emaciated score', () {
      final tips = evaluateNutritionRules(buildAnimal(bodyConditionScore: 1));

      final tip = tips.firstWhere((t) => t.title.startsWith('Condición corporal baja'));
      expect(tip.severity, TipSeverity.critical);
    });

    test('does not fire for an acceptable score', () {
      final tips = evaluateNutritionRules(buildAnimal(bodyConditionScore: 3));

      expect(tips.any((t) => t.title.startsWith('Condición corporal baja')), isFalse);
      expect(
        tips.map((t) => t.title),
        isNot(contains('Sin registro de condición corporal')),
      );
    });
  });

  group('evaluateNutritionRules — calf nutrition', () {
    test('fires for a calf 10 months old or younger', () {
      final tips = evaluateNutritionRules(
        buildAnimal(lifeStage: LifeStage.calf, ageMonths: 4),
      );

      expect(tips.any((t) => t.title.startsWith('Nutrición de cría')), isTrue);
    });

    test('does not fire once older than 10 months', () {
      final tips = evaluateNutritionRules(
        buildAnimal(lifeStage: LifeStage.calf, ageMonths: 11),
      );

      expect(tips.any((t) => t.title.startsWith('Nutrición de cría')), isFalse);
    });

    test('does not fire for non-calf life stages', () {
      final tips = evaluateNutritionRules(
        buildAnimal(lifeStage: LifeStage.cow, ageMonths: 4),
      );

      expect(tips.any((t) => t.title.startsWith('Nutrición de cría')), isFalse);
    });
  });

  group('evaluateNutritionRules — pregnant cow nutrition', () {
    const title = 'Último tercio de gestación — aumentar nutrición';

    test('fires within the last third of gestation', () {
      final tips = evaluateNutritionRules(
        buildAnimal(
          reproductiveStatus: ReproductiveStatus.pregnant,
          expectedCalvingDate: DateTime.now().add(const Duration(days: 45)),
        ),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire earlier in gestation', () {
      final tips = evaluateNutritionRules(
        buildAnimal(
          reproductiveStatus: ReproductiveStatus.pregnant,
          expectedCalvingDate: DateTime.now().add(const Duration(days: 150)),
        ),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });

    test('does not fire once the expected calving date has passed', () {
      final tips = evaluateNutritionRules(
        buildAnimal(
          reproductiveStatus: ReproductiveStatus.pregnant,
          expectedCalvingDate: DateTime.now().subtract(const Duration(days: 5)),
        ),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });

    test('does not fire without an expected calving date', () {
      final tips = evaluateNutritionRules(
        buildAnimal(reproductiveStatus: ReproductiveStatus.pregnant),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateNutritionRules — lactating cow nutrition', () {
    const title = 'Vaca en lactación — alta demanda nutricional';

    test('fires for a lactating animal', () {
      final tips = evaluateNutritionRules(
        buildAnimal(reproductiveStatus: ReproductiveStatus.lactating),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire for a non-lactating animal', () {
      final tips = evaluateNutritionRules(
        buildAnimal(reproductiveStatus: ReproductiveStatus.active),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateNutritionRules — feed transition advice', () {
    const title = 'Cambios de dieta graduales';

    test('fires when a feed type is registered', () {
      final tips = evaluateNutritionRules(buildAnimal(feedType: 'Concentrado'));

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire when no feed type is registered', () {
      final tips = evaluateNutritionRules(buildAnimal(feedType: null));

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });

    test('does not fire for an empty feed type', () {
      final tips = evaluateNutritionRules(buildAnimal(feedType: ''));

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateNutritionRules — mineral supplementation', () {
    const title = 'Suplementación mineral continua';

    test('fires whenever the production purpose is defined', () {
      final tips = evaluateNutritionRules(
        buildAnimal(productionPurpose: ProductionPurpose.dairy),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire when the production purpose is undefined', () {
      final tips = evaluateNutritionRules(
        buildAnimal(productionPurpose: ProductionPurpose.undefined),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateNutritionRules — fattening nutrition', () {
    const title = 'Protocolo de engorde';

    test('fires when in the finishing production stage', () {
      final tips = evaluateNutritionRules(
        buildAnimal(productionStage: ProductionStage.finishing),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire in other production stages', () {
      final tips = evaluateNutritionRules(
        buildAnimal(productionStage: ProductionStage.growth),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });
}
