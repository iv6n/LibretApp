import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/maintenance/data_maintenance.dart';

class RecoveryCopiesPage extends StatefulWidget {
  const RecoveryCopiesPage({required this.service, this.reopen, super.key});
  final DataMaintenance service;
  final MaintenanceReopener? reopen;
  @override
  State<RecoveryCopiesPage> createState() => _RecoveryCopiesPageState();
}

class _RecoveryCopiesPageState extends State<RecoveryCopiesPage> {
  List<RecoverySnapshot> _snapshots = [];
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _busy = true);
    try {
      final rows = await widget.service.snapshots();
      if (mounted)
        setState(() {
          _snapshots = rows;
          _error = null;
        });
    } catch (_) {
      if (mounted)
        setState(
          () => _error = 'No se pudieron listar las copias. Intenta de nuevo.',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) await _reload();
    } catch (error) {
      if (mounted)
        setState(() => _error = 'La operación no se completó. $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore(RecoverySnapshot snapshot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restaurar copia previa'),
        content: const Text(
          'Se reemplazarán los datos de este espacio por la copia elegida y se creará primero una copia del estado actual. La app volverá a abrir el espacio.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Crear copia y restaurar'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted && widget.reopen != null) {
      await _run(
        () =>
            widget.service.restoreSnapshot(snapshot.id, reopen: widget.reopen!),
      );
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Copias de recuperación'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _busy ? null : _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Las copias nativas permiten deshacer una limpieza en este mismo espacio y dispositivo, incluso con registros inválidos. Para trasladar datos a otro dispositivo utiliza el respaldo completo .libretbackup.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _run(() async {
                        await widget.service.createSnapshot();
                      }),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Crear copia'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _run(() async {
                        await widget.service.importSnapshot();
                      }),
                      icon: const Icon(Icons.file_open_outlined),
                      label: const Text('Importar copia nativa'),
                    ),
                  ],
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (_snapshots.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Text('Aún no hay copias previas en este espacio.'),
                  ),
                for (final snapshot in _snapshots)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(snapshot.createdAt.toLocal()),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            snapshot.native
                                ? 'Copia nativa de recuperación'
                                : 'Respaldo completo previo',
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              TextButton.icon(
                                onPressed: () => _run(() async {
                                  await widget.service.saveSnapshot(
                                    snapshot.id,
                                  );
                                }),
                                icon: const Icon(Icons.download),
                                label: const Text('Exportar'),
                              ),
                              TextButton.icon(
                                onPressed: widget.reopen == null
                                    ? null
                                    : () => _restore(snapshot),
                                icon: const Icon(Icons.restore),
                                label: const Text('Restaurar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    ),
  );
}
