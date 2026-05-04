/// features \u203a directorio \u203a bloc \u203a animales_tab_state \u2014 state for AnimalesTabBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';

abstract class AnimalesTabState extends Equatable {
  const AnimalesTabState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AnimalesTabInitial extends AnimalesTabState {
  const AnimalesTabInitial();
}

/// Estado cargando
class AnimalesTabLoading extends AnimalesTabState {
  const AnimalesTabLoading();
}

/// Estado cargado
class AnimalesTabLoaded extends AnimalesTabState {
  const AnimalesTabLoaded({required this.animales, this.filteredAnimales});

  final List<AnimalEntity> animales;
  final List<AnimalEntity>? filteredAnimales;

  /// Devuelve los animales a mostrar (filtrados o todos)
  List<AnimalEntity> get displayAnimales => filteredAnimales ?? animales;

  AnimalesTabLoaded copyWith({
    List<AnimalEntity>? animales,
    List<AnimalEntity>? filteredAnimales,
  }) {
    return AnimalesTabLoaded(
      animales: animales ?? this.animales,
      filteredAnimales: filteredAnimales ?? this.filteredAnimales,
    );
  }

  @override
  List<Object?> get props => [animales, filteredAnimales];
}

/// Estado con error
class AnimalesTabError extends AnimalesTabState {
  const AnimalesTabError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
