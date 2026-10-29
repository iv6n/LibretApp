import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/platform/release_features.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'lite_visibility.dart';

class LiteNotificationService {
  const LiteNotificationService._();
  static const _channel = MethodChannel('libretapp/lite_reminders');
  static int _generation = 0;

  static Future<bool> exactAvailable() async {
    if (ReleaseFeatures.demoMode) return true;
    if (defaultTargetPlatform != TargetPlatform.android || kIsWeb) return true;
    return await _channel.invokeMethod<bool>('exactAvailable') ?? false;
  }

  static Future<void> requestExactAccess() async {
    if (ReleaseFeatures.demoMode) return;
    if (defaultTargetPlatform != TargetPlatform.android || kIsWeb) return;
    await _channel.invokeMethod<void>('requestExactAccess');
  }

  /// Invalidates repository reads in flight before their workspace is closed.
  static Future<void> cancelForWorkspaceChange() async {
    ++_generation;
    if (defaultTargetPlatform != TargetPlatform.android || kIsWeb) return;
    await _channel.invokeMethod<void>('replace', {'entries': <Object>[]});
  }

  /// Replaces device alarms for this workspace, including in Completa.
  static Future<bool> syncFromRepository({
    bool requestPermission = false,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android || kIsWeb) return true;
    final generation = ++_generation;
    if (ReleaseFeatures.demoMode) {
      await _channel.invokeMethod<void>('replace', {'entries': <Object>[]});
      return true;
    }
    final entries = await locator<AgendaRepository>().fetchEntries();
    if (generation != _generation || ReleaseFeatures.demoMode) return true;
    final pending = entries
        .where(
          (entry) =>
              (entry.remindAt != null || entry.sourceType == 'lite') &&
              LiteVisibility.isOpenEntry(entry) &&
              (entry.remindAt ?? entry.fecha).isAfter(DateTime.now()),
        )
        .toList();
    if (requestPermission && pending.isNotEmpty) {
      final status = await Permission.notification.request();
      if (!status.isGranted) return false;
    }
    if (generation != _generation) return true;
    await _channel.invokeMethod<void>('replace', {
      'entries': pending
          .map(
            (entry) => {
              'id': entry.id,
              'title': entry.titulo,
              'body': entry.descripcion,
              'at': (entry.remindAt ?? entry.fecha).millisecondsSinceEpoch,
            },
          )
          .toList(),
    });
    return true;
  }
}
