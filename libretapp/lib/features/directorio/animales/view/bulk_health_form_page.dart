/// features › directorio › animales › view › bulk_health_form_page —
/// Full-screen form for applying a health record to multiple animals at once.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/widgets/record_form_scaffold.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class BulkHealthFormPage extends StatefulWidget {
  const BulkHealthFormPage({
    super.key,
    required this.selectedCount,
    required this.onSubmit,
  });

  final int selectedCount;
  final Future<bool> Function(HealthRecord record) onSubmit;

  @override
  State<BulkHealthFormPage> createState() => _BulkHealthFormPageState();
}

class _BulkHealthFormPageState extends State<BulkHealthFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _doseController = TextEditingController();
  final _appliedByController = TextEditingController();
  final _causeController = TextEditingController();
  final _notesController = TextEditingController();

  HealthRecordType _type = HealthRecordType.vaccine;
  DateTime _date = DateTime.now();
  DateTime? _nextDate;
  bool _saving = false;

  @override
  void dispose() {
    _productController.dispose();
    _doseController.dispose();
    _appliedByController.dispose();
    _causeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);

    final record = HealthRecord(
      date: _date,
      type: _type,
      product: _productController.text.trim(),
      dose: _doseController.text.trim().isEmpty
          ? null
          : _doseController.text.trim(),
      appliedBy: _appliedByController.text.trim().isEmpty
          ? null
          : _appliedByController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      nextDueDate: _nextDate,
      cause: _causeController.text.trim().isEmpty
          ? null
          : _causeController.text.trim(),
    );

    final ok = await widget.onSubmit(record);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RecordFormScaffold(
      title: l10n.animalsBulkMaintenanceAction(widget.selectedCount),
      saving: _saving,
      onSave: _submit,
      saveLabel: l10n.actionSave,
      formKey: _formKey,
      fields: [
        DropdownButtonFormField<HealthRecordType>(
          initialValue: _type,
          decoration: InputDecoration(
            labelText: l10n.detailFormHealthType,
            border: const OutlineInputBorder(),
          ),
          items: HealthRecordType.values
              .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _type = value);
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _productController,
          decoration: InputDecoration(
            labelText: l10n.detailFormHealthProduct,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.detailFormHealthProductRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _doseController,
                decoration: InputDecoration(
                  labelText: l10n.detailFormHealthDose,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _appliedByController,
                decoration: InputDecoration(
                  labelText: l10n.detailFormHealthAppliedBy,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.today),
                label: Text('${_date.year}-${_date.month}-${_date.day}'),
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
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.event_available),
                label: Text(
                  _nextDate == null
                      ? l10n.detailFormHealthNext
                      : '${_nextDate!.year}-${_nextDate!.month}-${_nextDate!.day}',
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _nextDate ?? _date,
                    firstDate: DateTime(_date.year),
                    lastDate: DateTime(_date.year + 5),
                  );
                  setState(() => _nextDate = picked);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _causeController,
          decoration: InputDecoration(
            labelText: l10n.detailFormHealthCause,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.fieldNotes,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
