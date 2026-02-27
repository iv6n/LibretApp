import 'package:equatable/equatable.dart';

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

  final List<dynamic> animales;
  final List<dynamic>? filteredAnimales;

  /// Devuelve los animales a mostrar (filtrados o todos)
  List<dynamic> get displayAnimales => filteredAnimales ?? animales;

  AnimalesTabLoaded copyWith({
    List<dynamic>? animales,
    List<dynamic>? filteredAnimales,
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
