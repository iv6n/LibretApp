import 'package:equatable/equatable.dart';

abstract class AnimalesTabEvent extends Equatable {
  const AnimalesTabEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar los animales
class LoadAnimalesTab extends AnimalesTabEvent {
  const LoadAnimalesTab();
}

/// Evento para filtrar animales por búsqueda
class SearchAnimalesTab extends AnimalesTabEvent {
  const SearchAnimalesTab(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

/// Evento cuando el stream de animales se actualiza
class AnimalesTabStreamUpdated extends AnimalesTabEvent {
  const AnimalesTabStreamUpdated(this.animales);

  final List<dynamic> animales;

  @override
  List<Object> get props => [animales];
}

/// Evento cuando hay error en el stream
class AnimalesTabStreamFailed extends AnimalesTabEvent {
  const AnimalesTabStreamFailed(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
