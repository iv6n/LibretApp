/// registro › view › RegistroSanitarioPage
///
/// Form page for recording a health/sanitary record (vaccine, treatment, etc.).
/// Provides [RegistroBloc] and dispatches [RegistroSanitarioSubmitted].
///
/// Layer: view (presentation)
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/infrastructure.dart';
import 'package:libretapp/features/registro/bloc/index.dart';
import 'package:libretapp/features/registro/widgets/animal_selector.dart';
import 'package:libretapp/l10n/app_localizations.dart';

/// Page wrapper that provides [RegistroBloc] for the sanitary registration form.
class RegistroSanitarioPage extends StatelessWidget {
  const RegistroSanitarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RegistroBloc(animalRepository: locator<AnimalRepository>()),
      child: const _RegistroSanitarioView(),
    );
  }
}

/// Internal form view for sanitary registration.
class _RegistroSanitarioView extends StatefulWidget {
  const _RegistroSanitarioView();

  @override
  State<_RegistroSanitarioView> createState() => _RegistroSanitarioViewState();
}

class _RegistroSanitarioViewState extends State<_RegistroSanitarioView> {
  final _productCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _appliedByCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _causeCtrl = TextEditingController();
  var _type = HealthRecordType.vaccine;
  var _date = DateTime.now();
  DateTime? _nextDate;
  AnimalEntity? _selectedAnimal;

  @override
  void dispose() {
    _productCtrl.dispose();
    _doseCtrl.dispose();
    _appliedByCtrl.dispose();
    _notesCtrl.dispose();
    _causeCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (_selectedAnimal == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormAnimalRequired)),
      );
      return;
    }
    if (_productCtrl.text.trim().isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormHealthProductRequired)),
      );
      return;
    }
    if (_nextDate != null && _nextDate!.isBefore(_date)) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormHealthNextAfterDate)),
      );
      return;
    }

    final record = HealthRecord(
      date: _date,
      type: _type,
      product: _productCtrl.text.trim(),
      dose: _doseCtrl.text.trim().isEmpty ? null : _doseCtrl.text.trim(),
      appliedBy: _appliedByCtrl.text.trim().isEmpty
          ? null
          : _appliedByCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      nextDueDate: _nextDate,
      cause: _causeCtrl.text.trim().isEmpty ? null : _causeCtrl.text.trim(),
    );
    context.read<RegistroBloc>().add(
      RegistroSanitarioSubmitted(
        animalUuid: _selectedAnimal!.uuid,
        record: record,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<RegistroBloc, RegistroState>(
      listener: (context, state) {
        if (state.status == RegistroStatus.success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.detailFormHealthSaved)));
          context.read<RegistroBloc>().add(const RegistroReset());
        } else if (state.status == RegistroStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error al guardar')),
          );
          context.read<RegistroBloc>().add(const RegistroReset());
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.detailFormHealthTitle)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimalSelector(
                selectedAnimal: _selectedAnimal,
                onSelected: (a) => setState(() => _selectedAnimal = a),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<HealthRecordType>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: l10n.detailFormHealthType,
                  border: const OutlineInputBorder(),
                ),
                items: HealthRecordType.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _type = v);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _productCtrl,
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
                      controller: _doseCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.detailFormHealthDose,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _appliedByCtrl,
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
                        if (picked != null) setState(() => _date = picked);
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
                controller: _causeCtrl,
                decoration: InputDecoration(
                  labelText: l10n.detailFormHealthCause,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesCtrl,
                decoration: InputDecoration(
                  labelText: l10n.fieldNotes,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              BlocBuilder<RegistroBloc, RegistroState>(
                buildWhen: (prev, curr) => prev.status != curr.status,
                builder: (context, state) {
                  final isSaving = state.status == RegistroStatus.loading;
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isSaving ? null : _save,
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l10n.actionSave),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
