/// features \u203a directorio \u203a animales \u203a view \u203a animales_list_controller \u2014 controller for the animals list screen.
library;

import 'package:flutter/foundation.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

@immutable
class AnimalesListState {
  const AnimalesListState({
    required this.locations,
    required this.selectedStages,
    required this.onlyAttention,
    required this.onlyPendingEarTag,
    this.indicatorSnapshots = const <String, AnimalIndicatorSnapshot>{},
  });

  factory AnimalesListState.initial() => const AnimalesListState(
    locations: <LocationEntity>[],
    selectedStages: <LifeStage>{},
    onlyAttention: false,
    onlyPendingEarTag: false,
  );

  final List<LocationEntity> locations;
  final Set<LifeStage> selectedStages;
  final bool onlyAttention;
  final bool onlyPendingEarTag;

  /// Record-derived card figures, keyed by animal uuid. Missing entries simply
  /// mean the card falls back to the animal's denormalized fields.
  final Map<String, AnimalIndicatorSnapshot> indicatorSnapshots;

  AnimalesListState copyWith({
    List<LocationEntity>? locations,
    Set<LifeStage>? selectedStages,
    bool? onlyAttention,
    bool? onlyPendingEarTag,
    Map<String, AnimalIndicatorSnapshot>? indicatorSnapshots,
  }) {
    return AnimalesListState(
      locations: locations ?? this.locations,
      selectedStages: selectedStages ?? this.selectedStages,
      onlyAttention: onlyAttention ?? this.onlyAttention,
      onlyPendingEarTag: onlyPendingEarTag ?? this.onlyPendingEarTag,
      indicatorSnapshots: indicatorSnapshots ?? this.indicatorSnapshots,
    );
  }

  bool get hasFilters =>
      selectedStages.isNotEmpty || onlyAttention || onlyPendingEarTag;
}

class AnimalesListController extends ChangeNotifier {
  AnimalesListController({
    required LocationRepository locationRepository,
    ReproductionRecordRepository? reproductionRepository,
    HealthRecordRepository? healthRepository,
    WeightRecordRepository? weightRepository,
    MilkingRepository? milkingRepository,
  }) : _locationRepository = locationRepository,
       _reproductionRepository = reproductionRepository,
       _healthRepository = healthRepository,
       _weightRepository = weightRepository,
       _milkingRepository = milkingRepository,
       _state = AnimalesListState.initial();

  final LocationRepository _locationRepository;

  // All optional: focused widget tests build the list without them, and each
  // missing source simply leaves its slice of the snapshot null, which the
  // indicator service degrades from.
  final ReproductionRecordRepository? _reproductionRepository;
  final HealthRecordRepository? _healthRepository;
  final WeightRecordRepository? _weightRepository;
  final MilkingRepository? _milkingRepository;

  static const _kpiService = ReproductiveKpiService();

  /// Window used for the average daily yield shown on dairy cards. A week
  /// smooths out the difference between a heavy morning and a light evening
  /// milking without lagging behind a real drop in production.
  static const _milkAverageWindow = Duration(days: 7);

  AnimalesListState _state;
  bool _disposed = false;
  AnimalesListState get state => _state;

  /// Figures for [uuid], or null while they are still loading.
  AnimalIndicatorSnapshot? snapshotFor(String uuid) =>
      _state.indicatorSnapshots[uuid];

  Future<void> loadInitial() async {
    final locations = await _locationRepository.getAll();
    _setState(_state.copyWith(locations: locations));
  }

  /// Builds card indicators for [animals] in one batch query.
  ///
  /// Called with the animals actually on screen rather than the whole herd:
  /// the cost is one round trip per page, not one per card.
  Future<void> loadIndicatorSnapshots(
    Iterable<AnimalEntity> animals, {
    DateTime? now,
  }) async {
    final uuids = animals.map((animal) => animal.uuid).toSet()
      ..removeAll(_state.indicatorSnapshots.keys);
    if (uuids.isEmpty) return;

    final reference = now ?? DateTime.now();

    // One round trip per source for the whole page, all in flight together.
    final reproductions =
        await _reproductionRepository?.getReproductionRecordsForAnimals(
          uuids,
        ) ??
        const <String, List<ReproductionRecord>>{};
    final withdrawals =
        await _healthRepository?.getActiveWithdrawals(uuids, asOf: reference) ??
        const <String, DateTime>{};
    final weights =
        await _weightRepository?.getWeightRecordsForAnimals(uuids) ??
        const <String, List<WeightRecord>>{};
    final milkings =
        await _milkingRepository?.getRecordsForAnimals(
          uuids,
          since: reference.subtract(_milkAverageWindow),
        ) ??
        const <String, List<MilkingRecord>>{};

    if (_disposed) return;

    final byUuid = {for (final animal in animals) animal.uuid: animal};
    final snapshots = Map<String, AnimalIndicatorSnapshot>.from(
      _state.indicatorSnapshots,
    );

    for (final uuid in uuids) {
      final records = reproductions[uuid] ?? const <ReproductionRecord>[];
      final animalWeights = weights[uuid] ?? const <WeightRecord>[];

      snapshots[uuid] = AnimalIndicatorSnapshot(
        reproductiveKpis: records.isEmpty
            ? null
            : _kpiService.forAnimal(
                records: records,
                birthDate: byUuid[uuid]?.birthDate,
              ),
        withdrawalEndsOn: withdrawals[uuid],
        lastWeightKg: animalWeights.isEmpty ? null : animalWeights.first.weight,
        averageDailyGainKg: _dailyGain(animalWeights),
        milkLitersPerDay: _litersPerDay(
          milkings[uuid] ?? const <MilkingRecord>[],
        ),
      );
    }

    _setState(_state.copyWith(indicatorSnapshots: snapshots));
  }

  /// Gain per day between the two most recent weighings.
  ///
  /// Measured rather than estimated, which is the point: it is the only figure
  /// that shows an animal losing weight. Returns null when there is nothing to
  /// compare against, or when both weighings landed on the same day.
  static double? _dailyGain(List<WeightRecord> weights) {
    if (weights.length < 2) return null;

    final latest = weights[0];
    final previous = weights[1];
    final days = latest.date.difference(previous.date).inDays;
    if (days <= 0) return null;

    return (latest.weight - previous.weight) / days;
  }

  /// Average litres per calendar day the animal was actually milked.
  ///
  /// Dividing by days milked rather than by the window length keeps a cow that
  /// was only milked twice this week from looking like a poor producer.
  static double? _litersPerDay(List<MilkingRecord> records) {
    if (records.isEmpty) return null;

    final litersByDay = <DateTime, double>{};
    for (final record in records) {
      final occurred = record.session.occurredAt;
      final day = DateTime(occurred.year, occurred.month, occurred.day);
      litersByDay.update(
        day,
        (value) => value + record.entry.liters,
        ifAbsent: () => record.entry.liters,
      );
    }

    if (litersByDay.isEmpty) return null;
    final total = litersByDay.values.reduce((a, b) => a + b);
    return total / litersByDay.length;
  }

  Future<void> refreshLocations() async {
    final locations = await _locationRepository.getAll();
    _setState(_state.copyWith(locations: locations));
  }

  void setStages(Set<LifeStage> stages) {
    _setState(_state.copyWith(selectedStages: Set<LifeStage>.from(stages)));
  }

  void setOnlyAttention(bool value) {
    _setState(_state.copyWith(onlyAttention: value));
  }

  void setOnlyPendingEarTag(bool value) {
    _setState(_state.copyWith(onlyPendingEarTag: value));
  }

  LocationEntity? locationById(String? uuid) {
    final normalizedLookup = _normalizeLookup(uuid);
    if (normalizedLookup == null) return null;

    final directMatch = _findLocationByLookup(normalizedLookup);
    if (directMatch != null) return directMatch;

    final aliasTarget = _legacyLocationAliases[normalizedLookup];
    if (aliasTarget == null) return null;

    final normalizedAlias = _normalizeLookup(aliasTarget);
    if (normalizedAlias == null) return null;
    return _findLocationByLookup(normalizedAlias);
  }

  LocationEntity? locationForAnimal(AnimalEntity animal) {
    return locationById(animal.currentLocationId) ??
        locationById(animal.initialLocationId);
  }

  LocationEntity? _findLocationByLookup(String normalizedLookup) {
    for (final location in _state.locations) {
      if (_normalizeLookup(location.uuid) == normalizedLookup) {
        return location;
      }
    }

    for (final location in _state.locations) {
      if (_normalizeLookup(location.name) == normalizedLookup) {
        return location;
      }
    }

    for (final location in _state.locations) {
      if (location.id != null && location.id.toString() == normalizedLookup) {
        return location;
      }
    }

    return null;
  }

  String? _normalizeLookup(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }

  List<AnimalEntity> applyFilters(List<AnimalEntity> animales) {
    final filtered = animales.where((animal) {
      final matchesStage =
          _state.selectedStages.isEmpty ||
          _state.selectedStages.contains(animal.lifeStage);

      final needsAttention =
          animal.requiresAttention ||
          animal.underObservation ||
          animal.riskLevel == RiskLevel.high ||
          animal.riskLevel == RiskLevel.critical ||
          animal.healthStatus == HealthStatus.poor ||
          animal.healthStatus == HealthStatus.critical;

      final matchesAttention = !_state.onlyAttention || needsAttention;
      final matchesPendingEarTag =
          !_state.onlyPendingEarTag || hasPendingEarTag(animal);

      return matchesStage && matchesAttention && matchesPendingEarTag;
    }).toList();

    // Sort critical/attention cases first, then by severity and most recent.
    filtered.sort(_compareAnimals);
    return filtered;
  }

  int _compareAnimals(AnimalEntity a, AnimalEntity b) {
    final aNeedsPriority = _needsTopPriority(a);
    final bNeedsPriority = _needsTopPriority(b);
    if (aNeedsPriority != bNeedsPriority) {
      return aNeedsPriority ? -1 : 1;
    }

    if (a.underObservation != b.underObservation) {
      return a.underObservation ? -1 : 1;
    }

    final healthOrder = _healthSeverity(
      b.healthStatus,
    ).compareTo(_healthSeverity(a.healthStatus));
    if (healthOrder != 0) return healthOrder;

    final riskOrder = _riskSeverity(
      b.riskLevel,
    ).compareTo(_riskSeverity(a.riskLevel));
    if (riskOrder != 0) return riskOrder;

    if (a.requiresAttention != b.requiresAttention) {
      return a.requiresAttention ? -1 : 1;
    }

    final recencyOrder = b.lastUpdateDate.compareTo(a.lastUpdateDate);
    if (recencyOrder != 0) return recencyOrder;

    return _stableIdentifier(a).compareTo(_stableIdentifier(b));
  }

  bool _needsTopPriority(AnimalEntity animal) {
    return animal.underObservation ||
        animal.requiresAttention ||
        _healthSeverity(animal.healthStatus) >= 3 ||
        _riskSeverity(animal.riskLevel) >= 3;
  }

  int _healthSeverity(HealthStatus status) {
    switch (status) {
      case HealthStatus.critical:
        return 4;
      case HealthStatus.poor:
        return 3;
      case HealthStatus.fair:
        return 2;
      case HealthStatus.good:
        return 1;
      case HealthStatus.excellent:
      case HealthStatus.unknown:
        return 0;
    }
  }

  int _riskSeverity(RiskLevel level) {
    switch (level) {
      case RiskLevel.critical:
        return 4;
      case RiskLevel.high:
        return 3;
      case RiskLevel.medium:
        return 2;
      case RiskLevel.low:
        return 1;
      case RiskLevel.none:
        return 0;
    }
  }

  String _stableIdentifier(AnimalEntity animal) {
    final earTag = animal.earTagNumber.trim().toLowerCase();
    if (earTag.isNotEmpty) return earTag;

    final visualId = animal.visualId?.trim().toLowerCase();
    if (visualId != null && visualId.isNotEmpty) return visualId;

    return animal.uuid.trim().toLowerCase();
  }

  void _setState(AnimalesListState newState) {
    if (_disposed) return;
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

const Map<String, String> _legacyLocationAliases = {
  'potrero-a': 'milpa-corral-a',
  'potrero-b': 'milpa-corral-b',
  'potrero-c': 'ejido-corral-priv',
  'potrero-d': 'casa-corral-2',
  'corral-crias': 'milpa-corral-becerros',
  'feedlot-1': 'casa-corral-1',
  'rancho-principal': 'prop-casa',
  'rancho-trabajo': 'prop-casa',
  'rancho': 'prop-casa',
  'gallinero-central': 'casa-house',
  'almacen': 'casa-bodega',
  'almacen-principal': 'casa-bodega',
  'almacen-equipo': 'casa-bodega',
  'monte-norte': 'monte-ejidal',
  'monte': 'monte-ejidal',
  'milpa-1': 'milpa-campo',
  'milpa-alfalfa': 'milpa-campo',
  'milpa-alfalfa-norte': 'milpa-campo',
  'potrero': 'milpa-corral-a',
  'corral-engorda': 'casa-corral-1',
};
