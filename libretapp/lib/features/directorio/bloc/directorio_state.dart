/// features \u203a directorio \u203a bloc \u203a directorio_state \u2014 state for DirectorioBloc.
library;

import 'package:equatable/equatable.dart';

enum CombinedSearchType { animal, lote, ubicacion }

enum DirectorioSection { animales, lotes, ubicaciones }

const defaultDirectorioSectionOrder = <DirectorioSection>[
  DirectorioSection.animales,
  DirectorioSection.ubicaciones,
  DirectorioSection.lotes,
];

const defaultDirectorioVisibleSections = <DirectorioSection>{
  DirectorioSection.animales,
  DirectorioSection.ubicaciones,
};

extension DirectorioSectionX on DirectorioSection {
  CombinedSearchType get searchType {
    switch (this) {
      case DirectorioSection.animales:
        return CombinedSearchType.animal;
      case DirectorioSection.lotes:
        return CombinedSearchType.lote;
      case DirectorioSection.ubicaciones:
        return CombinedSearchType.ubicacion;
    }
  }

  static DirectorioSection fromSearchType(CombinedSearchType type) {
    switch (type) {
      case CombinedSearchType.animal:
        return DirectorioSection.animales;
      case CombinedSearchType.lote:
        return DirectorioSection.lotes;
      case CombinedSearchType.ubicacion:
        return DirectorioSection.ubicaciones;
    }
  }
}

extension CombinedSearchTypeX on CombinedSearchType {
  String get label {
    switch (this) {
      case CombinedSearchType.animal:
        return 'animal';
      case CombinedSearchType.lote:
        return 'lote';
      case CombinedSearchType.ubicacion:
        return 'ubicacion';
    }
  }
}

/// Modelo para representar un resultado de búsqueda combinada
class CombinedSearchResult extends Equatable {
  const CombinedSearchResult({
    required this.type,
    required this.id,
    required this.name,
  });

  /// Tipo de entidad resultante de búsqueda combinada.
  final CombinedSearchType type;

  /// ID único de la entidad
  final String id;

  /// Nombre de la entidad
  final String name;

  @override
  List<Object?> get props => [type, id, name];
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
    required this.activeSection,
    this.orderedSections = defaultDirectorioSectionOrder,
    this.visibleSections = defaultDirectorioVisibleSections,
    required this.isSearching,
    required this.searchResults,
    required this.searchQuery,
  });

  /// Active directory section.
  final DirectorioSection activeSection;

  /// Directory sections in the user-configured tab order.
  final List<DirectorioSection> orderedSections;

  /// Directory sections currently visible in the tab bar and search scope.
  final Set<DirectorioSection> visibleSections;

  /// Visible sections in the user-configured order.
  List<DirectorioSection> get activeSections => orderedSections
      .where(visibleSections.contains)
      .toList(growable: false);

  /// Legacy index used by older callers and tests.
  int get activeTabIndex {
    final index = activeSections.indexOf(activeSection);
    return index < 0 ? 0 : index;
  }

  /// Si está activa la búsqueda
  final bool isSearching;

  /// Resultados de la búsqueda combinada
  final List<CombinedSearchResult> searchResults;

  /// Query de búsqueda actual
  final String searchQuery;

  DirectorioLoaded copyWith({
    DirectorioSection? activeSection,
    List<DirectorioSection>? orderedSections,
    Set<DirectorioSection>? visibleSections,
    bool? isSearching,
    List<CombinedSearchResult>? searchResults,
    String? searchQuery,
  }) {
    return DirectorioLoaded(
      activeSection: activeSection ?? this.activeSection,
      orderedSections: orderedSections ?? this.orderedSections,
      visibleSections: visibleSections ?? this.visibleSections,
      isSearching: isSearching ?? this.isSearching,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    activeSection,
    orderedSections,
    visibleSections,
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
