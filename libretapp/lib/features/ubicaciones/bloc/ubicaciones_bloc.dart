/// features \u203a ubicaciones \u203a bloc \u203a ubicaciones_bloc \u2014 BLoC for the ubicaciones (farm locations) feature.
library;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_category.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/view/ubicaciones_tree_builder.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_labels.dart';
import 'package:libretapp/core/constants/ui_constants.dart';
import 'package:stream_transform/stream_transform.dart';

class UbicacionesBloc extends Bloc<UbicacionesEvent, UbicacionesState> {
  UbicacionesBloc(this.repository, {AnimalRepository? animalRepository})
    : _animalRepository = animalRepository,
      super(const UbicacionesInitial()) {
    on<LoadUbicaciones>(_onLoadUbicaciones);
    on<UbicacionesStreamUpdated>(_onStreamUpdated);
    on<UbicacionesStreamFailed>(_onStreamFailed);
    on<UpsertUbicacion>(_onUpsertUbicacion);
    on<DeleteUbicacion>(_onDeleteUbicacion);
    on<ToggleSearch>(_onToggleSearch);
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: _debounce(UiConstants.searchDebounceDuration),
    );
    on<ClearSearch>(_onClearSearch);
    // Compatibility with older calls using SearchUbicaciones.
    on<SearchUbicaciones>(
      _onSearchUbicaciones,
      transformer: _debounce(UiConstants.searchDebounceDuration),
    );
    on<AddVisitRecordEvent>(_onAddVisit);
    on<AddWaterRecordEvent>(_onAddWater);
    on<AddSaltRecordEvent>(_onAddSalt);
    on<AddShadeRecordEvent>(_onAddShade);
    on<AddPastureRecordEvent>(_onAddPasture);
    on<AddSeedingRecordEvent>(_onAddSeeding);
    on<AddIrrigationRecordEvent>(_onAddIrrigation);
    on<AddRainRecordEvent>(_onAddRain);
    on<AddCostRecordEvent>(_onAddCost);
    on<AddCropEvent>(_onAddCrop);
    on<UpdateCropEvent>(_onUpdateCrop);
    on<DeleteCropEvent>(_onDeleteCrop);
    on<AddHarvestRecordEvent>(_onAddHarvest);
    on<AddCropWateringEvent>(_onAddCropWatering);
    on<AddCropHealthEvent>(_onAddCropHealth);
    on<AddCropTaskEvent>(_onAddCropTask);
    on<CompleteCropTaskEvent>(_onCompleteCropTask);
    on<AddInventoryItemEvent>(_onAddInventoryItem);
    on<UpdateInventoryItemEvent>(_onUpdateInventoryItem);
    on<RemoveInventoryItemEvent>(_onRemoveInventoryItem);
    on<SelectParentFilter>(_onSelectParentFilter);
    on<ToggleCategoryFilter>(_onToggleCategoryFilter);
    on<ClearCategoryFilters>(_onClearCategoryFilters);
    on<ClearAllFilters>(_onClearAllFilters);
  }

  final LocationRepository repository;
  final AnimalRepository? _animalRepository;
  StreamSubscription<List<LocationEntity>>? _subscription;
  List<LocationEntity> _latest = const [];
  String _searchQuery = '';
  bool _isSearching = false;
  String? _selectedRanchoUuid;
  final Set<LocationCategory> _selectedCategoryFilters = <LocationCategory>{};
  Map<String, int> _animalCounts = const {};
  Map<String, int> _subtreeAnimalCounts = const {};
  Map<String, double> _averageWeights = const {};
  String _lastCountsKey = '';

  Future<void> _onLoadUbicaciones(
    LoadUbicaciones event,
    Emitter<UbicacionesState> emit,
  ) async {
    emit(const UbicacionesLoading());
    try {
      await _subscription?.cancel();
      var receivedFirstStreamEmission = false;
      _subscription = repository.watchAll().listen(
        (ubicaciones) {
          receivedFirstStreamEmission = true;
          add(UbicacionesStreamUpdated(ubicaciones));
        },
        onError: (error, _) {
          if (!isClosed) {
            add(UbicacionesStreamFailed(error.toString()));
          }
        },
      );

      final bootstrapData = await repository.getAll().timeout(
        const Duration(seconds: 3),
        onTimeout: () => _latest,
      );
      if (!receivedFirstStreamEmission && !emit.isDone && !isClosed) {
        _latest = bootstrapData;
        _emitLoaded(emit);
        unawaited(_refreshAnimalCounts(emit));
      }
    } catch (e) {
      if (emit.isDone || isClosed) return;
      emit(UbicacionesError('Error al cargar ubicaciones: $e'));
    }
  }

  void _onStreamUpdated(
    UbicacionesStreamUpdated event,
    Emitter<UbicacionesState> emit,
  ) {
    _latest = event.ubicaciones;
    _emitLoaded(emit);
    unawaited(_refreshAnimalCounts(emit));
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
      final location = event.ubicacion;
      if (location.parentUuid != null) {
        if (location.parentUuid == location.uuid) {
          emit(
            const UbicacionesError(
              'Una ubicacion no puede asignarse como su propio padre',
            ),
          );
          return;
        }
        final parentUuid = location.parentUuid!;
        final parentExists = _latest.any((l) => l.uuid == parentUuid);
        if (!parentExists) {
          emit(
            const UbicacionesError(
              'La ubicacion padre seleccionada no existe o fue eliminada',
            ),
          );
          return;
        }
        final parent = _latest.firstWhere((l) => l.uuid == parentUuid);
        if (!parent.canAcceptSubLocationType(location.type)) {
          emit(
            UbicacionesError(
              '${locationTypeLabelEs(location.type)} no puede estar dentro de ${locationTypeLabelEs(parent.type)}',
            ),
          );
          return;
        }
      }
      emit(const UbicacionesLoading());
      await repository.upsert(location);
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
    _emitLoaded(emit);
  }

  void _onToggleSearch(ToggleSearch event, Emitter<UbicacionesState> emit) {
    _isSearching = event.enabled;
    if (!_isSearching) {
      _searchQuery = '';
    }
    _emitLoaded(emit);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<UbicacionesState> emit,
  ) async {
    _searchQuery = event.query.trim();
    _isSearching = true;
    _emitLoaded(emit);
  }

  void _onClearSearch(ClearSearch event, Emitter<UbicacionesState> emit) {
    _searchQuery = '';
    _isSearching = false;
    _emitLoaded(emit);
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

  Future<void> _onAddSalt(
    AddSaltRecordEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addSalt(event.uuid, event.record),
      emit,
    );
  }

  Future<void> _onAddShade(
    AddShadeRecordEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addShade(event.uuid, event.record),
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

  Future<void> _onAddCrop(
    AddCropEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addCrop(event.locationUuid, event.crop),
      emit,
    );
  }

  Future<void> _onUpdateCrop(
    UpdateCropEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.updateCrop(event.locationUuid, event.crop),
      emit,
    );
  }

  Future<void> _onDeleteCrop(
    DeleteCropEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.deleteCrop(event.locationUuid, event.cropUuid),
      emit,
    );
  }

  Future<void> _onAddHarvest(
    AddHarvestRecordEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addHarvest(
        event.locationUuid,
        event.cropUuid,
        event.record,
      ),
      emit,
    );
  }

  Future<void> _onAddCropWatering(
    AddCropWateringEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addCropWatering(
        event.locationUuid,
        event.cropUuid,
        event.record,
      ),
      emit,
    );
  }

  Future<void> _onAddCropHealth(
    AddCropHealthEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addCropHealth(
        event.locationUuid,
        event.cropUuid,
        event.record,
      ),
      emit,
    );
  }

  Future<void> _onAddCropTask(
    AddCropTaskEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addCropTask(
        event.locationUuid,
        event.cropUuid,
        event.task,
      ),
      emit,
    );
  }

  Future<void> _onCompleteCropTask(
    CompleteCropTaskEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.completeCropTask(
        event.locationUuid,
        event.cropUuid,
        event.taskUuid,
      ),
      emit,
    );
  }

  // ── Inventory handlers ────────────────────────────────────────────────

  Future<void> _onAddInventoryItem(
    AddInventoryItemEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addInventoryItem(event.locationUuid, event.item),
      emit,
    );
  }

  Future<void> _onUpdateInventoryItem(
    UpdateInventoryItemEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.updateInventoryItem(event.locationUuid, event.item),
      emit,
    );
  }

  Future<void> _onRemoveInventoryItem(
    RemoveInventoryItemEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.removeInventoryItem(event.locationUuid, event.itemUuid),
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

  List<LocationEntity> _computeVisible(List<LocationEntity> source) {
    var result = _applyParentScope(source);
    result = _applyFilter(result, _searchQuery);
    if (_selectedCategoryFilters.isNotEmpty) {
      result = result
          .where(
            (location) =>
                _selectedCategoryFilters.contains(location.effectiveCategory),
          )
          .toList(growable: false);
    }
    return result;
  }

  List<LocationEntity> _applyParentScope(List<LocationEntity> source) {
    final selectedUuid = _selectedRanchoUuid;
    if (selectedUuid == null) return source;

    final childrenByParent = <String?, List<LocationEntity>>{};
    for (final location in source) {
      childrenByParent
          .putIfAbsent(location.parentUuid, () => <LocationEntity>[])
          .add(location);
    }

    final allowed = <String>{selectedUuid};
    final queue = <String>[selectedUuid];

    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      final children = childrenByParent[current] ?? const <LocationEntity>[];
      for (final child in children) {
        if (allowed.add(child.uuid)) {
          queue.add(child.uuid);
        }
      }
    }

    return source
        .where((location) => allowed.contains(location.uuid))
        .toList(growable: false);
  }

  void _onSelectParentFilter(
    SelectParentFilter event,
    Emitter<UbicacionesState> emit,
  ) {
    _selectedRanchoUuid = event.ranchoUuid;
    _emitLoaded(emit);
  }

  void _onToggleCategoryFilter(
    ToggleCategoryFilter event,
    Emitter<UbicacionesState> emit,
  ) {
    if (event.selected) {
      _selectedCategoryFilters.add(event.category);
    } else {
      _selectedCategoryFilters.remove(event.category);
    }
    _emitLoaded(emit);
  }

  void _onClearCategoryFilters(
    ClearCategoryFilters event,
    Emitter<UbicacionesState> emit,
  ) {
    if (_selectedCategoryFilters.isEmpty) return;
    _selectedCategoryFilters.clear();
    _emitLoaded(emit);
  }

  void _onClearAllFilters(
    ClearAllFilters event,
    Emitter<UbicacionesState> emit,
  ) {
    var changed = false;
    if (_selectedRanchoUuid != null) {
      _selectedRanchoUuid = null;
      changed = true;
    }
    if (_selectedCategoryFilters.isNotEmpty) {
      _selectedCategoryFilters.clear();
      changed = true;
    }
    if (!changed) return;
    _emitLoaded(emit);
  }

  Future<void> _refreshAnimalCounts(Emitter<UbicacionesState> emit) async {
    final repository = _animalRepository;
    if (repository == null || emit.isDone || isClosed) return;

    final key = _latest.map((e) => e.uuid).join('|');
    if (key == _lastCountsKey && _animalCounts.isNotEmpty) return;
    _lastCountsKey = key;

    try {
      final ids = _latest.map((e) => e.uuid).toSet();
      final animals = await repository.getAll();
      final counts = <String, int>{};
      final weightTotals = <String, double>{};
      final weightSamples = <String, int>{};

      for (final animal in animals) {
        final locId = animal.currentLocationId ?? animal.initialLocationId;
        if (locId == null || !ids.contains(locId)) continue;
        counts[locId] = (counts[locId] ?? 0) + 1;

        final weight = animal.weight;
        if (weight == null) continue;
        weightTotals[locId] = (weightTotals[locId] ?? 0) + weight;
        weightSamples[locId] = (weightSamples[locId] ?? 0) + 1;
      }

      final avgWeights = <String, double>{};
      for (final entry in weightTotals.entries) {
        final samples = weightSamples[entry.key] ?? 0;
        if (samples <= 0) continue;
        avgWeights[entry.key] = entry.value / samples;
      }

      _animalCounts = counts;
      _averageWeights = avgWeights;
      final subtreeCounts = UbicacionesTreeBuilder.computeSubtreeAnimalCounts(
        locations: _latest,
        directCounts: counts,
      );
      _subtreeAnimalCounts = subtreeCounts;
      if (!emit.isDone && !isClosed) {
        _emitLoaded(emit);
      }
    } catch (_) {
      // Counts are optional; list still works without them.
    }
  }

  UbicacionesTreeSnapshot _buildTreeSnapshot(List<LocationEntity> visible) {
    final allByUuid = {for (final location in _latest) location.uuid: location};
    final childrenByParent = UbicacionesTreeBuilder.childrenByParent(_latest);
    final visibleIds = visible.map((location) => location.uuid).toSet();
    final roots = UbicacionesTreeBuilder.buildRoots(
      allLocations: _latest,
      allByUuid: allByUuid,
      childrenByParent: childrenByParent,
      visibleIds: visibleIds,
    );
    return UbicacionesTreeSnapshot(
      allByUuid: allByUuid,
      childrenByParent: childrenByParent,
      visibleIds: visibleIds,
      roots: roots,
    );
  }

  void _emitLoaded(Emitter<UbicacionesState> emit) {
    if (emit.isDone || isClosed) return;
    final visible = _computeVisible(_latest);
    emit(
      UbicacionesLoaded(
        allUbicaciones: _latest,
        visibleUbicaciones: visible,
        isSearching: _isSearching,
        searchQuery: _searchQuery,
        selectedRanchoUuid: _selectedRanchoUuid,
        selectedCategoryFilters: {..._selectedCategoryFilters},
        animalCounts: Map<String, int>.from(_animalCounts),
        subtreeAnimalCounts: Map<String, int>.from(_subtreeAnimalCounts),
        averageWeights: Map<String, double>.from(_averageWeights),
        treeSnapshot: _buildTreeSnapshot(visible),
      ),
    );
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
