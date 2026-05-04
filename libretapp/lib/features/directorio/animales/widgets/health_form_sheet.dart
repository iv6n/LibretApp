/// features \u203a directorio \u203a animales \u203a widgets \u203a health_form_sheet \u2014 bottom sheet form for health records.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/advisor/livestock_advisor.dart';
import 'package:libretapp/core/advisor/widgets/advisor_tips_panel.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/animal_event.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/l10n/app_localizations.dart';

typedef HealthRecordSubmit = Future<bool> Function(HealthRecord record);

Future<void> showHealthForm(
  BuildContext context, {
  required String animalUuid,
  required Future<bool> Function(AnimalEvent) dispatchAndAwait,
  required VoidCallback onReload,
  AnimalEntity? animal,
}) async {
  await _showHealthForm(
    context,
    title: null,
    onSubmit: (record) => dispatchAndAwait(
      AddHealthRecord(animalUuid: animalUuid, record: record),
    ),
    onSaved: onReload,
    animal: animal,
  );
}

Future<void> showBulkHealthForm(
  BuildContext context, {
  required int selectedCount,
  required HealthRecordSubmit onSubmit,
  required VoidCallback onSaved,
}) async {
  final l10n = AppLocalizations.of(context);
  await _showHealthForm(
    context,
    title: '${l10n.detailFormHealthTitle} ($selectedCount)',
    onSubmit: onSubmit,
    onSaved: onSaved,
  );
}

Future<void> _showHealthForm(
  BuildContext context, {
  required String? title,
  required HealthRecordSubmit onSubmit,
  required VoidCallback onSaved,
  AnimalEntity? animal,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final l10n = AppLocalizations.of(context);
  final productCtrl = TextEditingController();
  final doseCtrl = TextEditingController();
  final appliedByCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final causeCtrl = TextEditingController();
  var type = HealthRecordType.vaccine;
  var date = DateTime.now();
  DateTime? nextDate;

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
                      const Icon(Icons.medical_services, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(title ?? l10n.detailFormHealthTitle),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<HealthRecordType>(
                    initialValue: type,
                    decoration: InputDecoration(
                      labelText: l10n.detailFormHealthType,
                      border: const OutlineInputBorder(),
                    ),
                    items: HealthRecordType.values
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
                  TextField(
                    controller: productCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.detailFormHealthProduct,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: doseCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.detailFormHealthDose,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: appliedByCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.detailFormHealthAppliedBy,
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
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.event_available),
                          label: Text(
                            nextDate == null
                                ? l10n.detailFormHealthNext
                                : '${nextDate!.year}-${nextDate!.month}-${nextDate!.day}',
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: nextDate ?? date,
                              firstDate: DateTime(date.year),
                              lastDate: DateTime(date.year + 5),
                            );
                            setModalState(() => nextDate = picked);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: causeCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.detailFormHealthCause,
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
                  if (animal != null) ...[
                    Builder(
                      builder: (_) {
                        final previewRecord = HealthRecord(
                          date: date,
                          type: type,
                          product: '',
                        );
                        final tips = LivestockAdvisor.forHealth(
                          animal,
                          previewRecord,
                        );
                        return AdvisorTipsPanel(tips: tips);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (productCtrl.text.trim().isEmpty) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.detailFormHealthProductRequired,
                              ),
                            ),
                          );
                          return;
                        }
                        final record = HealthRecord(
                          id: null,
                          date: date,
                          type: type,
                          product: productCtrl.text.trim(),
                          dose: doseCtrl.text.trim().isEmpty
                              ? null
                              : doseCtrl.text.trim(),
                          appliedBy: appliedByCtrl.text.trim().isEmpty
                              ? null
                              : appliedByCtrl.text.trim(),
                          notes: notesCtrl.text.trim().isEmpty
                              ? null
                              : notesCtrl.text.trim(),
                          nextDueDate: nextDate,
                          cause: causeCtrl.text.trim().isEmpty
                              ? null
                              : causeCtrl.text.trim(),
                        );
                        final ok = await onSubmit(record);
                        if (!context.mounted || !ok) return;
                        navigator.pop();
                        onSaved();
                        messenger.showSnackBar(
                          SnackBar(content: Text(l10n.detailFormHealthSaved)),
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

  productCtrl.dispose();
  doseCtrl.dispose();
  appliedByCtrl.dispose();
  notesCtrl.dispose();
  causeCtrl.dispose();
}
