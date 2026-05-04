/// features \u203a directorio \u203a animales \u203a widgets \u203a cost_form_sheet \u2014 bottom sheet form for cost records.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/animal_event.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/l10n/app_localizations.dart';

Future<void> showCostForm(
  BuildContext context, {
  required String animalUuid,
  required Future<bool> Function(AnimalEvent) dispatchAndAwait,
  required VoidCallback onReload,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final l10n = AppLocalizations.of(context);
  final amountCtrl = TextEditingController();
  final currencyCtrl = TextEditingController(text: 'USD');
  final notesCtrl = TextEditingController();
  var type = CostType.medication;
  var date = DateTime.now();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.payments, color: Colors.brown),
                      const SizedBox(width: 8),
                      Text(l10n.detailFormCostTitle),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<CostType>(
                    initialValue: type,
                    decoration: InputDecoration(
                      labelText: l10n.detailFormCostType,
                      border: const OutlineInputBorder(),
                    ),
                    items: CostType.values
                        .map(
                          (t) =>
                              DropdownMenuItem(value: t, child: Text(t.name)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setModalState(() => type = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: amountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.detailFormCostAmount,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: currencyCtrl,
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
                    label: Text('${date.year}-${date.month}-${date.day}'),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(date.year - 5),
                        lastDate: DateTime(date.year + 1),
                      );
                      if (picked != null) setModalState(() => date = picked);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.fieldNotes,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final amount = double.tryParse(amountCtrl.text.trim());
                        if (amount == null) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(l10n.detailFormCostAmountRequired),
                            ),
                          );
                          return;
                        }
                        final record = CostRecord(
                          id: null,
                          date: date,
                          type: type,
                          amount: amount,
                          currency: currencyCtrl.text.trim().isEmpty
                              ? null
                              : currencyCtrl.text.trim(),
                          notes: notesCtrl.text.trim().isEmpty
                              ? null
                              : notesCtrl.text.trim(),
                        );
                        final ok = await dispatchAndAwait(
                          AddCostRecord(animalUuid: animalUuid, record: record),
                        );
                        if (!context.mounted || !ok) return;
                        navigator.pop();
                        onReload();
                        messenger.showSnackBar(
                          SnackBar(content: Text(l10n.detailFormCostSaved)),
                        );
                      },
                      child: Text(l10n.actionSave),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  amountCtrl.dispose();
  currencyCtrl.dispose();
  notesCtrl.dispose();
}
