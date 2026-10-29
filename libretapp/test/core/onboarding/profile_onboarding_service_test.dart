import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libretapp/core/onboarding/profile_onboarding_service.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/data/profile_input.dart';
import '../../support/profile_onboarding_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPrefsService preferences;
  late MemoryProfileRepository repository;
  late ProfileOnboardingService service;
  const workspace = LocalWorkspace(id: 'guest', kind: WorkspaceKind.guest);

  ProfileOnboardingService makeService({
    LocalWorkspace space = workspace,
    SharedPrefsService? prefs,
  }) => ProfileOnboardingService(
    workspace: space,
    preferences: prefs ?? preferences,
    repository: repository,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = SharedPrefsService(
      await SharedPreferences.getInstance(),
    ).scoped(workspace.preferencePrefix);
    repository = MemoryProfileRepository();
    service = makeService();
  });

  test(
    'perfil vacío se ofrece y puede retomarse tras cerrar sin guardar',
    () async {
      expect(await service.shouldOffer(), isTrue);
      expect(await makeService().shouldOffer(), isTrue);
      expect(repository.saveCalls, 0);
      expect(
        preferences.getBool(PrefsKeys.profileOnboardingResolvedV1),
        isNull,
      );
    },
  );

  for (final field in [
    'nombre',
    'apellido',
    'email',
    'telefono',
    'finca',
    'upp',
    'direccion',
  ]) {
    test(
      'un perfil existente con solo $field no recibe la invitación',
      () async {
        repository.value = Perfil.fromJson({
          ...emptyProfile.toJson(),
          field: 'dato',
        });
        expect(await service.shouldOffer(), isFalse);
        expect(
          preferences.getBool(PrefsKeys.profileOnboardingResolvedV1),
          isTrue,
        );
        expect(repository.saveCalls, 0);
      },
    );
  }

  test('región y producción no sustituyen los datos opcionales', () async {
    repository.value = emptyProfile.copyWith(
      regionState: 'sonora',
      productionSetting: 'rangeland',
    );
    expect(await service.shouldOffer(), isTrue);
  });

  test('demo omite la pantalla sin leer ni escribir el perfil', () async {
    service = makeService(
      space: const LocalWorkspace(id: 'demo', kind: WorkspaceKind.demo),
    );
    expect(await service.shouldOffer(), isFalse);
    expect(repository.loadCalls, 0);
    expect(repository.saveCalls, 0);
  });

  test('omitir no guarda datos y se recuerda al reabrir', () async {
    await service.skip();
    expect(await makeService().shouldOffer(), isFalse);
    expect(repository.saveCalls, 0);
    expect(preferences.getBool(PrefsKeys.onboardingCompletedV1), isNull);
  });

  for (final details in [
    emptyProfile,
    emptyProfile.copyWith(nombre: ' Ana '),
    emptyProfile.copyWith(upp: ' 0012-MX '),
    emptyProfile.copyWith(telefono: ' +52 55-1234-5678 '),
    emptyProfile.copyWith(email: ' ana@example.com '),
  ]) {
    test(
      'permite guardar cualquier combinación: ${details.toJson()}',
      () async {
        await service.save(details, includeRanch: true);
        expect(repository.value.nombre, details.nombre.trim());
        expect(repository.value.upp, details.upp.trim());
        expect(repository.value.telefono, details.telefono.trim());
        expect(repository.value.email, details.email.trim());
        expect(await makeService().shouldOffer(), isFalse);
      },
    );
  }

  test(
    'Lite conserva datos ocultos e identidad y configuración más recientes',
    () async {
      final draft = await service.load();
      repository.value = emptyProfile.copyWith(
        id: 'same-user',
        finca: 'Rancho real',
        upp: '001234',
        direccion: 'Camino',
        regionState: 'sonora',
        productionSetting: 'rangeland',
      );
      await service.save(
        draft.copyWith(nombre: ' Ana ', telefono: ' +1 555-555 '),
        includeRanch: false,
      );
      expect(repository.value.id, 'same-user');
      expect(repository.value.finca, 'Rancho real');
      expect(repository.value.upp, '001234');
      expect(repository.value.direccion, 'Camino');
      expect(repository.value.regionState, 'sonora');
      expect(repository.value.productionSetting, 'rangeland');
    },
  );

  test(
    'un fallo de guardado mantiene el paso pendiente y permite reintentar',
    () async {
      repository.failSave = true;
      await expectLater(
        service.save(emptyProfile.copyWith(nombre: 'Ana'), includeRanch: true),
        throwsStateError,
      );
      expect(
        preferences.getBool(PrefsKeys.profileOnboardingResolvedV1),
        isNull,
      );
      expect(repository.value, emptyProfile);
      expect(await service.shouldOffer(), isTrue);
      repository.failSave = false;
      await service.save(
        emptyProfile.copyWith(nombre: 'Ana'),
        includeRanch: true,
      );
      expect(await service.shouldOffer(), isFalse);
    },
  );

  test(
    'fallar al registrar omisión no bloquea ni redirige de nuevo en la sesión',
    () async {
      final prefs = _FailingPreferences(await SharedPreferences.getInstance());
      service = makeService(prefs: prefs);
      await service.skip();
      expect(await service.shouldOffer(), isFalse);
      expect(repository.saveCalls, 0);
    },
  );

  test('un fallo de lectura permite omitir', () async {
    repository.failLoad = true;
    expect(await service.shouldOffer(), isTrue);
    await expectLater(service.load(), throwsStateError);
    await service.skip();
    expect(await service.shouldOffer(), isFalse);
  });

  test('la resolución queda aislada por espacio de trabajo', () async {
    await service.skip();
    final other = makeService(
      space: const LocalWorkspace(
        id: 'account',
        kind: WorkspaceKind.account,
        userId: 'user',
      ),
      prefs: preferences.scoped('workspace.account.'),
    );
    expect(await other.shouldOffer(), isTrue);
    expect(await service.shouldOffer(), isFalse);
  });

  test('correo vacío se acepta, un formato incorrecto no se escribe', () async {
    expect(validateOptionalProfileEmail(''), isNull);
    expect(validateOptionalProfileEmail(' ana+campo@example.com '), isNull);
    await expectLater(
      service.save(
        emptyProfile.copyWith(email: 'incorrecto'),
        includeRanch: true,
      ),
      throwsFormatException,
    );
    expect(repository.saveCalls, 0);
  });
}

class _FailingPreferences extends SharedPrefsService {
  _FailingPreferences(super.prefs);
  @override
  Future<void> setBool(String key, bool value) async =>
      throw StateError('write failed');
}
