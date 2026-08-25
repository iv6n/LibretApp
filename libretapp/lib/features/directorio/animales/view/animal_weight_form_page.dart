/// features > directorio > animales > view > animal_weight_form_page — full-screen weight record form.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/assets/app_asset_paths.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/editable_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/record_form_scaffold.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class AnimalWeightFormPage extends StatefulWidget {
  const AnimalWeightFormPage({
    required this.animalUuid,
    this.recordId,
    super.key,
  });

  final String animalUuid;

  /// Id of the weighing being corrected, or null to add a new one.
  final String? recordId;

  bool get isEditing => recordId != null;

  @override
  State<AnimalWeightFormPage> createState() => _AnimalWeightFormPageState();
}

class _AnimalWeightFormPageState extends State<AnimalWeightFormPage> {
  late final TextEditingController _weightController;
  late final TextEditingController _notesController;

  WeightMethod _method = WeightMethod.scale;
  DateTime _date = DateTime.now();
  bool _saving = false;
  bool _loading = false;
  WeightRecord? _editing;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _notesController = TextEditingController();
    if (widget.isEditing) _load();
  }

  /// Hydrates the form from the record being corrected.
  Future<void> _load() async {
    setState(() => _loading = true);
    final records = await locator<WeightRecordRepository>().getWeightRecords(
      widget.animalUuid,
    );
    if (!mounted) return;

    final record = records
        .where((candidate) => candidate.id == widget.recordId)
        .firstOrNull;
    if (record == null) {
      // Deleted from another screen while this one was opening.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).recordEditNotFound),
        ),
      );
      context.pop(false);
      return;
    }

    setState(() {
      _editing = record;
      _weightController.text = record.weight.toString();
      _notesController.text = record.notes ?? '';
      _method = record.method;
      _date = record.date;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || _loading || (widget.isEditing && _editing == null)) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final parsed = double.tryParse(_weightController.text.trim());
    if (parsed == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormWeightErrorInvalid)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final notes = _notesController.text.trim();
      final repository = locator<WeightRecordRepository>();
      final edited = _editing;

      if (edited != null &&
          repository is EditableRecordRepository<WeightRecord>) {
        await (repository as EditableRecordRepository<WeightRecord>)
            .updateRecord(
              widget.animalUuid,
              WeightRecord(
                id: edited.id,
                date: _date,
                weight: parsed,
                method: _method,
                notes: notes.isEmpty ? null : notes,
                measuredBy: edited.measuredBy,
                recordUuid: edited.recordUuid,
                updatedAt: edited.updatedAt,
              ),
            );
      } else {
        await repository.addWeightRecord(
          widget.animalUuid,
          WeightRecord(
            id: null,
            date: _date,
            weight: parsed,
            method: _method,
            notes: notes.isEmpty ? null : notes,
          ),
        );
      }
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            edited != null ? l10n.recordEditSaved : l10n.detailFormWeightSaved,
          ),
        ),
      );
      context.pop(true);
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGenericSave)));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return RecordFormScaffold(
      title: widget.isEditing
          ? l10n.recordEditTitle
          : l10n.detailFormWeightTitle,
      saving: _saving,
      loading: _loading,
      onSave: _save,
      saveLabel: l10n.actionSave,
      assetPath: AppAssetPaths.healthWeight,
      fallbackIcon: Icons.monitor_weight_outlined,
      fields: [
        TextField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.detailFormWeightValue,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<WeightMethod>(
          initialValue: _method,
          decoration: InputDecoration(
            labelText: l10n.detailFormWeightMethod,
            border: const OutlineInputBorder(),
          ),
          items: WeightMethod.values
              .map(
                (m) => DropdownMenuItem(
                  value: m,
                  child: Text(
                    m == WeightMethod.scale
                        ? l10n.detailFormWeightMethodScale
                        : l10n.detailFormWeightMethodEstimated,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _method = value);
          },
        ),
        const SizedBox(height: 12),
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
          decoration: InputDecoration(
            labelText: l10n.fieldNotesOptional,
            border: const OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}
