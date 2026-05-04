/// features \u203a directorio \u203a bloc \u203a ubicaciones_tab_bloc \u2014 BLoC managing the ubicaciones tab state within the directorio shell.
library;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class UbicacionesTabBloc
    extends Bloc<UbicacionesTabEvent, UbicacionesTabState> {
  UbicacionesTabBloc(this.repository) : super(const UbicacionesTabInitial()) {
    on<LoadUbicacionesTab>(_onLoadUbicaciones);
    on<SearchUbicacionesTab>(_onSearchUbicaciones);
    on<UbicacionesTabStreamUpdated>(_onStreamUpdated);
    on<UbicacionesTabStreamFailed>(_onStreamFailed);
  }
  final LocationRepository repository;
  StreamSubscription<List<LocationEntity>>? _subscription;

  Future<void> _onLoadUbicaciones(
    LoadUbicacionesTab event,
    Emitter<UbicacionesTabState> emit,
  ) async {
    _emitIfActive(emit, const UbicacionesTabLoading());
    try {
      await _subscription?.cancel();
      // Usamos watchAll() para obtener un stream de las ubicaciones
      _subscription = repository.watchAll().listen(
        (ubicaciones) => add(UbicacionesTabStreamUpdated(ubicaciones)),
        onError: (error, _) {
          if (!isClosed) {
            add(UbicacionesTabStreamFailed(error.toString()));
          }
        },
      );
    } catch (e) {
      _emitIfActive(
        emit,
        UbicacionesTabError('Error al cargar ubicaciones: $e'),
      );
    }
  }

  void _onStreamUpdated(
    UbicacionesTabStreamUpdated event,
    Emitter<UbicacionesTabState> emit,
  ) {
    _emitIfActive(emit, UbicacionesTabLoaded(ubicaciones: event.ubicaciones));
  }

  void _onStreamFailed(
    UbicacionesTabStreamFailed event,
    Emitter<UbicacionesTabState> emit,
  ) {
    _emitIfActive(emit, UbicacionesTabError(event.error));
  }

  void _onSearchUbicaciones(
    SearchUbicacionesTab event,
    Emitter<UbicacionesTabState> emit,
  ) {
    final currentState = state;
    if (currentState is! UbicacionesTabLoaded) return;

    if (event.query.isEmpty) {
      _emitIfActive(emit, currentState.copyWith(filteredUbicaciones: null));
      return;
    }

    final filtered = currentState.ubicaciones.where((ubicacion) {
      final nombre = ubicacion.name.toLowerCase();
      return nombre.contains(event.query.toLowerCase());
    }).toList();

    _emitIfActive(emit, currentState.copyWith(filteredUbicaciones: filtered));
  }

  void _emitIfActive(
    Emitter<UbicacionesTabState> emit,
    UbicacionesTabState state,
  ) {
    if (emit.isDone || isClosed) return;
    emit(state);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
