import 'package:equatable/equatable.dart';
import 'package:libretapp/features/animales/domain/entities/animal_entity.dart';

abstract class AnimalesState extends Equatable {
  const AnimalesState();

  @override
  List<Object> get props => [];
}

class AnimalesInitial extends AnimalesState {
  const AnimalesInitial();
}

class AnimalesLoading extends AnimalesState {
  const AnimalesLoading();
}

class AnimalesLoaded extends AnimalesState {
  final List<AnimalEntity> animales;

  const AnimalesLoaded(this.animales);

  @override
  List<Object> get props => [animales];
}

class AnimalesError extends AnimalesState {
  final String message;

  const AnimalesError(this.message);

  @override
  List<Object> get props => [message];
}
