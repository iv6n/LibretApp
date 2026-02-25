import 'package:equatable/equatable.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

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
  final List<LocationEntity> allUbicaciones;
  final List<LocationEntity> visibleUbicaciones;
  final bool isSearching;
  final String searchQuery;

  const UbicacionesLoaded({
    required this.allUbicaciones,
    required this.visibleUbicaciones,
    required this.isSearching,
    required this.searchQuery,
  });

  @override
  List<Object> get props => [
        allUbicaciones,
        visibleUbicaciones,
        isSearching,
        searchQuery,
      ];
}

class UbicacionesError extends UbicacionesState {
  final String message;

  const UbicacionesError(this.message);

  @override
  List<Object> get props => [message];
}
