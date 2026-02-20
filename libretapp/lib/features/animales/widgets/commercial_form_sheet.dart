import 'package:flutter/material.dart';
import 'package:libretapp/features/animales/application/bloc/animal_event.dart';
import 'package:libretapp/features/animales/domain/animal_domain.dart';
import 'package:libretapp/l10n/app_localizations.dart';

Future<void> showCommercialForm(
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
  final counterpartyCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  var type = CommercialRecordType.purchase;
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
                      const Icon(Icons.store, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(l10n.detailFormCommercialTitle),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<CommercialRecordType>(
                    initialValue: type,
                    decoration: InputDecoration(
                      labelText: l10n.detailFormCommercialType,
                      border: const OutlineInputBorder(),
                    ),
                    items: CommercialRecordType.values
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
                            labelText: l10n.detailFormCommercialAmount,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: currencyCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.detailFormCommercialCurrency,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: counterpartyCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.detailFormCommercialCounterparty,
                      border: const OutlineInputBorder(),
                    ),
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
                        final record = CommercialRecord(
                          id: null,
                          date: date,
                          type: type,
                          amount: amount,
                          currency: currencyCtrl.text.trim().isEmpty
                              ? null
                              : currencyCtrl.text.trim(),
                          counterparty: counterpartyCtrl.text.trim().isEmpty
                              ? null
                              : counterpartyCtrl.text.trim(),
                          notes: notesCtrl.text.trim().isEmpty
                              ? null
                              : notesCtrl.text.trim(),
                        );
                        final ok = await dispatchAndAwait(
                          AddCommercialRecord(
                            animalUuid: animalUuid,
                            record: record,
                          ),
                        );
                        if (!context.mounted || !ok) return;
                        navigator.pop();
                        onReload();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(l10n.detailFormCommercialSaved),
                          ),
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
  counterpartyCtrl.dispose();
  notesCtrl.dispose();
}
