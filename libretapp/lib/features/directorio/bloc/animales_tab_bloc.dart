/// features › directorio › bloc › animales_tab_bloc — BLoC managing the animales tab state within the directorio shell.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_state.dart';
import 'package:libretapp/features/directorio/bloc/watch_list_tab_bloc.dart';

class AnimalesTabBloc
    extends WatchListTabBloc<AnimalEntity, AnimalesTabEvent, AnimalesTabState> {
  AnimalesTabBloc(this.repository) : super(const AnimalesTabInitial()) {
    on<LoadAnimalesTab>((event, emit) => handleLoad(emit));
    on<SearchAnimalesTab>(_onSearchAnimales);
    on<AnimalesTabStreamUpdated>(_onStreamUpdated);
    on<AnimalesTabStreamFailed>(_onStreamFailed);
  }
  final AnimalRepository repository;

  @override
  Stream<List<AnimalEntity>> watchItems() => repository.watchAll();

  @override
  AnimalesTabState buildLoading() => const AnimalesTabLoading();

  @override
  AnimalesTabState buildError(String rawError) =>
      AnimalesTabError('Error al cargar animales: $rawError');

  @override
  void onStreamUpdated(List<AnimalEntity> items) =>
      add(AnimalesTabStreamUpdated(items));

  @override
  void onStreamFailed(String error) => add(AnimalesTabStreamFailed(error));

  void _onStreamUpdated(
    AnimalesTabStreamUpdated event,
    Emitter<AnimalesTabState> emit,
  ) {
    emitIfActive(emit, AnimalesTabLoaded(animales: event.animales));
  }

  void _onStreamFailed(
    AnimalesTabStreamFailed event,
    Emitter<AnimalesTabState> emit,
  ) {
    emitIfActive(emit, AnimalesTabError(event.error));
  }

  void _onSearchAnimales(
    SearchAnimalesTab event,
    Emitter<AnimalesTabState> emit,
  ) {
    final currentState = state;
    if (currentState is! AnimalesTabLoaded) return;

    if (event.query.isEmpty) {
      emitIfActive(emit, currentState.copyWith(filteredAnimales: null));
      return;
    }

    final filtered = currentState.animales.where((animal) {
      final normalized = event.query.toLowerCase();
      final label = animalSearchPresentationText(animal).toLowerCase();
      return label.contains(normalized);
    }).toList();

    emitIfActive(emit, currentState.copyWith(filteredAnimales: filtered));
  }
}
