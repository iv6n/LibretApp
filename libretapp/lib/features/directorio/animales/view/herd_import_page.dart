import 'package:flutter/material.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/herd_import_service.dart';

class HerdImportPage extends StatefulWidget {
  const HerdImportPage({super.key, this.service, this.initialDocument});
  final HerdImportService? service;
  final HerdImportDocument? initialDocument;

  @override
  State<HerdImportPage> createState() => _HerdImportPageState();
}

class _HerdImportPageState extends State<HerdImportPage> {
  late final HerdImportService _service;
  HerdImportDocument? _document;
  Map<HerdImportField, int> _mapping = {};
  HerdImportPreview? _preview;
  Map<int, HerdImportAction> _actions = {};
  HerdImportSummary? _summary;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? locator<HerdImportService>();
    final initial = widget.initialDocument;
    if (initial != null) {
      _document = initial;
      _mapping = _service.detectMapping(initial);
    }
  }

  Future<void> _pick() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final document = await _service.pickDocument();
      if (!mounted || document == null) return;
      setState(() {
        _document = document;
        _mapping = _service.detectMapping(document);
        _preview = null;
        _actions = {};
        _summary = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refresh() async {
    if (_busy || _document == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final preview = await _service.preview(_document!, mapping: _mapping);
      if (mounted)
        setState(() {
          _preview = preview;
          _actions = preview.defaultActions;
        });
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _commit() async {
    final preview = _preview;
    if (_busy || preview == null) return;
    final created = _actions.values
        .where((a) => a == HerdImportAction.create)
        .length;
    final updated = _actions.values
        .where((a) => a == HerdImportAction.update)
        .length;
    if (created + updated == 0) return;
    final skipped = preview.rows.length - created - updated;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar importación'),
        content: Text(
          'Se crearán $created animales y se actualizarán $updated.\n\n'
          'Se omitirán $skipped filas. Los campos vacíos conservan los datos existentes. '
          'Las fotografías, la genealogía y el historial se conservan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Revisar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar importación'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final summary = await _service.commit(preview, Map.of(_actions));
      if (mounted) setState(() => _summary = summary);
    } catch (error) {
      if (mounted) {
        final message = _message(error);
        setState(() => _error = message);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _message(Object error) => switch (error) {
    FormatException() => error.message,
    StateError() => '${error.message}',
    _ =>
      'No se pudo completar la operación. El hato no se ha importado; vuelve a intentarlo.',
  };

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    final document = _document;
    final summary = _summary;
    final selected = _actions.values
        .where((a) => a != HerdImportAction.skip)
        .length;
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Importar hato')),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: summary != null
                ? ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Icon(Icons.check_circle_outline, size: 56),
                      const SizedBox(height: 12),
                      Text(
                        'Importación completada',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${summary.created} animales nuevos\n${summary.updated} actualizados\n${summary.skipped} filas omitidas',
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Los animales quedaron guardados en este dispositivo.',
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, summary),
                        child: const Text('Finalizar'),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      const Text(
                        'Revisa el archivo antes de guardar. Funciona sin internet. Las coincidencias existentes se omiten hasta que elijas Actualizar.',
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _pick,
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          document == null
                              ? 'Seleccionar Excel o CSV'
                              : 'Cambiar archivo',
                        ),
                      ),
                      if (_busy)
                        const LinearProgressIndicator(
                          semanticsLabel: 'Procesando archivo',
                        ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ),
                      if (document != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          '${document.fileName} · ${document.rows.length} filas',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        ExpansionTile(
                          title: const Text('Revisar columnas'),
                          subtitle: Text('${_mapping.length} campos asignados'),
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'Asigna al menos Arete, SINIIGA o RFID. Se leen los encabezados, sin depender del orden de las columnas. Las columnas sin asignar no se importan.',
                              ),
                            ),
                            for (final field in HerdImportField.values)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: DropdownButtonFormField<int>(
                                  key: ValueKey(
                                    'mapping-${field.name}-${_mapping[field]}',
                                  ),
                                  initialValue: _mapping[field] ?? -1,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: field.label,
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: -1,
                                      child: Text('No importar'),
                                    ),
                                    for (
                                      var i = 0;
                                      i < document.headers.length;
                                      i++
                                    )
                                      DropdownMenuItem(
                                        value: i,
                                        child: Text(
                                          '${i + 1}. ${document.headers[i].isEmpty ? 'Sin encabezado' : document.headers[i]}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                  onChanged: _busy
                                      ? null
                                      : (value) => setState(() {
                                          if (value == null || value < 0) {
                                            _mapping.remove(field);
                                          } else {
                                            _mapping.removeWhere(
                                              (key, column) => column == value,
                                            );
                                            _mapping[field] = value;
                                          }
                                          _preview = null;
                                          _actions = {};
                                          _error = null;
                                        }),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _refresh,
                          icon: const Icon(Icons.preview_outlined),
                          label: Text(
                            preview == null
                                ? 'Generar vista previa'
                                : 'Actualizar vista previa',
                          ),
                        ),
                      ],
                      if (preview != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          '${preview.newCount} nuevos · ${preview.existingCount} coincidencias · ${preview.invalidCount} filas con errores',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Abre cada fila para revisar errores, avisos y cambios. Las filas con errores no se guardan.',
                        ),
                        for (final row in preview.rows) _row(row),
                      ],
                    ],
                  ),
          ),
        ),
        bottomNavigationBar: preview == null || _summary != null
            ? null
            : SafeArea(
                minimum: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: _busy || selected == 0 ? null : _commit,
                  icon: const Icon(Icons.save_outlined),
                  label: Text('Importar $selected filas seleccionadas'),
                ),
              ),
      ),
    );
  }

  Widget _row(HerdImportPreviewRow row) => Card(
    child: ExpansionTile(
      key: ValueKey('preview-row-${row.number}'),
      title: Text('Fila ${row.number} · ${row.tag}'),
      subtitle: Text(
        !row.isValid
            ? row.errors.join('\n')
            : row.isExisting
            ? 'Coincidencia: ${row.changes.length} cambios propuestos'
            : 'Animal nuevo',
      ),
      trailing: !row.isValid
          ? const Icon(Icons.error_outline)
          : DropdownButton<HerdImportAction>(
              key: ValueKey('import-action-${row.number}'),
              value: _actions[row.number],
              items: [
                DropdownMenuItem(
                  value: row.isExisting
                      ? HerdImportAction.update
                      : HerdImportAction.create,
                  child: Text(row.isExisting ? 'Actualizar' : 'Crear'),
                ),
                const DropdownMenuItem(
                  value: HerdImportAction.skip,
                  child: Text('Omitir'),
                ),
              ],
              onChanged: _busy
                  ? null
                  : (value) {
                      if (value != null)
                        setState(() => _actions[row.number] = value);
                    },
            ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final warning in row.warnings)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('Aviso: $warning'),
                  ),
                if (!row.isExisting)
                  for (final entry in row.values.entries.where(
                    (e) => e.value.isNotEmpty,
                  ))
                    Text('${entry.key.label}: ${entry.value}'),
                if (row.isExisting && row.changes.isEmpty)
                  const Text('No hay cambios en los campos importados.'),
                for (final change in row.changes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${change.field}: ${change.before} → ${change.after}',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
