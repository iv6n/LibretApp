/// features > directorio > animales > view > animal_health_form_page — full-screen health record form.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/advisor/livestock_advisor.dart';
import 'package:libretapp/core/advisor/widgets/advisor_tips_panel.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class AnimalHealthFormPage extends StatefulWidget {
  const AnimalHealthFormPage({required this.animalUuid, super.key});

  final String animalUuid;

  @override
  State<AnimalHealthFormPage> createState() => _AnimalHealthFormPageState();
}

class _AnimalHealthFormPageState extends State<AnimalHealthFormPage> {
  late final TextEditingController _productController;
  late final TextEditingController _doseController;
  late final TextEditingController _appliedByController;
  late final TextEditingController _causeController;
  late final TextEditingController _notesController;

  HealthRecordType _type = HealthRecordType.vaccine;
  DateTime _date = DateTime.now();
  DateTime? _nextDate;
  bool _saving = false;
  AnimalEntity? _animal;

  @override
  void initState() {
    super.initState();
    _productController = TextEditingController();
    _doseController = TextEditingController();
    _appliedByController = TextEditingController();
    _causeController = TextEditingController();
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
    _productController.dispose();
    _doseController.dispose();
    _appliedByController.dispose();
    _causeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_productController.text.trim().isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormHealthProductRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final record = HealthRecord(
        id: null,
        date: _date,
        type: _type,
        product: _productController.text.trim(),
        dose: _doseController.text.trim().isEmpty
            ? null
            : _doseController.text.trim(),
        appliedBy: _appliedByController.text.trim().isEmpty
            ? null
            : _appliedByController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        nextDueDate: _nextDate,
        cause: _causeController.text.trim().isEmpty
            ? null
            : _causeController.text.trim(),
      );
      await locator<HealthRecordRepository>().addHealthRecord(
        widget.animalUuid,
        record,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormHealthSaved)),
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.detailFormHealthTitle)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<HealthRecordType>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: l10n.detailFormHealthType,
                  border: const OutlineInputBorder(),
                ),
                items: HealthRecordType.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _type = value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _productController,
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
                      controller: _doseController,
                      decoration: InputDecoration(
                        labelText: l10n.detailFormHealthDose,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _appliedByController,
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.event_available),
                      label: Text(
                        _nextDate == null
                            ? l10n.detailFormHealthNext
                            : '${_nextDate!.year}-${_nextDate!.month}-${_nextDate!.day}',
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _nextDate ?? _date,
                          firstDate: DateTime(_date.year),
                          lastDate: DateTime(_date.year + 5),
                        );
                        setState(() => _nextDate = picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _causeController,
                decoration: InputDecoration(
                  labelText: l10n.detailFormHealthCause,
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
              const SizedBox(height: 16),
              if (_animal != null) ...[
                AdvisorTipsPanel(
                  tips: LivestockAdvisor.forHealth(
                    _animal!,
                    HealthRecord(
                      date: _date,
                      type: _type,
                      product: _productController.text.trim().isEmpty
                          ? 'N/A'
                          : _productController.text.trim(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.actionSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
