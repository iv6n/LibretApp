import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_state.dart';

class LotesTabBloc extends Bloc<LotesTabEvent, LotesTabState> {
  LotesTabBloc(this.repository) : super(const LotesTabInitial()) {
    on<LoadLotesTab>(_onLoadLotes);
    on<SearchLotesTab>(_onSearchLotes);
    on<LotesTabStreamUpdated>(_onStreamUpdated);
    on<LotesTabStreamFailed>(_onStreamFailed);
  }
  final LotesRepository repository;
  StreamSubscription<List<LoteEntity>>? _subscription;

  Future<void> _onLoadLotes(
    LoadLotesTab event,
    Emitter<LotesTabState> emit,
  ) async {
    _emitIfActive(emit, const LotesTabLoading());
    try {
      await _subscription?.cancel();
      // Usamos watchAll() para obtener un stream de los lotes
      _subscription = repository.watchAll().listen(
        (lotes) => add(LotesTabStreamUpdated(lotes)),
        onError: (error, _) {
          if (!isClosed) {
            add(LotesTabStreamFailed(error.toString()));
          }
        },
      );
    } catch (e) {
      _emitIfActive(emit, LotesTabError('Error al cargar lotes: $e'));
    }
  }

  void _onStreamUpdated(
    LotesTabStreamUpdated event,
    Emitter<LotesTabState> emit,
  ) {
    _emitIfActive(emit, LotesTabLoaded(lotes: event.lotes));
  }

  void _onStreamFailed(
    LotesTabStreamFailed event,
    Emitter<LotesTabState> emit,
  ) {
    _emitIfActive(emit, LotesTabError(event.error));
  }

  void _onSearchLotes(SearchLotesTab event, Emitter<LotesTabState> emit) {
    final currentState = state;
    if (currentState is! LotesTabLoaded) return;

    if (event.query.isEmpty) {
      _emitIfActive(emit, currentState.copyWith(filteredLotes: null));
      return;
    }

    final filtered = currentState.lotes.where((lote) {
      final nombre = lote.nombre.toLowerCase();
      return nombre.contains(event.query.toLowerCase());
    }).toList();

    _emitIfActive(emit, currentState.copyWith(filteredLotes: filtered));
  }

  void _emitIfActive(Emitter<LotesTabState> emit, LotesTabState state) {
    if (emit.isDone || isClosed) return;
    emit(state);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
