/// features › directorio › bloc › ubicaciones_tab_bloc — BLoC managing the ubicaciones tab state within the directorio shell.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_state.dart';
import 'package:libretapp/features/directorio/bloc/watch_list_tab_bloc.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class UbicacionesTabBloc
    extends
        WatchListTabBloc<
          LocationEntity,
          UbicacionesTabEvent,
          UbicacionesTabState
        > {
  UbicacionesTabBloc(this.repository) : super(const UbicacionesTabInitial()) {
    on<LoadUbicacionesTab>((event, emit) => handleLoad(emit));
    on<SearchUbicacionesTab>(_onSearchUbicaciones);
    on<UbicacionesTabStreamUpdated>(_onStreamUpdated);
    on<UbicacionesTabStreamFailed>(_onStreamFailed);
  }
  final LocationRepository repository;

  @override
  Stream<List<LocationEntity>> watchItems() => repository.watchAll();

  @override
  UbicacionesTabState buildLoading() => const UbicacionesTabLoading();

  @override
  UbicacionesTabState buildError(String rawError) =>
      UbicacionesTabError('Error al cargar ubicaciones: $rawError');

  @override
  void onStreamUpdated(List<LocationEntity> items) =>
      add(UbicacionesTabStreamUpdated(items));

  @override
  void onStreamFailed(String error) => add(UbicacionesTabStreamFailed(error));

  void _onStreamUpdated(
    UbicacionesTabStreamUpdated event,
    Emitter<UbicacionesTabState> emit,
  ) {
    emitIfActive(emit, UbicacionesTabLoaded(ubicaciones: event.ubicaciones));
  }

  void _onStreamFailed(
    UbicacionesTabStreamFailed event,
    Emitter<UbicacionesTabState> emit,
  ) {
    emitIfActive(emit, UbicacionesTabError(event.error));
  }

  void _onSearchUbicaciones(
    SearchUbicacionesTab event,
    Emitter<UbicacionesTabState> emit,
  ) {
    final currentState = state;
    if (currentState is! UbicacionesTabLoaded) return;

    if (event.query.isEmpty) {
      emitIfActive(emit, currentState.copyWith(filteredUbicaciones: null));
      return;
    }

    final filtered = currentState.ubicaciones.where((ubicacion) {
      final nombre = ubicacion.name.toLowerCase();
      return nombre.contains(event.query.toLowerCase());
    }).toList();

    emitIfActive(emit, currentState.copyWith(filteredUbicaciones: filtered));
  }
}
