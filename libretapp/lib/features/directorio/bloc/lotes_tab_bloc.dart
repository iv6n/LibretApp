/// features › directorio › bloc › lotes_tab_bloc — BLoC managing the lotes tab state within the directorio shell.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_state.dart';
import 'package:libretapp/features/directorio/bloc/watch_list_tab_bloc.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

class LotesTabBloc
    extends WatchListTabBloc<LoteEntity, LotesTabEvent, LotesTabState> {
  LotesTabBloc(this.repository) : super(const LotesTabInitial()) {
    on<LoadLotesTab>((event, emit) => handleLoad(emit));
    on<SearchLotesTab>(_onSearchLotes);
    on<LotesTabStreamUpdated>(_onStreamUpdated);
    on<LotesTabStreamFailed>(_onStreamFailed);
  }
  final LotesRepository repository;

  @override
  Stream<List<LoteEntity>> watchItems() => repository.watchAll();

  @override
  LotesTabState buildLoading() => const LotesTabLoading();

  @override
  LotesTabState buildError(String rawError) =>
      LotesTabError('Error al cargar lotes: $rawError');

  @override
  void onStreamUpdated(List<LoteEntity> items) =>
      add(LotesTabStreamUpdated(items));

  @override
  void onStreamFailed(String error) => add(LotesTabStreamFailed(error));

  void _onStreamUpdated(
    LotesTabStreamUpdated event,
    Emitter<LotesTabState> emit,
  ) {
    emitIfActive(emit, LotesTabLoaded(lotes: event.lotes));
  }

  void _onStreamFailed(
    LotesTabStreamFailed event,
    Emitter<LotesTabState> emit,
  ) {
    emitIfActive(emit, LotesTabError(event.error));
  }

  void _onSearchLotes(SearchLotesTab event, Emitter<LotesTabState> emit) {
    final currentState = state;
    if (currentState is! LotesTabLoaded) return;

    if (event.query.isEmpty) {
      emitIfActive(emit, currentState.copyWith(filteredLotes: null));
      return;
    }

    final filtered = currentState.lotes.where((lote) {
      final nombre = lote.name.toLowerCase();
      return nombre.contains(event.query.toLowerCase());
    }).toList();

    emitIfActive(emit, currentState.copyWith(filteredLotes: filtered));
  }
}
