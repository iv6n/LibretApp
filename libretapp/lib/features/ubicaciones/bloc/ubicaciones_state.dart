/// features › ubicaciones › bloc › ubicaciones_state — state for UbicacionesBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_category.dart';

class UbicacionesTreeSnapshot {
  const UbicacionesTreeSnapshot({
    required this.allByUuid,
    required this.childrenByParent,
    required this.visibleIds,
    required this.roots,
  });

  final Map<String, LocationEntity> allByUuid;
  final Map<String?, List<LocationEntity>> childrenByParent;
  final Set<String> visibleIds;
  final List<LocationEntity> roots;
}

abstract class UbicacionesState extends Equatable {
  const UbicacionesState();

  @override
  List<Object> get props => [];
}

class UbicacionesInitial extends UbicacionesState {
  const UbicacionesInitial();
}

class UbicacionesLoading extends UbicacionesState {
  const UbicacionesLoading();
}

class UbicacionesLoaded extends UbicacionesState {
  const UbicacionesLoaded({
    required this.allUbicaciones,
    required this.visibleUbicaciones,
    required this.isSearching,
    required this.searchQuery,
    this.selectedRanchoUuid,
    this.selectedCategoryFilters = const <LocationCategory>{},
    this.animalCounts = const <String, int>{},
    this.subtreeAnimalCounts = const <String, int>{},
    this.averageWeights = const <String, double>{},
    required this.treeSnapshot,
  });

  final List<LocationEntity> allUbicaciones;
  final List<LocationEntity> visibleUbicaciones;
  final bool isSearching;
  final String searchQuery;
  final String? selectedRanchoUuid;
  final Set<LocationCategory> selectedCategoryFilters;
  final Map<String, int> animalCounts;
  final Map<String, int> subtreeAnimalCounts;
  final Map<String, double> averageWeights;
  final UbicacionesTreeSnapshot treeSnapshot;

  int get totalCount => allUbicaciones.length;
  int get filteredCount => visibleUbicaciones.length;
  int get totalAnimalsAssigned =>
      animalCounts.values.fold<int>(0, (sum, count) => sum + count);

  bool get hasActiveFilters =>
      selectedRanchoUuid != null || selectedCategoryFilters.isNotEmpty;

  UbicacionesLoaded copyWith({
    List<LocationEntity>? allUbicaciones,
    List<LocationEntity>? visibleUbicaciones,
    bool? isSearching,
    String? searchQuery,
    Object? selectedRanchoUuid = _sentinel,
    Set<LocationCategory>? selectedCategoryFilters,
    Map<String, int>? animalCounts,
    Map<String, int>? subtreeAnimalCounts,
    Map<String, double>? averageWeights,
    UbicacionesTreeSnapshot? treeSnapshot,
  }) {
    return UbicacionesLoaded(
      allUbicaciones: allUbicaciones ?? this.allUbicaciones,
      visibleUbicaciones: visibleUbicaciones ?? this.visibleUbicaciones,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRanchoUuid: selectedRanchoUuid == _sentinel
          ? this.selectedRanchoUuid
          : selectedRanchoUuid as String?,
      selectedCategoryFilters:
          selectedCategoryFilters ?? this.selectedCategoryFilters,
      animalCounts: animalCounts ?? this.animalCounts,
      subtreeAnimalCounts: subtreeAnimalCounts ?? this.subtreeAnimalCounts,
      averageWeights: averageWeights ?? this.averageWeights,
      treeSnapshot: treeSnapshot ?? this.treeSnapshot,
    );
  }

  @override
  List<Object> get props => [
    allUbicaciones,
    visibleUbicaciones,
    isSearching,
    searchQuery,
    if (selectedRanchoUuid != null) selectedRanchoUuid!,
    selectedCategoryFilters,
    animalCounts,
    subtreeAnimalCounts,
    averageWeights,
    treeSnapshot,
  ];
}

const Object _sentinel = Object();

class UbicacionesError extends UbicacionesState {
  const UbicacionesError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
