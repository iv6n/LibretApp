/// features › directorio › animales › domain › services › reproductive_kpi_service — reproductive efficiency indicators.
library;

import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_lifecycle_calculator.dart';

/// Reproductive efficiency of a single female.
class AnimalReproductiveKpis {
  const AnimalReproductiveKpis({
    required this.calvingCount,
    required this.serviceCount,
    required this.calvingIntervalsDays,
    this.ageAtFirstCalvingMonths,
    this.averageCalvingIntervalDays,
    this.lastCalvingIntervalDays,
    this.daysOpen,
    this.daysOpenIsOngoing = false,
    this.servicesPerConception,
    this.currentGestationDays,
    this.lastCalvingDate,
    this.expectedCalvingDate,
  });

  static const AnimalReproductiveKpis empty = AnimalReproductiveKpis(
    calvingCount: 0,
    serviceCount: 0,
    calvingIntervalsDays: <int>[],
  );

  final int calvingCount;
  final int serviceCount;

  /// Days between each pair of consecutive calvings, oldest pair first.
  final List<int> calvingIntervalsDays;

  /// Age at first calving. Late first calvings mean a heifer that ate for
  /// months without producing.
  final int? ageAtFirstCalvingMonths;

  /// Intervalo entre partos (IEP) — the master efficiency figure for a
  /// breeding female. Null until she has calved at least twice.
  final double? averageCalvingIntervalDays;

  final int? lastCalvingIntervalDays;

  /// Days from the last calving to the conception that followed it. When
  /// [daysOpenIsOngoing] is true she has not conceived again yet and this is
  /// the running count, which only grows.
  final int? daysOpen;
  final bool daysOpenIsOngoing;

  /// Services needed per confirmed pregnancy. 1.0 is perfect; above ~2.0 the
  /// cost of semen, labour and lost days starts to bite.
  final double? servicesPerConception;

  final int? currentGestationDays;
  final DateTime? lastCalvingDate;
  final DateTime? expectedCalvingDate;

  bool get hasCalved => calvingCount > 0;
  bool get isPregnant => currentGestationDays != null;
}

/// One female's interval, for ranking the herd.
class AnimalCalvingInterval {
  const AnimalCalvingInterval({
    required this.animalUuid,
    required this.averageIntervalDays,
    required this.calvingCount,
  });

  final String animalUuid;
  final double averageIntervalDays;
  final int calvingCount;
}

/// Aggregate reproductive performance across the herd.
class HerdReproductiveKpis {
  const HerdReproductiveKpis({
    required this.femalesEvaluated,
    required this.pregnantCount,
    required this.calvingsInPeriod,
    required this.calvingsByMonth,
    required this.longestIntervals,
    this.pregnancyRate,
    this.averageCalvingIntervalDays,
    this.averageServicesPerConception,
  });

  static const HerdReproductiveKpis empty = HerdReproductiveKpis(
    femalesEvaluated: 0,
    pregnantCount: 0,
    calvingsInPeriod: 0,
    calvingsByMonth: <int, int>{},
    longestIntervals: <AnimalCalvingInterval>[],
  );

  final int femalesEvaluated;
  final int pregnantCount;
  final int calvingsInPeriod;

  /// Calendar month (1–12) to number of calvings. A herd meant to calve in a
  /// tight season shows a spike; a flat spread means the breeding season has
  /// drifted.
  final Map<int, int> calvingsByMonth;

  /// Females with the worst interval first — the culling shortlist.
  final List<AnimalCalvingInterval> longestIntervals;

  final double? pregnancyRate;
  final double? averageCalvingIntervalDays;
  final double? averageServicesPerConception;
}

/// Computes reproductive indicators from reproduction records.
///
/// Pure and I/O free: callers hand over the records they already loaded. Note
/// that weaning rate deliberately lives outside this service — there is no
/// weaning event in the model yet, and deriving it from birth records alone
/// would overstate it by counting calves that died before weaning.
class ReproductiveKpiService {
  const ReproductiveKpiService();

  /// The cycle awaiting a calving: confirmed pregnant and not yet calved.
  ///
  /// Returns the most recent one, so a re-service after a failed pregnancy
  /// wins over the older record. Shared with the calving flow so the
  /// definition of "open cycle" lives in exactly one place.
  static ReproductionRecord? openCycleOf(List<ReproductionRecord> records) {
    final open = records
        .where(
          (record) =>
              !record.hasCalved &&
              record.pregnancyResult == PregnancyCheckResult.positive,
        )
        .toList()
      ..sort((a, b) => a.serviceDate.compareTo(b.serviceDate));

    return open.isEmpty ? null : open.last;
  }

  AnimalReproductiveKpis forAnimal({
    required List<ReproductionRecord> records,
    DateTime? birthDate,
    DateTime? now,
  }) {
    if (records.isEmpty) return AnimalReproductiveKpis.empty;

    final reference = now ?? DateTime.now();

    final ordered = [...records]
      ..sort((a, b) => a.serviceDate.compareTo(b.serviceDate));

    final calvingDates =
        ordered
            .map((record) => record.actualCalvingDate)
            .whereType<DateTime>()
            .toList()
          ..sort();

    final intervals = <int>[];
    for (var i = 1; i < calvingDates.length; i++) {
      intervals.add(calvingDates[i].difference(calvingDates[i - 1]).inDays);
    }

    final averageInterval = intervals.isEmpty
        ? null
        : intervals.reduce((a, b) => a + b) / intervals.length;

    final confirmedPregnancies = ordered.where(_isConfirmedPregnancy).length;
    final servicesPerConception = confirmedPregnancies == 0
        ? null
        : ordered.length / confirmedPregnancies;

    final lastCalving = calvingDates.isEmpty ? null : calvingDates.last;

    int? daysOpen;
    var daysOpenIsOngoing = false;
    if (lastCalving != null) {
      final nextConception = ordered
          .where(
            (record) =>
                record.serviceDate.isAfter(lastCalving) &&
                _isConfirmedPregnancy(record),
          )
          .map((record) => record.serviceDate)
          .fold<DateTime?>(
            null,
            (earliest, date) =>
                earliest == null || date.isBefore(earliest) ? date : earliest,
          );

      if (nextConception != null) {
        daysOpen = nextConception.difference(lastCalving).inDays;
      } else if (!reference.isBefore(lastCalving)) {
        daysOpen = reference.difference(lastCalving).inDays;
        daysOpenIsOngoing = true;
      }
    }

    final openCycle = openCycleOf(ordered);

    final currentGestationDays =
        openCycle != null && !reference.isBefore(openCycle.serviceDate)
        ? reference.difference(openCycle.serviceDate).inDays
        : null;

    return AnimalReproductiveKpis(
      calvingCount: calvingDates.length,
      serviceCount: ordered.length,
      calvingIntervalsDays: intervals,
      ageAtFirstCalvingMonths: birthDate == null || calvingDates.isEmpty
          ? null
          : AnimalLifecycleCalculator.monthsBetween(
              birthDate,
              calvingDates.first,
            ),
      averageCalvingIntervalDays: averageInterval,
      lastCalvingIntervalDays: intervals.isEmpty ? null : intervals.last,
      daysOpen: daysOpen,
      daysOpenIsOngoing: daysOpenIsOngoing,
      servicesPerConception: servicesPerConception,
      currentGestationDays: currentGestationDays,
      lastCalvingDate: lastCalving,
      expectedCalvingDate: openCycle?.expectedCalvingDate,
    );
  }

  /// Aggregates per-animal results. [recordsByAnimal] is keyed by animal uuid;
  /// [periodStart] and [periodEnd] limit which calvings feed the in-period
  /// count and the month distribution.
  HerdReproductiveKpis forHerd({
    required Map<String, List<ReproductionRecord>> recordsByAnimal,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? now,
    int longestIntervalsLimit = 5,
  }) {
    if (recordsByAnimal.isEmpty) return HerdReproductiveKpis.empty;

    final reference = now ?? DateTime.now();

    var pregnantCount = 0;
    var calvingsInPeriod = 0;
    final calvingsByMonth = <int, int>{};
    final intervals = <AnimalCalvingInterval>[];
    final intervalAverages = <double>[];
    final serviceRatios = <double>[];

    for (final entry in recordsByAnimal.entries) {
      final kpis = forAnimal(records: entry.value, now: reference);

      if (kpis.isPregnant) pregnantCount++;

      final average = kpis.averageCalvingIntervalDays;
      if (average != null) {
        intervalAverages.add(average);
        intervals.add(
          AnimalCalvingInterval(
            animalUuid: entry.key,
            averageIntervalDays: average,
            calvingCount: kpis.calvingCount,
          ),
        );
      }

      final ratio = kpis.servicesPerConception;
      if (ratio != null) serviceRatios.add(ratio);

      for (final record in entry.value) {
        final calving = record.actualCalvingDate;
        if (calving == null) continue;
        if (periodStart != null && calving.isBefore(periodStart)) continue;
        if (periodEnd != null && calving.isAfter(periodEnd)) continue;
        calvingsInPeriod++;
        calvingsByMonth.update(
          calving.month,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }

    intervals.sort(
      (a, b) => b.averageIntervalDays.compareTo(a.averageIntervalDays),
    );

    final females = recordsByAnimal.length;

    return HerdReproductiveKpis(
      femalesEvaluated: females,
      pregnantCount: pregnantCount,
      calvingsInPeriod: calvingsInPeriod,
      calvingsByMonth: calvingsByMonth,
      longestIntervals: intervals.take(longestIntervalsLimit).toList(),
      pregnancyRate: females == 0 ? null : pregnantCount / females,
      averageCalvingIntervalDays: _average(intervalAverages),
      averageServicesPerConception: _average(serviceRatios),
    );
  }

  /// A service counts as a conception once it is confirmed positive or has
  /// already produced a calving.
  static bool _isConfirmedPregnancy(ReproductionRecord record) {
    return record.pregnancyResult == PregnancyCheckResult.positive ||
        record.actualCalvingDate != null;
  }

  static double? _average(List<double> values) {
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }
}
