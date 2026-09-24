/// features › directorio › animales › view › bulk_health_form_page —
/// Full-screen form for applying a health record to multiple animals at once.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/theme.dart';

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
    return AppFormScaffold(
      title: l10n.animalsBulkMaintenanceAction(widget.selectedCount),
      saving: _saving,
      onSave: _submit,
      saveLabel: l10n.actionSave,
      formKey: _formKey,
      fields: [
        AppSelectField<HealthRecordType>(
          value: _type,
          items: HealthRecordType.values,
          itemLabel: (type) => type.displayName,
          labelText: l10n.detailFormHealthType,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _type = value);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _productController,
          labelText: l10n.detailFormHealthProduct,
          requiredField: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.detailFormHealthProductRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _doseController,
          labelText: l10n.detailFormHealthDose,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _appliedByController,
          labelText: l10n.detailFormHealthAppliedBy,
        ),
        const SizedBox(height: AppSpacing.md),
        AppDateField(
          value: _date,
          labelText: l10n.fieldDate,
          firstDate: DateTime(_date.year - 5),
          lastDate: DateTime(_date.year + 1),
          onChanged: (value) {
            if (value != null) setState(() => _date = value);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppDateField(
          value: _nextDate,
          labelText: l10n.detailFormHealthNext,
          emptyLabel: l10n.detailFormHealthNext,
          clearTooltip: l10n.actionClearDate,
          firstDate: _date,
          lastDate: DateTime(_date.year + 5),
          allowClear: true,
          validator: (value) => value != null && value.isBefore(_date)
              ? l10n.detailFormHealthNextAfterDate
              : null,
          onChanged: (value) => setState(() => _nextDate = value),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _causeController,
          labelText: l10n.detailFormHealthCause,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _notesController,
          maxLines: 3,
          labelText: l10n.fieldNotes,
        ),
      ],
    );
  }
}
