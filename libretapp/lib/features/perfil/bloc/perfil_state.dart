import 'package:equatable/equatable.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';

abstract class PerfilState extends Equatable {
  const PerfilState();

  @override
  List<Object> get props => [];
}

class PerfilInitial extends PerfilState {
  const PerfilInitial();
}

class PerfilLoading extends PerfilState {
  const PerfilLoading();
}

class PerfilLoaded extends PerfilState {
  final Perfil perfil;

  const PerfilLoaded(this.perfil);

  @override
  List<Object> get props => [perfil];
}

class PerfilError extends PerfilState {
  final String message;

  const PerfilError(this.message);

  @override
  List<Object> get props => [message];
}

class PerfilUpdated extends PerfilState {
  final Perfil perfil;

  const PerfilUpdated(this.perfil);

  @override
  List<Object> get props => [perfil];
}
