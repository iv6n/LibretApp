/// features \u203a directorio \u203a bloc \u203a ubicaciones_tab_state \u2014 state for UbicacionesTabBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

const Object _copyWithUnset = Object();

abstract class UbicacionesTabState extends Equatable {
  const UbicacionesTabState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class UbicacionesTabInitial extends UbicacionesTabState {
  const UbicacionesTabInitial();
}

/// Estado cargando
class UbicacionesTabLoading extends UbicacionesTabState {
  const UbicacionesTabLoading();
}

/// Estado cargado
class UbicacionesTabLoaded extends UbicacionesTabState {
  const UbicacionesTabLoaded({
    required this.ubicaciones,
    this.filteredUbicaciones,
  });

  final List<LocationEntity> ubicaciones;
  final List<LocationEntity>? filteredUbicaciones;

  /// Devuelve las ubicaciones a mostrar (filtradas o todas)
  List<LocationEntity> get displayUbicaciones =>
      filteredUbicaciones ?? ubicaciones;

  UbicacionesTabLoaded copyWith({
    List<LocationEntity>? ubicaciones,
    Object? filteredUbicaciones = _copyWithUnset,
  }) {
    return UbicacionesTabLoaded(
      ubicaciones: ubicaciones ?? this.ubicaciones,
      filteredUbicaciones: identical(filteredUbicaciones, _copyWithUnset)
          ? this.filteredUbicaciones
          : filteredUbicaciones as List<LocationEntity>?,
    );
  }

  @override
  List<Object?> get props => [ubicaciones, filteredUbicaciones];
}

/// Estado con error
class UbicacionesTabError extends UbicacionesTabState {
  const UbicacionesTabError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
