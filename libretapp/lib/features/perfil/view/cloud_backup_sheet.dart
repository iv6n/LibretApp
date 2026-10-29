/// Versioned cloud backup history and disaster recovery controls.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/cloud_backup_service.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/backup/automatic_backup.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CloudBackupSheet extends StatefulWidget {
  const CloudBackupSheet({super.key});

  @override
  State<CloudBackupSheet> createState() => _CloudBackupSheetState();
}

class _CloudBackupSheetState extends State<CloudBackupSheet> {
  late Future<List<CloudBackupMetadata>> _snapshots;
  bool _busy = false;

  CloudBackupService get _service => locator<CloudBackupService>();

  @override
  void initState() {
    super.initState();
    _snapshots = _load();
  }

  Future<List<CloudBackupMetadata>> _load() {
    if (!_service.isAvailable) return Future.value(const []);
    return _service.listSnapshots();
  }

  void _reload() {
    // A block body is required, not `=>`: the arrow form's "return value" is
    // the assignment's value — a Future here — and setState()'s callback
    // must return void, or Flutter throws in debug mode even though nothing
    // is awaited.
    setState(() {
      _snapshots = _load();
    });
  }

  Future<void> _backupNow() async {
    setState(() => _busy = true);
    try {
      await _service.backupNow();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Respaldo verificado y guardado.')),
      );
      _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore(CloudBackupMetadata metadata) async {
    final mode = await showDialog<BackupImportMode>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restaurar esta copia'),
        content: const Text(
          'Fusionar agrega lo que falte y conserva los cambios locales más '
          'recientes.\n\n'
          'Reemplazar todo borra los datos locales y los sustituye por esta '
          'copia; antes de hacerlo se guarda una copia de emergencia en el '
          'dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, BackupImportMode.replaceAll),
            child: const Text('Reemplazar todo'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, BackupImportMode.merge),
            child: const Text('Fusionar'),
          ),
        ],
      ),
    );
    if (mode == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final manager = locator<WorkspaceManager>();
      await _service.restore(metadata, mode: mode);
      await manager.reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mode == BackupImportMode.merge
                ? 'Copia fusionada.'
                : 'Copia restaurada.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_service.isAvailable) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Esta compilación no tiene configurado un proyecto de respaldo '
          'en la nube.',
        ),
      );
    }
    // This sheet is shown with useRootNavigator: true, so it renders above
    // the whole app on the root Overlay — including above AppShell's own
    // Scaffold. Without a ScaffoldMessenger of its own here,
    // ScaffoldMessenger.of(context) below would resolve to whichever
    // ScaffoldMessenger is currently registered as active (AppShell's), whose
    // SnackBar host paints on AppShell's layer — i.e. *underneath* this
    // sheet. Scoping a ScaffoldMessenger to this subtree makes the SnackBar
    // render as part of the sheet's own layer instead.
    return ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              children: [
                Wrap(
                  spacing: 12, runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Copias en la nube',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    FilledButton.icon(
                      onPressed: _busy ? null : _backupNow,
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text('Respaldar'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Hasta cinco copias verificadas por cuenta, de hasta 100 MiB. Se requiere Wi-Fi.'),
                if (AutomaticBackup.supported && locator.isRegistered<LocalWorkspace>())
                  _AutomaticBackupControl(workspace: locator<LocalWorkspace>()),
                const SizedBox(height: 12),
                if (_busy) const LinearProgressIndicator(),
                Expanded(
                  child: FutureBuilder<List<CloudBackupMetadata>>(
                    future: _snapshots,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final items = snapshot.data!;
                      if (items.isEmpty) {
                        return const Center(
                          child: Text('Todavía no hay copias verificadas.'),
                        );
                      }
                      return ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ListTile(
                            leading: const Icon(Icons.cloud_done_outlined),
                            title: Text(
                              DateFormat(
                                'dd/MM/yyyy HH:mm',
                              ).format(item.createdAt.toLocal()),
                            ),
                            subtitle: Text(
                              '${(item.sizeBytes / 1024).toStringAsFixed(1)} KB · '
                              'v${item.schemaVersion}',
                            ),
                            trailing: TextButton(
                              onPressed: _busy ? null : () => _restore(item),
                              child: const Text('Restaurar'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AutomaticBackupControl extends StatefulWidget {
  const _AutomaticBackupControl({required this.workspace});
  final LocalWorkspace workspace;
  @override
  State<_AutomaticBackupControl> createState() => _AutomaticBackupControlState();
}
class _AutomaticBackupControlState extends State<_AutomaticBackupControl> {
  bool _enabled = false;
  bool _busy = false;
  String _status = 'pending';
  DateTime? _last;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (!mounted) return;
    final key = AutomaticBackup.key(widget.workspace.userId!);
    setState(() {
      _enabled = prefs.getBool(key) == true;
      _status = prefs.getString('$key.status') ?? 'pending';
      _last = locator<SharedPrefsService>().getDateTime(PrefsKeys.lastCloudBackup);
    });
  }
  Future<void> _toggle(bool enabled) async {
    setState(() => _busy = true);
    try {
      await AutomaticBackup.setEnabled(widget.workspace, enabled);
      await _load();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cambiar la programación. Intenta de nuevo.')));
    } finally { if (mounted) setState(() => _busy = false); }
  }
  @override
  Widget build(BuildContext context) => Column(children: [
    SwitchListTile.adaptive(value: _enabled, onChanged: _busy ? null : _toggle,
      title: const Text('Respaldo automático cada 24 horas'),
      subtitle: const Text('Solo por Wi-Fi y con batería suficiente. Android puede aplazarlo.')),
    ListTile(title: Text(_last == null ? 'Sin copia correcta registrada' :
      'Última copia correcta: ${DateFormat('dd/MM/yyyy HH:mm').format(_last!.toLocal())}'),
      subtitle: Text(!_enabled ? 'Desactivado' : switch (_status) {
        'running' => 'Creando copia',
        'retry' => 'Fallo recuperable; Android volverá a intentarlo',
        'success' => 'Copia correcta; próxima ejecución pendiente',
        _ => 'Pendiente de Wi-Fi, batería y programación de Android',
      }), trailing: IconButton(onPressed: _load, tooltip: 'Actualizar estado', icon: const Icon(Icons.refresh))),
  ]);
}
