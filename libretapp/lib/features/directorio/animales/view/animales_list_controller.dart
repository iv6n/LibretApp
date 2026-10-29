/// features \u203a directorio \u203a animales \u203a view \u203a animales_list_controller \u2014 controller for the animals list screen.
library;

import 'package:flutter/foundation.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_indicator_snapshot.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

const Object _selectedSpeciesUnset = Object();
const Object _selectedLoteUnset = Object();
const Object _selectedLocationUnset = Object();

@immutable
class AnimalesListState {
  const AnimalesListState({
    required this.locations,
    required this.selectedStages,
    required this.onlyAttention,
    required this.onlyPendingEarTag,
    this.selectedSpecies,
    this.selectedLoteUuid,
    this.selectedLocationUuid,
    this.taxonomyCounts = const <Species, Map<LifeStage, int>>{},
    this.includeInactive = false,
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
  final Species? selectedSpecies;
  final String? selectedLoteUuid;
  final String? selectedLocationUuid;
  final Map<Species, Map<LifeStage, int>> taxonomyCounts;

  /// Shows animals that left the herd — sold, dead or archived. Off by
  /// default so the list reflects what is actually out in the field.
  final bool includeInactive;

  /// Record-derived card figures, keyed by animal uuid. Missing entries simply
  /// mean the card falls back to the animal's denormalized fields.
  final Map<String, AnimalIndicatorSnapshot> indicatorSnapshots;

  AnimalesListState copyWith({
    List<LocationEntity>? locations,
    Set<LifeStage>? selectedStages,
    bool? onlyAttention,
    bool? onlyPendingEarTag,
    Object? selectedSpecies = _selectedSpeciesUnset,
    Object? selectedLoteUuid = _selectedLoteUnset,
    Object? selectedLocationUuid = _selectedLocationUnset,
    Map<Species, Map<LifeStage, int>>? taxonomyCounts,
    bool? includeInactive,
    Map<String, AnimalIndicatorSnapshot>? indicatorSnapshots,
  }) {
    return AnimalesListState(
      locations: locations ?? this.locations,
      selectedStages: selectedStages ?? this.selectedStages,
      onlyAttention: onlyAttention ?? this.onlyAttention,
      onlyPendingEarTag: onlyPendingEarTag ?? this.onlyPendingEarTag,
      selectedSpecies: identical(selectedSpecies, _selectedSpeciesUnset)
          ? this.selectedSpecies
          : selectedSpecies as Species?,
      selectedLoteUuid: identical(selectedLoteUuid, _selectedLoteUnset)
          ? this.selectedLoteUuid
          : selectedLoteUuid as String?,
      selectedLocationUuid:
          identical(selectedLocationUuid, _selectedLocationUnset)
          ? this.selectedLocationUuid
          : selectedLocationUuid as String?,
      taxonomyCounts: taxonomyCounts ?? this.taxonomyCounts,
      includeInactive: includeInactive ?? this.includeInactive,
      indicatorSnapshots: indicatorSnapshots ?? this.indicatorSnapshots,
    );
  }

  bool get hasFilters =>
      selectedStages.isNotEmpty ||
      selectedSpecies != null ||
      onlyAttention ||
      onlyPendingEarTag ||
      selectedLoteUuid != null ||
      selectedLocationUuid != null ||
      includeInactive;
}

class AnimalesListController extends ChangeNotifier {
  AnimalesListController({
    required LocationRepository locationRepository,
    AnimalRepository? animalRepository,
    ReproductionRecordRepository? reproductionRepository,
    HealthRecordRepository? healthRepository,
    WeightRecordRepository? weightRepository,
    MilkingRepository? milkingRepository,
  }) : _locationRepository = locationRepository,
       _animalRepository = animalRepository,
       _reproductionRepository = reproductionRepository,
       _healthRepository = healthRepository,
       _weightRepository = weightRepository,
       _milkingRepository = milkingRepository,
       _state = AnimalesListState.initial();

  final LocationRepository _locationRepository;
  final AnimalRepository? _animalRepository;

  // All optional: focused widget tests build the list without them, and each
  // missing source simply leaves its slice of the snapshot null, which the
  // indicator service degrades from.
  final ReproductionRecordRepository? _reproductionRepository;
  final HealthRecordRepository? _healthRepository;
  final WeightRecordRepository? _weightRepository;
  final MilkingRepository? _milkingRepository;

  /// Window used for the average daily yield shown on dairy cards. A week
  /// smooths out the difference between a heavy morning and a light evening
  /// milking without lagging behind a real drop in production.
  static const _milkAverageWindow = Duration(days: 7);

  AnimalesListState _state;
  bool _disposed = false;
  int _snapshotGeneration = 0;
  final Set<String> _indicatorLoadsInFlight = <String>{};
  AnimalesListState get state => _state;

  /// Figures for [uuid], or null while they are still loading.
  AnimalIndicatorSnapshot? snapshotFor(String uuid) =>
      _state.indicatorSnapshots[uuid];

  Future<void> loadInitial() async {
    final locations = await _locationRepository.getAll();
    _setState(_state.copyWith(locations: locations));
  }

  /// Loads whole-herd species/stage availability so filter chips never depend
  /// on which animal page happens to be visible.
  Future<void> loadTaxonomy([Iterable<AnimalEntity>? fallbackAnimals]) async {
    final counts = _animalRepository == null
        ? _taxonomyFromAnimals(fallbackAnimals ?? const <AnimalEntity>[])
        : await _animalRepository.getActiveTaxonomyCounts();
    if (_disposed) return;

    final selected = _state.selectedSpecies;
    final nextSelected = selected != null && counts.containsKey(selected)
        ? selected
        : null;
    _setState(
      _state.copyWith(
        taxonomyCounts: counts,
        selectedSpecies: nextSelected,
        selectedStages: _stagesForSpecies(
          _state.selectedStages,
          nextSelected,
          counts,
        ),
      ),
    );
  }

  Set<Species> get availableSpecies => _state.taxonomyCounts.keys.toSet();

  int get taxonomyTotal => _state.taxonomyCounts.values.fold<int>(
    0,
    (sum, stages) => sum + stages.values.fold<int>(0, (a, b) => a + b),
  );

  Map<LifeStage, int> get selectedSpeciesStageCounts {
    var species = _state.selectedSpecies;
    if (species == null && availableSpecies.length == 1) {
      species = availableSpecies.first;
    }
    return species == null
        ? const <LifeStage, int>{}
        : _state.taxonomyCounts[species] ?? const <LifeStage, int>{};
  }

  Map<Species, Map<LifeStage, int>> _taxonomyFromAnimals(
    Iterable<AnimalEntity> animals,
  ) {
    final counts = <Species, Map<LifeStage, int>>{};
    for (final animal in animals) {
      counts
          .putIfAbsent(animal.species, () => <LifeStage, int>{})
          .update(animal.lifeStage, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  Set<LifeStage> _stagesForSpecies(
    Set<LifeStage> stages,
    Species? species,
    Map<Species, Map<LifeStage, int>> counts,
  ) {
    if (species == null) return const <LifeStage>{};
    final available = counts[species]?.keys.toSet() ?? const <LifeStage>{};
    return stages.where(available.contains).toSet();
  }

  /// Builds card indicators for [animals] in one batch query.
  ///
  /// Called with the animals actually on screen rather than the whole herd:
  /// the cost is one round trip per page, not one per card.
  Future<void> loadIndicatorSnapshots(
    Iterable<AnimalEntity> animals, {
    DateTime? now,
  }) async {
    // Capture the iterable once. The view passes a filtered list today, but
    // keeping a stable snapshot also makes the in-flight de-duplication safe
    // for callers that provide a lazy iterable.
    final animalList = animals.toList(growable: false);
    final uuids = animalList.map((animal) => animal.uuid).toSet()
      ..removeAll(_state.indicatorSnapshots.keys)
      ..removeAll(_indicatorLoadsInFlight);
    if (uuids.isEmpty) return;

    _indicatorLoadsInFlight.addAll(uuids);

    final reference = now ?? DateTime.now();
    final generation = _snapshotGeneration;

    // The four sources are independent. Start each one before waiting so a
    // page of cards pays one round-trip's latency rather than four in series.
    // Future.sync also turns a synchronous fake/repository error into a future
    // so every started source is covered by the same cleanup path.
    var reproductions = const <String, List<ReproductionRecord>>{};
    var withdrawals = const <String, DateTime>{};
    var weights = const <String, List<WeightRecord>>{};
    var milkings = const <String, List<MilkingRecord>>{};
    final queries = <Future<void>>[];

    final reproductionRepository = _reproductionRepository;
    if (reproductionRepository != null) {
      queries.add(
        Future<Map<String, List<ReproductionRecord>>>.sync(
          () => reproductionRepository.getReproductionRecordsForAnimals(uuids),
        ).then<void>((value) {
          reproductions = value;
        }),
      );
    }

    final healthRepository = _healthRepository;
    if (healthRepository != null) {
      queries.add(
        Future<Map<String, DateTime>>.sync(
          () => healthRepository.getActiveWithdrawals(uuids, asOf: reference),
        ).then<void>((value) {
          withdrawals = value;
        }),
      );
    }

    final weightRepository = _weightRepository;
    if (weightRepository != null) {
      queries.add(
        Future<Map<String, List<WeightRecord>>>.sync(
          () => weightRepository.getWeightRecordsForAnimals(uuids),
        ).then<void>((value) {
          weights = value;
        }),
      );
    }

    final milkingRepository = _milkingRepository;
    if (milkingRepository != null) {
      queries.add(
        Future<Map<String, List<MilkingRecord>>>.sync(
          () => milkingRepository.getRecordsForAnimals(
            uuids,
            since: reference.subtract(_milkAverageWindow),
          ),
        ).then<void>((value) {
          milkings = value;
        }),
      );
    }

    try {
      // Wait for every source to settle before clearing the in-flight set. If
      // one source fails, a still-running sibling must remain de-duplicated
      // until it finishes; the error still propagates to the caller.
      await Future.wait<void>(queries, eagerError: false);

      if (_disposed || generation != _snapshotGeneration) return;

      final byUuid = {for (final animal in animalList) animal.uuid: animal};
      final snapshots = Map<String, AnimalIndicatorSnapshot>.from(
        _state.indicatorSnapshots,
      );

      for (final uuid in uuids) {
        final records = reproductions[uuid] ?? const <ReproductionRecord>[];
        final animalWeights = weights[uuid] ?? const <WeightRecord>[];

        snapshots[uuid] = buildAnimalIndicatorSnapshot(
          animal: byUuid[uuid]!,
          reproductions: records,
          weights: animalWeights,
          milkings: milkings[uuid] ?? const <MilkingRecord>[],
          now: reference,
          withdrawalEndsOn: withdrawals[uuid],
        );
      }

      _setState(_state.copyWith(indicatorSnapshots: snapshots));
    } finally {
      _indicatorLoadsInFlight.removeAll(uuids);
      if (!_disposed && generation != _snapshotGeneration) notifyListeners();
    }
  }

  void invalidateIndicatorSnapshots() {
    _snapshotGeneration++;
    _setState(_state.copyWith(indicatorSnapshots: const {}));
  }

  Future<void> refreshLocations() async {
    final locations = await _locationRepository.getAll();
    _setState(_state.copyWith(locations: locations));
  }

  void setStages(Set<LifeStage> stages) {
    _setState(_state.copyWith(selectedStages: Set<LifeStage>.from(stages)));
  }

  void setSpecies(Species? species) {
    _setState(
      _state.copyWith(
        selectedSpecies: species,
        selectedStages: const <LifeStage>{},
      ),
    );
  }

  void setOnlyAttention(bool value) {
    _setState(_state.copyWith(onlyAttention: value));
  }

  void setOnlyPendingEarTag(bool value) {
    _setState(_state.copyWith(onlyPendingEarTag: value));
  }

  void setLoteUuid(String? uuid) {
    _setState(_state.copyWith(selectedLoteUuid: uuid));
  }

  void setLocationUuid(String? uuid) {
    _setState(_state.copyWith(selectedLocationUuid: uuid));
  }

  void setIncludeInactive(bool value) {
    _setState(_state.copyWith(includeInactive: value));
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
    final selectedLocationScope = _selectedLocationScope();
    final filtered = animales.where((animal) {
      final matchesStage =
          _state.selectedStages.isEmpty ||
          _state.selectedStages.contains(animal.lifeStage);
      final matchesSpecies =
          _state.selectedSpecies == null ||
          _state.selectedSpecies == animal.species;

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
      final matchesLote =
          _state.selectedLoteUuid == null ||
          animal.batchUuid == _state.selectedLoteUuid;
      final matchesLocation =
          selectedLocationScope.isEmpty ||
          selectedLocationScope.contains(animal.currentLocationId) ||
          selectedLocationScope.contains(animal.initialLocationId);
      // The repository already limits the feed to the active herd; this only
      // matters when a caller hands over inactive animals too.
      final matchesHerd =
          _state.includeInactive || animal.status.isInActiveHerd;

      return matchesSpecies &&
          matchesStage &&
          matchesAttention &&
          matchesPendingEarTag &&
          matchesLote &&
          matchesLocation &&
          matchesHerd;
    }).toList();

    // Activity is the directory's primary order. Alerts remain available as
    // indicators and filters, but an older alert must not outrank a newer
    // animal record.
    filtered.sort(_compareAnimals);
    return filtered;
  }

  /// Includes descendants when a root location is selected. Root location
  /// cards display subtree totals, so their "Ver animales" link should open
  /// the same scope rather than silently omitting animals in child locations.
  Set<String> _selectedLocationScope() {
    final selected = _state.selectedLocationUuid;
    if (selected == null || selected.isEmpty) return const <String>{};

    final root = locationById(selected);
    final scope = <String>{root?.uuid ?? selected};
    var changed = true;
    while (changed) {
      changed = false;
      for (final location in _state.locations) {
        if (location.parentUuid != null &&
            scope.contains(location.parentUuid) &&
            scope.add(location.uuid)) {
          changed = true;
        }
      }
    }
    return scope;
  }

  int _compareAnimals(AnimalEntity a, AnimalEntity b) {
    final recencyOrder = b.lastUpdateDate.compareTo(a.lastUpdateDate);
    if (recencyOrder != 0) return recencyOrder;

    final ageOrder = a.ageMonths.compareTo(b.ageMonths);
    if (ageOrder != 0) return ageOrder;

    final earTagOrder = a.earTagNumber.trim().toLowerCase().compareTo(
      b.earTagNumber.trim().toLowerCase(),
    );
    if (earTagOrder != 0) return earTagOrder;
    return a.uuid.trim().toLowerCase().compareTo(b.uuid.trim().toLowerCase());
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
