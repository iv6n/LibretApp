import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/advisor/livestock_tip.dart';
import 'package:libretapp/features/directorio/animales/advisor/rules/health_rules.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/health_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/reproductive_status.dart';

import 'rule_test_fixtures.dart';

void main() {
  group('evaluateHealthRules — vaccination schedule', () {
    test('fires for a vaccine record', () {
      final tips = evaluateHealthRules(
        buildAnimal(),
        buildHealthRecord(type: HealthRecordType.vaccine),
      );

      expect(tips.map((t) => t.title), contains('Calendario de vacunación'));
      final tip = tips.firstWhere((t) => t.title == 'Calendario de vacunación');
      expect(tip.category, TipCategory.health);
      expect(tip.severity, TipSeverity.info);
    });

    test('does not fire for a non-vaccine record', () {
      final tips = evaluateHealthRules(
        buildAnimal(),
        buildHealthRecord(type: HealthRecordType.checkup),
      );

      expect(tips.map((t) => t.title), isNot(contains('Calendario de vacunación')));
    });
  });

  group('evaluateHealthRules — deworming interval', () {
    test('fires for a deworming record', () {
      final tips = evaluateHealthRules(
        buildAnimal(),
        buildHealthRecord(type: HealthRecordType.deworming),
      );

      expect(tips.map((t) => t.title), contains('Intervalo de desparasitación'));
    });

    test('does not fire for other record types', () {
      final tips = evaluateHealthRules(
        buildAnimal(),
        buildHealthRecord(type: HealthRecordType.checkup),
      );

      expect(tips.map((t) => t.title), isNot(contains('Intervalo de desparasitación')));
    });
  });

  group('evaluateHealthRules — pregnant animal treatment', () {
    const title = 'Animal gestante — verificar contraindicaciones';

    test('fires when the animal is pregnant and the record is not a checkup', () {
      final tips = evaluateHealthRules(
        buildAnimal(reproductiveStatus: ReproductiveStatus.pregnant),
        buildHealthRecord(type: HealthRecordType.treatment),
      );

      expect(tips.map((t) => t.title), contains(title));
      final tip = tips.firstWhere((t) => t.title == title);
      expect(tip.severity, TipSeverity.critical);
    });

    test('does not fire for a checkup even if the animal is pregnant', () {
      final tips = evaluateHealthRules(
        buildAnimal(reproductiveStatus: ReproductiveStatus.pregnant),
        buildHealthRecord(type: HealthRecordType.checkup),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });

    test('does not fire when the animal is not pregnant', () {
      final tips = evaluateHealthRules(
        buildAnimal(reproductiveStatus: ReproductiveStatus.active),
        buildHealthRecord(type: HealthRecordType.treatment),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateHealthRules — young animal dosage', () {
    const title = 'Cría joven — ajustar dosis';

    test('fires for an animal 6 months old or younger with a treatment record', () {
      final tips = evaluateHealthRules(
        buildAnimal(ageMonths: 6),
        buildHealthRecord(type: HealthRecordType.treatment),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire for an animal older than 6 months', () {
      final tips = evaluateHealthRules(
        buildAnimal(ageMonths: 7),
        buildHealthRecord(type: HealthRecordType.treatment),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });

    test('does not fire for checkup or other record types even if young', () {
      final checkupTips = evaluateHealthRules(
        buildAnimal(ageMonths: 2),
        buildHealthRecord(type: HealthRecordType.checkup),
      );
      final otherTips = evaluateHealthRules(
        buildAnimal(ageMonths: 2),
        buildHealthRecord(type: HealthRecordType.other),
      );

      expect(checkupTips.map((t) => t.title), isNot(contains(title)));
      expect(otherTips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateHealthRules — chronic animal alert', () {
    const title = 'Animal con antecedentes crónicos';

    test('fires and includes the chronic notes when present', () {
      final tips = evaluateHealthRules(
        buildAnimal(hasChronicIssues: true, chronicNotes: 'Cojera leve'),
        buildHealthRecord(),
      );

      final tip = tips.firstWhere((t) => t.title == title);
      expect(tip.description, contains('Cojera leve'));
    });

    test('does not fire when the animal has no chronic issues', () {
      final tips = evaluateHealthRules(
        buildAnimal(hasChronicIssues: false),
        buildHealthRecord(),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateHealthRules — critical health follow-up', () {
    const title = 'Salud comprometida — seguimiento necesario';

    test('fires for critical health status', () {
      final tips = evaluateHealthRules(
        buildAnimal(healthStatus: HealthStatus.critical),
        buildHealthRecord(),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('fires for poor health status', () {
      final tips = evaluateHealthRules(
        buildAnimal(healthStatus: HealthStatus.poor),
        buildHealthRecord(),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire for good health status', () {
      final tips = evaluateHealthRules(
        buildAnimal(healthStatus: HealthStatus.good),
        buildHealthRecord(),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateHealthRules — disease isolation', () {
    const title = 'Enfermedad — evaluar aislamiento';

    test('fires for a disease record', () {
      final tips = evaluateHealthRules(
        buildAnimal(),
        buildHealthRecord(type: HealthRecordType.disease),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire for a non-disease record', () {
      final tips = evaluateHealthRules(
        buildAnimal(),
        buildHealthRecord(type: HealthRecordType.checkup),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateHealthRules — vitamin supplementation', () {
    const title = 'Suplementación vitamínica';

    test('fires for a vitamins record', () {
      final tips = evaluateHealthRules(
        buildAnimal(),
        buildHealthRecord(type: HealthRecordType.vitamins),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire for a non-vitamins record', () {
      final tips = evaluateHealthRules(
        buildAnimal(),
        buildHealthRecord(type: HealthRecordType.checkup),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  test('a fully neutral animal and checkup record produce no tips', () {
    final tips = evaluateHealthRules(
      buildAnimal(),
      buildHealthRecord(type: HealthRecordType.checkup),
    );

    expect(tips, isEmpty);
  });
}
