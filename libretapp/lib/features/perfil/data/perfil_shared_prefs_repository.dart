/// features › perfil › data › perfil_shared_prefs_repository — SharedPreferences
/// implementation of [PerfilRepository].
library;

import 'dart:convert';

import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';

class PerfilSharedPrefsRepository implements PerfilRepository {
  PerfilSharedPrefsRepository(this._prefs);

  static const _key = 'perfil_v1';

  final SharedPrefsService _prefs;

  @override
  Future<Perfil> fetchPerfil() async {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return const Perfil(
        id: '',
        nombre: '',
        apellido: '',
        email: '',
        telefono: '',
        finca: '',
        direccion: '',
      );
    }
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return Perfil.fromJson(map);
  }

  @override
  Future<void> savePerfil(Perfil perfil) async {
    await _prefs.setString(_key, jsonEncode(perfil.toJson()));
  }

  @override
  Future<void> updatePerfil(Perfil perfil) => savePerfil(perfil);
}
