/// Unit tests for [ReproductiveKpiService] — pure domain, no Isar.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/services/reproductive_kpi_service.dart';

ReproductionRecord _record({
  required DateTime serviceDate,
  PregnancyCheckResult? pregnancyResult,
  DateTime? actualCalvingDate,
  DateTime? expectedCalvingDate,
}) {
  return ReproductionRecord(
    serviceDate: serviceDate,
    serviceType: ServiceType.naturalService,
    pregnancyResult: pregnancyResult,
    actualCalvingDate: actualCalvingDate,
    expectedCalvingDate: expectedCalvingDate,
  );
}

void main() {
  const service = ReproductiveKpiService();

  group('forAnimal', () {
    test('returns empty for an animal with no records', () {
      final kpis = service.forAnimal(records: const []);

      expect(kpis, AnimalReproductiveKpis.empty);
      expect(kpis.hasCalved, isFalse);
      expect(kpis.isPregnant, isFalse);
    });

    test('computes calving interval (IEP) across consecutive calvings', () {
      final kpis = service.forAnimal(
        records: [
          _record(
            serviceDate: DateTime(2022, 1, 1),
            actualCalvingDate: DateTime(2022, 10, 11),
          ),
          _record(
            serviceDate: DateTime(2023, 1, 1),
            actualCalvingDate: DateTime(2023, 10, 11),
          ),
          _record(
            serviceDate: DateTime(2024, 1, 1),
            actualCalvingDate: DateTime(2024, 10, 10),
          ),
        ],
        now: DateTime(2025, 1, 1),
      );

      expect(kpis.calvingCount, 3);
      expect(kpis.calvingIntervalsDays, [365, 365]);
      expect(kpis.averageCalvingIntervalDays, 365);
      expect(kpis.lastCalvingIntervalDays, 365);
    });

    test('leaves IEP null until a second calving exists', () {
      final kpis = service.forAnimal(
        records: [
          _record(
            serviceDate: DateTime(2023, 1, 1),
            actualCalvingDate: DateTime(2023, 10, 11),
          ),
        ],
        now: DateTime(2024, 1, 1),
      );

      expect(kpis.calvingCount, 1);
      expect(kpis.averageCalvingIntervalDays, isNull);
    });

    test('computes age at first calving from the birth date', () {
      final kpis = service.forAnimal(
        records: [
          _record(
            serviceDate: DateTime(2023, 1, 1),
            actualCalvingDate: DateTime(2023, 10, 11),
          ),
          _record(
            serviceDate: DateTime(2024, 1, 1),
            actualCalvingDate: DateTime(2024, 10, 10),
          ),
        ],
        birthDate: DateTime(2020, 10, 11),
        now: DateTime(2025, 1, 1),
      );

      // First calving at exactly 3 years.
      expect(kpis.ageAtFirstCalvingMonths, 36);
    });

    test('counts services per confirmed conception', () {
      final kpis = service.forAnimal(
        records: [
          _record(
            serviceDate: DateTime(2024, 1, 1),
            pregnancyResult: PregnancyCheckResult.negative,
          ),
          _record(
            serviceDate: DateTime(2024, 2, 1),
            pregnancyResult: PregnancyCheckResult.negative,
          ),
          _record(
            serviceDate: DateTime(2024, 3, 1),
            pregnancyResult: PregnancyCheckResult.positive,
          ),
        ],
        now: DateTime(2024, 6, 1),
      );

      expect(kpis.serviceCount, 3);
      expect(kpis.servicesPerConception, 3);
    });

    test('measures days open up to the conception that followed', () {
      final kpis = service.forAnimal(
        records: [
          _record(
            serviceDate: DateTime(2023, 1, 1),
            actualCalvingDate: DateTime(2023, 10, 11),
          ),
          _record(
            serviceDate: DateTime(2023, 12, 20),
            pregnancyResult: PregnancyCheckResult.positive,
          ),
        ],
        now: DateTime(2024, 3, 1),
      );

      expect(kpis.daysOpen, 70);
      expect(kpis.daysOpenIsOngoing, isFalse);
    });

    test('reports a running days-open count while still not pregnant', () {
      final kpis = service.forAnimal(
        records: [
          _record(
            serviceDate: DateTime(2023, 1, 1),
            actualCalvingDate: DateTime(2023, 10, 11),
          ),
        ],
        now: DateTime(2023, 12, 10),
      );

      expect(kpis.daysOpen, 60);
      expect(kpis.daysOpenIsOngoing, isTrue);
    });

    test('tracks the current gestation for an open confirmed cycle', () {
      final kpis = service.forAnimal(
        records: [
          _record(
            serviceDate: DateTime(2024, 1, 1),
            pregnancyResult: PregnancyCheckResult.positive,
            expectedCalvingDate: DateTime(2024, 10, 10),
          ),
        ],
        now: DateTime(2024, 4, 10),
      );

      expect(kpis.isPregnant, isTrue);
      expect(kpis.currentGestationDays, 100);
      expect(kpis.expectedCalvingDate, DateTime(2024, 10, 10));
    });

    test('a cycle that already calved is not counted as pregnant', () {
      final kpis = service.forAnimal(
        records: [
          _record(
            serviceDate: DateTime(2024, 1, 1),
            pregnancyResult: PregnancyCheckResult.positive,
            actualCalvingDate: DateTime(2024, 10, 10),
          ),
        ],
        now: DateTime(2024, 12, 1),
      );

      expect(kpis.isPregnant, isFalse);
      expect(kpis.currentGestationDays, isNull);
    });
  });

  group('cycle helpers', () {
    test('pendingDiagnosisOf picks the latest undiagnosed service', () {
      final records = [
        _record(serviceDate: DateTime(2026, 1, 1)),
        _record(serviceDate: DateTime(2026, 3, 1)),
      ];

      expect(
        ReproductiveKpiService.pendingDiagnosisOf(records)!.serviceDate,
        DateTime(2026, 3, 1),
      );
    });

    test('an uncertain result still counts as pending', () {
      // An inconclusive palpation is precisely the case that needs a repeat.
      final records = [
        _record(
          serviceDate: DateTime(2026, 1, 1),
          pregnancyResult: PregnancyCheckResult.uncertain,
        ),
      ];

      expect(ReproductiveKpiService.pendingDiagnosisOf(records), isNotNull);
    });

    test('a diagnosed or calved service is not pending', () {
      expect(
        ReproductiveKpiService.pendingDiagnosisOf([
          _record(
            serviceDate: DateTime(2026, 1, 1),
            pregnancyResult: PregnancyCheckResult.positive,
          ),
        ]),
        isNull,
      );
      expect(
        ReproductiveKpiService.pendingDiagnosisOf([
          _record(
            serviceDate: DateTime(2026, 1, 1),
            actualCalvingDate: DateTime(2026, 10, 1),
          ),
        ]),
        isNull,
      );
    });

    test('openCycleOf ignores a cycle that already calved', () {
      final records = [
        _record(
          serviceDate: DateTime(2026, 1, 1),
          pregnancyResult: PregnancyCheckResult.positive,
          actualCalvingDate: DateTime(2026, 10, 1),
        ),
      ];

      expect(ReproductiveKpiService.openCycleOf(records), isNull);
    });
  });

  group('forHerd', () {
    test('aggregates pregnancy rate, calving months and worst intervals', () {
      final herd = service.forHerd(
        recordsByAnimal: {
          'vaca-eficiente': [
            _record(
              serviceDate: DateTime(2022, 1, 1),
              actualCalvingDate: DateTime(2022, 10, 11),
            ),
            _record(
              serviceDate: DateTime(2023, 1, 1),
              actualCalvingDate: DateTime(2023, 10, 11),
            ),
          ],
          'vaca-lenta': [
            _record(
              serviceDate: DateTime(2021, 1, 1),
              actualCalvingDate: DateTime(2021, 10, 11),
            ),
            _record(
              serviceDate: DateTime(2023, 1, 1),
              actualCalvingDate: DateTime(2023, 10, 11),
            ),
          ],
          'vaca-gestante': [
            _record(
              serviceDate: DateTime(2024, 1, 1),
              pregnancyResult: PregnancyCheckResult.positive,
            ),
          ],
        },
        now: DateTime(2024, 6, 1),
      );

      expect(herd.femalesEvaluated, 3);
      expect(herd.pregnantCount, 1);
      expect(herd.pregnancyRate, closeTo(1 / 3, 0.001));
      // Every calving above happened in October.
      expect(herd.calvingsByMonth, {10: 4});
      expect(herd.calvingsInPeriod, 4);
      // The slow cow's ~730-day interval must rank first for culling.
      expect(herd.longestIntervals.first.animalUuid, 'vaca-lenta');
      expect(herd.longestIntervals, hasLength(2));
    });

    test('restricts the calving count to the requested period', () {
      final herd = service.forHerd(
        recordsByAnimal: {
          'vaca': [
            _record(
              serviceDate: DateTime(2022, 1, 1),
              actualCalvingDate: DateTime(2022, 10, 11),
            ),
            _record(
              serviceDate: DateTime(2023, 1, 1),
              actualCalvingDate: DateTime(2023, 10, 11),
            ),
          ],
        },
        periodStart: DateTime(2023, 1, 1),
        periodEnd: DateTime(2023, 12, 31),
        now: DateTime(2024, 1, 1),
      );

      expect(herd.calvingsInPeriod, 1);
      expect(herd.calvingsByMonth, {10: 1});
    });

    test('returns empty for an empty herd', () {
      final herd = service.forHerd(recordsByAnimal: const {});

      expect(herd, HerdReproductiveKpis.empty);
    });
  });
}
