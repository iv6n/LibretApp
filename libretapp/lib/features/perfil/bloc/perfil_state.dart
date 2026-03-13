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
  const PerfilLoaded(this.perfil);
  final Perfil perfil;

  @override
  List<Object> get props => [perfil];
}

class PerfilError extends PerfilState {
  const PerfilError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class PerfilUpdated extends PerfilState {
  const PerfilUpdated(this.perfil);
  final Perfil perfil;

  @override
  List<Object> get props => [perfil];
}
