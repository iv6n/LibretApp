import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/advisor/livestock_tip.dart';
import 'package:libretapp/features/directorio/animales/advisor/rules/reproduction_rules.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/reproductive_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/sex.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';

import 'rule_test_fixtures.dart';

void main() {
  group('evaluateReproductionRules — young animal service', () {
    test('fires as critical for a female under 15 months', () {
      final tips = evaluateReproductionRules(
        buildAnimal(sex: Sex.female, ageMonths: 10),
        buildReproductionRecord(),
      );

      final tip = tips.firstWhere((t) => t.title.startsWith('Animal joven'));
      expect(tip.severity, TipSeverity.critical);
    });

    test('does not fire for a female 15 months or older', () {
      final tips = evaluateReproductionRules(
        buildAnimal(sex: Sex.female, ageMonths: 15),
        buildReproductionRecord(),
      );

      expect(tips.any((t) => t.title.startsWith('Animal joven')), isFalse);
    });

    test('does not fire for males regardless of age', () {
      final tips = evaluateReproductionRules(
        buildAnimal(sex: Sex.male, ageMonths: 3),
        buildReproductionRecord(),
      );

      expect(tips.any((t) => t.title.startsWith('Animal joven')), isFalse);
    });
  });

  group('evaluateReproductionRules — service interval check', () {
    test('warns when the previous service was fewer than 21 days ago', () {
      final serviceDate = DateTime(2024, 6, 1);
      final tips = evaluateReproductionRules(
        buildAnimal(
          sex: Sex.female,
          ageMonths: 40,
          lastServiceDate: serviceDate.subtract(const Duration(days: 10)),
        ),
        buildReproductionRecord(serviceDate: serviceDate),
      );

      expect(tips.any((t) => t.title.startsWith('Servicio reciente')), isTrue);
    });

    test('does not fire once at least 21 days have passed', () {
      final serviceDate = DateTime(2024, 6, 1);
      final tips = evaluateReproductionRules(
        buildAnimal(
          sex: Sex.female,
          ageMonths: 40,
          lastServiceDate: serviceDate.subtract(const Duration(days: 21)),
        ),
        buildReproductionRecord(serviceDate: serviceDate),
      );

      expect(tips.any((t) => t.title.startsWith('Servicio reciente')), isFalse);
    });

    test('does not fire without a previous service date', () {
      final tips = evaluateReproductionRules(
        buildAnimal(sex: Sex.female, ageMonths: 40),
        buildReproductionRecord(),
      );

      expect(tips.any((t) => t.title.startsWith('Servicio reciente')), isFalse);
    });
  });

  group('evaluateReproductionRules — artificial insemination timing', () {
    const title = 'Timing de inseminación artificial';

    test('fires for artificial insemination', () {
      final tips = evaluateReproductionRules(
        buildAnimal(sex: Sex.female, ageMonths: 40),
        buildReproductionRecord(serviceType: ServiceType.artificialInsemination),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire for natural service', () {
      final tips = evaluateReproductionRules(
        buildAnimal(sex: Sex.female, ageMonths: 40),
        buildReproductionRecord(serviceType: ServiceType.naturalService),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateReproductionRules — pregnancy check reminder', () {
    const title = 'Diagnóstico de preñez pendiente';

    test('fires before day 28 when the check has not been done', () {
      final tips = evaluateReproductionRules(
        buildAnimal(sex: Sex.female, ageMonths: 40),
        buildReproductionRecord(
          serviceDate: DateTime.now().subtract(const Duration(days: 10)),
        ),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire once 28 or more days have passed', () {
      final tips = evaluateReproductionRules(
        buildAnimal(sex: Sex.female, ageMonths: 40),
        buildReproductionRecord(
          serviceDate: DateTime.now().subtract(const Duration(days: 30)),
        ),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });

    test('does not fire when a pregnancy result was already recorded', () {
      final tips = evaluateReproductionRules(
        buildAnimal(sex: Sex.female, ageMonths: 40),
        buildReproductionRecord(
          serviceDate: DateTime.now().subtract(const Duration(days: 10)),
          pregnancyResult: PregnancyCheckResult.positive,
        ),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateReproductionRules — calving preparation', () {
    test('fires within 30 days of the expected calving date', () {
      final tips = evaluateReproductionRules(
        buildAnimal(
          reproductiveStatus: ReproductiveStatus.pregnant,
          expectedCalvingDate: DateTime.now().add(const Duration(days: 15)),
        ),
        buildReproductionRecord(),
      );

      expect(tips.any((t) => t.title.startsWith('Parto próximo')), isTrue);
    });

    test('does not fire more than 30 days before calving', () {
      final tips = evaluateReproductionRules(
        buildAnimal(
          reproductiveStatus: ReproductiveStatus.pregnant,
          expectedCalvingDate: DateTime.now().add(const Duration(days: 60)),
        ),
        buildReproductionRecord(),
      );

      expect(tips.any((t) => t.title.startsWith('Parto próximo')), isFalse);
    });

    test('does not fire once the expected calving date has passed', () {
      final tips = evaluateReproductionRules(
        buildAnimal(
          reproductiveStatus: ReproductiveStatus.pregnant,
          expectedCalvingDate: DateTime.now().subtract(const Duration(days: 5)),
        ),
        buildReproductionRecord(),
      );

      expect(tips.any((t) => t.title.startsWith('Parto próximo')), isFalse);
    });

    test('does not fire for a non-pregnant animal', () {
      final tips = evaluateReproductionRules(
        buildAnimal(
          reproductiveStatus: ReproductiveStatus.active,
          expectedCalvingDate: DateTime.now().add(const Duration(days: 15)),
        ),
        buildReproductionRecord(),
      );

      expect(tips.any((t) => t.title.startsWith('Parto próximo')), isFalse);
    });
  });

  group('evaluateReproductionRules — post-partum recovery', () {
    const title = 'Período de espera voluntario';

    test('fires for a lactating animal', () {
      final tips = evaluateReproductionRules(
        buildAnimal(reproductiveStatus: ReproductiveStatus.lactating),
        buildReproductionRecord(),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire for a non-lactating animal', () {
      final tips = evaluateReproductionRules(
        buildAnimal(reproductiveStatus: ReproductiveStatus.active),
        buildReproductionRecord(),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateReproductionRules — consanguinity warning', () {
    test('asks to register the sire identity when missing', () {
      final tips = evaluateReproductionRules(
        buildAnimal(),
        buildReproductionRecord(
          serviceType: ServiceType.naturalService,
          maleSireUuid: null,
        ),
      );

      expect(
        tips.map((t) => t.title),
        contains('Registrar identificación del toro'),
      );
    });

    test('warns of direct consanguinity when the sire matches the animal\'s father', () {
      final tips = evaluateReproductionRules(
        buildAnimal(sireUuid: 'bull-1'),
        buildReproductionRecord(
          serviceType: ServiceType.naturalService,
          maleSireUuid: 'bull-1',
        ),
      );

      final tip = tips.firstWhere((t) => t.title == 'Posible consanguinidad directa');
      expect(tip.severity, TipSeverity.critical);
    });

    test('does not warn when the sire is unrelated', () {
      final tips = evaluateReproductionRules(
        buildAnimal(sireUuid: 'bull-1'),
        buildReproductionRecord(
          serviceType: ServiceType.naturalService,
          maleSireUuid: 'bull-2',
        ),
      );

      expect(
        tips.map((t) => t.title),
        isNot(contains('Posible consanguinidad directa')),
      );
    });

    test('flags full siblings as critical once the herd is available', () {
      // Neither animal has the other as a parent, so the pre-pedigree rule
      // could not see this: they share both parents.
      final dam = buildAnimal(
        uuid: 'hembra',
        sireUuid: 'padre',
        damUuid: 'madre',
      );
      final herd = {
        'padre': buildAnimal(uuid: 'padre', sex: Sex.male),
        'madre': buildAnimal(uuid: 'madre'),
        'hermano': buildAnimal(
          uuid: 'hermano',
          sex: Sex.male,
          sireUuid: 'padre',
          damUuid: 'madre',
        ),
        'hembra': dam,
      };

      final tips = evaluateReproductionRules(
        dam,
        buildReproductionRecord(
          serviceType: ServiceType.naturalService,
          maleSireUuid: 'hermano',
        ),
        herd: herd,
      );

      final tip = tips.firstWhere(
        (t) => t.title == 'Consanguinidad cercana detectada',
      );
      expect(tip.severity, TipSeverity.critical);
    });

    test('a shared grandparent is a warning, not critical', () {
      final dam = buildAnimal(uuid: 'hembra', sireUuid: 'p1');
      final herd = {
        'raiz': buildAnimal(uuid: 'raiz', sex: Sex.male),
        'p1': buildAnimal(uuid: 'p1', sex: Sex.male, sireUuid: 'raiz'),
        'p2': buildAnimal(uuid: 'p2', sex: Sex.male, sireUuid: 'raiz'),
        'toro': buildAnimal(uuid: 'toro', sex: Sex.male, sireUuid: 'p2'),
        'hembra': dam,
      };

      final tips = evaluateReproductionRules(
        dam,
        buildReproductionRecord(
          serviceType: ServiceType.naturalService,
          maleSireUuid: 'toro',
        ),
        herd: herd,
      );

      final tip = tips.firstWhere(
        (t) => t.title == 'Parentesco detectado en el pedigrí',
      );
      expect(tip.severity, TipSeverity.warning);
    });

    test('stays silent when the pedigrees are disjoint', () {
      final dam = buildAnimal(uuid: 'hembra', sireUuid: 'a', damUuid: 'b');
      final herd = {
        'hembra': dam,
        'toro': buildAnimal(uuid: 'toro', sex: Sex.male, sireUuid: 'c'),
      };

      final tips = evaluateReproductionRules(
        dam,
        buildReproductionRecord(
          serviceType: ServiceType.naturalService,
          maleSireUuid: 'toro',
        ),
        herd: herd,
      );

      expect(
        tips.map((t) => t.title),
        isNot(contains('Parentesco detectado en el pedigrí')),
      );
      expect(
        tips.map((t) => t.title),
        isNot(contains('Consanguinidad cercana detectada')),
      );
    });

    test('does not fire for artificial insemination', () {
      final tips = evaluateReproductionRules(
        buildAnimal(),
        buildReproductionRecord(
          serviceType: ServiceType.artificialInsemination,
          maleSireUuid: null,
        ),
      );

      expect(
        tips.map((t) => t.title),
        isNot(contains('Registrar identificación del toro')),
      );
    });
  });

  group('evaluateReproductionRules — seasonal breeding tip', () {
    const title = 'Fuera de temporada reproductiva natural';

    test('fires for sheep serviced off-season', () {
      final tips = evaluateReproductionRules(
        buildAnimal(species: Species.sheep),
        buildReproductionRecord(serviceDate: DateTime(2024, 9, 1)),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire for sheep serviced in-season', () {
      final tips = evaluateReproductionRules(
        buildAnimal(species: Species.sheep),
        buildReproductionRecord(serviceDate: DateTime(2024, 4, 1)),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });

    test('does not fire for cattle regardless of month', () {
      final tips = evaluateReproductionRules(
        buildAnimal(species: Species.cattle),
        buildReproductionRecord(serviceDate: DateTime(2024, 9, 1)),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });

  group('evaluateReproductionRules — body condition for service', () {
    test('warns when body condition is below 3', () {
      final tips = evaluateReproductionRules(
        buildAnimal(bodyConditionScore: 2),
        buildReproductionRecord(),
      );

      expect(tips.any((t) => t.title.startsWith('Condición corporal baja')), isTrue);
    });

    test('does not fire at or above 3', () {
      final tips = evaluateReproductionRules(
        buildAnimal(bodyConditionScore: 3),
        buildReproductionRecord(),
      );

      expect(tips.any((t) => t.title.startsWith('Condición corporal baja')), isFalse);
    });

    test('does not fire without a recorded score', () {
      final tips = evaluateReproductionRules(
        buildAnimal(bodyConditionScore: null),
        buildReproductionRecord(),
      );

      expect(tips.any((t) => t.title.startsWith('Condición corporal baja')), isFalse);
    });
  });

  group('evaluateReproductionRules — repeated service failure', () {
    const title = 'Múltiples servicios sin preñez';

    test('warns after 3+ estrous cycles without conception', () {
      final firstService = DateTime(2024, 1, 1);
      final tips = evaluateReproductionRules(
        buildAnimal(
          reproductiveStatus: ReproductiveStatus.active,
          firstServiceDate: firstService,
          lastServiceDate: firstService.add(const Duration(days: 42)),
        ),
        buildReproductionRecord(serviceDate: firstService.add(const Duration(days: 63))),
      );

      expect(tips.map((t) => t.title), contains(title));
    });

    test('does not fire before 3 cycles have passed', () {
      final firstService = DateTime(2024, 1, 1);
      final tips = evaluateReproductionRules(
        buildAnimal(
          reproductiveStatus: ReproductiveStatus.active,
          firstServiceDate: firstService,
          lastServiceDate: firstService.add(const Duration(days: 21)),
        ),
        buildReproductionRecord(serviceDate: firstService.add(const Duration(days: 30))),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });

    test('does not fire for a non-active reproductive status', () {
      final firstService = DateTime(2024, 1, 1);
      final tips = evaluateReproductionRules(
        buildAnimal(
          reproductiveStatus: ReproductiveStatus.pregnant,
          firstServiceDate: firstService,
          lastServiceDate: firstService.add(const Duration(days: 42)),
        ),
        buildReproductionRecord(serviceDate: firstService.add(const Duration(days: 63))),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });

    test('does not fire without first/last service dates on record', () {
      final tips = evaluateReproductionRules(
        buildAnimal(reproductiveStatus: ReproductiveStatus.active),
        buildReproductionRecord(),
      );

      expect(tips.map((t) => t.title), isNot(contains(title)));
    });
  });
}
