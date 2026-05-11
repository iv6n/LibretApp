/// features > directorio > animales > view > animal_movement_form_page — full-screen movement record form.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/advisor/livestock_advisor.dart';
import 'package:libretapp/core/advisor/widgets/advisor_tips_panel.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class AnimalMovementFormPage extends StatefulWidget {
  const AnimalMovementFormPage({required this.animalUuid, super.key});

  final String animalUuid;

  @override
  State<AnimalMovementFormPage> createState() => _AnimalMovementFormPageState();
}

class _AnimalMovementFormPageState extends State<AnimalMovementFormPage> {
  late final TextEditingController _fromController;
  late final TextEditingController _toController;
  late final TextEditingController _notesController;
  late final TextEditingController _movedByController;

  MovementReason _reason = MovementReason.paddockRotation;
  DateTime _date = DateTime.now();
  bool _saving = false;
  AnimalEntity? _animal;

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController();
    _toController = TextEditingController();
    _notesController = TextEditingController();
    _movedByController = TextEditingController();
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
    _fromController.dispose();
    _toController.dispose();
    _notesController.dispose();
    _movedByController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_toController.text.trim().isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormMovementToRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final record = MovementRecord(
        id: null,
        fromLocation: _fromController.text.trim().isEmpty
            ? null
            : _fromController.text.trim(),
        toLocation: _toController.text.trim(),
        date: _date,
        reason: _reason,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        movedBy: _movedByController.text.trim().isEmpty
            ? null
            : _movedByController.text.trim(),
      );
      await locator<MovementRecordRepository>().addMovementRecord(
        widget.animalUuid,
        record,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormMovementSaved)),
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
      appBar: AppBar(title: Text(l10n.detailFormMovementTitle)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<MovementReason>(
                initialValue: _reason,
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
                  if (value == null) return;
                  setState(() => _reason = value);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fromController,
                      decoration: InputDecoration(
                        labelText: l10n.detailFormMovementFrom,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _toController,
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
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.fieldNotes,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _movedByController,
                decoration: InputDecoration(
                  labelText: l10n.detailFormMovementMovedBy,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (_animal != null) ...[
                AdvisorTipsPanel(
                  tips: LivestockAdvisor.forMovement(
                    _animal!,
                    MovementRecord(
                      id: null,
                      fromLocation: null,
                      toLocation: _toController.text.trim(),
                      date: _date,
                      reason: _reason,
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
