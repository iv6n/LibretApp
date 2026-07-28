/// features > directorio > animales > view > animal_production_form_page — full-screen production record form.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/record_form_scaffold.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class AnimalProductionFormPage extends StatefulWidget {
  const AnimalProductionFormPage({required this.animalUuid, super.key});

  final String animalUuid;

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

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController();
    _unitController = TextEditingController();
    _scoreController = TextEditingController();
    _notesController = TextEditingController();
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
    if (_saving) return;
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
      final record = ProductionRecord(
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
      );
      await locator<ProductionRecordRepository>().addProductionRecord(
        widget.animalUuid,
        record,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormProductionSaved)),
      );
      context.pop(true);
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Ocurrió un error')));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return RecordFormScaffold(
      title: l10n.detailFormProductionTitle,
      saving: _saving,
      onSave: _save,
      saveLabel: l10n.actionSave,
      fields: [
        DropdownButtonFormField<ProductionRecordType>(
          initialValue: _type,
          decoration: InputDecoration(
            labelText: l10n.detailFormProductionType,
            border: const OutlineInputBorder(),
          ),
          items: ProductionRecordType.values
              .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
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
