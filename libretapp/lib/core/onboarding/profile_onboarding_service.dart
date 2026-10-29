import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';
import 'package:libretapp/features/perfil/data/profile_input.dart';

/// Optional setup, scoped to the same workspace as its repository/preferences.
/// Resolving in memory also prevents a redirect loop if preferences cannot save.
class ProfileOnboardingService {
  ProfileOnboardingService({
    required this.workspace,
    required this.preferences,
    required this.repository,
  });

  final LocalWorkspace workspace;
  final SharedPrefsService preferences;
  final PerfilRepository repository;
  bool _resolved = false;

  Future<bool> shouldOffer() async {
    if (workspace.isDemo || _resolved) return false;
    if (preferences.getBool(PrefsKeys.profileOnboardingResolvedV1) == true) {
      _resolved = true;
      return false;
    }
    try {
      if (hasProfileDetails(await repository.fetchPerfil())) {
        await _resolve();
        return false;
      }
    } catch (_) {
      // The page exposes retry and skip even when its profile cannot load.
    }
    return !_resolved;
  }

  Future<Perfil> load() => repository.fetchPerfil();

  Future<void> save(Perfil details, {required bool includeRanch}) async {
    if (workspace.isDemo) {
      throw StateError('Sal de la demo para guardar tu perfil.');
    }
    final emailError = validateOptionalProfileEmail(details.email);
    if (emailError != null) throw FormatException(emailError);
    final current = await repository.fetchPerfil();
    await repository.savePerfil(
      current.copyWith(
        nombre: details.nombre.trim(),
        apellido: details.apellido.trim(),
        email: details.email.trim(),
        telefono: details.telefono.trim(),
        finca: includeRanch ? details.finca.trim() : current.finca,
        upp: includeRanch ? details.upp.trim() : current.upp,
        direccion: includeRanch ? details.direccion.trim() : current.direccion,
      ),
    );
    await _resolve();
  }

  Future<void> skip() => _resolve();

  Future<void> _resolve() async {
    _resolved = true;
    try {
      await preferences.setBool(PrefsKeys.profileOnboardingResolvedV1, true);
    } catch (_) {
      // An optional introduction must never prevent entry to the workspace.
    }
  }
}
