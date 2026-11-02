/// features \u203a directorio \u203a bloc \u203a directorio_bloc \u2014 top-level BLoC for the directorio feature.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:libretapp/core/constants/ui_constants.dart';
import 'package:libretapp/core/performance/performance_monitor.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_state.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/bloc/directorio_event.dart';
import 'package:libretapp/features/directorio/bloc/directorio_state.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_state.dart';
import 'package:libretapp/features/directorio/data/directorio_config_repository.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class DirectorioBloc extends Bloc<DirectorioEvent, DirectorioState> {
  DirectorioBloc({
    this.animalesTabBloc,
    this.lotesTabBloc,
    this.ubicacionesTabBloc,
    AnimalRepository? animalRepository,
    LotesRepository? lotesRepository,
    LocationRepository? locationRepository,
    this.cultivationRepository,
    DirectorioConfigRepository? configRepository,
  }) : _animalRepository = animalRepository ?? animalesTabBloc?.repository,
       _lotesRepository = lotesRepository ?? lotesTabBloc?.repository,
       _locationRepository =
           locationRepository ?? ubicacionesTabBloc?.repository,
       _configRepository = configRepository,
       super(const DirectorioInitial()) {
    on<LoadDirectorioData>(_onLoadDirectorioData);
    on<ChangeDirectorioTab>(_onChangeTab);
    on<ChangeDirectorioSection>(_onChangeSection);
    on<SetDirectorioVisibleSections>(_onSetVisibleSections);
    on<SetDirectorioSectionConfig>(_onSetSectionConfig);
    on<SetAnimalDirectoryViewMode>(
      _onSetAnimalViewMode,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
    on<StartSearch>(_onStartSearch);
    on<PerformCombinedSearch>(
      _onPerformCombinedSearch,
      transformer: _debounceSearch(UiConstants.searchDebounceDuration),
    );
    on<ClearSearch>(_onClearSearch);
    on<ClearSearchQuery>(_onClearSearchQuery);
  }
  final AnimalesTabBloc? animalesTabBloc;
  final LotesTabBloc? lotesTabBloc;
  final UbicacionesTabBloc? ubicacionesTabBloc;
  final AnimalRepository? _animalRepository;
  final LotesRepository? _lotesRepository;
  final LocationRepository? _locationRepository;
  final CultivationRepository? cultivationRepository;
  final DirectorioConfigRepository? _configRepository;
  int _searchGeneration = 0;

  Future<void> _onLoadDirectorioData(
    LoadDirectorioData event,
    Emitter<DirectorioState> emit,
  ) async {
    emit(const DirectorioLoading());
    try {
      final preferenceSpan = PerformanceMonitor().startSpan(
        'directorio.open.preferences',
      );
      final preferences = await Future.wait<Object>([
        _configRepository?.load() ??
            Future<DirectorioSectionConfig>.value(
              defaultDirectorioSectionConfig,
            ),
        _configRepository?.loadAnimalViewMode() ??
            Future<AnimalDirectoryViewMode>.value(
              AnimalDirectoryViewMode.cards,
            ),
      ]);
      preferenceSpan.stop();
      final config = preferences[0] as DirectorioSectionConfig;
      final animalViewMode = preferences[1] as AnimalDirectoryViewMode;
      final activeSection = _firstVisibleSection(config);

      emit(
        DirectorioLoaded(
          activeSection: activeSection,
          orderedSections: config.orderedSections,
          visibleSections: config.visibleSections,
          animalViewMode: animalViewMode,
          isSearching: false,
          searchResults: const [],
          searchQuery: '',
        ),
      );
    } catch (e) {
      emit(DirectorioError('Error al cargar datos: $e'));
    }
  }

  void _onChangeTab(ChangeDirectorioTab event, Emitter<DirectorioState> emit) {
    final currentState = state;
    if (currentState is! DirectorioLoaded) return;

    final activeSections = currentState.activeSections;
    if (activeSections.isEmpty) return;
    final sectionIndex = event.tabIndex.clamp(0, activeSections.length - 1);
    _emitSectionChange(activeSections[sectionIndex], emit);
  }

  Future<void> _onSetAnimalViewMode(
    SetAnimalDirectoryViewMode event,
    Emitter<DirectorioState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DirectorioLoaded ||
        currentState.animalViewMode == event.mode) {
      return;
    }

    await _configRepository?.saveAnimalViewMode(event.mode);
    final latestState = state;
    if (latestState is! DirectorioLoaded) return;
    emit(latestState.copyWith(animalViewMode: event.mode));
  }

  void _onChangeSection(
    ChangeDirectorioSection event,
    Emitter<DirectorioState> emit,
  ) {
    _emitSectionChange(event.section, emit);
  }

  void _emitSectionChange(
    DirectorioSection section,
    Emitter<DirectorioState> emit,
  ) {
    final currentState = state;
    if (currentState is! DirectorioLoaded) return;
    if (!currentState.visibleSections.contains(section)) return;

    _searchGeneration++;
    emit(
      currentState.copyWith(
        activeSection: section,
        isSearching: false,
        searchResults: [],
        searchQuery: '',
        isSearchLoading: false,
        searchFailedSources: const [],
      ),
    );
  }

  Future<void> _onSetVisibleSections(
    SetDirectorioVisibleSections event,
    Emitter<DirectorioState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DirectorioLoaded || event.visibleSections.isEmpty) {
      return;
    }

    await _setSectionConfig(
      orderedSections: currentState.orderedSections,
      visibleSections: event.visibleSections,
      preferredActiveSection: event.activeSection,
      currentState: currentState,
      emit: emit,
    );
  }

  Future<void> _onSetSectionConfig(
    SetDirectorioSectionConfig event,
    Emitter<DirectorioState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DirectorioLoaded || event.visibleSections.isEmpty) {
      return;
    }

    await _setSectionConfig(
      orderedSections: event.orderedSections,
      visibleSections: event.visibleSections,
      preferredActiveSection: event.activeSection,
      currentState: currentState,
      emit: emit,
    );
  }

  Future<void> _setSectionConfig({
    required List<DirectorioSection> orderedSections,
    required Set<DirectorioSection> visibleSections,
    required DirectorioSection preferredActiveSection,
    required DirectorioLoaded currentState,
    required Emitter<DirectorioState> emit,
  }) async {
    final config = DirectorioSectionConfig(
      orderedSections: orderedSections,
      visibleSections: visibleSections,
    ).normalized();
    final active = config.visibleSections.contains(preferredActiveSection)
        ? preferredActiveSection
        : _firstVisibleSection(config);

    await _configRepository?.save(config);

    _searchGeneration++;
    emit(
      currentState.copyWith(
        activeSection: active,
        orderedSections: config.orderedSections,
        visibleSections: config.visibleSections,
        isSearching: false,
        searchResults: [],
        searchQuery: '',
        isSearchLoading: false,
        searchFailedSources: const [],
      ),
    );
  }

  void _onStartSearch(StartSearch event, Emitter<DirectorioState> emit) {
    final currentState = state;
    if (currentState is! DirectorioLoaded) return;

    _searchGeneration++;
    emit(
      currentState.copyWith(
        isSearching: true,
        searchResults: [],
        searchQuery: '',
        isSearchLoading: false,
        searchFailedSources: const [],
      ),
    );
  }

  Future<void> _onPerformCombinedSearch(
    PerformCombinedSearch event,
    Emitter<DirectorioState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DirectorioLoaded) return;

    final query = event.query.trim().toLowerCase();

    if (query.isEmpty) {
      _searchGeneration++;
      emit(
        currentState.copyWith(
          searchResults: [],
          searchQuery: '',
          isSearchLoading: false,
          searchFailedSources: const [],
        ),
      );
      return;
    }

    final searchGeneration = event.requestGeneration;
    if (searchGeneration == null || searchGeneration != _searchGeneration) {
      return;
    }

    emit(
      currentState.copyWith(
        searchResults: const [],
        searchQuery: query,
        isSearchLoading: true,
        searchFailedSources: const [],
      ),
    );

    // Ordenamos según el tab activo
    final orders = _getSearchOrder(
      currentState.activeSection,
      currentState.orderedSections,
    );

    final animalTabState = animalesTabBloc?.state;
    final lotesTabState = lotesTabBloc?.state;
    final locationsTabState = ubicacionesTabBloc?.state;
    final fallbackAnimals = animalTabState is AnimalesTabLoaded
        ? animalTabState.animales
        : null;
    final fallbackLotes = lotesTabState is LotesTabLoaded
        ? lotesTabState.lotes
        : null;
    final fallbackLocations = locationsTabState is UbicacionesTabLoaded
        ? locationsTabState.ubicaciones
        : null;

    final loads = await Future.wait<Object>([
      _loadList<AnimalEntity>(
        _animalRepository?.getAll,
        fallbackItems: fallbackAnimals,
      ),
      _loadList<LoteEntity>(
        _lotesRepository?.getAll,
        fallbackItems: fallbackLotes,
      ),
      _loadList<CultivationEntity>(cultivationRepository?.getAll),
      _loadList<LocationEntity>(
        _locationRepository?.getAll,
        fallbackItems: fallbackLocations,
      ),
    ]);
    final animalLoad = loads[0] as _LoadedSearchItems<AnimalEntity>;
    final loteLoad = loads[1] as _LoadedSearchItems<LoteEntity>;
    final cultivationLoad = loads[2] as _LoadedSearchItems<CultivationEntity>;
    final locationLoad = loads[3] as _LoadedSearchItems<LocationEntity>;
    final animals = animalLoad.items;
    final lotes = loteLoad.items;
    final cultivations = cultivationLoad.items;
    final ubicaciones = locationLoad.items;

    if (isClosed || searchGeneration != _searchGeneration) return;

    final latestState = state;
    if (latestState is! DirectorioLoaded) return;
    final results = <CombinedSearchResult>[];
    final seen = <String>{};

    for (final order in orders) {
      if (order == CombinedSearchType.animal) {
        for (final animal in animals) {
          if (_matchesQuery(animal, query)) {
            _addResultIfNew(
              seen,
              results,
              CombinedSearchResult(
                type: CombinedSearchType.animal,
                id: _getId(animal),
                name: _getAnimalName(animal),
              ),
            );
          }
        }
      } else if (order == CombinedSearchType.lote) {
        for (final lote in lotes) {
          if (_matchesQuery(lote, query)) {
            _addResultIfNew(
              seen,
              results,
              CombinedSearchResult(
                type: CombinedSearchType.lote,
                id: _getId(lote),
                name: _getLoteName(lote),
              ),
            );
          }
        }
      } else if (order == CombinedSearchType.cultivo) {
        for (final cultivation in cultivations) {
          if (_matchesQuery(cultivation, query)) {
            _addResultIfNew(
              seen,
              results,
              CombinedSearchResult(
                type: CombinedSearchType.cultivo,
                id: cultivation.uuid,
                name: cultivation.name,
              ),
            );
          }
        }
      } else if (order == CombinedSearchType.ubicacion) {
        for (final ubicacion in ubicaciones) {
          if (_matchesQuery(ubicacion, query)) {
            _addResultIfNew(
              seen,
              results,
              CombinedSearchResult(
                type: CombinedSearchType.ubicacion,
                id: _getId(ubicacion),
                name: _getUbicacionName(ubicacion),
              ),
            );
          }
        }
      }
    }

    final failedSources = <CombinedSearchType>[
      if (animalLoad.failed) CombinedSearchType.animal,
      if (loteLoad.failed) CombinedSearchType.lote,
      if (cultivationLoad.failed) CombinedSearchType.cultivo,
      if (locationLoad.failed) CombinedSearchType.ubicacion,
    ];
    emit(
      latestState.copyWith(
        searchResults: results,
        searchQuery: query,
        isSearchLoading: false,
        searchFailedSources: failedSources,
      ),
    );
  }

  void _onClearSearch(ClearSearch event, Emitter<DirectorioState> emit) {
    final currentState = state;
    if (currentState is! DirectorioLoaded) return;

    _searchGeneration++;
    emit(
      currentState.copyWith(
        isSearching: false,
        searchResults: [],
        searchQuery: '',
        isSearchLoading: false,
        searchFailedSources: const [],
      ),
    );
  }

  void _onClearSearchQuery(
    ClearSearchQuery event,
    Emitter<DirectorioState> emit,
  ) {
    final currentState = state;
    if (currentState is! DirectorioLoaded) return;
    _searchGeneration++;
    emit(
      currentState.copyWith(
        searchResults: const [],
        searchQuery: '',
        isSearchLoading: false,
        searchFailedSources: const [],
      ),
    );
  }

  /// Devuelve el orden de búsqueda según el tab activo
  List<CombinedSearchType> _getSearchOrder(
    DirectorioSection activeSection,
    List<DirectorioSection> orderedSections,
  ) {
    final config = DirectorioSectionConfig(
      orderedSections: orderedSections,
      visibleSections: defaultDirectorioVisibleSections,
    ).normalized();
    final searchSections = <DirectorioSection>[
      activeSection,
      ...config.orderedSections.where((section) => section != activeSection),
    ];
    return searchSections
        .map((section) => section.searchType)
        .toList(growable: false);
  }

  DirectorioSection _firstVisibleSection(DirectorioSectionConfig config) {
    final normalized = config.normalized();
    return normalized.orderedSections.firstWhere(
      normalized.visibleSections.contains,
      orElse: () => DirectorioSection.animales,
    );
  }

  /// Checks if an ear tag matches the search query.
  /// Supports:
  /// - Full ear tag number matching
  /// - Last 4 digits matching (e.g., "6849" matches "002658976849")
  /// - Leading zero stripping (e.g., "2658976849" matches "002658976849")
  bool _matchesEarTagQuery(String earTag, String normalized) {
    final tagLower = earTag.toLowerCase();

    // Direct substring match
    if (tagLower.contains(normalized)) return true;

    // Last 4 digits match
    if (normalized.length <= 4 && tagLower.endsWith(normalized)) return true;

    // Strip leading zeros and check
    final stripped = earTag.replaceFirst(RegExp(r'^0+'), '');
    final strippedLower = stripped.toLowerCase();
    if (strippedLower.contains(normalized)) return true;
    if (normalized.length <= 4 && strippedLower.endsWith(normalized)) {
      return true;
    }

    return false;
  }

  bool _matchesQuery(Object item, String query) {
    final normalized = query.trim().toLowerCase();

    final id = _getId(item).toLowerCase();
    if (id.contains(normalized)) return true;

    // For animals, use special ear tag matching logic
    final name = _getName(item);
    if (item is AnimalEntity && item.earTagNumber == name) {
      return _matchesEarTagQuery(name, normalized);
    }

    final nameLower = name.toLowerCase();
    if (nameLower.contains(normalized)) return true;
    if (item is AnimalEntity) {
      return animalSearchPresentationText(
        item,
      ).toLowerCase().contains(normalized);
    }
    return false;
  }

  void _addResultIfNew(
    Set<String> seen,
    List<CombinedSearchResult> results,
    CombinedSearchResult candidate,
  ) {
    final key = '${candidate.type.name}:${candidate.id}';
    if (!seen.add(key)) return;
    results.add(candidate);
  }

  String _getName(Object item) {
    final animal = _getAnimalName(item);
    if (animal.isNotEmpty) return animal;

    final lote = _getLoteName(item);
    if (lote.isNotEmpty) return lote;

    if (item is CultivationEntity) return item.name;

    return _getUbicacionName(item);
  }

  String _getAnimalName(Object animal) {
    if (animal is AnimalEntity) {
      return primaryAnimalLabel(animal);
    }
    return '';
  }

  String _getLoteName(Object lote) {
    if (lote is LoteEntity) {
      return lote.name;
    }
    return '';
  }

  String _getUbicacionName(Object ubicacion) {
    if (ubicacion is LocationEntity) {
      return ubicacion.name;
    }
    return '';
  }

  String _getId(Object item) {
    if (item is AnimalEntity) {
      return item.uuid;
    }
    if (item is LoteEntity) {
      return item.uuid;
    }
    if (item is CultivationEntity) {
      return item.uuid;
    }
    if (item is LocationEntity) {
      return item.uuid;
    }
    return '';
  }

  @override
  Future<void> close() async {
    await Future.wait([
      if (animalesTabBloc != null) animalesTabBloc!.close(),
      if (lotesTabBloc != null) lotesTabBloc!.close(),
      if (ubicacionesTabBloc != null) ubicacionesTabBloc!.close(),
    ]);
    await super.close();
  }

  Future<_LoadedSearchItems<T>> _loadList<T>(
    Future<List<T>> Function()? load, {
    List<T>? fallbackItems,
  }) async {
    if (load == null) {
      return _LoadedSearchItems<T>(fallbackItems ?? const [], failed: false);
    }
    try {
      return _LoadedSearchItems<T>(await load(), failed: false);
    } catch (_) {
      return _LoadedSearchItems<T>(fallbackItems ?? const [], failed: true);
    }
  }

  EventTransformer<PerformCombinedSearch> _debounceSearch(Duration duration) =>
      (events, mapper) => events
          .map((event) => event.forGeneration(++_searchGeneration))
          .debounce(duration)
          .switchMap(mapper);
}

class _LoadedSearchItems<T> {
  const _LoadedSearchItems(this.items, {required this.failed});

  final List<T> items;
  final bool failed;
}
