import 'package:libretapp/core/workspace/workspace_registry.dart';
class AutomaticBackup {
  static const supported = false;
  static String key(String userId) => 'cloud.auto.$userId';
  static Future<void> initialize() async {}
  static Future<void> cancelAll() async {}
  static Future<void> setEnabled(LocalWorkspace workspace, bool enabled) async =>
      throw UnsupportedError('Los respaldos automáticos requieren Android.');
}
