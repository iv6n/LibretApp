import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_state.dart';

class LotesTabBloc extends Bloc<LotesTabEvent, LotesTabState> {
  final LotesRepository repository;
  StreamSubscription<List<dynamic>>? _subscription;

  LotesTabBloc(this.repository) : super(const LotesTabInitial()) {
    on<LoadLotesTab>(_onLoadLotes);
    on<SearchLotesTab>(_onSearchLotes);
    on<LotesTabStreamUpdated>(_onStreamUpdated);
    on<LotesTabStreamFailed>(_onStreamFailed);
  }

  Future<void> _onLoadLotes(
    LoadLotesTab event,
    Emitter<LotesTabState> emit,
  ) async {
    emit(const LotesTabLoading());
    try {
      await _subscription?.cancel();
      // Usamos watchAll() para obtener un stream de los lotes
      _subscription = repository.watchAll().listen(
        (lotes) => add(LotesTabStreamUpdated(lotes)),
        onError: (error, _) => add(LotesTabStreamFailed(error.toString())),
      );
    } catch (e) {
      emit(LotesTabError('Error al cargar lotes: $e'));
    }
  }

  void _onStreamUpdated(
    LotesTabStreamUpdated event,
    Emitter<LotesTabState> emit,
  ) {
    emit(LotesTabLoaded(lotes: event.lotes));
  }

  void _onStreamFailed(
    LotesTabStreamFailed event,
    Emitter<LotesTabState> emit,
  ) {
    emit(LotesTabError(event.error));
  }

  void _onSearchLotes(SearchLotesTab event, Emitter<LotesTabState> emit) {
    final currentState = state;
    if (currentState is! LotesTabLoaded) return;

    if (event.query.isEmpty) {
      emit(currentState.copyWith(filteredLotes: null));
      return;
    }

    final filtered = currentState.lotes.where((lote) {
      final nombre = _getLoteName(lote).toLowerCase();
      return nombre.contains(event.query.toLowerCase());
    }).toList();

    emit(currentState.copyWith(filteredLotes: filtered));
  }

  String _getLoteName(dynamic lote) {
    if (lote is Map && lote.containsKey('nombre')) {
      return lote['nombre'] as String? ?? '';
    }
    if (lote is Map && lote.containsKey('name')) {
      return lote['name'] as String? ?? '';
    }
    try {
      return lote.toString();
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
