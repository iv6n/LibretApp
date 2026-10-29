import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/core/experience/registration_preferences.dart';
import 'package:libretapp/core/security/ports/phone_auth_port.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Auth extends UnavailablePhoneAuth {
  int signOuts = 0;
  bool failSignOut = false;
  @override
  Future<void> signOut() async {
    signOuts++;
    if (failSignOut) throw StateError('cannot contact auth');
  }
}

class _FalliblePrefs extends SharedPrefsService {
  _FalliblePrefs(super.prefs);
  bool failNext = false;
  @override
  Future<void> setString(String key, String value) async {
    if (failNext) {
      failNext = false;
      throw StateError('disk full');
    }
    await super.setString(key, value);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences raw;
  late _FalliblePrefs prefs;
  late WorkspaceRegistry registry;
  late WorkspaceManager manager;
  late _Auth auth;
  const ana = VerifiedPhoneIdentity(userId: 'ana-id', phone: '+525555123456');
  const pedro = VerifiedPhoneIdentity(
    userId: 'pedro-id',
    phone: '+525555654321',
  );
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    raw = await SharedPreferences.getInstance();
    prefs = _FalliblePrefs(raw);
    registry = WorkspaceRegistry(prefs);
    await registry.load();
    auth = _Auth();
    manager = WorkspaceManager(registry: registry, auth: auth)
      ..opener = (space, {required enterApp}) async {};
  });

  test(
    'failed job cancellation still clears the session and retires local access',
    () async {
      LocalWorkspace? opened;
      manager =
          WorkspaceManager(
              registry: registry,
              auth: auth,
              cancelBackups: () async =>
                  throw StateError('scheduler unavailable'),
            )
            ..opener = (space, {required enterApp}) async {
              opened = space;
            };
      await manager.openAccount(ana);
      await expectLater(manager.signOut(), throwsStateError);
      expect(auth.signOuts, 1);
      expect(registry.active, isNull);
      expect(opened?.kind, WorkspaceKind.guest);
    },
  );

  test(
    'background identity reads neither initialize nor prune workspace ownership',
    () async {
      await manager.openDemo();
      final before = prefs.getString(WorkspaceRegistry.key);
      final readOnly = WorkspaceRegistry(prefs);
      await readOnly.load(startup: false);
      expect(readOnly.active?.isDemo, isTrue);
      expect(prefs.getString(WorkspaceRegistry.key), before);
      expect(readOnly.discardedDemos, isEmpty);
      await prefs.remove(WorkspaceRegistry.key);
      await WorkspaceRegistry(prefs).load(startup: false);
      expect(prefs.getString(WorkspaceRegistry.key), isNull);
    },
  );

  test(
    'guest reopens its data after restarting without creating a remote account',
    () async {
      await manager.openGuest();
      await SharedPrefsService(
        raw,
        prefix: manager.current!.preferencePrefix,
      ).setString('perfil_v1', 'datos de invitado');
      final restored = WorkspaceRegistry(prefs);
      await restored.load();
      expect(restored.active!.id, manager.current!.id);
      expect(
        SharedPrefsService(
          raw,
          prefix: restored.active!.preferencePrefix,
        ).getString('perfil_v1'),
        'datos de invitado',
      );
      expect(restored.active!.userId, isNull);
    },
  );

  test(
    'new guest and account spaces open without an experience setup choice',
    () async {
      await prefs.setString(
        RegistrationPreferences.pendingKey,
        RegistrationPreferences(
          preferredSpecies: const {},
          includePlants: false,
        ).encode(),
      );
      await prefs.setString(AppExperienceController.pendingKey, 'lite');
      await prefs
          .scoped(registry.guest.preferencePrefix)
          .setBool(PrefsKeys.experienceSetupPendingV1, true);
      await manager.openGuest(requireExperienceSelection: true);
      var spacePrefs = SharedPrefsService(
        raw,
        prefix: manager.current!.preferencePrefix,
      );
      expect(spacePrefs.getBool(PrefsKeys.experienceSetupPendingV1), isNull);
      expect(prefs.getString(RegistrationPreferences.pendingKey), isNull);
      expect(prefs.getString(AppExperienceController.pendingKey), isNull);
      expect(prefs.getBool(PrefsKeys.onboardingCompletedV1), isTrue);

      await manager.openAccount(ana);
      spacePrefs = SharedPrefsService(
        raw,
        prefix: manager.current!.preferencePrefix,
      );
      expect(spacePrefs.getBool(PrefsKeys.experienceSetupPendingV1), isNull);
    },
  );

  test('an existing local account clears legacy setup prompts', () async {
    await manager.openAccount(ana);
    final first = manager.current!;
    final firstPrefs = SharedPrefsService(raw, prefix: first.preferencePrefix);
    await firstPrefs.setBool(PrefsKeys.experienceSetupPendingV1, false);
    await manager.signOut();
    await manager.openAccount(ana);
    expect(manager.current!.id, first.id);
    expect(firstPrefs.getBool(PrefsKeys.experienceSetupPendingV1), isNull);
  });

  test(
    'linking adopts the exact guest space and its photos and preferences',
    () async {
      await manager.openGuest();
      final original = manager.current!;
      await prefs.setString('animal.wizard.draft', 'photo:/legacy/luna.jpg');
      await manager.openAccount(ana, linkGuest: true);
      expect(manager.current!.id, original.id);
      expect(manager.current!.legacy, isTrue);
      expect(manager.current!.userId, ana.userId);
      expect(
        SharedPrefsService(
          raw,
          prefix: manager.current!.preferencePrefix,
        ).getString('animal.wizard.draft'),
        'photo:/legacy/luna.jpg',
      );
      expect(registry.guest.id, isNot(original.id));
      expect(
        SharedPrefsService(
          raw,
          prefix: registry.guest.preferencePrefix,
        ).getString('animal.wizard.draft'),
        isNull,
      );
    },
  );

  test(
    'two accounts retain independent local profiles and share only theme',
    () async {
      await manager.openAccount(ana);
      final first = manager.current!;
      final firstPrefs = SharedPrefsService(
        raw,
        prefix: first.preferencePrefix,
      );
      await firstPrefs.setString('perfil_v1', 'Ana');
      await firstPrefs.setString(PrefsKeys.appTheme, 'dark');
      await manager.signOut();
      expect(registry.active, isNull);
      expect(auth.signOuts, 1);
      await manager.openAccount(pedro);
      final secondPrefs = SharedPrefsService(
        raw,
        prefix: manager.current!.preferencePrefix,
      );
      expect(secondPrefs.getString('perfil_v1'), isNull);
      expect(secondPrefs.getString(PrefsKeys.appTheme), 'dark');
      await secondPrefs.setString('perfil_v1', 'Pedro');
      await manager.signOut();
      await manager.openAccount(ana);
      expect(manager.current!.id, first.id);
      expect(firstPrefs.getString('perfil_v1'), 'Ana');
    },
  );

  test(
    'an existing account never merges or overwrites an occupied guest',
    () async {
      await manager.openAccount(ana);
      final account = manager.current!;
      await manager.signOut();
      await manager.openGuest();
      final guest = manager.current!;
      final before = prefs.getString(WorkspaceRegistry.key);
      await expectLater(
        manager.openAccount(ana, linkGuest: true),
        throwsA(isA<WorkspaceConflict>()),
      );
      expect(prefs.getString(WorkspaceRegistry.key), before);
      expect(registry.guest.id, guest.id);
      expect(registry.account(ana.userId)!.id, account.id);
    },
  );

  test(
    'demo does not complete onboarding and never resumes after process death',
    () async {
      await manager.openDemo();
      final demo = manager.current!;
      expect(prefs.getBool(PrefsKeys.onboardingCompletedV1), isNull);
      await expectLater(manager.openAccount(ana), throwsStateError);
      final restored = WorkspaceRegistry(prefs);
      await restored.load();
      expect(restored.active, isNull);
      expect(restored.interruptedDemo, isTrue);
      expect(restored.discardedDemos.single.id, demo.id);
      expect(restored.spaces.any((s) => s.isDemo), isFalse);
    },
  );

  test(
    'demo exit preserves guest and each new demo uses fresh storage',
    () async {
      final guest = registry.guest;
      await manager.openDemo();
      final firstDemo = manager.current!.id;
      await manager.exitDemo();
      expect(registry.active, isNull);
      expect(registry.guest.id, guest.id);
      await manager.openDemo();
      expect(manager.current!.id, isNot(firstDemo));
    },
  );

  test(
    'preparation failure rolls back ownership and onboarding completion',
    () async {
      final original = registry.guest.id;
      manager.opener = (space, {required enterApp}) async {
        if (space.kind == WorkspaceKind.account) {
          throw StateError('cannot open');
        }
      };
      await expectLater(
        manager.openAccount(ana, linkGuest: true),
        throwsStateError,
      );
      expect(registry.account(ana.userId), isNull);
      expect(registry.guest.id, original);
      expect(registry.active, isNull);
      expect(prefs.getBool(PrefsKeys.onboardingCompletedV1), isNull);
    },
  );

  test(
    'failed persistence does not claim data or complete onboarding',
    () async {
      prefs.failNext = true;
      await expectLater(
        manager.openAccount(ana, linkGuest: true),
        throwsStateError,
      );
      expect(registry.account(ana.userId), isNull);
      expect(registry.active, isNull);
      expect(prefs.getBool(PrefsKeys.onboardingCompletedV1), isNull);
      await manager.openGuest();
      expect(registry.active!.kind, WorkspaceKind.guest);
    },
  );

  test('unfinished intro progress survives reopening the registry', () async {
    await prefs.setInt('onboarding.page.v2', 2);
    await WorkspaceRegistry(prefs).load();
    expect(prefs.getInt('onboarding.page.v2'), 2);
  });

  test(
    'logout failure never reopens an account after its access was retired',
    () async {
      await manager.openAccount(ana);
      final accountId = manager.current!.id;
      auth.failSignOut = true;
      await expectLater(manager.signOut(), throwsStateError);
      expect(registry.active, isNull);
      expect(registry.account(ana.userId)!.id, accountId);
      final restored = WorkspaceRegistry(prefs);
      await restored.load();
      expect(restored.active, isNull);
    },
  );

  test(
    'Mexico normalization rejects missing digits and duplicated country code',
    () {
      expect(normalizePhone('52', '55 5512 3456'), '+525555123456');
      expect(
        () => normalizePhone('52', '12345'),
        throwsA(isA<PhoneAuthFailure>()),
      );
      expect(
        () => normalizePhone('52', '+525555123456'),
        throwsA(isA<PhoneAuthFailure>()),
      );
    },
  );
}
