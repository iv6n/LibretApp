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
  final Perfil perfil;

  const UpdatePerfil(this.perfil);

  @override
  List<Object> get props => [perfil];
}

class SavePerfil extends PerfilEvent {
  final Perfil perfil;

  const SavePerfil(this.perfil);

  @override
  List<Object> get props => [perfil];
}
