import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_event.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_state.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/core/constants/ui_constants.dart';
import 'package:stream_transform/stream_transform.dart';

class AnimalesBloc extends Bloc<AnimalesEvent, AnimalesState> {
  AnimalesBloc(this.repository) : super(const AnimalesInitial()) {
    on<LoadAnimales>(_onLoadAnimales);
    on<AnimalesStreamUpdated>(_onStreamUpdated);
    on<AnimalesStreamFailed>(_onStreamFailed);
    on<AddAnimal>(_onAddAnimal);
    on<UpdateAnimal>(_onUpdateAnimal);
    on<DeleteAnimal>(_onDeleteAnimal);
    on<AssignAnimalLocationBatch>(_onAssignAnimalLocationBatch);
    on<RenameBatch>(_onRenameBatch);
    on<ToggleSearch>(_onToggleSearch);
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: _debounce(UiConstants.searchDebounceDuration),
    );
    on<ClearSearch>(_onClearSearch);
    on<ToggleAnimalSelection>(_onToggleAnimalSelection);
    on<SelectAllVisibleAnimals>(_onSelectAllVisibleAnimals);
    on<ClearAnimalSelection>(_onClearAnimalSelection);
  }
  final AnimalRepository repository;

  StreamSubscription<List<AnimalEntity>>? _subscription;
  List<AnimalEntity> _latest = const [];
  String _searchQuery = '';
  bool _isSearching = false;
  Set<String> _selectedAnimalUuids = const <String>{};

  Future<void> _onLoadAnimales(
    LoadAnimales event,
    Emitter<AnimalesState> emit,
  ) async {
    emit(const AnimalesLoading());
    await _subscription?.cancel();
    _subscription = repository.watchAll().listen(
      (animales) => add(AnimalesStreamUpdated(animales)),
      onError: (error, _) {
        if (!isClosed) {
          add(AnimalesStreamFailed(error.toString()));
        }
      },
    );
  }

  void _onStreamUpdated(
    AnimalesStreamUpdated event,
    Emitter<AnimalesState> emit,
  ) {
    _latest = event.animales;
    final existingUuids = _latest.map((a) => a.uuid).toSet();
    _selectedAnimalUuids = _selectedAnimalUuids
        .where(existingUuids.contains)
        .toSet();
    final filtered = _applyFilter(_latest, _searchQuery);
    emit(
      AnimalesLoaded(
        allAnimals: _latest,
        visibleAnimals: filtered,
        isSearching: _isSearching,
        searchQuery: _searchQuery,
        selectedAnimalUuids: _selectedAnimalUuids,
      ),
    );
  }

  void _onStreamFailed(
    AnimalesStreamFailed event,
    Emitter<AnimalesState> emit,
  ) {
    emit(AnimalesError(event.message));
  }

  Future<void> _onAddAnimal(
    AddAnimal event,
    Emitter<AnimalesState> emit,
  ) async {
    try {
      emit(const AnimalesLoading());
      await repository.save(event.animal);
      await _refreshLoadedState(emit);
    } catch (e) {
      emit(AnimalesError(e.toString()));
    }
  }

  Future<void> _onUpdateAnimal(
    UpdateAnimal event,
    Emitter<AnimalesState> emit,
  ) async {
    try {
      emit(const AnimalesLoading());
      await repository.update(event.animal);
      await _refreshLoadedState(emit);
    } catch (e) {
      emit(AnimalesError(e.toString()));
    }
  }

  Future<void> _onDeleteAnimal(
    DeleteAnimal event,
    Emitter<AnimalesState> emit,
  ) async {
    try {
      emit(const AnimalesLoading());
      await repository.delete(event.id);
      await _refreshLoadedState(emit);
    } catch (e) {
      emit(AnimalesError(e.toString()));
    }
  }

  void _onToggleSearch(ToggleSearch event, Emitter<AnimalesState> emit) {
    _isSearching = event.enabled;
    if (!_isSearching) {
      _searchQuery = '';
    }
    final filtered = _applyFilter(_latest, _searchQuery);
    emit(
      AnimalesLoaded(
        allAnimals: _latest,
        visibleAnimals: filtered,
        isSearching: _isSearching,
        searchQuery: _searchQuery,
        selectedAnimalUuids: _selectedAnimalUuids,
      ),
    );
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<AnimalesState> emit,
  ) async {
    _searchQuery = event.query.trim();
    _isSearching = true;
    final filtered = _applyFilter(_latest, _searchQuery);
    emit(
      AnimalesLoaded(
        allAnimals: _latest,
        visibleAnimals: filtered,
        isSearching: _isSearching,
        searchQuery: _searchQuery,
        selectedAnimalUuids: _selectedAnimalUuids,
      ),
    );
  }

  void _onClearSearch(ClearSearch event, Emitter<AnimalesState> emit) {
    _searchQuery = '';
    _isSearching = false;
    emit(
      AnimalesLoaded(
        allAnimals: _latest,
        visibleAnimals: _latest,
        isSearching: _isSearching,
        searchQuery: _searchQuery,
        selectedAnimalUuids: _selectedAnimalUuids,
      ),
    );
  }

  void _onToggleAnimalSelection(
    ToggleAnimalSelection event,
    Emitter<AnimalesState> emit,
  ) {
    final selected = Set<String>.from(_selectedAnimalUuids);
    if (selected.contains(event.animalUuid)) {
      selected.remove(event.animalUuid);
    } else {
      selected.add(event.animalUuid);
    }
    _selectedAnimalUuids = selected;
    emit(_buildLoadedState());
  }

  void _onSelectAllVisibleAnimals(
    SelectAllVisibleAnimals event,
    Emitter<AnimalesState> emit,
  ) {
    final visibleSet = event.visibleAnimalUuids.toSet();
    if (visibleSet.isEmpty) {
      return;
    }
    final selected = Set<String>.from(_selectedAnimalUuids);
    final allVisibleSelected = visibleSet.every(selected.contains);
    if (allVisibleSelected) {
      selected.removeAll(visibleSet);
    } else {
      selected.addAll(visibleSet);
    }
    _selectedAnimalUuids = selected;
    emit(_buildLoadedState());
  }

  void _onClearAnimalSelection(
    ClearAnimalSelection event,
    Emitter<AnimalesState> emit,
  ) {
    _selectedAnimalUuids = const <String>{};
    emit(_buildLoadedState());
  }

  Future<void> _onAssignAnimalLocationBatch(
    AssignAnimalLocationBatch event,
    Emitter<AnimalesState> emit,
  ) async {
    try {
      emit(const AnimalesLoading());
      final current = await repository.getByUuid(event.uuid);
      if (current == null) {
        emit(const AnimalesError('Animal no encontrado'));
        return;
      }

      final now = DateTime.now();
      final updated = current.copyWith(
        currentPaddockId: event.locationId,
        initialLocationId:
            current.initialLocationId ??
            event.locationId ??
            current.initialLocationId,
        lastMovementDate: event.locationId != null
            ? now
            : current.lastMovementDate,
        lastUpdateDate: now,
        synced: false,
      );

      await repository.update(updated);
      await _refreshLoadedState(emit);
    } catch (e) {
      emit(AnimalesError(e.toString()));
    }
  }

  Future<void> _onRenameBatch(
    RenameBatch event,
    Emitter<AnimalesState> emit,
  ) async {
    try {
      emit(const AnimalesLoading());
      await repository.getAll(); // Fetch all animals to ensure consistency
      // Note: RenameBatch is a legacy handler. Batch renaming should be done
      // through the LotesBloc by updating LoteEntity.nombre instead.
      // This handler is kept for backward compatibility but doesn't update animals.
    } catch (e) {
      emit(AnimalesError(e.toString()));
    }
  }

  List<AnimalEntity> _applyFilter(List<AnimalEntity> source, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return source;
    return source.where((animal) {
      final fields = <String?>[
        animal.earTagNumber,
        animal.visualId,
        animal.breed,
        animal.species.displayName,
        animal.category.displayName,
        animal.lifeStage.displayName,
        animal.sex.displayName,
        animal.rfidTag,
        animal.batchUuid,
        animal.chronicNotes,
      ];
      return fields.any(
        (field) => (field ?? '').toLowerCase().contains(normalized),
      );
    }).toList();
  }

  AnimalesLoaded _buildLoadedState() {
    final filtered = _applyFilter(_latest, _searchQuery);
    return AnimalesLoaded(
      allAnimals: _latest,
      visibleAnimals: filtered,
      isSearching: _isSearching,
      searchQuery: _searchQuery,
      selectedAnimalUuids: _selectedAnimalUuids,
    );
  }

  Future<void> _refreshLoadedState(Emitter<AnimalesState> emit) async {
    final animals = await repository.getAll();
    _latest = animals;
    final existingUuids = _latest.map((a) => a.uuid).toSet();
    _selectedAnimalUuids = _selectedAnimalUuids
        .where(existingUuids.contains)
        .toSet();
    emit(_buildLoadedState());
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
