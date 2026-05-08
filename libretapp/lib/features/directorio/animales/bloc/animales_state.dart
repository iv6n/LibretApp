/// features \u203a directorio \u203a animales \u203a bloc \u203a animales_state \u2014 state for AnimalesBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';

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
  static const int pageSize = 20;

  const AnimalesLoaded({
    required this.allAnimals,
    required this.visibleAnimals,
    this.isSearching = false,
    this.searchQuery = '',
    this.selectedAnimalUuids = const {},
    this.hasMore = false,
    this.isLoadingMore = false,
    this.currentOffset = 0,
  });

  final List<AnimalEntity> allAnimals;
  final List<AnimalEntity> visibleAnimals;
  final bool isSearching;
  final String searchQuery;
  final Set<String> selectedAnimalUuids;
  final bool hasMore;
  final bool isLoadingMore;
  final int currentOffset;

  // Backward-friendly accessor for existing usages.
  List<AnimalEntity> get animales => visibleAnimals;
  bool get isSelectionMode => selectedAnimalUuids.isNotEmpty;
  int get selectedCount => selectedAnimalUuids.length;

  AnimalesLoaded copyWith({
    List<AnimalEntity>? allAnimals,
    List<AnimalEntity>? visibleAnimals,
    bool? isSearching,
    String? searchQuery,
    Set<String>? selectedAnimalUuids,
    bool? hasMore,
    bool? isLoadingMore,
    int? currentOffset,
  }) {
    return AnimalesLoaded(
      allAnimals: allAnimals ?? this.allAnimals,
      visibleAnimals: visibleAnimals ?? this.visibleAnimals,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedAnimalUuids: selectedAnimalUuids ?? this.selectedAnimalUuids,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }

  @override
  List<Object> get props => [
    allAnimals,
    visibleAnimals,
    isSearching,
    searchQuery,
    selectedAnimalUuids,
    hasMore,
    isLoadingMore,
    currentOffset,
  ];
}

class AnimalesError extends AnimalesState {
  const AnimalesError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
