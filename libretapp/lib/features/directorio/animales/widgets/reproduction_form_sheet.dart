import 'package:flutter/material.dart';
import 'package:libretapp/core/advisor/livestock_advisor.dart';
import 'package:libretapp/core/advisor/widgets/advisor_tips_panel.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/animal_event.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/l10n/app_localizations.dart';

Future<void> showReproductionForm(
  BuildContext context, {
  required String animalUuid,
  required Future<bool> Function(AnimalEvent) dispatchAndAwait,
  required VoidCallback onReload,
  AnimalEntity? animal,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final l10n = AppLocalizations.of(context);
  var serviceType = ServiceType.naturalService;
  var serviceDate = DateTime.now();
  DateTime? expectedCalvingDate;
  String? sireId;
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
                    const Icon(Icons.favorite, color: Colors.pink),
                    const SizedBox(width: 8),
                    Text(
                      l10n.detailFormReproductionTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ServiceType>(
                  initialValue: serviceType,
                  decoration: InputDecoration(
                    labelText: l10n.detailFormReproductionServiceType,
                    border: const OutlineInputBorder(),
                  ),
                  items: ServiceType.values
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            s == ServiceType.naturalService
                                ? l10n.detailFormReproductionServiceNatural
                                : s == ServiceType.artificialInsemination
                                ? l10n.detailFormReproductionServiceAi
                                : l10n.detailFormReproductionServiceIvf,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setModalState(() => serviceType = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.event),
                        label: Text(
                          '${serviceDate.year}-${serviceDate.month}-${serviceDate.day}',
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: serviceDate,
                            firstDate: DateTime(serviceDate.year - 5),
                            lastDate: DateTime(serviceDate.year + 1),
                          );
                          if (picked != null) {
                            setModalState(() => serviceDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.child_friendly),
                        label: Text(
                          expectedCalvingDate == null
                              ? l10n.detailFormReproductionExpectedCalving
                              : '${expectedCalvingDate!.year}-${expectedCalvingDate!.month}-${expectedCalvingDate!.day}',
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: expectedCalvingDate ?? serviceDate,
                            firstDate: DateTime(serviceDate.year - 1),
                            lastDate: DateTime(serviceDate.year + 2),
                          );
                          if (picked != null) {
                            setModalState(() => expectedCalvingDate = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: l10n.detailFormReproductionSire,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) => sireId = v.trim().isEmpty ? null : v.trim(),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: l10n.detailFormReproductionNotes,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (v) => notes = v,
                ),
                const SizedBox(height: 16),
                if (animal != null) ...[
                  Builder(
                    builder: (_) {
                      final previewRecord = ReproductionRecord(
                        serviceDate: serviceDate,
                        serviceType: serviceType,
                        maleSireIdentifier: sireId,
                        expectedCalvingDate: expectedCalvingDate,
                      );
                      final tips = LivestockAdvisor.forReproduction(
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
                      final record = ReproductionRecord(
                        id: null,
                        serviceDate: serviceDate,
                        serviceType: serviceType,
                        maleSireIdentifier: sireId,
                        expectedCalvingDate: expectedCalvingDate,
                        notes: notes,
                      );
                      final ok = await dispatchAndAwait(
                        AddReproductionRecord(
                          animalUuid: animalUuid,
                          record: record,
                        ),
                      );
                      if (!context.mounted || !ok) return;
                      navigator.pop();
                      onReload();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(l10n.detailFormReproductionSaved),
                        ),
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
}
