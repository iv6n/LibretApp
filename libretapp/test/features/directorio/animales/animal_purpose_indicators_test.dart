/// Unit tests for the purpose-aware card indicators.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';

final _now = DateTime(2026, 6, 1);

AnimalEntity _animal({
  ProductionPurpose purpose = ProductionPurpose.meat,
  ReproductiveStatus reproductiveStatus = ReproductiveStatus.active,
  double? weight,
  double? dailyGainEstimate,
  int ageMonths = 36,
  int? bodyConditionScore,
  HealthStatus healthStatus = HealthStatus.good,
  DateTime? lastServiceDate,
}) {
  return AnimalEntity(
    uuid: 'a1',
    earTagNumber: '001',
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: 'Brahman',
    birthDate: DateTime(2023, 6, 1),
    ageMonths: ageMonths,
    weight: weight,
    dailyGainEstimate: dailyGainEstimate,
    bodyConditionScore: bodyConditionScore,
    healthStatus: healthStatus,
    vaccinated: true,
    dewormed: true,
    hasVitamins: true,
    hasChronicIssues: false,
    reproductiveStatus: reproductiveStatus,
    lastServiceDate: lastServiceDate,
    productionPurpose: purpose,
    productionStage: ProductionStage.reproductive,
    productionSystem: ProductionSystem.extensive,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.none,
    gallery: const [],
    status: AnimalStatus.active,
    synced: true,
    creationDate: _now,
    lastUpdateDate: _now,
  );
}

List<PurposeIndicatorKind> _kinds(List<PurposeIndicator> indicators) =>
    indicators.map((i) => i.kind).toList();

void main() {
  group('every purpose produces at least one indicator', () {
    // The old widget switch returned null for eggs, fiber, sport, guard and
    // companion, leaving those cards with no indicator at all.
    for (final purpose in ProductionPurpose.values) {
      test(purpose.name, () {
        final indicators = indicatorsFor(
          _animal(purpose: purpose, weight: 400),
          now: _now,
        );

        if (purpose == ProductionPurpose.other) {
          expect(indicators, isEmpty);
        } else {
          expect(indicators, isNotEmpty, reason: 'purpose ${purpose.name}');
        }
      });
    }
  });

  group('meat', () {
    test('prefers measured gain over the typed estimate', () {
      final indicators = indicatorsFor(
        _animal(purpose: ProductionPurpose.meat, weight: 300, dailyGainEstimate: 0.4),
        snapshot: const AnimalIndicatorSnapshot(
          lastWeightKg: 420,
          averageDailyGainKg: 0.9,
        ),
        now: _now,
      );

      expect(indicators.map((i) => i.label), contains('420 kg'));
      expect(indicators.map((i) => i.label), contains('+0.9 kg/día'));
    });

    test('flags weight loss as attention', () {
      final indicators = indicatorsFor(
        _animal(purpose: ProductionPurpose.meat, weight: 300),
        snapshot: const AnimalIndicatorSnapshot(averageDailyGainKg: -0.3),
        now: _now,
      );

      final gain = indicators.firstWhere(
        (i) => i.kind == PurposeIndicatorKind.dailyGain,
      );
      expect(gain.severity, IndicatorSeverity.attention);
      expect(gain.label, '-0.3 kg/día');
    });
  });

  group('dairy', () {
    test('shows litres per day and days in milk', () {
      final indicators = indicatorsFor(
        _animal(
          purpose: ProductionPurpose.dairy,
          reproductiveStatus: ReproductiveStatus.lactating,
        ),
        snapshot: const AnimalIndicatorSnapshot(
          milkLitersPerDay: 12.5,
          daysInMilk: 90,
        ),
        now: _now,
      );

      expect(indicators.map((i) => i.label), contains('12.5 L/día'));
      expect(indicators.map((i) => i.label), contains('90 d. lactancia'));
    });

    test('falls back to the stored state when nothing is measured', () {
      final indicators = indicatorsFor(
        _animal(
          purpose: ProductionPurpose.dairy,
          reproductiveStatus: ReproductiveStatus.dry,
        ),
        now: _now,
      );

      expect(_kinds(indicators), contains(PurposeIndicatorKind.reproductiveState));
    });
  });

  group('breeding', () {
    test('surfaces IEP and calving count from the KPIs', () {
      final indicators = indicatorsFor(
        _animal(purpose: ProductionPurpose.breeding),
        snapshot: const AnimalIndicatorSnapshot(
          reproductiveKpis: AnimalReproductiveKpis(
            calvingCount: 3,
            serviceCount: 4,
            calvingIntervalsDays: [380, 400],
            averageCalvingIntervalDays: 390,
          ),
        ),
        now: _now,
      );

      expect(indicators.map((i) => i.label), contains('IEP 390 d'));
      expect(indicators.map((i) => i.label), contains('3 partos'));
    });

    test('flags an interval that already cost a calf', () {
      final indicators = indicatorsFor(
        _animal(purpose: ProductionPurpose.breeding),
        snapshot: const AnimalIndicatorSnapshot(
          reproductiveKpis: AnimalReproductiveKpis(
            calvingCount: 2,
            serviceCount: 2,
            calvingIntervalsDays: [500],
            averageCalvingIntervalDays: 500,
          ),
        ),
        now: _now,
      );

      final iep = indicators.firstWhere(
        (i) => i.kind == PurposeIndicatorKind.calvingInterval,
      );
      expect(iep.severity, IndicatorSeverity.attention);
    });

    test('flags a long open period', () {
      final indicators = indicatorsFor(
        _animal(purpose: ProductionPurpose.breeding),
        snapshot: const AnimalIndicatorSnapshot(
          reproductiveKpis: AnimalReproductiveKpis(
            calvingCount: 1,
            serviceCount: 1,
            calvingIntervalsDays: [],
            daysOpen: 200,
            daysOpenIsOngoing: true,
          ),
        ),
        now: _now,
      );

      final open = indicators.firstWhere(
        (i) => i.kind == PurposeIndicatorKind.daysOpen,
      );
      expect(open.label, '200 d. abierta');
      expect(open.severity, IndicatorSeverity.attention);
    });

    test('reports an overdue calving as critical', () {
      final indicators = indicatorsFor(
        _animal(purpose: ProductionPurpose.breeding),
        snapshot: AnimalIndicatorSnapshot(
          reproductiveKpis: AnimalReproductiveKpis(
            calvingCount: 0,
            serviceCount: 1,
            calvingIntervalsDays: const [],
            currentGestationDays: 295,
            expectedCalvingDate: _now.subtract(const Duration(days: 12)),
          ),
        ),
        now: _now,
      );

      expect(indicators.first.kind, PurposeIndicatorKind.overdueCalving);
      expect(indicators.first.severity, IndicatorSeverity.critical);
      expect(indicators.first.label, 'Parto vencido 12 d');
    });
  });

  group('severity and limits', () {
    test('an active withdrawal outranks every statistic', () {
      final indicators = indicatorsFor(
        _animal(purpose: ProductionPurpose.dairy),
        snapshot: AnimalIndicatorSnapshot(
          milkLitersPerDay: 20,
          daysInMilk: 100,
          withdrawalEndsOn: _now.add(const Duration(days: 3)),
        ),
        now: _now,
      );

      expect(indicators.first.kind, PurposeIndicatorKind.milkWithdrawal);
      expect(indicators.first.severity, IndicatorSeverity.critical);
      expect(indicators.first.label, 'Retiro 4 días');
    });

    test('an expired withdrawal is not shown', () {
      final indicators = indicatorsFor(
        _animal(purpose: ProductionPurpose.dairy),
        snapshot: AnimalIndicatorSnapshot(
          withdrawalEndsOn: _now.subtract(const Duration(days: 1)),
        ),
        now: _now,
      );

      expect(_kinds(indicators), isNot(contains(PurposeIndicatorKind.milkWithdrawal)));
    });

    test('never returns more than the requested number of chips', () {
      final indicators = indicatorsFor(
        _animal(purpose: ProductionPurpose.breeding),
        snapshot: AnimalIndicatorSnapshot(
          withdrawalEndsOn: _now.add(const Duration(days: 5)),
          reproductiveKpis: const AnimalReproductiveKpis(
            calvingCount: 4,
            serviceCount: 5,
            calvingIntervalsDays: [400, 400, 400],
            averageCalvingIntervalDays: 400,
            daysOpen: 300,
            daysOpenIsOngoing: true,
          ),
        ),
        now: _now,
        maxIndicators: 2,
      );

      expect(indicators, hasLength(2));
      expect(indicators.first.kind, PurposeIndicatorKind.milkWithdrawal);
    });
  });

  test('undefined purpose turns the gap into an action', () {
    final indicators = indicatorsFor(
      _animal(purpose: ProductionPurpose.undefined),
      now: _now,
    );

    expect(indicators.single.kind, PurposeIndicatorKind.definePurpose);
    expect(indicators.single.severity, IndicatorSeverity.attention);
  });

  test('degrades to entity fields when there is no snapshot', () {
    final indicators = indicatorsFor(
      _animal(
        purpose: ProductionPurpose.meat,
        weight: 355.5,
        dailyGainEstimate: 0.6,
      ),
      now: _now,
    );

    expect(indicators.map((i) => i.label), contains('355.5 kg'));
    expect(indicators.map((i) => i.label), contains('+0.6 kg/día'));
  });
}
