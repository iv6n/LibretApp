import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/animal_event.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/l10n/app_localizations.dart';

Future<void> showMovementForm(
  BuildContext context, {
  required String animalUuid,
  required Future<bool> Function(AnimalEvent) dispatchAndAwait,
  required VoidCallback onReload,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final l10n = AppLocalizations.of(context);
  final fromCtrl = TextEditingController();
  final toCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final movedByCtrl = TextEditingController();
  var reason = MovementReason.paddockRotation;
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
                      const Icon(Icons.drive_eta, color: Colors.indigo),
                      const SizedBox(width: 8),
                      Text(l10n.detailFormMovementTitle),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<MovementReason>(
                    initialValue: reason,
                    decoration: InputDecoration(
                      labelText: l10n.detailFormMovementReason,
                      border: const OutlineInputBorder(),
                    ),
                    items: MovementReason.values
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setModalState(() => reason = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: fromCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.detailFormMovementFrom,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: toCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.detailFormMovementTo,
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: movedByCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.detailFormMovementMovedBy,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (toCtrl.text.trim().isEmpty) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(l10n.detailFormMovementToRequired),
                            ),
                          );
                          return;
                        }
                        final record = MovementRecord(
                          id: null,
                          fromLocation: fromCtrl.text.trim().isEmpty
                              ? null
                              : fromCtrl.text.trim(),
                          toLocation: toCtrl.text.trim(),
                          date: date,
                          reason: reason,
                          notes: notesCtrl.text.trim().isEmpty
                              ? null
                              : notesCtrl.text.trim(),
                          movedBy: movedByCtrl.text.trim().isEmpty
                              ? null
                              : movedByCtrl.text.trim(),
                        );
                        final ok = await dispatchAndAwait(
                          AddMovementRecord(
                            animalUuid: animalUuid,
                            record: record,
                          ),
                        );
                        if (!context.mounted || !ok) return;
                        navigator.pop();
                        onReload();
                        messenger.showSnackBar(
                          SnackBar(content: Text(l10n.detailFormMovementSaved)),
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

  fromCtrl.dispose();
  toCtrl.dispose();
  notesCtrl.dispose();
  movedByCtrl.dispose();
}
