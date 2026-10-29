import 'package:libretapp/core/backup/cloud_backup_repository.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Re-evaluated before every request, including after network awaits.
class BackupIdentity {
  BackupIdentity({required this.workspace, required this.activeWorkspace});
  final LocalWorkspace workspace;
  final Future<LocalWorkspace?> Function() activeWorkspace;

  Future<String> require(SupabaseClient client) async {
    final active = await activeWorkspace();
    final user = client.auth.currentUser;
    if (workspace.kind != WorkspaceKind.account ||
        workspace.userId == null || active?.id != workspace.id ||
        active?.userId != workspace.userId ||
        user?.id != workspace.userId || user?.phoneConfirmedAt == null ||
        client.auth.currentSession == null) {
      throw const CloudBackupUnavailable(
        'Verifica el teléfono de esta cuenta antes de acceder a sus copias.',
      );
    }
    return workspace.userId!;
  }
}
