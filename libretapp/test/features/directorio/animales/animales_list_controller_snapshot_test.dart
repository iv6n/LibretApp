/// Covers the record-derived figures the animal cards read.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/view/animales_list_controller.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

final _now = DateTime(2026, 6, 10);

AnimalEntity _animal(String uuid) => AnimalEntity(
  uuid: uuid,
  earTagNumber: uuid,
  species: Species.cattle,
  category: Category.cow,
  lifeStage: LifeStage.cow,
  sex: Sex.female,
  breed: 'Holstein',
  birthDate: DateTime(2022, 1, 1),
  ageMonths: 52,
  healthStatus: HealthStatus.good,
  vaccinated: true,
  dewormed: true,
  hasVitamins: true,
  hasChronicIssues: false,
  reproductiveStatus: ReproductiveStatus.lactating,
  productionPurpose: ProductionPurpose.dairy,
  productionStage: ProductionStage.lactating,
  productionSystem: ProductionSystem.intensive,
  underObservation: false,
  requiresAttention: false,
  riskLevel: RiskLevel.none,
  gallery: const [],
  status: AnimalStatus.active,
  synced: true,
  creationDate: _now,
  lastUpdateDate: _now,
);

class _FakeLocationRepository implements LocationRepository {
  @override
  Future<List<LocationEntity>> getAll() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWeightRepository implements WeightRecordRepository {
  _FakeWeightRepository(this._records);
  final Map<String, List<WeightRecord>> _records;

  @override
  Future<Map<String, List<WeightRecord>>> getWeightRecordsForAnimals(
    Set<String> animalUuids,
  ) async => _records;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHealthRepository implements HealthRecordRepository {
  _FakeHealthRepository(this._withdrawals);
  final Map<String, DateTime> _withdrawals;

  Set<String>? lastQueried;

  @override
  Future<Map<String, DateTime>> getActiveWithdrawals(
    Set<String> animalUuids, {
    DateTime? asOf,
  }) async {
    lastQueried = animalUuids;
    return _withdrawals;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMilkingRepository implements MilkingRepository {
  _FakeMilkingRepository(this._records);
  final Map<String, List<MilkingRecord>> _records;

  @override
  Future<Map<String, List<MilkingRecord>>> getRecordsForAnimals(
    Set<String> animalUuids, {
    DateTime? since,
  }) async => _records;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MilkingRecord _milking(String animalUuid, DateTime day, double liters) {
  return MilkingRecord(
    session: MilkingSession(
      uuid: 'session-${day.toIso8601String()}',
      occurredAt: day,
      shift: MilkingShift.morning,
      status: MilkingStatus.completed,
      createdAt: day,
      updatedAt: day,
    ),
    entry: MilkingEntry(
      uuid: 'entry-$animalUuid-${day.toIso8601String()}',
      sessionUuid: 'session-${day.toIso8601String()}',
      animalUuid: animalUuid,
      volumeMilliliters: (liters * 1000).round(),
      createdAt: day,
      updatedAt: day,
    ),
  );
}

WeightRecord _weight(DateTime date, double kg) =>
    WeightRecord(date: date, weight: kg, method: WeightMethod.scale);

AnimalesListController _controller({
  Map<String, List<WeightRecord>> weights = const {},
  Map<String, DateTime> withdrawals = const {},
  Map<String, List<MilkingRecord>> milkings = const {},
}) {
  return AnimalesListController(
    locationRepository: _FakeLocationRepository(),
    weightRepository: _FakeWeightRepository(weights),
    healthRepository: _FakeHealthRepository(withdrawals),
    milkingRepository: _FakeMilkingRepository(milkings),
  );
}

void main() {
  test('daily gain is measured between the two most recent weighings', () async {
    final controller = _controller(
      weights: {
        'a1': [
          _weight(DateTime(2026, 6, 10), 420),
          _weight(DateTime(2026, 5, 11), 390),
        ],
      },
    );

    await controller.loadIndicatorSnapshots([_animal('a1')], now: _now);

    final snapshot = controller.snapshotFor('a1')!;
    expect(snapshot.lastWeightKg, 420);
    // 30 kg over 30 days.
    expect(snapshot.averageDailyGainKg, closeTo(1.0, 0.001));
  });

  test('daily gain is negative when the animal lost weight', () async {
    final controller = _controller(
      weights: {
        'a1': [
          _weight(DateTime(2026, 6, 10), 380),
          _weight(DateTime(2026, 5, 11), 400),
        ],
      },
    );

    await controller.loadIndicatorSnapshots([_animal('a1')], now: _now);

    expect(controller.snapshotFor('a1')!.averageDailyGainKg, lessThan(0));
  });

  test('daily gain is null with a single weighing', () async {
    final controller = _controller(
      weights: {
        'a1': [_weight(DateTime(2026, 6, 10), 420)],
      },
    );

    await controller.loadIndicatorSnapshots([_animal('a1')], now: _now);

    final snapshot = controller.snapshotFor('a1')!;
    expect(snapshot.lastWeightKg, 420);
    expect(snapshot.averageDailyGainKg, isNull);
  });

  test('daily gain is null when both weighings share a date', () async {
    // Two entries on the same day would divide by zero.
    final controller = _controller(
      weights: {
        'a1': [
          _weight(DateTime(2026, 6, 10), 420),
          _weight(DateTime(2026, 6, 10), 415),
        ],
      },
    );

    await controller.loadIndicatorSnapshots([_animal('a1')], now: _now);

    expect(controller.snapshotFor('a1')!.averageDailyGainKg, isNull);
  });

  test('milk average sums the shifts of a day, then averages days', () async {
    final controller = _controller(
      milkings: {
        'a1': [
          _milking('a1', DateTime(2026, 6, 9, 6), 8),
          _milking('a1', DateTime(2026, 6, 9, 18), 6),
          _milking('a1', DateTime(2026, 6, 10, 6), 10),
        ],
      },
    );

    await controller.loadIndicatorSnapshots([_animal('a1')], now: _now);

    // Day one totals 14 L, day two 10 L → 12 L/day across two milked days,
    // not 8 L/day if the week's length were used as the divisor.
    expect(controller.snapshotFor('a1')!.milkLitersPerDay, closeTo(12, 0.001));
  });

  test('an active withdrawal reaches the snapshot', () async {
    final endsOn = DateTime(2026, 6, 14);
    final controller = _controller(withdrawals: {'a1': endsOn});

    await controller.loadIndicatorSnapshots([_animal('a1')], now: _now);

    expect(controller.snapshotFor('a1')!.withdrawalEndsOn, endsOn);

    // And it surfaces as a critical chip rather than a statistic.
    final indicators = indicatorsFor(
      _animal('a1'),
      snapshot: controller.snapshotFor('a1'),
      now: _now,
    );
    expect(indicators.first.kind, PurposeIndicatorKind.milkWithdrawal);
    expect(indicators.first.severity, IndicatorSeverity.critical);
  });

  test('animals already loaded are not queried again', () async {
    final health = _FakeHealthRepository(const {});
    final controller = AnimalesListController(
      locationRepository: _FakeLocationRepository(),
      healthRepository: health,
    );

    await controller.loadIndicatorSnapshots([_animal('a1')], now: _now);
    health.lastQueried = null;
    await controller.loadIndicatorSnapshots([_animal('a1')], now: _now);

    expect(health.lastQueried, isNull);
  });

  test('missing repositories leave the snapshot empty but present', () async {
    final controller = AnimalesListController(
      locationRepository: _FakeLocationRepository(),
    );

    await controller.loadIndicatorSnapshots([_animal('a1')], now: _now);

    final snapshot = controller.snapshotFor('a1');
    expect(snapshot, isNotNull);
    expect(snapshot!.withdrawalEndsOn, isNull);
    expect(snapshot.milkLitersPerDay, isNull);
  });
}
