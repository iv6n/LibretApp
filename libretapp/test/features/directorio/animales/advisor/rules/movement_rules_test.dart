import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/advisor/livestock_tip.dart';
import 'package:libretapp/features/directorio/animales/advisor/rules/movement_rules.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/health_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/life_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/reproductive_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/risk_level.dart';

import 'rule_test_fixtures.dart';

void main() {
  test('a fully neutral animal and movement record produce no tips', () {
    final tips = evaluateMovementRules(buildAnimal(), buildMovementRecord());

    expect(tips, isEmpty);
  });

  group('evaluateMovementRules — pregnant animal movement', () {
    const title = 'Animal gestante en movimiento';

    test('fires for a pregnant animal moved for a non-medical reason', () {
      final tips = evaluateMovementRules(
        buildAnimal(reproductiveStatus: ReproductiveStatus.pregnant),
        buildMovementRecord(reason: MovementReason.relocation),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire for medically justified movements (treatment)', () {
      final tips = evaluateMovementRules(
        buildAnimal(reproductiveStatus: ReproductiveStatus.pregnant),
        buildMovementRecord(reason: MovementReason.treatment),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });

    test('does not fire for medically justified movements (quarantine)', () {
      final tips = evaluateMovementRules(
        buildAnimal(reproductiveStatus: ReproductiveStatus.pregnant),
        buildMovementRecord(reason: MovementReason.quarantine),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });

    test('does not fire for a non-pregnant animal', () {
      final tips = evaluateMovementRules(
        buildAnimal(reproductiveStatus: ReproductiveStatus.active),
        buildMovementRecord(reason: MovementReason.relocation),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateMovementRules — late pregnancy movement', () {
    test('fires within the last third of gestation (<=90 days to calving)', () {
      final tips = evaluateMovementRules(
        buildAnimal(
          reproductiveStatus: ReproductiveStatus.pregnant,
          expectedCalvingDate: DateTime.now().add(const Duration(days: 60)),
        ),
        buildMovementRecord(),
      );

      final tip = tips.firstWhere(
        (t) => t.title.startsWith('Gestación avanzada'),
      );
      expect(tip.severity, TipSeverity.critical);
    });

    test('does not fire when more than 90 days remain to calving', () {
      final tips = evaluateMovementRules(
        buildAnimal(
          reproductiveStatus: ReproductiveStatus.pregnant,
          expectedCalvingDate: DateTime.now().add(const Duration(days: 120)),
        ),
        buildMovementRecord(),
      );

      expect(tips.any((t) => t.title.startsWith('Gestación avanzada')), isFalse);
    });

    test('does not fire without an expected calving date', () {
      final tips = evaluateMovementRules(
        buildAnimal(reproductiveStatus: ReproductiveStatus.pregnant),
        buildMovementRecord(),
      );

      expect(tips.any((t) => t.title.startsWith('Gestación avanzada')), isFalse);
    });
  });

  group('evaluateMovementRules — young animal stress', () {
    const title = 'Cría joven — riesgo de estrés';

    test('fires for calves', () {
      final tips = evaluateMovementRules(
        buildAnimal(lifeStage: LifeStage.calf),
        buildMovementRecord(),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('fires for foals (colt)', () {
      final tips = evaluateMovementRules(
        buildAnimal(lifeStage: LifeStage.colt),
        buildMovementRecord(),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire for adult life stages', () {
      final tips = evaluateMovementRules(
        buildAnimal(lifeStage: LifeStage.cow),
        buildMovementRecord(),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateMovementRules — diet transition', () {
    const title = 'Transición de dieta gradual';

    for (final reason in [
      MovementReason.paddockRotation,
      MovementReason.feeding,
      MovementReason.relocation,
    ]) {
      test('fires for reason $reason', () {
        final tips = evaluateMovementRules(buildAnimal(), buildMovementRecord(reason: reason));

        expect(tips.map((t) => t.title), contains(title));
      });
    }

    test('does not fire for unrelated reasons', () {
      final tips = evaluateMovementRules(
        buildAnimal(),
        buildMovementRecord(reason: MovementReason.transport),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateMovementRules — health compromised movement', () {
    const title = 'Salud comprometida — mover con precaución';

    test('fires as critical for critical health status', () {
      final tips = evaluateMovementRules(
        buildAnimal(healthStatus: HealthStatus.critical),
        buildMovementRecord(),
      );

      final tip = tips.firstWhere((t) => t.title == title);
      expect(tip.severity, TipSeverity.critical);
    });

    test('fires as warning for poor health status', () {
      final tips = evaluateMovementRules(
        buildAnimal(healthStatus: HealthStatus.poor),
        buildMovementRecord(),
      );

      final tip = tips.firstWhere((t) => t.title == title);
      expect(tip.severity, TipSeverity.warning);
    });

    test('does not fire for good health status', () {
      final tips = evaluateMovementRules(
        buildAnimal(healthStatus: HealthStatus.good),
        buildMovementRecord(),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateMovementRules — high risk movement', () {
    const title = 'Animal con nivel de riesgo elevado';

    test('fires for high risk when health is otherwise fine', () {
      final tips = evaluateMovementRules(
        buildAnimal(riskLevel: RiskLevel.high),
        buildMovementRecord(),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('fires for critical risk when health is otherwise fine', () {
      final tips = evaluateMovementRules(
        buildAnimal(riskLevel: RiskLevel.critical),
        buildMovementRecord(),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not duplicate when health compromised tip already covers it', () {
      final tips = evaluateMovementRules(
        buildAnimal(riskLevel: RiskLevel.critical, healthStatus: HealthStatus.critical),
        buildMovementRecord(),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });

    test('does not fire for low/medium risk', () {
      final tips = evaluateMovementRules(
        buildAnimal(riskLevel: RiskLevel.medium),
        buildMovementRecord(),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateMovementRules — long distance transport', () {
    const title = 'Transporte — cuidados especiales';

    test('fires for transport reason', () {
      final tips = evaluateMovementRules(
        buildAnimal(),
        buildMovementRecord(reason: MovementReason.transport),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire for other reasons', () {
      final tips = evaluateMovementRules(
        buildAnimal(),
        buildMovementRecord(reason: MovementReason.other),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateMovementRules — quarantine reminder', () {
    const title = 'Protocolo de cuarentena';

    test('fires for quarantine reason', () {
      final tips = evaluateMovementRules(
        buildAnimal(),
        buildMovementRecord(reason: MovementReason.quarantine),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire for other reasons', () {
      final tips = evaluateMovementRules(
        buildAnimal(),
        buildMovementRecord(reason: MovementReason.other),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateMovementRules — recent movement frequency', () {
    test('fires when the last movement was 14 days ago or less', () {
      final tips = evaluateMovementRules(
        buildAnimal(lastMovementDate: DateTime.now().subtract(const Duration(days: 5))),
        buildMovementRecord(),
      );

      expect(tips.any((t) => t.title.startsWith('Movimiento reciente')), isTrue);
    });

    test('does not fire when the last movement was more than 14 days ago', () {
      final tips = evaluateMovementRules(
        buildAnimal(lastMovementDate: DateTime.now().subtract(const Duration(days: 20))),
        buildMovementRecord(),
      );

      expect(tips.any((t) => t.title.startsWith('Movimiento reciente')), isFalse);
    });

    test('does not fire when there is no recorded last movement', () {
      final tips = evaluateMovementRules(buildAnimal(), buildMovementRecord());

      expect(tips.any((t) => t.title.startsWith('Movimiento reciente')), isFalse);
    });
  });

  group('evaluateMovementRules — lactating cow movement', () {
    const title = 'Vaca lactante — asegurar acceso a cría';

    test('fires for a lactating animal', () {
      final tips = evaluateMovementRules(
        buildAnimal(reproductiveStatus: ReproductiveStatus.lactating),
        buildMovementRecord(),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire for a non-lactating animal', () {
      final tips = evaluateMovementRules(
        buildAnimal(reproductiveStatus: ReproductiveStatus.active),
        buildMovementRecord(),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });
}
