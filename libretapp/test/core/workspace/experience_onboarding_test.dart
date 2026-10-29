import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/core/experience/registration_preferences.dart';
import 'package:libretapp/core/security/ports/phone_auth_port.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'descarta la selección Lite antigua al entrar con todas las opciones',
    () async {
      SharedPreferences.setMockInitialValues({});
      final raw = await SharedPreferences.getInstance();
      final global = SharedPrefsService(raw);
      await global.setString(
        AppExperienceController.pendingKey,
        AppExperience.lite.name,
      );
      final registry = WorkspaceRegistry(global);
      await registry.load();
      var sawLiteBeforeHome = false;
      final manager =
          WorkspaceManager(
              registry: registry,
              auth: const UnavailablePhoneAuth(),
            )
            ..opener = (space, {required enterApp}) async {
              sawLiteBeforeHome =
                  global
                      .scoped(space.preferencePrefix)
                      .getString(AppExperienceController.experienceKey) ==
                  AppExperience.lite.name;
            };
      await manager.openGuest();
      expect(sawLiteBeforeHome, isFalse);
      expect(global.getString(AppExperienceController.pendingKey), isNull);
      final preferences = RegistrationPreferencesController(
        global.scoped(registry.guest.preferencePrefix),
      );
      expect(
        preferences.value.preferredSpecies,
        RegistrationPreferences.allSpecies,
      );
      expect(preferences.value.includePlants, isTrue);
      expect(preferences.value.configured, isFalse);
      expect(
        AppExperienceController(
          global.scoped(registry.guest.preferencePrefix),
        ).isLite,
        isFalse,
      );
      preferences.dispose();
    },
  );

  test(
    'cuenta existente conserva su experiencia frente a elección pendiente',
    () async {
      SharedPreferences.setMockInitialValues({});
      final raw = await SharedPreferences.getInstance();
      final global = SharedPrefsService(raw);
      final registry = WorkspaceRegistry(global);
      await registry.load();
      final manager = WorkspaceManager(
        registry: registry,
        auth: const UnavailablePhoneAuth(),
      )..opener = (space, {required enterApp}) async {};
      const identity = VerifiedPhoneIdentity(
        userId: 'existing',
        phone: '+525555123456',
      );
      await manager.openAccount(identity);
      final account = registry.account(identity.userId)!;
      await global
          .scoped(account.preferencePrefix)
          .setString(
            AppExperienceController.experienceKey,
            AppExperience.complete.name,
          );
      await global.setString(
        AppExperienceController.pendingKey,
        AppExperience.lite.name,
      );
      await manager.openAccount(identity);
      expect(
        global
            .scoped(account.preferencePrefix)
            .getString(AppExperienceController.experienceKey),
        AppExperience.complete.name,
      );
      expect(global.getString(AppExperienceController.pendingKey), isNull);
    },
  );

  test('cuenta nueva recibe acceso completo y la demo queda aislada', () async {
    SharedPreferences.setMockInitialValues({});
    final raw = await SharedPreferences.getInstance();
    final global = SharedPrefsService(raw);
    final registry = WorkspaceRegistry(global);
    await registry.load();
    await global.setString(
      AppExperienceController.pendingKey,
      AppExperience.lite.name,
    );
    final manager = WorkspaceManager(
      registry: registry,
      auth: const UnavailablePhoneAuth(),
    )..opener = (space, {required enterApp}) async {};
    await manager.openAccount(
      const VerifiedPhoneIdentity(userId: 'new', phone: '+525555123456'),
    );
    final accountPreferences = RegistrationPreferencesController(
      global.scoped(manager.current!.preferencePrefix),
    );
    expect(
      accountPreferences.value.preferredSpecies,
      RegistrationPreferences.allSpecies,
    );
    expect(accountPreferences.value.includePlants, isTrue);
    expect(accountPreferences.value.configured, isFalse);
    expect(
      AppExperienceController(
        global.scoped(manager.current!.preferencePrefix),
      ).isLite,
      isFalse,
    );
    accountPreferences.dispose();
    await manager.openDemo();
    expect(
      AppExperienceController(
        global.scoped(manager.current!.preferencePrefix),
        demo: true,
      ).experience,
      AppExperience.complete,
    );
  });

  test('descarta la selección pendiente antigua al crear una cuenta', () async {
    SharedPreferences.setMockInitialValues({});
    final global = SharedPrefsService(await SharedPreferences.getInstance());
    final registry = WorkspaceRegistry(global);
    await registry.load();
    final selected = RegistrationPreferences(
      preferredSpecies: const {Species.cattle, Species.canine},
      includePlants: true,
    );
    await global.setString(
      RegistrationPreferences.pendingKey,
      selected.encode(),
    );
    final manager = WorkspaceManager(
      registry: registry,
      auth: const UnavailablePhoneAuth(),
    )..opener = (space, {required enterApp}) async {};

    await manager.openAccount(
      const VerifiedPhoneIdentity(userId: 'selected', phone: '+525555123456'),
    );

    final accountPrefs = global.scoped(manager.current!.preferencePrefix);
    expect(accountPrefs.getString(RegistrationPreferences.storageKey), isNull);
    expect(global.getString(RegistrationPreferences.pendingKey), isNull);
    expect(
      RegistrationPreferencesController(accountPrefs).value.preferredSpecies,
      RegistrationPreferences.allSpecies,
    );
  });

  test('cuenta existente conserva las preferencias guardadas', () async {
    SharedPreferences.setMockInitialValues({});
    final global = SharedPrefsService(await SharedPreferences.getInstance());
    final registry = WorkspaceRegistry(global);
    await registry.load();
    final manager = WorkspaceManager(
      registry: registry,
      auth: const UnavailablePhoneAuth(),
    )..opener = (space, {required enterApp}) async {};
    const identity = VerifiedPhoneIdentity(
      userId: 'preserved',
      phone: '+525555123456',
    );
    await manager.openAccount(identity);
    final accountPrefs = global.scoped(manager.current!.preferencePrefix);
    final selected = RegistrationPreferences(
      preferredSpecies: const {Species.sheep},
      includePlants: false,
    );
    await accountPrefs.setString(
      RegistrationPreferences.storageKey,
      selected.encode(),
    );
    await global.setString(
      RegistrationPreferences.pendingKey,
      RegistrationPreferences(
        preferredSpecies: const {Species.pig},
        includePlants: true,
      ).encode(),
    );

    await manager.openAccount(identity);

    expect(
      accountPrefs.getString(RegistrationPreferences.storageKey),
      selected.encode(),
    );
    expect(global.getString(RegistrationPreferences.pendingKey), isNull);
  });

  for (final experience in AppExperience.values) {
    test(
      'demo ${experience.name} conserva su modo, salida y aislamiento',
      () async {
        SharedPreferences.setMockInitialValues({});
        final global = SharedPrefsService(
          await SharedPreferences.getInstance(),
        );
        final registry = WorkspaceRegistry(global);
        await registry.load();
        final guestId = registry.guest.id;
        final manager = WorkspaceManager(
          registry: registry,
          auth: const UnavailablePhoneAuth(),
        )..opener = (space, {required enterApp}) async {};
        await manager.openDemo(experience: experience);
        final demo = manager.current!;
        final controller = AppExperienceController(
          global.scoped(demo.preferencePrefix),
          demo: true,
        );
        expect(controller.experience, experience);
        final other = experience == AppExperience.lite
            ? AppExperience.complete
            : AppExperience.lite;
        await expectLater(controller.setExperience(other), throwsStateError);
        await manager.reload();
        expect(
          global
              .scoped(demo.preferencePrefix)
              .getString(AppExperienceController.experienceKey),
          experience.name,
        );
        expect(global.getBool(PrefsKeys.onboardingCompletedV1), isNull);
        await manager.exitDemo();
        expect(global.getString(AppExperienceController.pendingKey), isNull);
        expect(
          global
              .scoped(registry.guest.preferencePrefix)
              .getString(AppExperienceController.experienceKey),
          isNull,
          reason:
              'Salir de ejemplos no configura el espacio real antes de entrar.',
        );
        expect(registry.guest.id, guestId);
        expect(registry.active, isNull);
        controller.dispose();
      },
    );
  }

  test(
    'un invitado configurado conserva su experiencia y su espacio',
    () async {
      SharedPreferences.setMockInitialValues({});
      final global = SharedPrefsService(await SharedPreferences.getInstance());
      final registry = WorkspaceRegistry(global);
      await registry.load();
      final guestId = registry.guest.id;
      final guestPrefs = global.scoped(registry.guest.preferencePrefix);
      await guestPrefs.setString(
        AppExperienceController.experienceKey,
        AppExperience.complete.name,
      );
      await global.setString(
        AppExperienceController.pendingKey,
        AppExperience.lite.name,
      );
      final manager = WorkspaceManager(
        registry: registry,
        auth: const UnavailablePhoneAuth(),
      )..opener = (space, {required enterApp}) async {};
      await manager.openGuest();
      expect(manager.current!.id, guestId);
      expect(
        guestPrefs.getString(AppExperienceController.experienceKey),
        AppExperience.complete.name,
      );
      expect(global.getString(AppExperienceController.pendingKey), isNull);
    },
  );
}
