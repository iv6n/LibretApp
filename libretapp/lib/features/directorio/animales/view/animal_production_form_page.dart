/// features > directorio > animales > view > animal_production_form_page — full-screen production record form.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/assets/app_asset_paths.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/record_form_scaffold.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_record_assets.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/editable_record_repository.dart';

class AnimalProductionFormPage extends StatefulWidget {
  const AnimalProductionFormPage({
    required this.animalUuid,
    this.recordId,
    super.key,
  });

  final String animalUuid;

  /// Id of the record being corrected, or null to add a new one.
  final String? recordId;

  bool get isEditing => recordId != null;

  @override
  State<AnimalProductionFormPage> createState() =>
      _AnimalProductionFormPageState();
}

class _AnimalProductionFormPageState extends State<AnimalProductionFormPage> {
  late final TextEditingController _valueController;
  late final TextEditingController _unitController;
  late final TextEditingController _scoreController;
  late final TextEditingController _notesController;

  ProductionRecordType _type = ProductionRecordType.weighing;
  DateTime _date = DateTime.now();
  bool _saving = false;
  bool _loading = false;
  ProductionRecord? _editing;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController();
    _unitController = TextEditingController();
    _scoreController = TextEditingController();
    _notesController = TextEditingController();
    if (widget.isEditing) _load();
  }

  /// Hydrates the form from the record being corrected.
  Future<void> _load() async {
    setState(() => _loading = true);
    final records = await locator<ProductionRecordRepository>()
        .getProductionRecords(widget.animalUuid);
    if (!mounted) return;

    final record = records
        .where((candidate) => candidate.id == widget.recordId)
        .firstOrNull;
    if (record == null) {
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
      _valueController.text = record.value?.toString() ?? '';
      _unitController.text = record.unit ?? '';
      _scoreController.text = record.score?.toString() ?? '';
      _notesController.text = record.notes ?? '';
      _type = record.type;
      _date = record.date;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _valueController.dispose();
    _unitController.dispose();
    _scoreController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || _loading || (widget.isEditing && _editing == null)) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final valueText = _valueController.text.trim();
    final scoreText = _scoreController.text.trim();

    final value = valueText.isEmpty ? null : double.tryParse(valueText);
    final score = scoreText.isEmpty ? null : int.tryParse(scoreText);

    if (valueText.isNotEmpty && value == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormProductionValueRequired)),
      );
      return;
    }
    if (scoreText.isNotEmpty && score == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormProductionScoreInvalid)),
      );
      return;
    }
    if (score != null && (score < 1 || score > 5)) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormProductionScoreRange)),
      );
      return;
    }
    if (value == null && score == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormProductionDataRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repository = locator<ProductionRecordRepository>();
      final edited = _editing;

      if (edited != null &&
          repository is EditableRecordRepository<ProductionRecord>) {
        await (repository as EditableRecordRepository<ProductionRecord>)
            .updateRecord(
              widget.animalUuid,
              ProductionRecord(
                id: edited.id,
                date: _date,
                type: _type,
                value: value,
                unit: _unitController.text.trim().isEmpty
                    ? null
                    : _unitController.text.trim(),
                score: score,
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
              ),
            );
      } else {
        await repository.addProductionRecord(
          widget.animalUuid,
          ProductionRecord(
            id: null,
            date: _date,
            type: _type,
            value: value,
            unit: _unitController.text.trim().isEmpty
                ? null
                : _unitController.text.trim(),
            score: score,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          ),
        );
      }
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            edited != null
                ? l10n.recordEditSaved
                : l10n.detailFormProductionSaved,
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
          : l10n.detailFormProductionTitle,
      saving: _saving,
      loading: _loading,
      onSave: _save,
      saveLabel: l10n.actionSave,
      assetPath:
          assetForProductionRecordType(_type) ?? AppAssetPaths.recordProduction,
      fallbackIcon: Icons.agriculture_outlined,
      fields: [
        DropdownButtonFormField<ProductionRecordType>(
          initialValue: _type,
          decoration: InputDecoration(
            labelText: l10n.detailFormProductionType,
            border: const OutlineInputBorder(),
          ),
          items: ProductionRecordType.values
              .map(
                (t) => DropdownMenuItem(value: t, child: Text(t.displayName)),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _type = value);
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.event),
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
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.detailFormProductionValue,
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
              child: TextField(
                controller: _unitController,
                decoration: InputDecoration(
                  labelText: l10n.detailFormProductionUnit,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _scoreController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.detailFormProductionScore,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: l10n.fieldNotes,
            border: const OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}
