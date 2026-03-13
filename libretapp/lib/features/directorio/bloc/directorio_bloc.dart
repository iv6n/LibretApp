import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_state.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/bloc/directorio_event.dart';
import 'package:libretapp/features/directorio/bloc/directorio_state.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_state.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

class DirectorioBloc extends Bloc<DirectorioEvent, DirectorioState> {
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
  final AnimalesTabBloc animalesTabBloc;
  final LotesTabBloc lotesTabBloc;
  final UbicacionesTabBloc ubicacionesTabBloc;

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
    final seen = <String>{};
    final query = event.query.trim().toLowerCase();

    if (query.isEmpty) {
      emit(currentState.copyWith(searchResults: [], searchQuery: ''));
      return;
    }

    // Ordenamos según el tab activo
    final orders = _getSearchOrder(currentState.activeTabIndex);

    for (final order in orders) {
      if (order == CombinedSearchType.animal) {
        final animalesState = animalesTabBloc.state;
        if (animalesState is AnimalesTabLoaded) {
          for (final animal in animalesState.animales) {
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
        }
      } else if (order == CombinedSearchType.lote) {
        final lotesState = lotesTabBloc.state;
        if (lotesState is LotesTabLoaded) {
          for (final lote in lotesState.lotes) {
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
        }
      } else if (order == CombinedSearchType.ubicacion) {
        final ubicacionesState = ubicacionesTabBloc.state;
        if (ubicacionesState is UbicacionesTabLoaded) {
          for (final ubicacion in ubicacionesState.ubicaciones) {
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
  List<CombinedSearchType> _getSearchOrder(int tabIndex) {
    switch (tabIndex) {
      case 0: // Animales
        return [
          CombinedSearchType.animal,
          CombinedSearchType.lote,
          CombinedSearchType.ubicacion,
        ];
      case 1: // Lotes
        return [
          CombinedSearchType.lote,
          CombinedSearchType.animal,
          CombinedSearchType.ubicacion,
        ];
      case 2: // Ubicaciones
        return [
          CombinedSearchType.ubicacion,
          CombinedSearchType.animal,
          CombinedSearchType.lote,
        ];
      default:
        return [
          CombinedSearchType.animal,
          CombinedSearchType.lote,
          CombinedSearchType.ubicacion,
        ];
    }
  }

  bool _matchesQuery(Object item, String query) {
    final id = _getId(item).toLowerCase();
    if (id.contains(query)) return true;

    final name = _getName(item).toLowerCase();
    return name.contains(query);
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

    return _getUbicacionName(item);
  }

  String _getAnimalName(Object animal) {
    if (animal is AnimalEntity) {
      return animal.customName?.trim().isNotEmpty == true
          ? animal.customName!.trim()
          : animal.earTagNumber;
    }
    return '';
  }

  String _getLoteName(Object lote) {
    if (lote is LoteEntity) {
      return lote.nombre;
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
    if (item is LocationEntity) {
      return item.uuid;
    }
    return '';
  }

  @override
  Future<void> close() {
    animalesTabBloc.close();
    lotesTabBloc.close();
    ubicacionesTabBloc.close();
    return super.close();
  }
}
