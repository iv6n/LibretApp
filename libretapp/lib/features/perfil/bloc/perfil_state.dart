/// features \u203a perfil \u203a bloc \u203a perfil_state \u2014 state for PerfilBloc.
library;

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
  const PerfilError(this.message, {this.perfil});
  final String message;
  final Perfil? perfil;

  @override
  List<Object> get props => [message, ?perfil];
}

class PerfilSaving extends PerfilState {
  const PerfilSaving(this.perfil);
  final Perfil perfil;

  @override
  List<Object> get props => [perfil];
}

class PerfilUpdated extends PerfilState {
  const PerfilUpdated(this.perfil);
  final Perfil perfil;

  @override
  List<Object> get props => [perfil];
}
