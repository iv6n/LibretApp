/// registro › view › RegistroReproduccionPage
///
/// Form page for recording a reproductive event (service, insemination, calving).
/// Provides [RegistroBloc] and dispatches [RegistroReproduccionSubmitted].
///
/// Layer: view (presentation)
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/registro/bloc/index.dart';
import 'package:libretapp/features/registro/widgets/animal_selector.dart';
import 'package:libretapp/l10n/app_localizations.dart';

/// Page wrapper that provides [RegistroBloc] for the reproduction registration form.
class RegistroReproduccionPage extends StatelessWidget {
  const RegistroReproduccionPage({this.preset, super.key});

  final String? preset;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegistroBloc(
        weightRepo: locator<WeightRecordRepository>(),
        healthRepo: locator<HealthRecordRepository>(),
        productionRepo: locator<ProductionRecordRepository>(),
        reproductionRepo: locator<ReproductionRecordRepository>(),
        commercialRepo: locator<CommercialRecordRepository>(),
        movementRepo: locator<MovementRecordRepository>(),
        costRepo: locator<CostRecordRepository>(),
      ),
      child: _RegistroReproduccionView(preset: preset),
    );
  }
}

/// Internal form view for reproduction registration.
class _RegistroReproduccionView extends StatefulWidget {
  const _RegistroReproduccionView({this.preset});

  final String? preset;

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
  void initState() {
    super.initState();
    final isParicionPreset = widget.preset?.toLowerCase() == 'paricion';
    if (isParicionPreset) {
      _serviceType = ServiceType.naturalService;
      _expectedCalvingDate = DateTime.now();
    }
  }

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
            SnackBar(content: Text(state.errorMessage ?? l10n.errorGenericSave)),
          );
          context.read<RegistroBloc>().add(const RegistroReset());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.preset?.toLowerCase() == 'paricion'
                ? l10n.detailFormReproductionParicionTitle
                : l10n.detailFormReproductionTitle,
          ),
        ),
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
                        DateFormat('dd/MM/yyyy').format(_serviceDate),
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
                            : DateFormat('dd/MM/yyyy').format(_expectedCalvingDate!),
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
