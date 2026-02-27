import 'package:equatable/equatable.dart';

/// Modelo para representar un resultado de búsqueda combinada
class CombinedSearchResult extends Equatable {
  const CombinedSearchResult({
    required this.type,
    required this.id,
    required this.name,
    required this.data,
  });

  /// Tipo de entidad: 'animal', 'lote', 'ubicacion'
  final String type;

  /// ID único de la entidad
  final String id;

  /// Nombre de la entidad
  final String name;

  /// Datos adicionales de la entidad
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [type, id, name, data];
}

abstract class DirectorioState extends Equatable {
  const DirectorioState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class DirectorioInitial extends DirectorioState {
  const DirectorioInitial();
}

/// Estado cuando se están cargando los datos
class DirectorioLoading extends DirectorioState {
  const DirectorioLoading();
}

/// Estado cuando los datos se han cargado
class DirectorioLoaded extends DirectorioState {
  const DirectorioLoaded({
    required this.activeTabIndex,
    required this.isSearching,
    required this.searchResults,
    required this.searchQuery,
  });

  /// Índice del tab activo (0: animales, 1: lotes, 2: ubicaciones)
  final int activeTabIndex;

  /// Si está activa la búsqueda
  final bool isSearching;

  /// Resultados de la búsqueda combinada
  final List<CombinedSearchResult> searchResults;

  /// Query de búsqueda actual
  final String searchQuery;

  DirectorioLoaded copyWith({
    int? activeTabIndex,
    bool? isSearching,
    List<CombinedSearchResult>? searchResults,
    String? searchQuery,
  }) {
    return DirectorioLoaded(
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      isSearching: isSearching ?? this.isSearching,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    activeTabIndex,
    isSearching,
    searchResults,
    searchQuery,
  ];
}

/// Estado cuando ocurre un error
class DirectorioError extends DirectorioState {
  const DirectorioError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
