import 'package:libretapp/core/backup/backup_identity.dart';
import 'package:libretapp/core/backup/backup_operation_lock.dart';
import 'package:libretapp/core/backup/automatic_backup.dart';
import 'package:libretapp/core/workspace/workspace_files.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'supabase_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException, FunctionResponse;

class AccountDeletionService {
  static Future<void> recoverLocal(WorkspaceRegistry registry) =>
      BackupOperationLock().run(() async {
    for (final workspace in registry.spaces.toList()) {
      final marker = 'account.deletion.${workspace.id}';
      if (registry.preferences.getString(marker) != 'remote-complete') continue;
      await eraseAccountFiles(workspace);
      await clearAccountPreferences(workspace);
      final activeId = registry.active?.id;
      await registry.replace(registry.spaces.where((s) => s.id != workspace.id).toList(),
        activeId == workspace.id ? null : activeId);
      await registry.preferences.remove(marker);
    }
  });

  Future<void> delete(WorkspaceManager manager) => BackupOperationLock().run(() async {
    final workspace = manager.current;
    if (workspace == null || manager.isGuest || manager.isDemo) {
      throw StateError('Abre la cuenta que deseas eliminar.');
    }
    final client = await SupabaseSession.client();
    await BackupIdentity(workspace: workspace,
      activeWorkspace: () async => manager.current).require(client);
    await AutomaticBackup.cancelAll();
    final prefs = manager.registry.preferences;
    final marker = 'account.deletion.${workspace.id}';
    await prefs.setString(marker, 'pending');
    late final FunctionResponse response;
    try {
      response = await client.functions.invoke('delete-account');
    } on FunctionException catch (error) {
      if (error.status == 403 && error.details is Map &&
          error.details['code'] == 'reauth_required') {
        // The server confirms no deletion has started. Allow a fresh SMS,
        // rather than trapping the user in an unrecoverable pending state.
        await prefs.remove(marker);
        throw StateError('La verificación venció. Solicita un nuevo código SMS.');
      }
      throw StateError('La eliminación no pudo completarse. Reintenta la solicitud o contacta soporte.');
    }
    if (response.status != 200 || response.data is! Map || response.data['status'] != 'complete') {
      throw StateError('La eliminación está pendiente. Puedes reintentar; tus respaldos automáticos están desactivados.');
    }
    // Keep a durable receipt so a crash during local erasure needs no new OTP.
    await prefs.setString(marker, 'remote-complete');
    await _erase(manager, marker);
  });

  Future<void> resumeLocal(WorkspaceManager manager) => BackupOperationLock().run(() async {
    final marker = 'account.deletion.${manager.current?.id}';
    if (manager.registry.preferences.getString(marker) != 'remote-complete') {
      throw StateError('Primero debe completarse la eliminación remota.');
    }
    await _erase(manager, marker);
  });

  Future<void> _erase(WorkspaceManager manager, String marker) async {
    final workspace = manager.current!;
    final preferences = manager.registry.preferences;
    await manager.removeCurrentAccount(() async {
      await eraseAccountFiles(workspace);
      await clearAccountPreferences(workspace);
    });
    await preferences.remove(marker);
  }
}
