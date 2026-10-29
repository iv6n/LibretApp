import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';

const emptyProfile = Perfil(
  id: 'local',
  nombre: '',
  apellido: '',
  email: '',
  telefono: '',
  finca: '',
  direccion: '',
);

class MemoryProfileRepository implements PerfilRepository {
  MemoryProfileRepository([this.value = emptyProfile]);
  Perfil value;
  int saveCalls = 0;
  int loadCalls = 0;
  bool failLoad = false;
  bool failSave = false;
  Future<void>? saveGate;

  @override
  Future<Perfil> fetchPerfil() async {
    loadCalls++;
    if (failLoad) throw StateError('read failed');
    return value;
  }

  @override
  Future<void> savePerfil(Perfil profile) async {
    saveCalls++;
    await saveGate;
    if (failSave) throw StateError('write failed');
    value = profile;
  }

  @override
  Future<void> updatePerfil(Perfil profile) => savePerfil(profile);
}
