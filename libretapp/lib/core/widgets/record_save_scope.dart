/// Keeps record forms open until their data has been persisted.
library;

import 'package:flutter/material.dart';

void submitRecordForm<T>(BuildContext context, T result) {
  final scope = context.findAncestorStateOfType<_RecordSaveScopeState>();
  if (scope == null) {
    Navigator.of(context).pop(result);
  } else {
    scope.save(result as Object);
  }
}

class RecordSaveScope extends StatefulWidget {
  const RecordSaveScope({super.key, required this.onSave, required this.child});
  final Future<void> Function(Object) onSave;
  final Widget child;
  @override
  State<RecordSaveScope> createState() => _RecordSaveScopeState();
}

class _RecordSaveScopeState extends State<RecordSaveScope> {
  bool _saving = false;
  String? _error;

  Future<void> save(Object result) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(result);
      if (mounted) Navigator.of(context).pop(result);
    } catch (_) {
      if (mounted)
        setState(
          () => _error =
              'No se pudo guardar. Tus datos siguen aquí; vuelve a intentarlo.',
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_saving) const LinearProgressIndicator(semanticsLabel: 'Guardando'),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        Flexible(
          child: AbsorbPointer(absorbing: _saving, child: widget.child),
        ),
      ],
    ),
  );
}
