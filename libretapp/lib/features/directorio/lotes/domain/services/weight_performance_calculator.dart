/// Domain calculations for animal and lot weighing performance.
library;

import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';
import 'package:libretapp/features/directorio/lotes/alimentacion/feed_models.dart';

enum WeightClassification { good, belowAverage, noGain, noReference }

class AnimalWeightPerformance {
  const AnimalWeightPerformance({
    required this.animalUuid,
    required this.currentWeightKg,
    required this.measuredAt,
    this.previousWeightKg,
    this.previousMeasuredAt,
    this.gainKg,
    this.daysBetween,
    this.adgKgPerDay,
    this.classification = WeightClassification.noReference,
  });

  final String animalUuid;
  final double currentWeightKg;
  final DateTime measuredAt;
  final double? previousWeightKg;
  final DateTime? previousMeasuredAt;
  final double? gainKg;
  final int? daysBetween;
  final double? adgKgPerDay;
  final WeightClassification classification;

  AnimalWeightPerformance withClassification(WeightClassification value) =>
      AnimalWeightPerformance(
        animalUuid: animalUuid,
        currentWeightKg: currentWeightKg,
        measuredAt: measuredAt,
        previousWeightKg: previousWeightKg,
        previousMeasuredAt: previousMeasuredAt,
        gainKg: gainKg,
        daysBetween: daysBetween,
        adgKgPerDay: adgKgPerDay,
        classification: value,
      );
}

class WeighingSessionSummary {
  const WeighingSessionSummary({
    required this.date,
    required this.measuredAnimalCount,
    required this.totalWeightKg,
    required this.averageWeightKg,
    required this.totalGainKg,
    required this.averageAdgKgPerDay,
  });

  final DateTime date;
  final int measuredAnimalCount;
  final double totalWeightKg;
  final double? averageWeightKg;
  final double? totalGainKg;
  final double? averageAdgKgPerDay;
}

class LotPerformanceSummary {
  const LotPerformanceSummary({
    required this.lotUuid,
    required this.activeAnimalCount,
    required this.measuredAnimalCount,
    required this.totalWeightKg,
    required this.averageWeightKg,
    required this.totalGainKg,
    required this.averageAdgKgPerDay,
    required this.latestMeasuredAt,
    required this.previousSession,
    required this.performances,
    required this.goodCount,
    required this.belowAverageCount,
    required this.noGainCount,
    required this.noReferenceCount,
  });

  final String lotUuid;
  final int activeAnimalCount;
  final int measuredAnimalCount;
  final double totalWeightKg;
  final double? averageWeightKg;
  final double? totalGainKg;
  final double? averageAdgKgPerDay;
  final DateTime? latestMeasuredAt;
  final WeighingSessionSummary? previousSession;
  final List<AnimalWeightPerformance> performances;
  final int goodCount;
  final int belowAverageCount;
  final int noGainCount;
  final int noReferenceCount;

  int get unmeasuredAnimalCount =>
      (activeAnimalCount - measuredAnimalCount).clamp(0, activeAnimalCount);
}

class LotEconomicMetrics {
  const LotEconomicMetrics({
    this.feedPricePerKg,
    this.dailyFeedKgPerHead,
    this.dailyFeedCost,
    this.adgKgPerDay,
    this.feedCostPerKgGain,
    this.liveWeightPricePerKg,
    this.dailyWeightValue,
    this.feedMargin,
  });

  final double? feedPricePerKg;
  final double? dailyFeedKgPerHead;
  final double? dailyFeedCost;
  final double? adgKgPerDay;
  final double? feedCostPerKgGain;
  final double? liveWeightPricePerKg;
  final double? dailyWeightValue;
  final double? feedMargin;
}

/// Keeps all performance arithmetic out of widgets and blocs.
class WeightPerformanceCalculator {
  const WeightPerformanceCalculator();

  double? calculateWeightGain({
    required double currentWeightKg,
    required double? previousWeightKg,
  }) {
    if (!_isFinite(currentWeightKg) ||
        currentWeightKg <= 0 ||
        previousWeightKg == null ||
        !_isFinite(previousWeightKg) ||
        previousWeightKg <= 0) {
      return null;
    }
    return currentWeightKg - previousWeightKg;
  }

  int? calculateDaysBetween(DateTime current, DateTime previous) {
    final days = _dateOnly(current).difference(_dateOnly(previous)).inDays;
    return days < 0 ? null : days;
  }

  double? calculateADG({required double? gainKg, required int? days}) {
    if (gainKg == null || days == null || days <= 0) return null;
    return gainKg / days;
  }

  double calculateLotTotalWeight(Iterable<double> weights) =>
      weights.where(_isFinite).fold(0, (sum, weight) => sum + weight);

  double? calculateLotAverageWeight(Iterable<double> weights) {
    final valid = weights.where(_isFinite).toList(growable: false);
    if (valid.isEmpty) return null;
    return calculateLotTotalWeight(valid) / valid.length;
  }

  double? calculateLotADG(Iterable<double?> adgs) {
    final valid = adgs
        .where((value) => value != null && _isFinite(value))
        .cast<double>()
        .toList(growable: false);
    if (valid.isEmpty) return null;
    return valid.fold<double>(0, (sum, value) => sum + value) / valid.length;
  }

  AnimalWeightPerformance calculateAnimalPerformance({
    required String animalUuid,
    required double currentWeightKg,
    required DateTime measuredAt,
    required Iterable<WeightRecord> history,
    String? currentRecordUuid,
    WeightMethod currentMethod = WeightMethod.scale,
  }) {
    final sorted = history.toList(growable: false)..sort(_compareNewestFirst);
    final previous = currentMethod == WeightMethod.scale
        ? _findPrevious(
            sorted,
            measuredAt: measuredAt,
            currentRecordUuid: currentRecordUuid,
          )
        : null;
    final gain = calculateWeightGain(
      currentWeightKg: currentWeightKg,
      previousWeightKg: previous?.weight,
    );
    final days = previous == null
        ? null
        : calculateDaysBetween(measuredAt, previous.date);

    return AnimalWeightPerformance(
      animalUuid: animalUuid,
      currentWeightKg: currentWeightKg,
      measuredAt: measuredAt,
      previousWeightKg: previous?.weight,
      previousMeasuredAt: previous?.date,
      gainKg: gain,
      daysBetween: days,
      adgKgPerDay: calculateADG(gainKg: gain, days: days),
    );
  }

  LotPerformanceSummary calculateLotPerformance({
    required String lotUuid,
    required Iterable<String> activeAnimalUuids,
    required Map<String, List<WeightRecord>> histories,
    DateTime? sessionDate,
  }) {
    final active = activeAnimalUuids.toSet();
    final allRecords = histories.values.expand((records) => records);
    final lotRecords = allRecords
        .where((record) => record.lotUuid == lotUuid)
        .toList(growable: false);
    final currentDate = sessionDate == null
        ? _latestDay(lotRecords)
        : _dateOnly(sessionDate);
    final performances = <AnimalWeightPerformance>[];

    if (currentDate != null) {
      for (final animalUuid in active) {
        final current = _latestForDay(
          histories[animalUuid] ?? const [],
          lotUuid: lotUuid,
          day: currentDate,
        );
        if (current == null) continue;
        performances.add(
          calculateAnimalPerformance(
            animalUuid: animalUuid,
            currentWeightKg: current.weight,
            measuredAt: current.date,
            history: histories[animalUuid] ?? const [],
            currentRecordUuid: current.recordUuid,
            currentMethod: current.method,
          ),
        );
      }
    }

    final averageAdg = calculateLotADG(
      performances.map((performance) => performance.adgKgPerDay),
    );
    final classified = performances
        .map(
          (performance) => performance.withClassification(
            classify(
              adgKgPerDay: performance.adgKgPerDay,
              lotAverageAdgKgPerDay: averageAdg,
            ),
          ),
        )
        .toList(growable: false);
    final currentSession = _sessionFromPerformances(
      date: currentDate,
      performances: classified,
    );
    final previousSession = _previousSession(
      lotUuid: lotUuid,
      records: lotRecords,
      before: currentDate,
      histories: histories,
    );

    return LotPerformanceSummary(
      lotUuid: lotUuid,
      activeAnimalCount: active.length,
      measuredAnimalCount: classified.length,
      totalWeightKg: calculateLotTotalWeight(
        classified.map((performance) => performance.currentWeightKg),
      ),
      averageWeightKg: calculateLotAverageWeight(
        classified.map((performance) => performance.currentWeightKg),
      ),
      totalGainKg: currentSession?.totalGainKg,
      averageAdgKgPerDay: currentSession?.averageAdgKgPerDay,
      latestMeasuredAt: currentDate,
      previousSession: previousSession,
      performances: classified,
      goodCount: _count(classified, WeightClassification.good),
      belowAverageCount: _count(classified, WeightClassification.belowAverage),
      noGainCount: _count(classified, WeightClassification.noGain),
      noReferenceCount: _count(classified, WeightClassification.noReference),
    );
  }

  List<WeighingSessionSummary> calculateWeighingSessions({
    required String lotUuid,
    required Iterable<WeightRecord> records,
    Map<String, List<WeightRecord>> histories = const {},
  }) {
    final byDay = <DateTime, Map<String, WeightRecord>>{};
    for (final record in records.where((item) => item.lotUuid == lotUuid)) {
      final animalUuid = record.animalUuid;
      if (animalUuid == null || animalUuid.isEmpty) continue;
      final day = _dateOnly(record.date);
      final current = byDay.putIfAbsent(
        day,
        () => <String, WeightRecord>{},
      )[animalUuid];
      if (current == null || _compareNewestFirst(record, current) < 0) {
        byDay[day]![animalUuid] = record;
      }
    }

    final sessions = <WeighingSessionSummary>[];
    for (final entry in byDay.entries) {
      final performances = entry.value.entries
          .map((item) {
            final history = histories[item.key] ?? [item.value];
            return calculateAnimalPerformance(
              animalUuid: item.key,
              currentWeightKg: item.value.weight,
              measuredAt: item.value.date,
              history: history,
              currentRecordUuid: item.value.recordUuid,
              currentMethod: item.value.method,
            );
          })
          .toList(growable: false);
      sessions.add(
        _sessionFromPerformances(date: entry.key, performances: performances)!,
      );
    }
    sessions.sort((a, b) => b.date.compareTo(a.date));
    return sessions;
  }

  WeightClassification classify({
    required double? adgKgPerDay,
    required double? lotAverageAdgKgPerDay,
  }) {
    if (adgKgPerDay == null || lotAverageAdgKgPerDay == null) {
      return WeightClassification.noReference;
    }
    if (adgKgPerDay <= 0) return WeightClassification.noGain;
    if (adgKgPerDay > lotAverageAdgKgPerDay) {
      return WeightClassification.good;
    }
    return WeightClassification.belowAverage;
  }

  double? calculateDailyFeedCost({
    required double? feedPricePerKg,
    required double? dailyFeedKgPerHead,
  }) {
    if (!_positive(feedPricePerKg) || !_positive(dailyFeedKgPerHead)) {
      return null;
    }
    return feedPricePerKg! * dailyFeedKgPerHead!;
  }

  double? calculateFeedCostPerKgGain({
    required double? dailyFeedCost,
    required double? adgKgPerDay,
  }) {
    if (!_positive(dailyFeedCost) || !_positive(adgKgPerDay)) return null;
    return dailyFeedCost! / adgKgPerDay!;
  }

  double? calculateDailyWeightValue({
    required double? adgKgPerDay,
    required double? liveWeightPricePerKg,
  }) {
    if (adgKgPerDay == null ||
        !_isFinite(adgKgPerDay) ||
        !_positive(liveWeightPricePerKg)) {
      return null;
    }
    return adgKgPerDay * liveWeightPricePerKg!;
  }

  double? calculateFeedMargin({
    required double? dailyWeightValue,
    required double? dailyFeedCost,
  }) {
    if (dailyWeightValue == null ||
        !_isFinite(dailyWeightValue) ||
        dailyFeedCost == null ||
        !_isFinite(dailyFeedCost)) {
      return null;
    }
    return dailyWeightValue - dailyFeedCost;
  }

  LotEconomicMetrics calculateEconomicMetrics({
    double? feedPricePerKg,
    double? dailyFeedKgPerHead,
    double? liveWeightPricePerKg,
    FeedPlan? feedPlan,
    double? adgKgPerDay,
    int headCount = 1,
  }) {
    final derivedPrice = feedPlan == null
        ? null
        : _weightedFeedPricePerKg(feedPlan);
    final price = _positive(feedPricePerKg) ? feedPricePerKg : derivedPrice;
    final consumption = _positive(dailyFeedKgPerHead)
        ? dailyFeedKgPerHead
        : _positive(feedPlan?.headRationKg)
        ? feedPlan!.headRationKg
        : null;
    final perHeadDailyCost = calculateDailyFeedCost(
      feedPricePerKg: price,
      dailyFeedKgPerHead: consumption,
    );
    final heads = headCount > 0 ? headCount : 1;
    final dailyCost = perHeadDailyCost == null
        ? null
        : perHeadDailyCost * heads;
    final perHeadWeightValue = calculateDailyWeightValue(
      adgKgPerDay: adgKgPerDay,
      liveWeightPricePerKg: liveWeightPricePerKg,
    );
    final weightValue = perHeadWeightValue == null
        ? null
        : perHeadWeightValue * heads;

    return LotEconomicMetrics(
      feedPricePerKg: price,
      dailyFeedKgPerHead: consumption,
      dailyFeedCost: dailyCost,
      adgKgPerDay: adgKgPerDay,
      feedCostPerKgGain: calculateFeedCostPerKgGain(
        dailyFeedCost: dailyCost,
        adgKgPerDay: adgKgPerDay == null ? null : adgKgPerDay * heads,
      ),
      liveWeightPricePerKg: liveWeightPricePerKg,
      dailyWeightValue: weightValue,
      feedMargin: calculateFeedMargin(
        dailyWeightValue: weightValue,
        dailyFeedCost: dailyCost,
      ),
    );
  }

  static double? _weightedFeedPricePerKg(FeedPlan plan) {
    final totalKg = plan.ingredients.fold<double>(
      0,
      (sum, ingredient) => sum + ingredient.quantityKg,
    );
    if (!_positive(totalKg)) return null;
    final totalCostCents = plan.ingredients.fold<double>(
      0,
      (sum, ingredient) =>
          sum + ingredient.quantityKg * ingredient.unitCostCentsPerKg,
    );
    if (!_isFinite(totalCostCents) || totalCostCents <= 0) return null;
    return totalCostCents / totalKg / 100;
  }

  static WeighingSessionSummary? _sessionFromPerformances({
    required DateTime? date,
    required List<AnimalWeightPerformance> performances,
  }) {
    if (date == null || performances.isEmpty) return null;
    final gains = performances
        .map((performance) => performance.gainKg)
        .whereType<double>()
        .toList(growable: false);
    final adgs = performances
        .map((performance) => performance.adgKgPerDay)
        .whereType<double>()
        .toList(growable: false);
    final totalWeight = performances.fold<double>(
      0,
      (sum, performance) => sum + performance.currentWeightKg,
    );
    return WeighingSessionSummary(
      date: _dateOnly(date),
      measuredAnimalCount: performances.length,
      totalWeightKg: totalWeight,
      averageWeightKg: totalWeight / performances.length,
      totalGainKg: gains.isEmpty
          ? null
          : gains.fold<double>(0, (sum, value) => sum + value),
      averageAdgKgPerDay: adgs.isEmpty
          ? null
          : adgs.fold<double>(0, (sum, value) => sum + value) / adgs.length,
    );
  }

  static WeighingSessionSummary? _previousSession({
    required String lotUuid,
    required List<WeightRecord> records,
    required DateTime? before,
    required Map<String, List<WeightRecord>> histories,
  }) {
    if (before == null) return null;
    final sessions = const WeightPerformanceCalculator()
        .calculateWeighingSessions(
          lotUuid: lotUuid,
          records: records,
          histories: histories,
        );
    for (final session in sessions) {
      if (session.date.isBefore(_dateOnly(before))) return session;
    }
    return null;
  }

  static WeightRecord? _findPrevious(
    List<WeightRecord> records, {
    required DateTime measuredAt,
    required String? currentRecordUuid,
  }) {
    for (final record in records) {
      if (currentRecordUuid != null && record.recordUuid == currentRecordUuid) {
        continue;
      }
      if (record.method != WeightMethod.scale ||
          !_dateOnly(record.date).isBefore(_dateOnly(measuredAt)))
        continue;
      return record;
    }
    return null;
  }

  static WeightRecord? _latestForDay(
    Iterable<WeightRecord> records, {
    required String lotUuid,
    required DateTime day,
  }) {
    final matching = records
        .where(
          (record) => record.lotUuid == lotUuid && _sameDay(record.date, day),
        )
        .toList(growable: false);
    if (matching.isEmpty) return null;
    matching.sort(_compareNewestFirst);
    return matching.first;
  }

  static DateTime? _latestDay(Iterable<WeightRecord> records) {
    DateTime? latest;
    for (final record in records) {
      final day = _dateOnly(record.date);
      if (latest == null || day.isAfter(latest)) latest = day;
    }
    return latest;
  }

  static int _count(
    Iterable<AnimalWeightPerformance> performances,
    WeightClassification classification,
  ) => performances
      .where((item) => item.classification == classification)
      .length;

  static int _compareNewestFirst(WeightRecord a, WeightRecord b) {
    final measured = b.date.compareTo(a.date);
    if (measured != 0) return measured;
    final created = (b.createdAt ?? b.date).compareTo(a.createdAt ?? a.date);
    if (created != 0) return created;
    return (b.recordUuid ?? b.id ?? '').compareTo(a.recordUuid ?? a.id ?? '');
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool _isFinite(num? value) => value != null && value.isFinite;

  static bool _positive(num? value) => _isFinite(value) && value! > 0;
}
