/// features \u203a directorio \u203a bloc \u203a animales_tab_bloc \u2014 BLoC managing the animales tab state within the directorio shell.
library;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_state.dart';

class AnimalesTabBloc extends Bloc<AnimalesTabEvent, AnimalesTabState> {
  AnimalesTabBloc(this.repository) : super(const AnimalesTabInitial()) {
    on<LoadAnimalesTab>(_onLoadAnimales);
    on<SearchAnimalesTab>(_onSearchAnimales);
    on<AnimalesTabStreamUpdated>(_onStreamUpdated);
    on<AnimalesTabStreamFailed>(_onStreamFailed);
  }
  final AnimalRepository repository;
  StreamSubscription<List<AnimalEntity>>? _subscription;

  Future<void> _onLoadAnimales(
    LoadAnimalesTab event,
    Emitter<AnimalesTabState> emit,
  ) async {
    _emitIfActive(emit, const AnimalesTabLoading());
    try {
      await _subscription?.cancel();
      // Usamos watchAll() para obtener un stream de los animales
      _subscription = repository.watchAll().listen(
        (animales) => add(AnimalesTabStreamUpdated(animales)),
        onError: (error, _) {
          if (!isClosed) {
            add(AnimalesTabStreamFailed(error.toString()));
          }
        },
      );
    } catch (e) {
      _emitIfActive(emit, AnimalesTabError('Error al cargar animales: $e'));
    }
  }

  void _onStreamUpdated(
    AnimalesTabStreamUpdated event,
    Emitter<AnimalesTabState> emit,
  ) {
    _emitIfActive(emit, AnimalesTabLoaded(animales: event.animales));
  }

  void _onStreamFailed(
    AnimalesTabStreamFailed event,
    Emitter<AnimalesTabState> emit,
  ) {
    _emitIfActive(emit, AnimalesTabError(event.error));
  }

  void _onSearchAnimales(
    SearchAnimalesTab event,
    Emitter<AnimalesTabState> emit,
  ) {
    final currentState = state;
    if (currentState is! AnimalesTabLoaded) return;

    if (event.query.isEmpty) {
      _emitIfActive(emit, currentState.copyWith(filteredAnimales: null));
      return;
    }

    final filtered = currentState.animales.where((animal) {
      final normalized = event.query.toLowerCase();
      final label = '${animal.earTagNumber} ${animal.customName ?? ''}'
          .toLowerCase();
      return label.contains(normalized);
    }).toList();

    _emitIfActive(emit, currentState.copyWith(filteredAnimales: filtered));
  }

  void _emitIfActive(Emitter<AnimalesTabState> emit, AnimalesTabState state) {
    if (emit.isDone || isClosed) return;
    emit(state);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
