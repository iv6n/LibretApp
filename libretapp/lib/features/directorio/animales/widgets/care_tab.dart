/// features › directorio › animales › widgets › care_tab — pending and past care tasks for an animal.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_rule.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/scheduled_care.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/care_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/services/care_calendar_service.dart';
import 'package:libretapp/features/directorio/animales/widgets/detail_helpers.dart';

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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
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
              busy: _busy,
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
    final result = await showDialog<_CareEntryResult>(
      context: context,
      builder: (_) => _RegisterCareDialog(title: title),
    );
    if (result == null || !mounted) return;

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
      await CareCalendarService(
        widget.careRepo,
      ).regenerateFor(widget.data.animal, now: DateTime.now());
      widget.onChanged();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _CareEntryResult {
  const _CareEntryResult({required this.date, this.notes});
  final DateTime date;
  final String? notes;
}

class _RegisterCareDialog extends StatefulWidget {
  const _RegisterCareDialog({required this.title});
  final String title;

  @override
  State<_RegisterCareDialog> createState() => _RegisterCareDialogState();
}

class _RegisterCareDialogState extends State<_RegisterCareDialog> {
  DateTime _date = DateTime.now();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Registrar: ${widget.title}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.today),
            label: Text(DateFormat('dd/MM/yyyy').format(_date)),
            onPressed: () async {
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
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notas',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            _CareEntryResult(
              date: _date,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            ),
          ),
          child: const Text('Guardar'),
        ),
      ],
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          overdue ? Icons.warning_amber_rounded : Icons.schedule,
          color: overdue ? theme.colorScheme.error : theme.colorScheme.primary,
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          overdue
              ? 'Vencido — ${formatDate(task.dueAt)}'
              : 'Programado — ${formatDate(task.dueAt)}',
        ),
        trailing: FilledButton.tonal(
          onPressed: busy ? null : onRegister,
          child: const Text('Registrar'),
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
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
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
