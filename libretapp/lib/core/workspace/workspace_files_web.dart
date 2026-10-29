import 'workspace_registry.dart';

Future<void> discardDemoFiles(LocalWorkspace workspace) async {}
Future<void> eraseAccountFiles(LocalWorkspace workspace) async =>
    throw UnsupportedError('El borrado local requiere Android.');
Future<void> clearAccountPreferences(LocalWorkspace workspace) async {}
