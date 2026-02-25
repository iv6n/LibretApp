import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:stream_transform/stream_transform.dart';

class UbicacionesBloc extends Bloc<UbicacionesEvent, UbicacionesState> {
  UbicacionesBloc(this.repository) : super(const UbicacionesInitial()) {
    on<LoadUbicaciones>(_onLoadUbicaciones);
    on<UbicacionesStreamUpdated>(_onStreamUpdated);
    on<UbicacionesStreamFailed>(_onStreamFailed);
    on<UpsertUbicacion>(_onUpsertUbicacion);
    on<DeleteUbicacion>(_onDeleteUbicacion);
    on<ToggleSearch>(_onToggleSearch);
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: _debounce(const Duration(milliseconds: 260)),
    );
    on<ClearSearch>(_onClearSearch);
    // Compatibility with older calls using SearchUbicaciones.
    on<SearchUbicaciones>(
      _onSearchUbicaciones,
      transformer: _debounce(const Duration(milliseconds: 260)),
    );
    on<AddVisitRecordEvent>(_onAddVisit);
    on<AddWaterRecordEvent>(_onAddWater);
    on<AddPastureRecordEvent>(_onAddPasture);
    on<AddSeedingRecordEvent>(_onAddSeeding);
    on<AddIrrigationRecordEvent>(_onAddIrrigation);
    on<AddRainRecordEvent>(_onAddRain);
    on<AddCostRecordEvent>(_onAddCost);
  }

  final LocationRepository repository;
  StreamSubscription<List<LocationEntity>>? _subscription;
  List<LocationEntity> _latest = const [];
  String _searchQuery = '';
  bool _isSearching = false;

  Future<void> _onLoadUbicaciones(
    LoadUbicaciones event,
    Emitter<UbicacionesState> emit,
  ) async {
    emit(const UbicacionesLoading());
    await _subscription?.cancel();
    _subscription = repository.watchAll().listen(
      (ubicaciones) => add(UbicacionesStreamUpdated(ubicaciones)),
      onError: (error, _) => add(UbicacionesStreamFailed(error.toString())),
    );
  }

  void _onStreamUpdated(
    UbicacionesStreamUpdated event,
    Emitter<UbicacionesState> emit,
  ) {
    _latest = event.ubicaciones;
    final filtered = _applyFilter(_latest, _searchQuery);
    emit(
      UbicacionesLoaded(
        allUbicaciones: _latest,
        visibleUbicaciones: filtered,
        isSearching: _isSearching,
        searchQuery: _searchQuery,
      ),
    );
  }

  void _onStreamFailed(
    UbicacionesStreamFailed event,
    Emitter<UbicacionesState> emit,
  ) {
    emit(UbicacionesError(event.message));
  }

  Future<void> _onUpsertUbicacion(
    UpsertUbicacion event,
    Emitter<UbicacionesState> emit,
  ) async {
    try {
      emit(const UbicacionesLoading());
      await repository.upsert(event.ubicacion);
    } catch (e) {
      emit(UbicacionesError(e.toString()));
    }
  }

  Future<void> _onDeleteUbicacion(
    DeleteUbicacion event,
    Emitter<UbicacionesState> emit,
  ) async {
    try {
      emit(const UbicacionesLoading());
      await repository.deleteByUuid(event.uuid);
    } catch (e) {
      emit(UbicacionesError(e.toString()));
    }
  }

  Future<void> _onSearchUbicaciones(
    SearchUbicaciones event,
    Emitter<UbicacionesState> emit,
  ) async {
    _searchQuery = event.query.trim();
    _isSearching = _searchQuery.isNotEmpty;
    final filtered = _applyFilter(_latest, _searchQuery);
    emit(
      UbicacionesLoaded(
        allUbicaciones: _latest,
        visibleUbicaciones: filtered,
        isSearching: _isSearching,
        searchQuery: _searchQuery,
      ),
    );
  }

  void _onToggleSearch(ToggleSearch event, Emitter<UbicacionesState> emit) {
    _isSearching = event.enabled;
    if (!_isSearching) {
      _searchQuery = '';
    }
    final filtered = _applyFilter(_latest, _searchQuery);
    emit(
      UbicacionesLoaded(
        allUbicaciones: _latest,
        visibleUbicaciones: filtered,
        isSearching: _isSearching,
        searchQuery: _searchQuery,
      ),
    );
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<UbicacionesState> emit,
  ) async {
    _searchQuery = event.query.trim();
    _isSearching = true;
    final filtered = _applyFilter(_latest, _searchQuery);
    emit(
      UbicacionesLoaded(
        allUbicaciones: _latest,
        visibleUbicaciones: filtered,
        isSearching: _isSearching,
        searchQuery: _searchQuery,
      ),
    );
  }

  void _onClearSearch(ClearSearch event, Emitter<UbicacionesState> emit) {
    _searchQuery = '';
    _isSearching = false;
    emit(
      UbicacionesLoaded(
        allUbicaciones: _latest,
        visibleUbicaciones: _latest,
        isSearching: _isSearching,
        searchQuery: _searchQuery,
      ),
    );
  }

  Future<void> _onAddVisit(
    AddVisitRecordEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addVisit(event.uuid, event.record),
      emit,
    );
  }

  Future<void> _onAddWater(
    AddWaterRecordEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addWater(event.uuid, event.record),
      emit,
    );
  }

  Future<void> _onAddPasture(
    AddPastureRecordEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addPasture(event.uuid, event.record),
      emit,
    );
  }

  Future<void> _onAddSeeding(
    AddSeedingRecordEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addSeeding(event.uuid, event.record),
      emit,
    );
  }

  Future<void> _onAddIrrigation(
    AddIrrigationRecordEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addIrrigation(event.uuid, event.record),
      emit,
    );
  }

  Future<void> _onAddRain(
    AddRainRecordEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addRain(event.uuid, event.record),
      emit,
    );
  }

  Future<void> _onAddCost(
    AddCostRecordEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addCost(event.uuid, event.record),
      emit,
    );
  }

  Future<void> _wrapMutation(
    Future<void> Function() action,
    Emitter<UbicacionesState> emit,
  ) async {
    try {
      await action();
    } catch (e) {
      emit(UbicacionesError(e.toString()));
    }
  }

  List<LocationEntity> _applyFilter(List<LocationEntity> source, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return source;
    return source
        .where((u) => u.name.toLowerCase().contains(normalized))
        .toList();
  }

  EventTransformer<T> _debounce<T>(Duration duration) {
    return (events, mapper) => events.debounce(duration).switchMap(mapper);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
