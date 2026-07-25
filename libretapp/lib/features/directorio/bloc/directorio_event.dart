/// features \u203a directorio \u203a bloc \u203a directorio_event \u2014 events for DirectorioBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/directorio/bloc/directorio_state.dart';

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

/// Evento para cambiar el tab activo por seccion.
class ChangeDirectorioSection extends DirectorioEvent {
  const ChangeDirectorioSection(this.section);

  final DirectorioSection section;

  @override
  List<Object> get props => [section];
}

/// Evento para cambiar las secciones visibles del directorio.
class SetDirectorioVisibleSections extends DirectorioEvent {
  const SetDirectorioVisibleSections({
    required this.visibleSections,
    required this.activeSection,
  });

  final Set<DirectorioSection> visibleSections;
  final DirectorioSection activeSection;

  @override
  List<Object> get props => [visibleSections, activeSection];
}

/// Evento para cambiar el orden y visibilidad de secciones del directorio.
class SetDirectorioSectionConfig extends DirectorioEvent {
  const SetDirectorioSectionConfig({
    required this.orderedSections,
    required this.visibleSections,
    required this.activeSection,
  });

  final List<DirectorioSection> orderedSections;
  final Set<DirectorioSection> visibleSections;
  final DirectorioSection activeSection;

  @override
  List<Object> get props => [orderedSections, visibleSections, activeSection];
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
