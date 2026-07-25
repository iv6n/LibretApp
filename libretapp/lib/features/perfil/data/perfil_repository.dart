/// features › perfil › data › perfil_repository — repository for reading and writing profile data.
library;

import 'package:libretapp/features/perfil/data/perfil_model.dart';

abstract class PerfilRepository {
  Future<Perfil> fetchPerfil();
  Future<void> savePerfil(Perfil perfil);
  Future<void> updatePerfil(Perfil perfil);
}
