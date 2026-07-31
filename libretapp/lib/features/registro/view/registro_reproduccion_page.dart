/// registro › view › RegistroReproduccionPage
///
/// Form page for recording a reproductive event (service, insemination, calving).
/// Provides [RegistroBloc] and dispatches [RegistroReproduccionSubmitted].
///
/// Layer: view (presentation)
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
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

  /// The confirmed-pregnant cycle awaiting a calving, if the selected female
  /// has one. Its presence is what turns this page into a calving form.
  ReproductionRecord? _openCycle;
  var _calvingMode = false;
  var _calvingDate = DateTime.now();
  CalvingOutcome? _calvingOutcome;
  int? _calvingEase;

  @override
  void initState() {
    super.initState();
    final isParicionPreset = widget.preset?.toLowerCase() == 'paricion';
    if (isParicionPreset) {
      _serviceType = ServiceType.naturalService;
      _expectedCalvingDate = DateTime.now();
    }
  }

  Future<void> _onAnimalSelected(AnimalEntity? animal) async {
    setState(() {
      _selectedAnimal = animal;
      _openCycle = null;
      _calvingMode = false;
    });
    if (animal == null) return;

    final records = await locator<ReproductionRecordRepository>()
        .getReproductionRecords(animal.uuid);
    if (!mounted) return;

    final open = ReproductiveKpiService.openCycleOf(records);
    setState(() {
      _openCycle = open;
      // Landing here from the "parición" shortcut means the calving is the
      // reason the user opened the page.
      _calvingMode =
          open != null && widget.preset?.toLowerCase() == 'paricion';
      if (open != null) {
        _calvingDate = DateTime.now();
        _calvingOutcome = CalvingOutcome.liveBirth;
      }
    });
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

    if (_calvingMode) {
      _saveCalving(messenger);
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

  /// Runs after the calving itself is stored: updates the dam and offers to
  /// register the newborn with its parentage already filled in.
  Future<void> _afterCalvingSaved() async {
    final dam = _selectedAnimal!;
    final cycle = _openCycle!;

    await _updateDamAfterCalving(dam);
    if (!mounted) return;

    final outcome = _calvingOutcome ?? CalvingOutcome.liveBirth;
    if (outcome != CalvingOutcome.liveBirth) {
      Navigator.of(context).pop();
      return;
    }

    final registerCalf = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Parto registrado'),
        content: const Text(
          '¿Quieres dar de alta la cría ahora? Su padre y madre quedarán '
          'enlazados automáticamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Más tarde'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Registrar cría'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (registerCalf != true) {
      Navigator.of(context).pop();
      return;
    }

    final seed = AnimalRegistrationSeed(
      species: dam.species,
      sex: Sex.female,
      ageMonths: 0,
      breed: dam.breed,
      damUuid: dam.uuid,
      sireUuid: cycle.maleSireUuid,
      birthDate: _calvingDate,
    );

    final calfUuid = await context.pushNamed(
      AppRoutes.nameAnimalNuevo,
      extra: seed,
    );
    if (!mounted) return;

    if (calfUuid is String && calfUuid.isNotEmpty) {
      await _linkOffspring(dam.uuid, cycle, calfUuid);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _updateDamAfterCalving(AnimalEntity dam) async {
    final repository = locator<AnimalRepository>();
    await repository.update(
      dam.copyWith(
        reproductiveStatus: ReproductiveStatus.lactating,
        expectedCalvingDate: null,
        lastUpdateDate: DateTime.now(),
        synced: false,
      ),
    );
  }

  Future<void> _linkOffspring(
    String damUuid,
    ReproductionRecord cycle,
    String calfUuid,
  ) async {
    final repository = locator<ReproductionRecordRepository>();
    // Re-read so the calving fields written a moment ago are not overwritten
    // by this stale in-memory copy.
    final records = await repository.getReproductionRecords(damUuid);
    final stored = records.firstWhere(
      (record) => record.id == cycle.id,
      orElse: () => cycle,
    );

    await repository.addReproductionRecord(
      damUuid,
      stored.copyWith(
        offspringUuids: [...stored.offspringUuids, calfUuid],
      ),
    );
  }

  void _saveCalving(ScaffoldMessengerState messenger) {
    final cycle = _openCycle!;

    if (_calvingDate.isBefore(cycle.serviceDate)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('El parto no puede ser anterior al servicio.'),
        ),
      );
      return;
    }

    final gestation = _calvingDate.difference(cycle.serviceDate).inDays;
    if (gestation < _minPlausibleGestationDays ||
        gestation > _maxPlausibleGestationDays) {
      // A gestation well outside the normal range usually means a mistyped
      // date, but it can also be a real abortion — warn, never block.
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Gestación de $gestation días, fuera del rango habitual. '
            'Verifica la fecha si no fue un aborto.',
          ),
        ),
      );
    }

    // Keeping the id makes this an update of the open cycle rather than a new
    // record: addReproductionRecord upserts when the record carries one.
    context.read<RegistroBloc>().add(
      RegistroReproduccionSubmitted(
        animalUuid: _selectedAnimal!.uuid,
        record: cycle.copyWith(
          actualCalvingDate: _calvingDate,
          calvingOutcome: _calvingOutcome ?? CalvingOutcome.liveBirth,
          calvingEase: _calvingEase,
          calvingNotes: _notes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<RegistroBloc, RegistroState>(
      listener: (context, state) {
        if (state.status == RegistroStatus.success) {
          context.read<RegistroBloc>().add(const RegistroReset());
          if (_calvingMode) {
            unawaited(_afterCalvingSaved());
            return;
          }
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.detailFormReproductionSaved)),
          );
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
                onSelected: (a) => unawaited(_onAnimalSelected(a)),
              ),
              if (_openCycle != null) ...[
                const SizedBox(height: 12),
                _OpenCycleBanner(
                  cycle: _openCycle!,
                  calvingMode: _calvingMode,
                  onChanged: (value) => setState(() => _calvingMode = value),
                ),
              ],
              const SizedBox(height: 16),
              if (_calvingMode) ...[
                _CalvingFields(
                  calvingDate: _calvingDate,
                  outcome: _calvingOutcome,
                  ease: _calvingEase,
                  onDateChanged: (value) =>
                      setState(() => _calvingDate = value),
                  onOutcomeChanged: (value) =>
                      setState(() => _calvingOutcome = value),
                  onEaseChanged: (value) => setState(() => _calvingEase = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: l10n.detailFormReproductionNotes,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (v) => _notes = v.trim().isEmpty ? null : v.trim(),
                ),
                const SizedBox(height: 24),
                _SaveButton(onPressed: _save, label: 'Registrar parto'),
              ] else ...[
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
              _SaveButton(onPressed: _save, label: l10n.actionSave),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Plausible bovine gestation window. Outside it the date is probably a typo,
/// but an abortion is also real, so the form warns instead of blocking.
const int _minPlausibleGestationDays = 230;
const int _maxPlausibleGestationDays = 300;

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistroBloc, RegistroState>(
      buildWhen: (prev, curr) => prev.status != curr.status,
      builder: (context, state) {
        final isSaving = state.status == RegistroStatus.loading;
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: isSaving ? null : onPressed,
            child: isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(label),
          ),
        );
      },
    );
  }
}

/// Announces that the selected female is carrying a confirmed pregnancy, and
/// lets the user switch the form over to registering its calving.
class _OpenCycleBanner extends StatelessWidget {
  const _OpenCycleBanner({
    required this.cycle,
    required this.calvingMode,
    required this.onChanged,
  });

  final ReproductionRecord cycle;
  final bool calvingMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expected = cycle.expectedCalvingDate;
    final subtitle = expected == null
        ? 'Servicio del ${DateFormat('dd/MM/yyyy').format(cycle.serviceDate)}'
        : 'Parto esperado el ${DateFormat('dd/MM/yyyy').format(expected)}';

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.secondaryContainer,
      child: SwitchListTile(
        value: calvingMode,
        onChanged: onChanged,
        title: const Text('Registrar el parto de este ciclo'),
        subtitle: Text(subtitle),
        secondary: const Icon(Icons.child_friendly),
      ),
    );
  }
}

class _CalvingFields extends StatelessWidget {
  const _CalvingFields({
    required this.calvingDate,
    required this.outcome,
    required this.ease,
    required this.onDateChanged,
    required this.onOutcomeChanged,
    required this.onEaseChanged,
  });

  final DateTime calvingDate;
  final CalvingOutcome? outcome;
  final int? ease;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<CalvingOutcome> onOutcomeChanged;
  final ValueChanged<int?> onEaseChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.event),
          label: Text('Parto: ${DateFormat('dd/MM/yyyy').format(calvingDate)}'),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: calvingDate,
              firstDate: DateTime(calvingDate.year - 2),
              lastDate: DateTime.now().add(const Duration(days: 1)),
            );
            if (picked != null) onDateChanged(picked);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<CalvingOutcome>(
          initialValue: outcome ?? CalvingOutcome.liveBirth,
          decoration: const InputDecoration(
            labelText: 'Desenlace',
            border: OutlineInputBorder(),
          ),
          items: CalvingOutcome.values
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(value.displayName),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onOutcomeChanged(value);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int?>(
          initialValue: ease,
          decoration: const InputDecoration(
            labelText: 'Dificultad del parto',
            border: OutlineInputBorder(),
            helperText: 'Escala 1 a 5, de sin asistencia a cesárea',
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text('Sin registrar')),
            DropdownMenuItem(value: 1, child: Text('1 — Sin asistencia')),
            DropdownMenuItem(value: 2, child: Text('2 — Asistencia leve')),
            DropdownMenuItem(value: 3, child: Text('3 — Asistencia mecánica')),
            DropdownMenuItem(value: 4, child: Text('4 — Distocia severa')),
            DropdownMenuItem(value: 5, child: Text('5 — Cesárea')),
          ],
          onChanged: onEaseChanged,
        ),
      ],
    );
  }
}
