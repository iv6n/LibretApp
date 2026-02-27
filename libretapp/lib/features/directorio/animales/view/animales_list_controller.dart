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
    if (uuid == null) return null;
    try {
      return _state.locations.firstWhere((l) => l.uuid == uuid);
    } catch (_) {
      return null;
    }
  }

  List<AnimalEntity> applyFilters(List<AnimalEntity> animales) {
    return animales.where((animal) {
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
