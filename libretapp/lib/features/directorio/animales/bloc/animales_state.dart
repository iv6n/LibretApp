/// features \u203a directorio \u203a animales \u203a bloc \u203a animales_state \u2014 state for AnimalesBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/index.dart';

abstract class AnimalesState extends Equatable {
  const AnimalesState();

  @override
  List<Object> get props => [];
}

class AnimalesInitial extends AnimalesState {
  const AnimalesInitial();
}

class AnimalesLoading extends AnimalesState {
  const AnimalesLoading();
}

class AnimalesLoaded extends AnimalesState {
  const AnimalesLoaded({
    required this.allAnimals,
    required this.visibleAnimals,
    this.isSearching = false,
    this.searchQuery = '',
    this.searchFilterStages = const {},
    this.searchFilterSexes = const {},
    this.selectedAnimalUuids = const {},
    this.hasMore = false,
    this.isLoadingMore = false,
    this.currentOffset = 0,
    this.herdTotal = 0,
    this.herdStageCounts = const {},
  });
  static const int pageSize = 20;

  /// Animals loaded so far — the first page, then more as the user scrolls.
  /// Not the herd: see [herdTotal].
  final List<AnimalEntity> allAnimals;
  final List<AnimalEntity> visibleAnimals;
  final bool isSearching;
  final String searchQuery;
  final Set<LifeStage> searchFilterStages;
  final Set<Sex> searchFilterSexes;
  final Set<String> selectedAnimalUuids;
  final bool hasMore;
  final bool isLoadingMore;
  final int currentOffset;

  /// Size of the whole active herd, counted in the database — not just the
  /// pages loaded so far. What the list's "N animales" label must show, so it
  /// does not read 20 and then climb as the user scrolls.
  final int herdTotal;

  /// Whole-herd tally per life stage, for the same reason as [herdTotal]:
  /// the filter chips have to state the real figure from the first frame.
  final Map<LifeStage, int> herdStageCounts;

  // Backward-friendly accessor for existing usages.
  List<AnimalEntity> get animales => visibleAnimals;
  bool get isSelectionMode => selectedAnimalUuids.isNotEmpty;
  int get selectedCount => selectedAnimalUuids.length;

  AnimalesLoaded copyWith({
    List<AnimalEntity>? allAnimals,
    List<AnimalEntity>? visibleAnimals,
    bool? isSearching,
    String? searchQuery,
    Set<LifeStage>? searchFilterStages,
    Set<Sex>? searchFilterSexes,
    Set<String>? selectedAnimalUuids,
    bool? hasMore,
    bool? isLoadingMore,
    int? currentOffset,
    int? herdTotal,
    Map<LifeStage, int>? herdStageCounts,
  }) {
    return AnimalesLoaded(
      allAnimals: allAnimals ?? this.allAnimals,
      visibleAnimals: visibleAnimals ?? this.visibleAnimals,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      searchFilterStages: searchFilterStages ?? this.searchFilterStages,
      searchFilterSexes: searchFilterSexes ?? this.searchFilterSexes,
      selectedAnimalUuids: selectedAnimalUuids ?? this.selectedAnimalUuids,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentOffset: currentOffset ?? this.currentOffset,
      herdTotal: herdTotal ?? this.herdTotal,
      herdStageCounts: herdStageCounts ?? this.herdStageCounts,
    );
  }

  @override
  List<Object> get props => [
    allAnimals,
    visibleAnimals,
    isSearching,
    searchQuery,
    searchFilterStages,
    searchFilterSexes,
    selectedAnimalUuids,
    hasMore,
    isLoadingMore,
    currentOffset,
    herdTotal,
    herdStageCounts,
  ];
}

class AnimalesError extends AnimalesState {
  const AnimalesError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
