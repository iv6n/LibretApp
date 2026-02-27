import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_state.dart';
import 'package:libretapp/features/directorio/bloc/directorio_event.dart';
import 'package:libretapp/features/directorio/bloc/directorio_state.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_state.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_state.dart';

class DirectorioBloc extends Bloc<DirectorioEvent, DirectorioState> {
  final AnimalesTabBloc animalesTabBloc;
  final LotesTabBloc lotesTabBloc;
  final UbicacionesTabBloc ubicacionesTabBloc;

  DirectorioBloc({
    required this.animalesTabBloc,
    required this.lotesTabBloc,
    required this.ubicacionesTabBloc,
  }) : super(const DirectorioInitial()) {
    on<LoadDirectorioData>(_onLoadDirectorioData);
    on<ChangeDirectorioTab>(_onChangeTab);
    on<StartSearch>(_onStartSearch);
    on<PerformCombinedSearch>(_onPerformCombinedSearch);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadDirectorioData(
    LoadDirectorioData event,
    Emitter<DirectorioState> emit,
  ) async {
    emit(const DirectorioLoading());
    try {
      // Cargamos todos los tabs
      animalesTabBloc.add(const LoadAnimalesTab());
      lotesTabBloc.add(const LoadLotesTab());
      ubicacionesTabBloc.add(const LoadUbicacionesTab());

      emit(
        const DirectorioLoaded(
          activeTabIndex: 0,
          isSearching: false,
          searchResults: [],
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

    emit(
      currentState.copyWith(
        activeTabIndex: event.tabIndex,
        isSearching: false,
        searchResults: [],
        searchQuery: '',
      ),
    );
  }

  void _onStartSearch(StartSearch event, Emitter<DirectorioState> emit) {
    final currentState = state;
    if (currentState is! DirectorioLoaded) return;

    emit(
      currentState.copyWith(
        isSearching: true,
        searchResults: [],
        searchQuery: '',
      ),
    );
  }

  void _onPerformCombinedSearch(
    PerformCombinedSearch event,
    Emitter<DirectorioState> emit,
  ) {
    final currentState = state;
    if (currentState is! DirectorioLoaded) return;

    final results = <CombinedSearchResult>[];
    final query = event.query.toLowerCase();

    if (query.isEmpty) {
      emit(currentState.copyWith(searchResults: [], searchQuery: ''));
      return;
    }

    // Ordenamos según el tab activo
    final orders = _getSearchOrder(currentState.activeTabIndex);

    for (final order in orders) {
      if (order == 'animales') {
        final animalesState = animalesTabBloc.state;
        if (animalesState is AnimalesTabLoaded) {
          for (final animal in animalesState.animales) {
            if (_matchesQuery(animal, query)) {
              results.add(
                CombinedSearchResult(
                  type: 'animal',
                  id: _getId(animal),
                  name: _getAnimalName(animal),
                  data: _toMap(animal),
                ),
              );
            }
          }
        }
      } else if (order == 'lotes') {
        final lotesState = lotesTabBloc.state;
        if (lotesState is LotesTabLoaded) {
          for (final lote in lotesState.lotes) {
            if (_matchesQuery(lote, query)) {
              results.add(
                CombinedSearchResult(
                  type: 'lote',
                  id: _getId(lote),
                  name: _getLoteName(lote),
                  data: _toMap(lote),
                ),
              );
            }
          }
        }
      } else if (order == 'ubicaciones') {
        final ubicacionesState = ubicacionesTabBloc.state;
        if (ubicacionesState is UbicacionesTabLoaded) {
          for (final ubicacion in ubicacionesState.ubicaciones) {
            if (_matchesQuery(ubicacion, query)) {
              results.add(
                CombinedSearchResult(
                  type: 'ubicacion',
                  id: _getId(ubicacion),
                  name: _getUbicacionName(ubicacion),
                  data: _toMap(ubicacion),
                ),
              );
            }
          }
        }
      }
    }

    emit(currentState.copyWith(searchResults: results, searchQuery: query));
  }

  void _onClearSearch(ClearSearch event, Emitter<DirectorioState> emit) {
    final currentState = state;
    if (currentState is! DirectorioLoaded) return;

    emit(
      currentState.copyWith(
        isSearching: false,
        searchResults: [],
        searchQuery: '',
      ),
    );
  }

  /// Devuelve el orden de búsqueda según el tab activo
  List<String> _getSearchOrder(int tabIndex) {
    switch (tabIndex) {
      case 0: // Animales
        return ['animales', 'lotes', 'ubicaciones'];
      case 1: // Lotes
        return ['lotes', 'animales', 'ubicaciones'];
      case 2: // Ubicaciones
        return ['ubicaciones', 'animales', 'lotes'];
      default:
        return ['animales', 'lotes', 'ubicaciones'];
    }
  }

  bool _matchesQuery(dynamic item, String query) {
    final name = _getName(item).toLowerCase();
    return name.contains(query);
  }

  String _getName(dynamic item) {
    final animal = _getAnimalName(item);
    if (animal.isNotEmpty) return animal;

    final lote = _getLoteName(item);
    if (lote.isNotEmpty) return lote;

    return _getUbicacionName(item);
  }

  String _getAnimalName(dynamic animal) {
    if (animal is Map && animal.containsKey('nombre')) {
      return animal['nombre'] as String? ?? '';
    }
    return '';
  }

  String _getLoteName(dynamic lote) {
    if (lote is Map && lote.containsKey('nombre')) {
      return lote['nombre'] as String? ?? '';
    }
    return '';
  }

  String _getUbicacionName(dynamic ubicacion) {
    if (ubicacion is Map && ubicacion.containsKey('nombre')) {
      return ubicacion['nombre'] as String? ?? '';
    }
    return '';
  }

  String _getId(dynamic item) {
    if (item is Map && item.containsKey('uuid')) {
      return item['uuid'] as String? ?? '';
    }
    if (item is Map && item.containsKey('id')) {
      return item['id'] as String? ?? '';
    }
    return '';
  }

  Map<String, dynamic> _toMap(dynamic item) {
    if (item is Map) {
      return Map<String, dynamic>.from(item);
    }
    return {};
  }

  @override
  Future<void> close() {
    animalesTabBloc.close();
    lotesTabBloc.close();
    ubicacionesTabBloc.close();
    return super.close();
  }
}
