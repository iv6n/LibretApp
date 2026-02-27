import 'package:equatable/equatable.dart';

abstract class DirectorioEvent extends Equatable {
  const DirectorioEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cambiar el tab activo
class ChangeDirectorioTab extends DirectorioEvent {
  const ChangeDirectorioTab(this.tabIndex);

  final int tabIndex;

  @override
  List<Object> get props => [tabIndex];
}

/// Evento para iniciar la búsqueda
class StartSearch extends DirectorioEvent {
  const StartSearch();
}

/// Evento para realizar búsqueda combinada
class PerformCombinedSearch extends DirectorioEvent {
  const PerformCombinedSearch(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

/// Evento para limpiar la búsqueda
class ClearSearch extends DirectorioEvent {
  const ClearSearch();
}

/// Evento para cargar todos los datos
class LoadDirectorioData extends DirectorioEvent {
  const LoadDirectorioData();
}
