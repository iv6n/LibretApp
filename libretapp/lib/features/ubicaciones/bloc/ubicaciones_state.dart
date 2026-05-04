/// features \u203a ubicaciones \u203a bloc \u203a ubicaciones_state \u2014 state for UbicacionesBloc.
library;

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
  const UbicacionesLoaded({
    required this.allUbicaciones,
    required this.visibleUbicaciones,
    required this.isSearching,
    required this.searchQuery,
  });
  final List<LocationEntity> allUbicaciones;
  final List<LocationEntity> visibleUbicaciones;
  final bool isSearching;
  final String searchQuery;

  @override
  List<Object> get props => [
    allUbicaciones,
    visibleUbicaciones,
    isSearching,
    searchQuery,
  ];
}

class UbicacionesError extends UbicacionesState {
  const UbicacionesError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
