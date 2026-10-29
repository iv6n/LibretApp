/// features › directorio › animales › widgets › care_tab — pending and past care tasks for an animal.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/app_card.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_rule.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/scheduled_care.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/care_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/services/care_calendar_service.dart';
import 'package:libretapp/features/directorio/animales/widgets/detail_helpers.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/app/widgets/shell_insets.dart';

/// What's due for this animal and what's already been done, driven by the
/// same [CareRule]s the Agenda reads to build its automatic reminders — this
/// tab is where the breeder closes the loop by recording that a task was
/// actually carried out.
class CareTab extends StatefulWidget {
  const CareTab({
    super.key,
    required this.data,
    required this.careRepo,
    required this.onChanged,
  });

  final DetailData data;
  final CareRepository careRepo;
  final VoidCallback onChanged;

  @override
  State<CareTab> createState() => _CareTabState();
}

class _CareTabState extends State<CareTab> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final pending = [...data.carePending]
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    final records = [...data.careRecords]
      ..sort((a, b) => b.performedAt.compareTo(a.performedAt));
    final operational = data.agendaPending
        .where((entry) => entry.actionKind != 'recordCare')
        .toList(growable: false);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        ShellInsets.bottomSafePadding(context) + 96,
      ),
      children: [
        const _SectionTitle(
          icon: Icons.work_outline,
          label: 'Próximos trabajos',
        ),
        const SizedBox(height: 8),
        if (operational.isEmpty)
          const _EmptyHint(message: 'Sin trabajos operativos programados.')
        else
          ...operational.map(_OperationalTile.new),
        const SizedBox(height: 20),
        const _SectionTitle(
          icon: Icons.event_available_outlined,
          label: 'Pendientes',
        ),
        const SizedBox(height: 8),
        if (pending.isEmpty)
          const _EmptyHint(
            message:
                'Sin tareas pendientes. Las reglas de vacunación, '
                'desparasitación y demás se aplican según especie, sexo y '
                'edad del animal.',
          )
        else
          ...pending.map(
            (task) => _PendingTile(
              task: task,
              rule: data.careRules[task.ruleId],
              busy: _busy || !data.animal.status.isInActiveHerd,
              onRegister: () => _registerCare(task),
            ),
          ),
        const SizedBox(height: 20),
        _SectionTitle(
          icon: Icons.history_outlined,
          label: 'Historial (${records.length})',
        ),
        const SizedBox(height: 8),
        if (records.isEmpty)
          const _EmptyHint(message: 'Aún no se ha registrado ningún cuidado.')
        else
          ...records.map(
            (record) => _RecordTile(
              record: record,
              rule: data.careRules[record.ruleId],
            ),
          ),
      ],
    );
  }

  Future<void> _registerCare(ScheduledCare task) async {
    final title =
        widget.data.careRules[task.ruleId]?.name ?? task.type.displayName;
    if (_busy || !widget.data.animal.status.isInActiveHerd) return;
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RegisterCareDialog(
        title: title,
        onSave: (result) async {
          setState(() => _busy = true);
          try {
            await widget.careRepo.saveRecord(
              CareRecord(
                id: '${widget.data.animal.uuid}_${task.ruleId}_${result.date.millisecondsSinceEpoch}',
                animalId: widget.data.animal.uuid,
                ruleId: task.ruleId,
                type: task.type,
                performedAt: result.date,
                notes: result.notes,
              ),
            );
          } finally {
            if (mounted) setState(() => _busy = false);
          }
        },
      ),
    );
    if (!mounted || saved != true) return;
    // Rebuild projections after the record is committed. Failure here must
    // not ask the user to submit a record that was already saved.
    try {
      await CareCalendarService(
        widget.careRepo,
      ).regenerateFor(widget.data.animal, now: DateTime.now());
      // The widget is also used in isolated flows (for example during local
      // draft capture and tests) where the global agenda coordinator is not
      // installed. Saving the care record must not fail just because the
      // optional agenda bridge is unavailable.
      if (locator.isRegistered<AgendaReminderSyncService>()) {
        await locator<AgendaReminderSyncService>().sync();
      }
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'El cuidado está guardado; no se pudo actualizar la agenda.',
            ),
          ),
        );
    } finally {
      if (mounted) widget.onChanged();
    }
  }
}

class _OperationalTile extends StatelessWidget {
  const _OperationalTile(this.entry);

  final AgendaEntry entry;

  @override
  Widget build(BuildContext context) {
    final overdue = entry.fecha.isBefore(DateTime.now());
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          overdue ? Icons.warning_amber_rounded : Icons.event_available,
          color: overdue
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
        ),
        title: Text(entry.titulo),
        subtitle: Text(
          '${DateFormat('dd/MM/yyyy').format(entry.fecha)} · ${entry.tipo}',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _CareEntryResult {
  const _CareEntryResult({required this.date, this.notes});
  final DateTime date;
  final String? notes;
}

class _RegisterCareDialog extends StatefulWidget {
  const _RegisterCareDialog({required this.title, required this.onSave});
  final Future<void> Function(_CareEntryResult) onSave;
  final String title;

  @override
  State<_RegisterCareDialog> createState() => _RegisterCareDialogState();
}

class _RegisterCareDialogState extends State<_RegisterCareDialog> {
  DateTime _date = DateTime.now();
  bool _saving = false;
  String? _error;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        scrollable: true,
        title: Text('Registrar: ${widget.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.today),
              label: Text(DateFormat('dd/MM/yyyy').format(_date)),
              onPressed: _saving
                  ? null
                  : () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(_date.year - 5),
                        lastDate: DateTime(_date.year + 1),
                      );
                      if (picked == null) return;
                      setState(() => _date = picked);
                    },
            ),
            const SizedBox(height: 12),
            TextField(
              enabled: !_saving,
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: _saving
                ? null
                : () async {
                    setState(() {
                      _saving = true;
                      _error = null;
                    });
                    try {
                      await widget.onSave(
                        _CareEntryResult(
                          date: _date,
                          notes: _notesController.text.trim().isEmpty
                              ? null
                              : _notesController.text.trim(),
                        ),
                      );
                      if (context.mounted) Navigator.of(context).pop(true);
                    } catch (_) {
                      if (mounted)
                        setState(
                          () => _error =
                              'No se pudo guardar. Tus notas se conservan; intenta de nuevo.',
                        );
                    } finally {
                      if (mounted) setState(() => _saving = false);
                    }
                  },
            child: Text(_saving ? 'Guardando…' : 'Guardar'),
          ),
        ],
      ),
    );
  }
}

class _PendingTile extends StatelessWidget {
  const _PendingTile({
    required this.task,
    required this.rule,
    required this.busy,
    required this.onRegister,
  });

  final ScheduledCare task;
  final CareRule? rule;
  final bool busy;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final overdue = task.dueAt.isBefore(DateTime(now.year, now.month, now.day));
    final label = rule?.name ?? task.type.displayName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        leading: Icon(
          overdue ? Icons.warning_amber_rounded : Icons.schedule,
          color: overdue ? theme.colorScheme.error : theme.colorScheme.primary,
        ),
        title: label,
        subtitle: overdue
            ? 'Vencido — ${formatDate(task.dueAt)}'
            : 'Programado — ${formatDate(task.dueAt)}',
        body: Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: FilledButton.tonal(
              onPressed: busy ? null : onRegister,
              child: const Text('Registrar'),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record, required this.rule});

  final CareRecord record;
  final CareRule? rule;

  @override
  Widget build(BuildContext context) {
    final label = rule?.name ?? record.type.displayName;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          [
            formatDate(record.performedAt),
            if (record.notes != null && record.notes!.isNotEmpty) record.notes!,
          ].join(' · '),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
