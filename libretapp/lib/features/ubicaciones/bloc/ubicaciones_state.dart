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
  final List<LocationEntity> ubicaciones;

  const UbicacionesLoaded(this.ubicaciones);

  @override
  List<Object> get props => [ubicaciones];
}

class UbicacionesError extends UbicacionesState {
  final String message;

  const UbicacionesError(this.message);

  @override
  List<Object> get props => [message];
}
