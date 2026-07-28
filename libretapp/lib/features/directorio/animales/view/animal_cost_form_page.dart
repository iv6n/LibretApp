/// features > directorio > animales > view > animal_cost_form_page — full-screen cost record form.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/record_form_scaffold.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class AnimalCostFormPage extends StatefulWidget {
  const AnimalCostFormPage({required this.animalUuid, super.key});

  final String animalUuid;

  @override
  State<AnimalCostFormPage> createState() => _AnimalCostFormPageState();
}

class _AnimalCostFormPageState extends State<AnimalCostFormPage> {
  late final TextEditingController _amountController;
  late final TextEditingController _currencyController;
  late final TextEditingController _notesController;

  CostType _type = CostType.medication;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _currencyController = TextEditingController(text: 'USD');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormCostAmountRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final record = CostRecord(
        id: null,
        date: _date,
        type: _type,
        amount: amount,
        currency: _currencyController.text.trim().isEmpty
            ? null
            : _currencyController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      await locator<CostRecordRepository>().addCostRecord(
        widget.animalUuid,
        record,
      );
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.detailFormCostSaved)));
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
      title: l10n.detailFormCostTitle,
      saving: _saving,
      onSave: _save,
      saveLabel: l10n.actionSave,
      fields: [
        DropdownButtonFormField<CostType>(
          initialValue: _type,
          decoration: InputDecoration(
            labelText: l10n.detailFormCostType,
            border: const OutlineInputBorder(),
          ),
          items: CostType.values
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
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.detailFormCostAmount,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _currencyController,
                decoration: InputDecoration(
                  labelText: l10n.detailFormCostCurrency,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
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
