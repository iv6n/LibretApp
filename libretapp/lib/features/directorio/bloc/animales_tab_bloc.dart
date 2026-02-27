import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_state.dart';

class AnimalesTabBloc extends Bloc<AnimalesTabEvent, AnimalesTabState> {
  final AnimalRepository repository;
  StreamSubscription<List<dynamic>>? _subscription;

  AnimalesTabBloc(this.repository) : super(const AnimalesTabInitial()) {
    on<LoadAnimalesTab>(_onLoadAnimales);
    on<SearchAnimalesTab>(_onSearchAnimales);
    on<AnimalesTabStreamUpdated>(_onStreamUpdated);
    on<AnimalesTabStreamFailed>(_onStreamFailed);
  }

  Future<void> _onLoadAnimales(
    LoadAnimalesTab event,
    Emitter<AnimalesTabState> emit,
  ) async {
    emit(const AnimalesTabLoading());
    try {
      await _subscription?.cancel();
      // Usamos watchAll() para obtener un stream de los animales
      _subscription = repository.watchAll().listen(
        (animales) => add(AnimalesTabStreamUpdated(animales)),
        onError: (error, _) => add(AnimalesTabStreamFailed(error.toString())),
      );
    } catch (e) {
      emit(AnimalesTabError('Error al cargar animales: $e'));
    }
  }

  void _onStreamUpdated(
    AnimalesTabStreamUpdated event,
    Emitter<AnimalesTabState> emit,
  ) {
    emit(AnimalesTabLoaded(animales: event.animales));
  }

  void _onStreamFailed(
    AnimalesTabStreamFailed event,
    Emitter<AnimalesTabState> emit,
  ) {
    emit(AnimalesTabError(event.error));
  }

  void _onSearchAnimales(
    SearchAnimalesTab event,
    Emitter<AnimalesTabState> emit,
  ) {
    final currentState = state;
    if (currentState is! AnimalesTabLoaded) return;

    if (event.query.isEmpty) {
      emit(currentState.copyWith(filteredAnimales: null));
      return;
    }

    final filtered = currentState.animales.where((animal) {
      final nombre = _getAnimalName(animal).toLowerCase();
      return nombre.contains(event.query.toLowerCase());
    }).toList();

    emit(currentState.copyWith(filteredAnimales: filtered));
  }

  String _getAnimalName(dynamic animal) {
    // Intenta obtener el nombre según la estructura de la entidad Animal
    if (animal is Map && animal.containsKey('nombre')) {
      return animal['nombre'] as String? ?? '';
    }
    if (animal is Map && animal.containsKey('name')) {
      return animal['name'] as String? ?? '';
    }
    // Intenta acceder a través de reflexión si es necesario
    try {
      return animal.toString();
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
