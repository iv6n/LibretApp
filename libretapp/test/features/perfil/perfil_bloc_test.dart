import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/perfil/bloc/perfil_bloc.dart';
import 'package:libretapp/features/perfil/bloc/perfil_event.dart';
import 'package:libretapp/features/perfil/bloc/perfil_state.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';

void main() {
  test(
    'guarda la edición conservando región y sistema de producción',
    () async {
      final repository = _FakePerfilRepository();
      final bloc = PerfilBloc(repository);
      addTearDown(bloc.close);

      final original = _profile();
      repository.value = original;
      bloc.add(const LoadPerfil());
      await bloc.stream.firstWhere((state) => state is PerfilLoaded);

      final updated = original.copyWith(nombre: 'Ana', finca: 'El Roble');
      bloc.add(SavePerfil(updated));
      await bloc.stream.firstWhere((state) => state is PerfilLoaded);

      expect(repository.saved, updated);
      expect(repository.saved?.regionState, 'sonora');
      expect(repository.saved?.productionSetting, 'rangeland');
    },
  );

  test('un fallo de guardado conserva el perfil anterior', () async {
    final repository = _FakePerfilRepository()..fail = true;
    final bloc = PerfilBloc(repository);
    addTearDown(bloc.close);

    final original = _profile();
    repository.value = original;
    bloc.add(const LoadPerfil());
    await bloc.stream.firstWhere((state) => state is PerfilLoaded);

    bloc.add(SavePerfil(original.copyWith(nombre: 'Cambio')));
    final error = await bloc.stream.firstWhere((state) => state is PerfilError);

    expect((error as PerfilError).perfil, original);
  });
}

Perfil _profile() => const Perfil(
  id: 'perfil-1',
  nombre: 'María',
  apellido: 'López',
  email: 'maria@example.com',
  telefono: '555',
  finca: 'La Esperanza',
  direccion: 'Camino rural',
  upp: 'UPP-1',
  regionState: 'sonora',
  productionSetting: 'rangeland',
);

class _FakePerfilRepository implements PerfilRepository {
  Perfil value = _profile();
  Perfil? saved;
  bool fail = false;

  @override
  Future<Perfil> fetchPerfil() async => value;

  @override
  Future<void> savePerfil(Perfil perfil) async {
    if (fail) throw StateError('offline');
    saved = perfil;
    value = perfil;
  }

  @override
  Future<void> updatePerfil(Perfil perfil) async => savePerfil(perfil);
}
