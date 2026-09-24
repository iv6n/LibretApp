import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';
import 'package:libretapp/features/directorio/lotes/alimentacion/feed_models.dart';
import 'package:libretapp/features/directorio/lotes/domain/services/weight_performance_calculator.dart';

void main() {
  const calculator = WeightPerformanceCalculator();

  WeightRecord record({
    required String animalUuid,
    required String lotUuid,
    required DateTime date,
    required double weight,
    String? recordUuid,
  }) => WeightRecord(
    animalUuid: animalUuid,
    lotUuid: lotUuid,
    date: date,
    weight: weight,
    method: WeightMethod.scale,
    recordUuid: recordUuid,
    createdAt: date,
  );

  test('calculates gain and ADG without storing derived values', () {
    expect(
      calculator.calculateWeightGain(
        currentWeightKg: 144,
        previousWeightKg: 121,
      ),
      23,
    );
    expect(
      calculator.calculateDaysBetween(
        DateTime(2026, 9, 28),
        DateTime(2026, 9, 13),
      ),
      15,
    );
    expect(
      calculator.calculateADG(gainKg: 23, days: 15),
      closeTo(1.5333, 0.001),
    );
  });

  test('handles first weighing, same-day weighing and weight loss', () {
    final first = calculator.calculateAnimalPerformance(
      animalUuid: 'a1',
      currentWeightKg: 121,
      measuredAt: DateTime(2026, 9, 13),
      history: const [],
    );
    expect(first.previousWeightKg, isNull);
    expect(first.adgKgPerDay, isNull);

    final sameDay = calculator.calculateAnimalPerformance(
      animalUuid: 'a1',
      currentWeightKg: 125,
      measuredAt: DateTime(2026, 9, 13),
      history: [
        record(
          animalUuid: 'a1',
          lotUuid: 'lot-1',
          date: DateTime(2026, 9, 13),
          weight: 121,
          recordUuid: 'old',
        ),
      ],
    );
    expect(sameDay.gainKg, 4);
    expect(sameDay.daysBetween, 0);
    expect(sameDay.adgKgPerDay, isNull);

    final loss = calculator.calculateAnimalPerformance(
      animalUuid: 'a2',
      currentWeightKg: 90,
      measuredAt: DateTime(2026, 9, 28),
      history: [
        record(
          animalUuid: 'a2',
          lotUuid: 'lot-1',
          date: DateTime(2026, 9, 13),
          weight: 100,
          recordUuid: 'old-2',
        ),
      ],
    );
    expect(loss.gainKg, -10);
    expect(loss.adgKgPerDay, closeTo(-0.6667, 0.001));
  });

  test('summarizes active animals and classifies against lot average', () {
    final histories = <String, List<WeightRecord>>{
      'a1': [
        record(
          animalUuid: 'a1',
          lotUuid: 'lot-1',
          date: DateTime(2026, 9, 28),
          weight: 130,
          recordUuid: 'a1-current',
        ),
        record(
          animalUuid: 'a1',
          lotUuid: 'lot-1',
          date: DateTime(2026, 9, 13),
          weight: 100,
          recordUuid: 'a1-old',
        ),
      ],
      'a2': [
        record(
          animalUuid: 'a2',
          lotUuid: 'lot-1',
          date: DateTime(2026, 9, 28),
          weight: 110,
          recordUuid: 'a2-current',
        ),
        record(
          animalUuid: 'a2',
          lotUuid: 'lot-1',
          date: DateTime(2026, 9, 13),
          weight: 100,
          recordUuid: 'a2-old',
        ),
      ],
      'a3': [
        record(
          animalUuid: 'a3',
          lotUuid: 'lot-1',
          date: DateTime(2026, 9, 28),
          weight: 90,
          recordUuid: 'a3-current',
        ),
        record(
          animalUuid: 'a3',
          lotUuid: 'lot-1',
          date: DateTime(2026, 9, 13),
          weight: 100,
          recordUuid: 'a3-old',
        ),
      ],
    };

    final summary = calculator.calculateLotPerformance(
      lotUuid: 'lot-1',
      activeAnimalUuids: const ['a1', 'a2', 'a3', 'a4'],
      histories: histories,
    );

    expect(summary.activeAnimalCount, 4);
    expect(summary.measuredAnimalCount, 3);
    expect(summary.unmeasuredAnimalCount, 1);
    expect(summary.totalWeightKg, 330);
    expect(summary.averageWeightKg, 110);
    expect(summary.goodCount, 1);
    expect(summary.belowAverageCount, 1);
    expect(summary.noGainCount, 1);
    expect(summary.noReferenceCount, 0);
  });

  test('groups sessions by lot and local calendar day', () {
    final records = [
      record(
        animalUuid: 'a1',
        lotUuid: 'lot-1',
        date: DateTime(2026, 9, 13),
        weight: 100,
      ),
      record(
        animalUuid: 'a2',
        lotUuid: 'lot-1',
        date: DateTime(2026, 9, 13),
        weight: 110,
      ),
      record(
        animalUuid: 'a1',
        lotUuid: 'lot-1',
        date: DateTime(2026, 9, 28),
        weight: 120,
      ),
    ];
    final sessions = calculator.calculateWeighingSessions(
      lotUuid: 'lot-1',
      records: records,
      histories: {
        'a1': records.where((r) => r.animalUuid == 'a1').toList(),
        'a2': records.where((r) => r.animalUuid == 'a2').toList(),
      },
    );

    expect(sessions, hasLength(2));
    expect(sessions.first.date, DateTime(2026, 9, 28));
    expect(sessions.first.averageWeightKg, 120);
    expect(sessions.last.averageWeightKg, 105);
  });

  test('calculates feed cost and margin from a FeedPlan', () {
    final plan = FeedPlan(
      uuid: 'plan-1',
      farmId: 'farm-1',
      lotId: 'lot-1',
      name: 'Ración base',
      version: 1,
      validFrom: DateTime(2026, 9, 1),
      ingredients: const [
        FeedIngredient(
          productId: 'feed-1',
          quantityKg: 1,
          dryMatterPercent: 90,
          unitCostCentsPerKg: 500,
        ),
      ],
      headRationKg: 6,
    );
    final metrics = calculator.calculateEconomicMetrics(
      feedPlan: plan,
      liveWeightPricePerKg: 75,
      adgKgPerDay: 1.5,
    );

    expect(metrics.feedPricePerKg, 5);
    expect(metrics.dailyFeedKgPerHead, 6);
    expect(metrics.dailyFeedCost, 30);
    expect(metrics.feedCostPerKgGain, 20);
    expect(metrics.dailyWeightValue, 112.5);
    expect(metrics.feedMargin, 82.5);

    final lotMetrics = calculator.calculateEconomicMetrics(
      feedPlan: plan,
      liveWeightPricePerKg: 75,
      adgKgPerDay: 1.5,
      headCount: 3,
    );
    expect(lotMetrics.dailyFeedCost, 90);
    expect(lotMetrics.dailyWeightValue, 337.5);
    expect(lotMetrics.feedCostPerKgGain, 20);
    expect(lotMetrics.feedMargin, 247.5);
  });
}
