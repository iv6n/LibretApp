/// registro › view › RegistroReproduccionPage
///
/// Form page for recording a reproductive event (service, insemination, calving).
/// Provides [RegistroBloc] and dispatches [RegistroReproduccionSubmitted].
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

/// Page wrapper that provides [RegistroBloc] for the reproduction registration form.
class RegistroReproduccionPage extends StatelessWidget {
  const RegistroReproduccionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RegistroBloc(animalRepository: locator<AnimalRepository>()),
      child: const _RegistroReproduccionView(),
    );
  }
}

/// Internal form view for reproduction registration.
class _RegistroReproduccionView extends StatefulWidget {
  const _RegistroReproduccionView();

  @override
  State<_RegistroReproduccionView> createState() =>
      _RegistroReproduccionViewState();
}

class _RegistroReproduccionViewState extends State<_RegistroReproduccionView> {
  var _serviceType = ServiceType.naturalService;
  var _serviceDate = DateTime.now();
  DateTime? _expectedCalvingDate;
  String? _sireId;
  String? _notes;
  AnimalEntity? _selectedAnimal;

  @override
  void dispose() {
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
    if (_expectedCalvingDate != null &&
        _expectedCalvingDate!.isBefore(_serviceDate)) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormReproductionExpectedAfterDate)),
      );
      return;
    }

    final record = ReproductionRecord(
      serviceDate: _serviceDate,
      serviceType: _serviceType,
      maleSireIdentifier: _sireId,
      expectedCalvingDate: _expectedCalvingDate,
      notes: _notes,
    );
    context.read<RegistroBloc>().add(
      RegistroReproduccionSubmitted(
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.detailFormReproductionSaved)),
          );
          context.read<RegistroBloc>().add(const RegistroReset());
        } else if (state.status == RegistroStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error al guardar')),
          );
          context.read<RegistroBloc>().add(const RegistroReset());
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.detailFormReproductionTitle)),
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
                onChanged: (v) {
                  if (v != null) setState(() => _serviceType = v);
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
                        if (picked != null) {
                          setState(() => _serviceDate = picked);
                        }
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
                        if (picked != null) {
                          setState(() => _expectedCalvingDate = picked);
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
                onChanged: (v) => _sireId = v.trim().isEmpty ? null : v.trim(),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: l10n.detailFormReproductionNotes,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (v) => _notes = v,
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
