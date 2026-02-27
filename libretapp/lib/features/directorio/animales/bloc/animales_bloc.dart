import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_event.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_state.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:stream_transform/stream_transform.dart';

class AnimalesBloc extends Bloc<AnimalesEvent, AnimalesState> {
  final AnimalRepository repository;

  StreamSubscription<List<AnimalEntity>>? _subscription;
  List<AnimalEntity> _latest = const [];
  String _searchQuery = '';
  bool _isSearching = false;

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
      transformer: _debounce(const Duration(milliseconds: 260)),
    );
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadAnimales(
    LoadAnimales event,
    Emitter<AnimalesState> emit,
  ) async {
    emit(const AnimalesLoading());
    try {
      await repository.refreshFromRemote(force: event.forceRefresh);
    } catch (e) {
      emit(AnimalesError('No se pudo sincronizar: $e'));
    }
    await _subscription?.cancel();
    _subscription = repository.watchAll().listen(
      (animales) => add(AnimalesStreamUpdated(animales)),
      onError: (error, _) => add(AnimalesStreamFailed(error.toString())),
    );
  }

  void _onStreamUpdated(
    AnimalesStreamUpdated event,
    Emitter<AnimalesState> emit,
  ) {
    _latest = event.animales;
    final filtered = _applyFilter(_latest, _searchQuery);
    emit(
      AnimalesLoaded(
        allAnimals: _latest,
        visibleAnimals: filtered,
        isSearching: _isSearching,
        searchQuery: _searchQuery,
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
      ),
    );
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

  EventTransformer<T> _debounce<T>(Duration duration) {
    return (events, mapper) => events.debounce(duration).switchMap(mapper);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
