/// features > directorio > animales > view > animal_commercial_form_page — full-screen commercial record form.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/record_form_scaffold.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class AnimalCommercialFormPage extends StatefulWidget {
  const AnimalCommercialFormPage({required this.animalUuid, super.key});

  final String animalUuid;

  @override
  State<AnimalCommercialFormPage> createState() =>
      _AnimalCommercialFormPageState();
}

class _AnimalCommercialFormPageState extends State<AnimalCommercialFormPage> {
  late final TextEditingController _amountController;
  late final TextEditingController _currencyController;
  late final TextEditingController _counterpartyController;
  late final TextEditingController _notesController;

  CommercialRecordType _type = CommercialRecordType.purchase;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _currencyController = TextEditingController(text: 'USD');
    _counterpartyController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
    _counterpartyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _saving = true);
    try {
      final amount = double.tryParse(_amountController.text.trim());
      final record = CommercialRecord(
        id: null,
        date: _date,
        type: _type,
        amount: amount,
        currency: _currencyController.text.trim().isEmpty
            ? null
            : _currencyController.text.trim(),
        counterparty: _counterpartyController.text.trim().isEmpty
            ? null
            : _counterpartyController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      await locator<CommercialRecordRepository>().addCommercialRecord(
        widget.animalUuid,
        record,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormCommercialSaved)),
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
      title: l10n.detailFormCommercialTitle,
      saving: _saving,
      onSave: _save,
      saveLabel: l10n.actionSave,
      fields: [
        DropdownButtonFormField<CommercialRecordType>(
          initialValue: _type,
          decoration: InputDecoration(
            labelText: l10n.detailFormCommercialType,
            border: const OutlineInputBorder(),
          ),
          items: CommercialRecordType.values
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
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.detailFormCommercialAmount,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _currencyController,
                decoration: InputDecoration(
                  labelText: l10n.detailFormCommercialCurrency,
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
          controller: _counterpartyController,
          decoration: InputDecoration(
            labelText: l10n.detailFormCommercialCounterparty,
            border: const OutlineInputBorder(),
          ),
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
