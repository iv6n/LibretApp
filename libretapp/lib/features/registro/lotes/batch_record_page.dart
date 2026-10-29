import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/registro/lotes/batch_record_service.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class BatchRecordPage extends StatefulWidget {
  const BatchRecordPage({
    super.key,
    this.initialLotUuid,
    this.service,
    this.lots,
    this.locations,
  });
  final String? initialLotUuid;
  final BatchRecordService? service;
  final LotesRepository? lots;
  final LocationRepository? locations;

  @override
  State<BatchRecordPage> createState() => _BatchRecordPageState();
}

class _BatchRecordPageState extends State<BatchRecordPage> {
  BatchRecordService? _service;
  List<LoteEntity> _lots = [];
  List<LocationEntity> _locations = [];
  Map<String, String> _locationNames = {};
  List<BatchRecordSession> _sessions = [];
  BatchRecordSession? _session;
  BatchRecordKind _kind = BatchRecordKind.weight;
  String? _lotUuid;
  bool _loading = true;
  bool _busy = false;
  String? _error;
  String? _draftError;
  int _pendingWrites = 0;
  int _persistedVersion = 0;
  Future<void> _pending = Future.value();

  @override
  void initState() {
    super.initState();
    _lotUuid = widget.initialLotUuid;
    _service =
        widget.service ??
        (locator.isRegistered<BatchRecordService>()
            ? locator<BatchRecordService>()
            : null);
    if (_service != null)
      _reload();
    else
      _loading = false;
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait<Object>([
        (widget.lots ?? locator<LotesRepository>()).getAll(),
        (widget.locations ?? locator<LocationRepository>()).getAll(),
        _service!.list(),
      ]);
      if (!mounted) return;
      setState(() {
        _lots = (results[0] as List<LoteEntity>)
            .where((l) => l.active)
            .toList();
        final allLocations = results[1] as List<LocationEntity>;
        _locationNames = {
          for (final location in allLocations) location.uuid: location.name,
        };
        _locations = allLocations
            .where((l) => l.status != LocationStatus.closed)
            .toList();
        _sessions = results[2] as List<BatchRecordSession>;
        if (!_lots.any((l) => l.uuid == _lotUuid)) _lotUuid = null;
        _session = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _edit(BatchRecordSession session) => setState(() {
    _session = session;
    _persistedVersion = session.version;
    _error = null;
    _draftError = null;
  });

  Future<void> _start() async {
    if (_busy || _lotUuid == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = await _service!.start(lotUuid: _lotUuid!, kind: _kind);
      if (mounted) _edit(session);
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _change(BatchRecordSession draft) {
    if (_busy || draft.isCompleted) return;
    setState(() {
      _session = draft;
      _pendingWrites++;
      _draftError = null;
      _error = null;
    });
    // Save in keystroke order. Subsequent snapshots also contain prior edits,
    // and keep raw invalid input so the user can correct it after reopening.
    _pending = _pending.then((_) async {
      try {
        final saved = await _service!.saveDraft(
          draft,
          expectedVersion: _persistedVersion,
        );
        _persistedVersion = saved.version;
        if (mounted) setState(() => _draftError = null);
      } catch (error) {
        if (mounted) setState(() => _draftError = _message(error));
      } finally {
        if (mounted) setState(() => _pendingWrites--);
      }
    });
  }

  Future<void> _backToList() async {
    await _pending;
    if (!mounted || _busy || _draftError != null) return;
    await _reload();
  }

  Future<void> _open(String uuid) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = await _service!.open(uuid);
      if (mounted) _edit(session);
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _discard(BatchRecordSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar captura'),
        content: const Text(
          'Se eliminará este borrador. No se ha aplicado ningún registro a los animales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Conservar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await _service!.discard(session.uuid);
      await _reload();
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _complete() async {
    if (_busy || _session == null) return;
    await _pending;
    if (!mounted || _draftError != null) return;
    final session = _session!;
    final count = session.included.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar registro por lote'),
        content: Text(
          'Se guardará ${session.kind.label.toLowerCase()} para $count animales. '
          '${session.participants.length - count} quedarán sin registro en esta sesión.\n\n'
          'Los registros se guardan juntos en este dispositivo, sin internet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Revisar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar registros'),
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
      final saved = await _service!.complete(
        session.uuid,
        expectedVersion: _persistedVersion,
      );
      if (mounted) _edit(saved);
      if (locator.isRegistered<AgendaReminderSyncService>()) {
        try {
          await locator<AgendaReminderSyncService>().sync();
        } catch (_) {
          if (mounted)
            setState(
              () => _error =
                  'Los registros quedaron guardados. No se pudo actualizar la agenda; vuelve a abrirla para reintentar.',
            );
        }
      }
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
    StateError() => '${error.message}',
    ArgumentError() => '${error.message}',
    _ => 'No se pudo guardar. La captura sigue aquí; vuelve a intentarlo.',
  };
  static String _date(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
  static String _dateTime(DateTime date) =>
      DateFormat('dd/MM/yyyy · HH:mm').format(date.toLocal());

  String _destinationName(BatchRecordSession session) {
    final destinationId = session.destinationId;
    if (destinationId == null) return 'Sin destino';
    return _locationNames[destinationId] ?? 'Ubicación no disponible';
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final writing = _pendingWrites > 0;
    return PopScope(
      canPop: !_busy && !writing && _draftError == null,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _busy) return;
        await _pending;
        if (mounted && _draftError == null) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registro por lotes'),
          actions: [
            if (session != null)
              IconButton(
                tooltip: 'Volver a sesiones',
                onPressed: _busy || writing || _draftError != null
                    ? null
                    : _backToList,
                icon: const Icon(Icons.list_alt),
              ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      if (_service == null)
                        const Text(
                          'No se pudo abrir el almacenamiento de las sesiones. Vuelve a abrir tu espacio de trabajo.',
                        ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
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
                      if (_service != null && session == null)
                        ..._sessionList(),
                      if (session != null && session.isCompleted) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 36,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sesión completada',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${session.kind.label} · ${session.lotName}',
                                ),
                                Text(
                                  '${session.savedCount} registros guardados en este dispositivo',
                                ),
                                Text(
                                  'Confirmada ${_dateTime(session.completedAt!)}',
                                ),
                                if (session.responsible.trim().isNotEmpty)
                                  Text(
                                    'Responsable: ${session.responsible.trim()}',
                                  ),
                                if (session.kind == BatchRecordKind.health)
                                  Text(
                                    '${session.healthType.displayName}${session.product.trim().isEmpty ? '' : ' · ${session.product.trim()}'}',
                                  ),
                                if (session.kind == BatchRecordKind.movement)
                                  Text(
                                    'Destino: ${_destinationName(session)} · ${session.reason.displayName}',
                                  ),
                                if (session.notes.trim().isNotEmpty)
                                  Text('Notas: ${session.notes.trim()}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Animales incluidos en esta sesión'),
                        for (final member in session.included)
                          ListTile(
                            title: Text(
                              member.name?.trim().isNotEmpty == true
                                  ? '${member.name!.trim()} · ${member.tag}'
                                  : member.tag,
                            ),
                          ),
                        FilledButton(
                          onPressed: _backToList,
                          child: const Text('Volver a sesiones'),
                        ),
                      ],
                      if (session != null && !session.isCompleted)
                        ..._editor(session),
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: session == null || session.isCompleted
            ? null
            : SafeArea(
                minimum: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_draftError != null) ...[
                      Semantics(
                        liveRegion: true,
                        child: const Text('Hay cambios sin guardar'),
                      ),
                      TextButton(
                        onPressed: _busy || writing
                            ? null
                            : () => _change(session),
                        child: const Text('Reintentar guardado'),
                      ),
                    ],
                    FilledButton.icon(
                      onPressed:
                          _busy ||
                              writing ||
                              _draftError != null ||
                              session.included.isEmpty
                          ? null
                          : _complete,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(
                        'Revisar ${session.included.length} registros',
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  List<Widget> _sessionList() {
    final drafts = _sessions.where((session) => !session.isCompleted).toList();
    final completed = _sessions
        .where((session) => session.isCompleted)
        .toList();
    return [
      const Text(
        'Captura sin conexión. Cada cambio se guarda como borrador; confirmar aplica los registros juntos.',
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        key: ValueKey('batch-lot-$_lotUuid'),
        initialValue: _lotUuid,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Lote'),
        items: [
          for (final lot in _lots)
            DropdownMenuItem(
              value: lot.uuid,
              child: Text(lot.name, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: _busy ? null : (value) => setState(() => _lotUuid = value),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<BatchRecordKind>(
        initialValue: _kind,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Actividad'),
        items: [
          for (final kind in BatchRecordKind.values)
            DropdownMenuItem(value: kind, child: Text(kind.label)),
        ],
        onChanged: _busy
            ? null
            : (value) {
                if (value != null) setState(() => _kind = value);
              },
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: _busy || _lotUuid == null ? null : _start,
        icon: const Icon(Icons.add),
        label: const Text('Iniciar sesión'),
      ),
      if (_lots.isEmpty)
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Crea un lote y asígnale animales para iniciar una sesión.',
          ),
        ),
      const SizedBox(height: 24),
      Text('Sesiones guardadas', style: Theme.of(context).textTheme.titleLarge),
      if (_sessions.isEmpty)
        const Text('Aquí aparecerán tus capturas pendientes y completadas.'),
      if (drafts.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            'Borradores · ${drafts.length}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      for (final saved in drafts) _sessionTile(saved),
      if (completed.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            'Completadas · ${completed.length}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      for (final saved in completed) _sessionTile(saved),
      if (_error != null)
        TextButton(
          onPressed: _busy ? null : _reload,
          child: const Text('Reintentar carga'),
        ),
    ];
  }

  Widget _sessionTile(BatchRecordSession saved) => Card(
    child: ListTile(
      leading: Icon(
        saved.isCompleted ? Icons.check_circle_outline : Icons.edit_note,
      ),
      title: Text('${saved.kind.label} · ${saved.lotName}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${saved.isCompleted ? 'Completada' : 'Borrador'} · ${_dateTime(saved.completedAt ?? saved.createdAt)} · ${saved.isCompleted ? '${saved.savedCount} guardados' : '${saved.included.length} animales incluidos'}',
          ),
          if (saved.responsible.trim().isNotEmpty)
            Text('Responsable: ${saved.responsible.trim()}'),
          if (saved.kind == BatchRecordKind.movement &&
              saved.destinationId != null)
            Text('Destino: ${_destinationName(saved)}'),
          if (saved.notes.trim().isNotEmpty)
            Text(
              saved.notes.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      onTap: _busy ? null : () => _open(saved.uuid),
      trailing: saved.isCompleted
          ? null
          : IconButton(
              tooltip: 'Descartar borrador',
              onPressed: _busy ? null : () => _discard(saved),
              icon: const Icon(Icons.delete_outline),
            ),
    ),
  );

  List<Widget> _editor(BatchRecordSession session) => [
    Text(
      '${session.kind.label} · ${session.lotName}',
      style: Theme.of(context).textTheme.titleLarge,
    ),
    const SizedBox(height: 8),
    Semantics(
      liveRegion: true,
      child: Text(
        _pendingWrites > 0
            ? 'Guardando captura…'
            : _draftError == null
            ? 'Borrador guardado en este dispositivo · Sin internet'
            : 'Error al guardar la captura',
        style: TextStyle(
          color: _draftError == null
              ? null
              : Theme.of(context).colorScheme.error,
        ),
      ),
    ),
    if (_draftError != null) ...[
      Text(_draftError!),
      OutlinedButton(
        onPressed: _busy || _pendingWrites > 0 ? null : () => _change(session),
        child: const Text('Volver a guardar captura'),
      ),
    ],
    const SizedBox(height: 8),
    OutlinedButton.icon(
      onPressed: _busy
          ? null
          : () async {
              final now = DateTime.now();
              final date = await showDatePicker(
                context: context,
                initialDate: session.date.isAfter(now) ? now : session.date,
                firstDate: DateTime(1900),
                lastDate: now,
              );
              if (date != null && mounted) {
                final previous = _session!.date;
                _change(
                  _session!.copyWith(
                    date: DateTime(
                      date.year,
                      date.month,
                      date.day,
                      previous.hour,
                      previous.minute,
                      previous.second,
                      previous.millisecond,
                      previous.microsecond,
                    ),
                  ),
                );
              }
            },
      icon: const Icon(Icons.calendar_today_outlined),
      label: Text('Fecha: ${_date(session.date)}'),
    ),
    const SizedBox(height: 12),
    _text(
      session,
      'responsible',
      'Responsable',
      session.responsible,
      (v) => _session!.copyWith(responsible: v),
    ),
    if (session.kind == BatchRecordKind.health) ...[
      const SizedBox(height: 12),
      DropdownButtonFormField<HealthRecordType>(
        key: ValueKey('${session.uuid}-health-type'),
        initialValue: session.healthType,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Tipo de registro sanitario',
        ),
        items: [
          for (final type in HealthRecordType.values.where(
            (t) => t != HealthRecordType.death,
          ))
            DropdownMenuItem(value: type, child: Text(type.displayName)),
        ],
        onChanged: _busy
            ? null
            : (value) {
                if (value != null)
                  _change(_session!.copyWith(healthType: value));
              },
      ),
      const SizedBox(height: 12),
      _text(
        session,
        'product',
        'Producto',
        session.product,
        (v) => _session!.copyWith(product: v),
      ),
      const SizedBox(height: 12),
      _text(
        session,
        'dose',
        'Dosis aplicada',
        session.dose,
        (v) => _session!.copyWith(dose: v),
      ),
      const SizedBox(height: 12),
      _text(
        session,
        'medicineBatch',
        'Lote del medicamento',
        session.medicineBatch,
        (v) => _session!.copyWith(medicineBatch: v),
      ),
      const SizedBox(height: 12),
      _text(
        session,
        'withdrawal',
        'Días de retiro',
        session.withdrawalDays,
        (v) => _session!.copyWith(withdrawalDays: v),
        number: true,
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          OutlinedButton(
            onPressed: _busy
                ? null
                : () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: session.nextDueDate ?? session.date,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (date != null && mounted)
                      _change(_session!.copyWith(nextDueDate: date));
                  },
            child: Text(
              session.nextDueDate == null
                  ? 'Programar próxima aplicación'
                  : 'Próxima: ${_date(session.nextDueDate!)}',
            ),
          ),
          if (session.nextDueDate != null)
            TextButton(
              onPressed: _busy
                  ? null
                  : () => _change(_session!.copyWith(clearNextDueDate: true)),
              child: const Text('Quitar fecha'),
            ),
        ],
      ),
    ],
    if (session.kind == BatchRecordKind.movement) ...[
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        key: ValueKey('${session.uuid}-destination'),
        initialValue: _locations.any((l) => l.uuid == session.destinationId)
            ? session.destinationId
            : null,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Ubicación de destino'),
        items: [
          for (final location in _locations)
            DropdownMenuItem(
              value: location.uuid,
              child: Text(location.name, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: _busy
            ? null
            : (value) => _change(_session!.copyWith(destinationId: value)),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<MovementReason>(
        key: ValueKey('${session.uuid}-reason'),
        initialValue: session.reason,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Motivo'),
        items: [
          for (final reason in MovementReason.values)
            DropdownMenuItem(value: reason, child: Text(reason.displayName)),
        ],
        onChanged: _busy
            ? null
            : (value) {
                if (value != null) _change(_session!.copyWith(reason: value));
              },
      ),
    ],
    const SizedBox(height: 12),
    _text(
      session,
      'notes',
      'Notas',
      session.notes,
      (v) => _session!.copyWith(notes: v),
    ),
    const SizedBox(height: 20),
    Text(
      '${session.included.length} con datos · ${session.participants.length - session.included.length} sin registro',
      style: Theme.of(context).textTheme.titleMedium,
    ),
    const Text(
      'Los integrantes corresponden al inicio de la sesión. Puedes omitir animales; los pesos vacíos no se aplican.',
    ),
    for (final member in session.participants)
      Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: !session.skipped.contains(member.uuid),
                title: Text(member.tag),
                subtitle: member.name == null ? null : Text(member.name!),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: _busy
                    ? null
                    : (selected) {
                        final skipped = {..._session!.skipped};
                        if (selected == true)
                          skipped.remove(member.uuid);
                        else
                          skipped.add(member.uuid);
                        _change(_session!.copyWith(skipped: skipped));
                      },
              ),
              if (session.kind == BatchRecordKind.weight)
                _text(
                  session,
                  'weight-${member.uuid}',
                  'Peso de ${member.tag} (kg)',
                  session.weights[member.uuid] ?? '',
                  (v) => _session!.copyWith(
                    weights: {..._session!.weights, member.uuid: v},
                  ),
                  number: true,
                  enabled: !session.skipped.contains(member.uuid),
                ),
            ],
          ),
        ),
      ),
  ];

  Widget _text(
    BatchRecordSession session,
    String key,
    String label,
    String initial,
    BatchRecordSession Function(String) update, {
    bool number = false,
    bool enabled = true,
  }) => TextFormField(
    key: ValueKey('${session.uuid}-$key'),
    initialValue: initial,
    enabled: enabled && !_busy,
    decoration: InputDecoration(labelText: label),
    keyboardType: number
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.text,
    onChanged: (value) => _change(update(value)),
  );
}
