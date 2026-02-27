import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_state.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class UbicacionesTabBloc
    extends Bloc<UbicacionesTabEvent, UbicacionesTabState> {
  final LocationRepository repository;
  StreamSubscription<List<dynamic>>? _subscription;

  UbicacionesTabBloc(this.repository) : super(const UbicacionesTabInitial()) {
    on<LoadUbicacionesTab>(_onLoadUbicaciones);
    on<SearchUbicacionesTab>(_onSearchUbicaciones);
    on<UbicacionesTabStreamUpdated>(_onStreamUpdated);
    on<UbicacionesTabStreamFailed>(_onStreamFailed);
  }

  Future<void> _onLoadUbicaciones(
    LoadUbicacionesTab event,
    Emitter<UbicacionesTabState> emit,
  ) async {
    emit(const UbicacionesTabLoading());
    try {
      await _subscription?.cancel();
      // Usamos watchAll() para obtener un stream de las ubicaciones
      _subscription = repository.watchAll().listen(
        (ubicaciones) => add(UbicacionesTabStreamUpdated(ubicaciones)),
        onError: (error, _) =>
            add(UbicacionesTabStreamFailed(error.toString())),
      );
    } catch (e) {
      emit(UbicacionesTabError('Error al cargar ubicaciones: $e'));
    }
  }

  void _onStreamUpdated(
    UbicacionesTabStreamUpdated event,
    Emitter<UbicacionesTabState> emit,
  ) {
    emit(UbicacionesTabLoaded(ubicaciones: event.ubicaciones));
  }

  void _onStreamFailed(
    UbicacionesTabStreamFailed event,
    Emitter<UbicacionesTabState> emit,
  ) {
    emit(UbicacionesTabError(event.error));
  }

  void _onSearchUbicaciones(
    SearchUbicacionesTab event,
    Emitter<UbicacionesTabState> emit,
  ) {
    final currentState = state;
    if (currentState is! UbicacionesTabLoaded) return;

    if (event.query.isEmpty) {
      emit(currentState.copyWith(filteredUbicaciones: null));
      return;
    }

    final filtered = currentState.ubicaciones.where((ubicacion) {
      final nombre = _getUbicacionName(ubicacion).toLowerCase();
      return nombre.contains(event.query.toLowerCase());
    }).toList();

    emit(currentState.copyWith(filteredUbicaciones: filtered));
  }

  String _getUbicacionName(dynamic ubicacion) {
    if (ubicacion is Map && ubicacion.containsKey('nombre')) {
      return ubicacion['nombre'] as String? ?? '';
    }
    if (ubicacion is Map && ubicacion.containsKey('name')) {
      return ubicacion['name'] as String? ?? '';
    }
    try {
      return ubicacion.toString();
    } catch (e) {
      return '';
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
