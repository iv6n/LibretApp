import 'package:flutter/material.dart';
import 'package:libretapp/features/animales/application/bloc/animal_event.dart';
import 'package:libretapp/features/animales/domain/animal_domain.dart';
import 'package:libretapp/l10n/app_localizations.dart';

Future<void> showProductionForm(
  BuildContext context, {
  required String animalUuid,
  required Future<bool> Function(AnimalEvent) dispatchAndAwait,
  required VoidCallback onReload,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final l10n = AppLocalizations.of(context);
  final valueCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  final scoreCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  var type = ProductionRecordType.weighing;
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
                      const Icon(Icons.analytics, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(l10n.detailFormProductionTitle),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ProductionRecordType>(
                    initialValue: type,
                    decoration: InputDecoration(
                      labelText: l10n.detailFormProductionType,
                      border: const OutlineInputBorder(),
                    ),
                    items: ProductionRecordType.values
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
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.event),
                          label: Text('${date.year}-${date.month}-${date.day}'),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: date,
                              firstDate: DateTime(date.year - 5),
                              lastDate: DateTime(date.year + 1),
                            );
                            if (picked != null) {
                              setModalState(() => date = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: valueCtrl,
                          keyboardType: TextInputType.number,
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
                          controller: unitCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.detailFormProductionUnit,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: scoreCtrl,
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
                        final record = ProductionRecord(
                          id: null,
                          date: date,
                          type: type,
                          value: double.tryParse(valueCtrl.text.trim()),
                          unit: unitCtrl.text.trim().isEmpty
                              ? null
                              : unitCtrl.text.trim(),
                          score: int.tryParse(scoreCtrl.text.trim()),
                          notes: notesCtrl.text.trim().isEmpty
                              ? null
                              : notesCtrl.text.trim(),
                        );
                        final ok = await dispatchAndAwait(
                          AddProductionRecord(
                            animalUuid: animalUuid,
                            record: record,
                          ),
                        );
                        if (!context.mounted || !ok) return;
                        navigator.pop();
                        onReload();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(l10n.detailFormProductionSaved),
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

  valueCtrl.dispose();
  unitCtrl.dispose();
  scoreCtrl.dispose();
  notesCtrl.dispose();
}
