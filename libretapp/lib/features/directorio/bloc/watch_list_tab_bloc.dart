/// features > directorio > bloc > watch_list_tab_bloc
library;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Shared skeleton for the directorio tab blocs (Animales/Lotes/Ubicaciones),
/// which all watch a repository stream and re-emit a loading/loaded/error
/// state as it updates. Concrete subclasses keep their own Event/State
/// classes (so nothing about the public Bloc API changes for consumers) and
/// only wire the stream + the loading/error state factories.
abstract class WatchListTabBloc<TItem, TEvent, TState>
    extends Bloc<TEvent, TState> {
  WatchListTabBloc(super.initialState);

  StreamSubscription<List<TItem>>? _subscription;

  /// Repository stream this bloc watches.
  Stream<List<TItem>> watchItems();

  TState buildLoading();

  /// Builds the error state from a raw error description (subclasses add
  /// their own "Error al cargar X: " prefix).
  TState buildError(String rawError);

  /// Dispatches the bloc's own stream-updated event with [items].
  void onStreamUpdated(List<TItem> items);

  /// Dispatches the bloc's own stream-failed event with [error].
  void onStreamFailed(String error);

  Future<void> handleLoad(Emitter<TState> emit) async {
    emitIfActive(emit, buildLoading());
    try {
      await _subscription?.cancel();
      _subscription = watchItems().listen(
        onStreamUpdated,
        onError: (error, _) {
          if (!isClosed) onStreamFailed(error.toString());
        },
      );
    } catch (e) {
      emitIfActive(emit, buildError('$e'));
    }
  }

  void emitIfActive(Emitter<TState> emit, TState newState) {
    if (emit.isDone || isClosed) return;
    emit(newState);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
