/// registro › view › RegistroPesoPage
///
/// Form page for recording an animal weight measurement.
/// Provides [RegistroBloc] and dispatches [RegistroPesoSubmitted].
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

/// Page wrapper that provides [RegistroBloc] for the weight registration form.
class RegistroPesoPage extends StatelessWidget {
  const RegistroPesoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RegistroBloc(animalRepository: locator<AnimalRepository>()),
      child: const _RegistroPesoView(),
    );
  }
}

/// Internal form view for weight registration.
class _RegistroPesoView extends StatefulWidget {
  const _RegistroPesoView();

  @override
  State<_RegistroPesoView> createState() => _RegistroPesoViewState();
}

class _RegistroPesoViewState extends State<_RegistroPesoView> {
  final _weightCtrl = TextEditingController();
  var _method = WeightMethod.scale;
  var _date = DateTime.now();
  String? _notes;
  AnimalEntity? _selectedAnimal;

  double? _parseDouble(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
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

    final parsed = _parseDouble(_weightCtrl.text);
    if (parsed == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormWeightErrorInvalid)),
      );
      return;
    }
    if (parsed <= 0) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormAmountPositive)),
      );
      return;
    }

    final record = WeightRecord(
      date: _date,
      weight: parsed,
      method: _method,
      notes: _notes,
    );
    context.read<RegistroBloc>().add(
      RegistroPesoSubmitted(animalUuid: _selectedAnimal!.uuid, record: record),
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
          ).showSnackBar(SnackBar(content: Text(l10n.detailFormWeightSaved)));
          context.read<RegistroBloc>().add(const RegistroReset());
        } else if (state.status == RegistroStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error al guardar')),
          );
          context.read<RegistroBloc>().add(const RegistroReset());
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.detailFormWeightTitle)),
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
              TextField(
                controller: _weightCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.detailFormWeightValue,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<WeightMethod>(
                initialValue: _method,
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
                onChanged: (v) {
                  if (v != null) setState(() => _method = v);
                },
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
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: l10n.fieldNotesOptional,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (v) => _notes = v,
                    ),
                  ),
                ],
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
