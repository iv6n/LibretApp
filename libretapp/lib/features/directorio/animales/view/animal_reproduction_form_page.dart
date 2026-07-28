/// features > directorio > animales > view > animal_reproduction_form_page — full-screen reproduction record form.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/features/directorio/animales/advisor/livestock_advisor.dart';
import 'package:libretapp/features/directorio/animales/advisor/widgets/advisor_tips_panel.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/record_form_scaffold.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class AnimalReproductionFormPage extends StatefulWidget {
  const AnimalReproductionFormPage({required this.animalUuid, super.key});

  final String animalUuid;

  @override
  State<AnimalReproductionFormPage> createState() =>
      _AnimalReproductionFormPageState();
}

class _AnimalReproductionFormPageState
    extends State<AnimalReproductionFormPage> {
  ServiceType _serviceType = ServiceType.naturalService;
  DateTime _serviceDate = DateTime.now();
  DateTime? _expectedCalvingDate;
  bool _saving = false;
  AnimalEntity? _animal;

  late final TextEditingController _sireController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _sireController = TextEditingController();
    _notesController = TextEditingController();
    _loadAnimal();
  }

  Future<void> _loadAnimal() async {
    final animal = await locator<AnimalRepository>().getByUuid(
      widget.animalUuid,
    );
    if (!mounted) return;
    setState(() => _animal = animal);
  }

  @override
  void dispose() {
    _sireController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _saving = true);
    try {
      final record = ReproductionRecord(
        id: null,
        serviceDate: _serviceDate,
        serviceType: _serviceType,
        maleSireIdentifier: _sireController.text.trim().isEmpty
            ? null
            : _sireController.text.trim(),
        expectedCalvingDate: _expectedCalvingDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      await locator<ReproductionRecordRepository>().addReproductionRecord(
        widget.animalUuid,
        record,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormReproductionSaved)),
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
      title: l10n.detailFormReproductionTitle,
      saving: _saving,
      onSave: _save,
      saveLabel: l10n.actionSave,
      fields: [
        DropdownButtonFormField<ServiceType>(
          initialValue: _serviceType,
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
            if (value == null) return;
            setState(() => _serviceType = value);
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.event),
                label: Text(
                  '${_serviceDate.year}-${_serviceDate.month}-${_serviceDate.day}',
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _serviceDate,
                    firstDate: DateTime(_serviceDate.year - 5),
                    lastDate: DateTime(_serviceDate.year + 1),
                  );
                  if (picked == null) return;
                  setState(() => _serviceDate = picked);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.child_friendly),
                label: Text(
                  _expectedCalvingDate == null
                      ? l10n.detailFormReproductionExpectedCalving
                      : '${_expectedCalvingDate!.year}-${_expectedCalvingDate!.month}-${_expectedCalvingDate!.day}',
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _expectedCalvingDate ?? _serviceDate,
                    firstDate: DateTime(_serviceDate.year - 1),
                    lastDate: DateTime(_serviceDate.year + 2),
                  );
                  if (picked == null) return;
                  setState(() => _expectedCalvingDate = picked);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _sireController,
          decoration: InputDecoration(
            labelText: l10n.detailFormReproductionSire,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: l10n.detailFormReproductionNotes,
            border: const OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        if (_animal != null) ...[
          AdvisorTipsPanel(
            tips: LivestockAdvisor.forReproduction(
              _animal!,
              ReproductionRecord(
                serviceDate: _serviceDate,
                serviceType: _serviceType,
                maleSireIdentifier: _sireController.text.trim().isEmpty
                    ? null
                    : _sireController.text.trim(),
                expectedCalvingDate: _expectedCalvingDate,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
