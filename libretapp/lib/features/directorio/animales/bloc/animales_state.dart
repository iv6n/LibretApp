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
  const AnimalesLoaded({
    required this.allAnimals,
    required this.visibleAnimals,
    this.isSearching = false,
    this.searchQuery = '',
  });

  final List<AnimalEntity> allAnimals;
  final List<AnimalEntity> visibleAnimals;
  final bool isSearching;
  final String searchQuery;

  // Backward-friendly accessor for existing usages.
  List<AnimalEntity> get animales => visibleAnimals;

  AnimalesLoaded copyWith({
    List<AnimalEntity>? allAnimals,
    List<AnimalEntity>? visibleAnimals,
    bool? isSearching,
    String? searchQuery,
  }) {
    return AnimalesLoaded(
      allAnimals: allAnimals ?? this.allAnimals,
      visibleAnimals: visibleAnimals ?? this.visibleAnimals,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object> get props => [
    allAnimals,
    visibleAnimals,
    isSearching,
    searchQuery,
  ];
}

class AnimalesError extends AnimalesState {
  final String message;

  const AnimalesError(this.message);

  @override
  List<Object> get props => [message];
}
