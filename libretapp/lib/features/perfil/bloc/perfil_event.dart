/// features \u203a perfil \u203a bloc \u203a perfil_event \u2014 events for PerfilBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';

abstract class PerfilEvent extends Equatable {
  const PerfilEvent();

  @override
  List<Object> get props => [];
}

class LoadPerfil extends PerfilEvent {
  const LoadPerfil();
}

class UpdatePerfil extends PerfilEvent {
  const UpdatePerfil(this.perfil);
  final Perfil perfil;

  @override
  List<Object> get props => [perfil];
}

class SavePerfil extends PerfilEvent {
  const SavePerfil(this.perfil);
  final Perfil perfil;

  @override
  List<Object> get props => [perfil];
}
