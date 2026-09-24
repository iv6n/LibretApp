/// Compact local-first connectivity indicator for the shell.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/services.dart';

class OfflineStatusBanner extends StatefulWidget {
  const OfflineStatusBanner({super.key});

  @override
  State<OfflineStatusBanner> createState() => _OfflineStatusBannerState();
}

class _OfflineStatusBannerState extends State<OfflineStatusBanner> {
  late final OfflineStatusService _service;

  @override
  void initState() {
    super.initState();
    _service = locator<OfflineStatusService>()..start();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OfflineStatus>(
      stream: _service.stream,
      initialData: _service.status,
      builder: (context, snapshot) {
        final status = snapshot.data ?? OfflineStatus.unknown;
        final scheme = Theme.of(context).colorScheme;
        final isOffline = status == OfflineStatus.offline;
        final isUnknown = status == OfflineStatus.unknown;
        final background = isOffline
            ? scheme.errorContainer
            : isUnknown
            ? scheme.surfaceContainerHighest
            : scheme.primaryContainer;
        final foreground = isOffline
            ? scheme.onErrorContainer
            : isUnknown
            ? scheme.onSurfaceVariant
            : scheme.onPrimaryContainer;
        final label = isOffline
            ? 'Sin conexión · guardado local'
            : isUnknown
            ? 'Estado de conexión desconocido · guardado local'
            : 'En línea · guardado local';
        final lastBackup = locator<SharedPrefsService>().getDateTime(
          PrefsKeys.lastLocalBackup,
        );
        final backupLabel = lastBackup == null
            ? label
            : '$label · respaldo ${DateFormat.Hm().format(lastBackup)}';
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          color: background,
          child: SafeArea(
            top: true,
            bottom: false,
            child: SizedBox(
              height: 28,
              child: Center(
                child: Semantics(
                  label: backupLabel,
                  liveRegion: true,
                  child: Text(
                    backupLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
