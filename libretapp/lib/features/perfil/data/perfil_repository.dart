/// features \u203a perfil \u203a data \u203a perfil_repository \u2014 repository for reading and writing profile data.
library;

import 'package:libretapp/features/perfil/data/perfil_model.dart';

abstract class PerfilRepository {
  Future<Perfil> fetchPerfil();
  Future<void> savePerfil(Perfil perfil);
  Future<void> updatePerfil(Perfil perfil);
}

class PerfilRepositoryImpl implements PerfilRepository {
  @override
  Future<Perfil> fetchPerfil() async {
    // Mock data for now
    await Future.delayed(const Duration(milliseconds: 500));
    return const Perfil(
      id: '1',
      nombre: 'Juan',
      apellido: 'Pérez',
      email: 'juan.perez@example.com',
      telefono: '+56912345678',
      finca: 'Finca El Roble',
      direccion: 'Calle Principal 123',
    );
  }

  @override
  Future<void> savePerfil(Perfil perfil) async {
    // Save to database
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> updatePerfil(Perfil perfil) async {
    // Update in database
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
