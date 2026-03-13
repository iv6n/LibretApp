import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/repositories/isar_location_repository.dart';

@immutable
class AnimalesListState {
  const AnimalesListState({
    required this.locations,
    required this.selectedStages,
    required this.onlyAttention,
  });

  factory AnimalesListState.initial() => const AnimalesListState(
    locations: <LocationEntity>[],
    selectedStages: <LifeStage>{},
    onlyAttention: false,
  );

  final List<LocationEntity> locations;
  final Set<LifeStage> selectedStages;
  final bool onlyAttention;

  AnimalesListState copyWith({
    List<LocationEntity>? locations,
    Set<LifeStage>? selectedStages,
    bool? onlyAttention,
  }) {
    return AnimalesListState(
      locations: locations ?? this.locations,
      selectedStages: selectedStages ?? this.selectedStages,
      onlyAttention: onlyAttention ?? this.onlyAttention,
    );
  }

  bool get hasFilters => selectedStages.isNotEmpty || onlyAttention;
}

class AnimalesListController extends ChangeNotifier {
  AnimalesListController({required IsarLocationRepository locationRepository})
    : _locationRepository = locationRepository,
      _state = AnimalesListState.initial();

  final IsarLocationRepository _locationRepository;

  AnimalesListState _state;
  bool _disposed = false;
  AnimalesListState get state => _state;

  Future<void> loadInitial() async {
    final locations = await _locationRepository.getAll();
    _setState(_state.copyWith(locations: locations));
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
    return locationById(animal.currentPaddockId) ??
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

      return matchesStage && matchesAttention;
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
  'potrero-a': 'potrero',
  'potrero-b': 'potrero',
  'potrero-c': 'potrero',
  'corral-crias': 'corral-engorda',
  'feedlot-1': 'corral-engorda',
  'rancho-principal': 'rancho-trabajo',
  'rancho': 'rancho-trabajo',
  'almacen': 'almacen-equipo',
  'almacen-principal': 'almacen-equipo',
  'monte-norte': 'monte',
  'milpa-1': 'milpa-alfalfa',
  'milpa-alfalfa-norte': 'milpa-alfalfa',
};
