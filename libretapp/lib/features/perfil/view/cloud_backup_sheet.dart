/// Versioned cloud backup history and disaster recovery controls.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/cloud_backup_service.dart';
import 'package:libretapp/core/di/injection.dart';

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
    setState(() => _snapshots = _load());
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
      await _service.restore(metadata, mode: mode);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mode == BackupImportMode.merge
                ? 'Copia fusionada. Reinicia la app para recargar todo.'
                : 'Copia restaurada. Reinicia la app para recargar todo.',
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Copias en la nube',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _busy ? null : _backupNow,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text('Respaldar'),
                ),
              ],
            ),
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
    );
  }
}
