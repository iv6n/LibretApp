/// features \u203a directorio \u203a animales \u203a widgets \u203a weight_form_sheet \u2014 bottom sheet form for weight records.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/animal_event.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/l10n/app_localizations.dart';

Future<void> showWeightForm(
  BuildContext context, {
  required String animalUuid,
  required Future<bool> Function(AnimalEvent) dispatchAndAwait,
  required VoidCallback onReload,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final l10n = AppLocalizations.of(context);
  final weightCtrl = TextEditingController();
  var method = WeightMethod.scale;
  var date = DateTime.now();
  String? notes;

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.scale, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      l10n.detailFormWeightTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.detailFormWeightValue,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<WeightMethod>(
                  initialValue: method,
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
                    if (value != null) {
                      setModalState(() => method = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.today),
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
                        decoration: InputDecoration(
                          labelText: l10n.fieldNotesOptional,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (v) => notes = v,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final parsed = double.tryParse(weightCtrl.text.trim());
                      if (parsed == null) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(l10n.detailFormWeightErrorInvalid),
                          ),
                        );
                        return;
                      }
                      final record = WeightRecord(
                        id: null,
                        date: date,
                        weight: parsed,
                        method: method,
                        notes: notes,
                      );
                      final ok = await dispatchAndAwait(
                        AddWeightRecord(animalUuid: animalUuid, record: record),
                      );
                      if (!context.mounted || !ok) return;
                      navigator.pop();
                      onReload();
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.detailFormWeightSaved)),
                      );
                    },
                    child: Text(l10n.actionSave),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  weightCtrl.dispose();
}
