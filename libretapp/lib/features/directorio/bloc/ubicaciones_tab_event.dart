/// features \u203a directorio \u203a bloc \u203a ubicaciones_tab_event \u2014 events for UbicacionesTabBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

abstract class UbicacionesTabEvent extends Equatable {
  const UbicacionesTabEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar las ubicaciones
class LoadUbicacionesTab extends UbicacionesTabEvent {
  const LoadUbicacionesTab();
}

/// Evento para filtrar ubicaciones por búsqueda
class SearchUbicacionesTab extends UbicacionesTabEvent {
  const SearchUbicacionesTab(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

/// Evento cuando el stream de ubicaciones se actualiza
class UbicacionesTabStreamUpdated extends UbicacionesTabEvent {
  const UbicacionesTabStreamUpdated(this.ubicaciones);

  final List<LocationEntity> ubicaciones;

  @override
  List<Object> get props => [ubicaciones];
}

/// Evento cuando hay error en el stream
class UbicacionesTabStreamFailed extends UbicacionesTabEvent {
  const UbicacionesTabStreamFailed(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
