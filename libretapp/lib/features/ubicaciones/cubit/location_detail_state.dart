/// State for [LocationDetailCubit].
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

class LocationDetailState extends Equatable {
  const LocationDetailState({
    this.location,
    this.allLocations = const [],
    this.allAnimals = const [],
    this.isLoading = true,
    this.isAssigning = false,
    this.errorMessage,
  });

  final LocationEntity? location;
  final List<LocationEntity> allLocations;
  final List<AnimalEntity> allAnimals;
  final bool isLoading;
  final bool isAssigning;
  final String? errorMessage;

  bool get isNotFound => !isLoading && location == null;

  List<AnimalEntity> get animalsHere {
    final locationUuid = location?.uuid;
    if (locationUuid == null) return const [];

    return allAnimals
        .where((animal) {
          final locId = animal.currentLocationId ?? animal.initialLocationId;
          return locId == locationUuid;
        })
        .toList(growable: false);
  }

  LocationDetailState copyWith({
    Object? location = _sentinel,
    List<LocationEntity>? allLocations,
    List<AnimalEntity>? allAnimals,
    bool? isLoading,
    bool? isAssigning,
    Object? errorMessage = _sentinel,
  }) {
    return LocationDetailState(
      location: location == _sentinel
          ? this.location
          : location as LocationEntity?,
      allLocations: allLocations ?? this.allLocations,
      allAnimals: allAnimals ?? this.allAnimals,
      isLoading: isLoading ?? this.isLoading,
      isAssigning: isAssigning ?? this.isAssigning,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    location,
    allLocations,
    allAnimals,
    isLoading,
    isAssigning,
    errorMessage,
  ];
}

const Object _sentinel = Object();
