import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'workspace_registry.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Directory> workspaceDirectory(LocalWorkspace workspace) async {
  final support = await getApplicationSupportDirectory();
  if (workspace.legacy) return support;
  if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(workspace.id)) {
    throw const FormatException('Espacio inválido.');
  }
  final dir = Directory(
    '${support.path}${Platform.pathSeparator}workspaces${Platform.pathSeparator}${workspace.id}',
  );
  await dir.create(recursive: true);
  return dir;
}

Future<void> discardDemoFiles(LocalWorkspace workspace) async {
  if (!workspace.isDemo || workspace.legacy) return;
  final support = await getApplicationSupportDirectory();
  final root = Directory(
    '${support.path}${Platform.pathSeparator}workspaces',
  ).absolute.path;
  final target = (await workspaceDirectory(workspace)).absolute.path;
  if (!target.startsWith('$root${Platform.pathSeparator}') || target == root) {
    throw StateError('Ruta de demo inválida.');
  }
  final dir = Directory(target);
  if (await dir.exists()) await dir.delete(recursive: true);
}

/// Called only after the host unmounted the account and closed Isar.
Future<void> eraseAccountFiles(LocalWorkspace workspace) async {
  if (workspace.kind != WorkspaceKind.account) throw StateError('Cuenta inválida.');
  final support = await getApplicationSupportDirectory();
  if (!workspace.legacy) {
    final target = await workspaceDirectory(workspace);
    final root = Directory('${support.path}${Platform.pathSeparator}workspaces').absolute.path;
    if (!target.absolute.path.startsWith('$root${Platform.pathSeparator}')) {
      throw StateError('Ruta de cuenta inválida.');
    }
    if (await target.exists()) await target.delete(recursive: true);
    return;
  }
  // Legacy ownership is restricted to named app-owned paths; never delete
  // the support root, other workspaces or files exported by the user.
  for (final name in ['libretapp_db.isar', 'libretapp_db.isar.lock', 'libretapp_db.isar.management',
      'backup_media', 'emergency_backups', 'libretapp_media']) {
    final path = '${support.path}${Platform.pathSeparator}$name';
    if (await FileSystemEntity.isDirectory(path)) {
      await Directory(path).delete(recursive: true);
    } else if (await File(path).exists()) { await File(path).delete(); }
  }
  final documents = await getApplicationDocumentsDirectory();
  final media = Directory('${documents.path}${Platform.pathSeparator}libretapp_media');
  if (await media.exists()) await media.delete(recursive: true);
}

Future<void> clearAccountPreferences(LocalWorkspace workspace) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  const global = {'app.theme', 'app.language', 'onboarding.completed.v1',
    'onboarding.page.v2', WorkspaceRegistry.key};
  for (final key in prefs.getKeys().toList()) {
    final owned = workspace.legacy
        ? !global.contains(key) && !key.startsWith('workspace.') &&
          !key.startsWith('account.deletion.') && !key.startsWith('cloud.auto.') && !key.startsWith('sb-')
        : key.startsWith(workspace.preferencePrefix);
    if (owned && !await prefs.remove(key)) throw StateError('No se pudieron borrar preferencias de la cuenta.');
  }
}
