/// features \u203a perfil \u203a bloc \u203a perfil_bloc \u2014 BLoC for the user profile feature.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/perfil/bloc/perfil_event.dart';
import 'package:libretapp/features/perfil/bloc/perfil_state.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';

class PerfilBloc extends Bloc<PerfilEvent, PerfilState> {
  PerfilBloc(this.repository) : super(const PerfilInitial()) {
    on<LoadPerfil>(_onLoadPerfil);
    on<UpdatePerfil>(_onUpdatePerfil);
    on<SavePerfil>(_onSavePerfil);
  }
  final PerfilRepository repository;

  Future<void> _onLoadPerfil(
    LoadPerfil event,
    Emitter<PerfilState> emit,
  ) async {
    emit(const PerfilLoading());
    try {
      final perfil = await repository.fetchPerfil();
      emit(PerfilLoaded(perfil));
    } catch (e) {
      emit(PerfilError(e.toString()));
    }
  }

  Future<void> _onUpdatePerfil(
    UpdatePerfil event,
    Emitter<PerfilState> emit,
  ) async {
    try {
      await repository.updatePerfil(event.perfil);
      emit(PerfilUpdated(event.perfil));
    } catch (e) {
      emit(PerfilError(e.toString()));
    }
  }

  Future<void> _onSavePerfil(
    SavePerfil event,
    Emitter<PerfilState> emit,
  ) async {
    try {
      await repository.savePerfil(event.perfil);
      emit(PerfilLoaded(event.perfil));
    } catch (e) {
      emit(PerfilError(e.toString()));
    }
  }
}
