import 'package:libretapp/core/security/ports/phone_auth_port.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/backup/automatic_backup.dart';
import 'package:libretapp/core/backup/backup_operation_lock.dart';
import 'package:libretapp/core/platform/release_features.dart';
import 'workspace_registry.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/core/experience/registration_preferences.dart';

typedef WorkspaceOpener =
    Future<void> Function(LocalWorkspace workspace, {required bool enterApp});

class WorkspaceConflict implements Exception {
  const WorkspaceConflict(this.existing);
  final LocalWorkspace existing;
}

/// Coordinates local ownership only. It never uploads or merges farm data.
class WorkspaceManager {
  WorkspaceManager({
    required this.registry,
    required this.auth,
    Future<void> Function()? cancelBackups,
  }) : _cancelBackups = cancelBackups ?? AutomaticBackup.cancelAll;
  final WorkspaceRegistry registry;
  final PhoneAuthPort auth;
  final Future<void> Function() _cancelBackups;
  WorkspaceOpener? opener;
  Future<void> Function(Future<void> Function() action)? maintenanceOpener;
  Future<void> Function(LocalWorkspace guest, Future<void> Function() erase)?
  deletionOpener;

  Future<void> removeCurrentAccount(Future<void> Function() erase) async {
    final account = current;
    if (_busy ||
        account?.kind != WorkspaceKind.account ||
        deletionOpener == null) {
      throw StateError('No se puede eliminar este espacio ahora.');
    }
    _busy = true;
    try {
      await _cancelBackups();
      // Do not discard the registry entry until all local files were erased.
      await deletionOpener!(registry.guest, erase);
      await registry.replace(
        registry.spaces.where((s) => s.id != account!.id).toList(),
        null,
      );
      await auth.signOut();
    } finally {
      _busy = false;
    }
  }

  Future<void> runMaintenance(Future<void> Function() action) =>
      ReleaseFeatures.cloudBackupEnabled
      ? BackupOperationLock().run(() => _runMaintenance(action))
      : _runMaintenance(action);

  Future<void> _runMaintenance(Future<void> Function() action) async {
    if (_busy || isDemo || current == null || maintenanceOpener == null) {
      throw StateError('No se puede restaurar este espacio en este momento.');
    }
    _busy = true;
    try {
      await maintenanceOpener!(action);
    } finally {
      _busy = false;
    }
  }

  bool _busy = false;
  bool get busy => _busy;
  LocalWorkspace? get current => registry.active;
  bool get isDemo => current?.isDemo ?? false;
  bool get isGuest => current == null || current?.kind == WorkspaceKind.guest;

  Future<void> reload() async {
    final space = current;
    if (space == null || _busy) {
      throw StateError('No se pudo recargar el espacio.');
    }
    await _activate(space);
  }

  Future<void> openGuest({bool requireExperienceSelection = false}) async {
    await registry.preferences
        .scoped(registry.guest.preferencePrefix)
        .remove(PrefsKeys.experienceSetupPendingV1);
    await registry.preferences.remove(RegistrationPreferences.pendingKey);
    await registry.preferences.remove(AppExperienceController.pendingKey);
    await _activate(registry.guest, complete: true);
  }

  Future<void> openAccount(
    VerifiedPhoneIdentity identity, {
    bool linkGuest = false,
  }) async {
    if (identity.userId.isEmpty || identity.phone.isEmpty) {
      throw const PhoneAuthFailure(
        'La identidad del teléfono no pudo verificarse.',
      );
    }
    if (isDemo) {
      throw StateError('Sal de la demo antes de vincular una cuenta.');
    }
    final existing = registry.account(identity.userId);
    final digits = identity.phone.replaceAll(RegExp(r'\D'), '');
    final suffix = digits.length >= 4
        ? digits.substring(digits.length - 4)
        : null;
    if (linkGuest && existing != null) throw WorkspaceConflict(existing);
    if (linkGuest) {
      if (!isGuest) {
        throw StateError('Este espacio ya está vinculado a una cuenta.');
      }
      final guest = registry.guest;
      final linked = LocalWorkspace(
        id: guest.id,
        kind: WorkspaceKind.account,
        userId: identity.userId,
        phoneSuffix: suffix,
        legacy: guest.legacy,
      );
      final spaces = registry.spaces.where((s) => s.id != guest.id).toList()
        ..add(linked)
        ..add(registry.create(WorkspaceKind.guest));
      await registry.preferences.remove(RegistrationPreferences.pendingKey);
      await registry.preferences.remove(AppExperienceController.pendingKey);
      await registry.preferences
          .scoped(guest.preferencePrefix)
          .remove(PrefsKeys.experienceSetupPendingV1);
      await _activate(linked, spaces: spaces, complete: true);
      return;
    }
    final target =
        existing ??
        registry.create(
          WorkspaceKind.account,
          userId: identity.userId,
          phoneSuffix: suffix,
        );
    await registry.preferences
        .scoped(target.preferencePrefix)
        .remove(PrefsKeys.experienceSetupPendingV1);
    await registry.preferences.remove(RegistrationPreferences.pendingKey);
    await registry.preferences.remove(AppExperienceController.pendingKey);
    await _activate(target, complete: true);
  }

  Future<void> openDemo({
    AppExperience experience = AppExperience.complete,
  }) async {
    if (_busy) return;
    // A new demo ID means no previous demo edits can leak into this session.
    await _activate(
      registry.create(WorkspaceKind.demo),
      demoExperience: experience,
    );
  }

  Future<void> exitDemo() async {
    if (!isDemo) return;
    await registry.preferences.remove(AppExperienceController.pendingKey);
    await registry.preferences.remove(RegistrationPreferences.pendingKey);
    await _activate(
      registry.guest,
      enterApp: false,
      deactivate: true,
      spaces: registry.spaces.where((s) => !s.isDemo).toList(),
    );
  }

  Future<void> signOut() => ReleaseFeatures.cloudBackupEnabled
      ? BackupOperationLock().run(_signOut)
      : _signOut();

  Future<void> _signOut() async {
    if (_busy) return;
    final open = opener;
    if (open == null) {
      throw StateError('No se pudo cerrar el espacio de trabajo.');
    }
    _busy = true;
    try {
      // Persist the access boundary first. A later network/storage failure
      // must never reactivate an account after its session was removed.
      await registry.replace(registry.spaces, null);
      try {
        await _cancelBackups();
      } finally {
        try {
          await auth.signOut();
        } finally {
          await open(registry.guest, enterApp: false);
        }
      }
    } finally {
      _busy = false;
    }
  }

  Future<void> _activate(
    LocalWorkspace target, {
    AppExperience? demoExperience,
    List<LocalWorkspace>? spaces,
    bool complete = false,
    bool enterApp = true,
    bool deactivate = false,
  }) {
    Future<void> open() => _activateUnlocked(
      target,
      demoExperience: demoExperience,
      spaces: spaces,
      complete: complete,
      enterApp: enterApp,
      deactivate: deactivate,
    );
    return ReleaseFeatures.cloudBackupEnabled
        ? BackupOperationLock().run(open)
        : open();
  }

  Future<void> _activateUnlocked(
    LocalWorkspace target, {
    AppExperience? demoExperience,
    List<LocalWorkspace>? spaces,
    bool complete = false,
    bool enterApp = true,
    bool deactivate = false,
  }) async {
    if (_busy) throw StateError('Espera a que termine el cambio de espacio.');
    final open = opener;
    if (open == null) {
      throw StateError('No se pudo abrir el espacio de trabajo.');
    }
    _busy = true;
    final previous = registry.spaces;
    final previousId = current?.id;
    final completed = registry.preferences.getBool(
      PrefsKeys.onboardingCompletedV1,
    );
    final next =
        spaces ??
        [...previous.where((s) => s.id != target.id && !s.isDemo), target];
    try {
      await registry.replace(next, deactivate ? null : target.id);
      final targetPrefs = registry.preferences.scoped(target.preferencePrefix);
      final pendingRegistration = registry.preferences.getString(
        RegistrationPreferences.pendingKey,
      );
      if (!target.isDemo &&
          targetPrefs.getString(RegistrationPreferences.storageKey) == null &&
          pendingRegistration != null) {
        await targetPrefs.setString(
          RegistrationPreferences.storageKey,
          pendingRegistration,
        );
        await targetPrefs.setBool(
          RegistrationPreferences.recordsMigrationKey,
          false,
        );
      }
      if (target.isDemo) {
        await targetPrefs.setString(
          AppExperienceController.experienceKey,
          demoExperience?.name ??
              targetPrefs.getString(AppExperienceController.experienceKey) ??
              AppExperience.complete.name,
        );
      } else if (enterApp &&
          targetPrefs.getString(AppExperienceController.experienceKey) ==
              null) {
        final pending = registry.preferences.getString(
          AppExperienceController.pendingKey,
        );
        if (pending == AppExperience.lite.name ||
            pending == AppExperience.complete.name) {
          await targetPrefs.setString(
            AppExperienceController.experienceKey,
            pending!,
          );
        }
      }
      if (complete) {
        await registry.preferences.setBool(
          PrefsKeys.onboardingCompletedV1,
          true,
        );
      }
      await open(target, enterApp: enterApp);
      if (complete) {
        await registry.preferences.remove(AppExperienceController.pendingKey);
        await registry.preferences.remove(RegistrationPreferences.pendingKey);
      }
    } catch (error, stack) {
      // Ownership and onboarding are rolled back if preparation or persistence fails.
      await registry.replace(previous, previousId);
      if (completed == null) {
        await registry.preferences.remove(PrefsKeys.onboardingCompletedV1);
      } else {
        await registry.preferences.setBool(
          PrefsKeys.onboardingCompletedV1,
          completed,
        );
      }
      try {
        await open(
          registry.active ?? registry.guest,
          enterApp: previousId != null,
        );
      } catch (_) {
        /* The host exposes a retry action if even recovery cannot open storage. */
      }
      Error.throwWithStackTrace(error, stack);
    } finally {
      _busy = false;
    }
  }
}
