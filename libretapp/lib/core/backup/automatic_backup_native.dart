import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/platform/release_features.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'cloud_backup_service.dart';
import 'backup_operation_lock.dart';

class AutomaticBackup {
  static const tag = 'libretapp.daily-backup';
  static bool get supported => !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      ReleaseFeatures.cloudBackupEnabled;
  static String key(String userId) => 'cloud.auto.$userId';
  static Future<void> initialize() async {
    if (supported) await Workmanager().initialize(backupDispatcher);
  }

  static Future<void> setEnabled(LocalWorkspace workspace, bool enabled) async {
    if (!supported || workspace.kind != WorkspaceKind.account || workspace.userId == null) {
      throw StateError('Los respaldos automáticos requieren una cuenta verificada.');
    }
    final prefs = await SharedPreferences.getInstance();
    final name = '$tag.${workspace.userId}';
    // Persist revocation before asking the OS to cancel any running job.
    await prefs.setBool(key(workspace.userId!), enabled);
    if (!enabled) {
      await Workmanager().cancelByUniqueName(name);
      return;
    }
    try {
      await Workmanager().registerPeriodicTask(name, tag,
        tag: tag, frequency: const Duration(hours: 24),
        initialDelay: const Duration(hours: 24),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
        inputData: {'workspaceId': workspace.id, 'userId': workspace.userId},
        constraints: Constraints(networkType: NetworkType.unmetered,
          requiresBatteryNotLow: true),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 15),
      );
      await prefs.setString('${key(workspace.userId!)}.status', 'pending');
    } catch (_) {
      await prefs.setBool(key(workspace.userId!), false);
      rethrow;
    }
  }

  static Future<void> cancelAll() async {
    if (!supported) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    for (final k in prefs.getKeys().where((k) => k.startsWith('cloud.auto.') && !k.endsWith('.status'))) {
      if (prefs.get(k) is bool) await prefs.setBool(k, false);
    }
    await Workmanager().cancelByTag(tag);
  }
}

@pragma('vm:entry-point')
void backupDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  Workmanager().executeTask((task, input) => BackupOperationLock().run(() async {
    if (task != AutomaticBackup.tag || !AutomaticBackup.supported) return true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final userId = input?['userId'] as String?;
    final registry = WorkspaceRegistry(SharedPrefsService(prefs));
    await registry.load(startup: false);
    final workspace = registry.active;
    if (userId == null || workspace?.kind != WorkspaceKind.account ||
        workspace?.userId != userId || workspace?.id != input?['workspaceId'] ||
        prefs.getBool(AutomaticBackup.key(userId)) != true) return true;
    final statusKey = '${AutomaticBackup.key(userId)}.status';
    // WorkManager's unmetered constraint alone also permits unmetered cellular.
    // Require a real Wi-Fi transport as well; recheck immediately before upload.
    if (!(await Connectivity().checkConnectivity()).contains(ConnectivityResult.wifi)) {
      await prefs.setString(statusKey, 'pending');
      return false;
    }
    try {
      await prefs.setString(statusKey, 'running');
      await setupLocator(workspace: workspace!);
      await locator<CloudBackupService>().backupNow(beforeUpload: () async {
        await prefs.reload();
        if (prefs.getBool(AutomaticBackup.key(userId)) != true ||
            !(await Connectivity().checkConnectivity()).contains(ConnectivityResult.wifi)) {
          throw StateError('Respaldo aplazado o cancelado.');
        }
      });
      await prefs.setString(statusKey, 'success');
      return true;
    } catch (_) {
      await prefs.setString(statusKey, 'retry');
      return false;
    } finally {
      if (locator.isRegistered<LocalWorkspace>()) await disposeLocator();
    }
  }));
}
