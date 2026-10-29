/// registro › view › RegistroReproduccionPage
///
/// Form page for recording a reproductive event (service, insemination, calving).
/// Provides [RegistroBloc] and dispatches [RegistroReproduccionSubmitted].
///
/// Layer: view (presentation)
library;

import 'dart:async';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:uuid/uuid.dart';
import 'package:libretapp/features/directorio/animales/widgets/offspring_editor.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/registro/bloc/index.dart';
import 'package:libretapp/features/registro/widgets/animal_selector.dart';
import 'package:libretapp/l10n/app_localizations.dart';

/// Page wrapper that provides [RegistroBloc] for the reproduction registration form.
class RegistroReproduccionPage extends StatelessWidget {
  const RegistroReproduccionPage({
    this.preset,
    this.animalUuid,
    this.recordId,
    super.key,
  });
  final String? animalUuid;
  final String? recordId;

  final String? preset;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegistroBloc(
        reproductionRepo: locator<ReproductionRecordRepository>(),
      ),
      child: _RegistroReproduccionView(
        preset: preset,
        animalUuid: animalUuid,
        recordId: recordId,
      ),
    );
  }
}

/// Internal form view for reproduction registration.
class _RegistroReproduccionView extends StatefulWidget {
  const _RegistroReproduccionView({
    this.preset,
    this.animalUuid,
    this.recordId,
  });
  final String? animalUuid;
  final String? recordId;

  final String? preset;

  @override
  State<_RegistroReproduccionView> createState() =>
      _RegistroReproduccionViewState();
}

class _RegistroReproduccionViewState extends State<_RegistroReproduccionView> {
  ReproductionRecord? _editing;
  ReproductionRecord? _submitted;
  bool _submitting = false;
  bool _loading = false;
  String? _loadError;
  var _serviceType = ServiceType.naturalService;
  var _serviceDate = DateTime.now();
  DateTime? _expectedCalvingDate;
  final _serviceNotesCtrl = TextEditingController();
  final _calvingNotesCtrl = TextEditingController();
  final _responsibleCtrl = TextEditingController();
  AnimalEntity? _selectedAnimal;

  /// Sire chosen from the herd. When set, the record carries his uuid and the
  /// link survives; a free-text name only ever reaches the display field.
  AnimalEntity? _selectedSire;
  final _externalSireCtrl = TextEditingController();

  /// The confirmed-pregnant cycle awaiting a calving, if the selected female
  /// has one. Its presence is what turns this page into a calving form.
  ReproductionRecord? _openCycle;

  /// The latest service still waiting for a pregnancy diagnosis. Until this
  /// existed there was no way to confirm a pregnancy after the animal was
  /// created, which left the calving step unreachable.
  ReproductionRecord? _pendingDiagnosis;

  var _calvingMode = false;
  var _calvingDate = DateTime.now();
  CalvingOutcome? _calvingOutcome;
  int? _calvingEase;

  var _diagnosisMode = false;
  var _diagnosisDate = DateTime.now();
  var _diagnosisResult = PregnancyCheckResult.positive;

  @override
  void initState() {
    super.initState();
    final isParicionPreset = widget.preset?.toLowerCase() == 'paricion';
    if (isParicionPreset) {
      _serviceType = ServiceType.naturalService;
    }
    _projectExpectedCalving();
    if (widget.animalUuid != null) _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final animal = await locator<AnimalRepository>().getByUuid(
        widget.animalUuid!,
      );
      if (animal == null) throw StateError('Animal no encontrado.');
      await _onAnimalSelected(animal);
      if (widget.recordId != null) {
        final records = await locator<ReproductionRecordRepository>()
            .getReproductionRecords(animal.uuid);
        final record = records
            .where((r) => r.id == widget.recordId)
            .firstOrNull;
        if (record == null) throw StateError('El registro ya no existe.');
        final sire = record.maleSireUuid == null
            ? null
            : await locator<AnimalRepository>().getByUuid(record.maleSireUuid!);
        if (!mounted) return;
        setState(() {
          _editing = record;
          _selectedSire = sire;
          _externalSireCtrl.text = sire == null
              ? record.maleSireIdentifier ?? ''
              : '';
          _serviceDate = record.serviceDate ?? DateTime.now();
          _serviceType = record.serviceType ?? ServiceType.naturalService;
          _expectedCalvingDate = record.expectedCalvingDate;
          _serviceNotesCtrl.text = record.notes ?? '';
          _calvingNotesCtrl.text = record.calvingNotes ?? '';
          _responsibleCtrl.text = record.servicedBy ?? '';
          if (record.serviceDate != null) _pendingDiagnosis = record;
          _openCycle = record;
          _calvingMode = record.hasCalved;
          _calvingDate = record.actualCalvingDate ?? DateTime.now();
          _calvingOutcome = record.calvingOutcome ?? CalvingOutcome.liveBirth;
          _calvingEase = record.calvingEase;
          _diagnosisDate = record.pregnancyCheckDate ?? DateTime.now();
          _diagnosisResult =
              record.pregnancyResult ?? PregnancyCheckResult.positive;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _loadError = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _submit(ReproductionRecord record) {
    try {
      final animal = _selectedAnimal!;
      AnimalRecordValidation.reproduction(record);
      AnimalRecordValidation.operation(
        animal,
        record.eventDate,
        editing: record.id != null,
      );
      if (animal.sex != Sex.female ||
          !AnimalRegistrationPolicy.forSpecies(
            animal.species,
          ).supportsReproduction) {
        throw ArgumentError('Selecciona una hembra reproductora.');
      }
      final submitted = record.copyWith(
        servicedBy: _responsibleCtrl.text.trim().isEmpty
            ? null
            : _responsibleCtrl.text.trim(),
        recordUuid: record.recordUuid ?? const Uuid().v4(),
      );
      setState(() {
        _submitting = true;
        _submitted = submitted;
      });
      context.read<RegistroBloc>().add(
        RegistroReproduccionSubmitted(
          animalUuid: animal.uuid,
          record: submitted,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  /// Fills the expected calving from the service date using the standard
  /// gestation, so the user gets a date without having to compute it. Manual
  /// edits win: this only ever writes when the field is still untouched.
  void _projectExpectedCalving() {
    _expectedCalvingDate = const ReproductionScheduler()
        .estimate(serviceDate: _serviceDate)
        .dueDate;
  }

  Future<void> _onAnimalSelected(AnimalEntity? animal) async {
    setState(() {
      _selectedAnimal = animal;
      _openCycle = null;
      _pendingDiagnosis = null;
      _calvingMode = false;
      _diagnosisMode = false;
    });
    if (animal == null) return;

    late List<ReproductionRecord> records;
    try {
      records = await locator<ReproductionRecordRepository>()
          .getReproductionRecords(animal.uuid);
    } catch (error) {
      if (mounted)
        setState(() => _loadError = 'No se pudieron cargar los ciclos: $error');
      return;
    }
    if (!mounted || _selectedAnimal?.uuid != animal.uuid) return;

    final open = ReproductiveKpiService.openCycleOf(records);
    final pending = ReproductiveKpiService.pendingDiagnosisOf(records);
    final current = open ?? pending;
    final sire = current?.maleSireUuid == null
        ? null
        : await locator<AnimalRepository>().getByUuid(current!.maleSireUuid!);
    if (!mounted || _selectedAnimal?.uuid != animal.uuid) return;
    setState(() {
      _loadError = null;
      _openCycle = open;
      _pendingDiagnosis = pending;
      _selectedSire = sire;
      _externalSireCtrl.text = current?.maleSireIdentifier ?? "";
      _responsibleCtrl.text = current?.servicedBy ?? "";
      // Landing here from the "parición" shortcut means the calving is the
      // reason the user opened the page.
      _calvingMode = widget.preset?.toLowerCase() == 'paricion';
      if (open != null) {
        _calvingDate = DateTime.now();
        _calvingOutcome = CalvingOutcome.liveBirth;
      }
      if (pending != null) {
        _diagnosisDate = DateTime.now();
        _diagnosisResult = PregnancyCheckResult.positive;
      }
    });
  }

  /// Males of the same species, excluding the cow's own descendants so her
  /// son can never be offered as her sire.
  bool _isEligibleSire(AnimalEntity candidate) {
    if (candidate.sex != Sex.male ||
        !candidate.status.isInActiveHerd ||
        candidate.reproductiveStatus == ReproductiveStatus.neutered ||
        candidate.reproductiveStatus == ReproductiveStatus.retired)
      return false;
    final cow = _selectedAnimal;
    if (cow == null) return true;
    return candidate.species == cow.species && candidate.uuid != cow.uuid;
  }

  @override
  void dispose() {
    _externalSireCtrl.dispose();
    _serviceNotesCtrl.dispose();
    _calvingNotesCtrl.dispose();
    _responsibleCtrl.dispose();
    super.dispose();
  }

  String _cycleSubtitle(ReproductionRecord cycle) {
    final expected = cycle.expectedCalvingDate;
    return expected == null
        ? 'Servicio del ${DateFormat('dd/MM/yyyy').format(cycle.eventDate)}'
        : 'Parto esperado el ${DateFormat('dd/MM/yyyy').format(expected)}';
  }

  void _saveDiagnosis(ScaffoldMessengerState messenger) {
    final pending = _pendingDiagnosis!;

    if (_diagnosisDate.isBefore(pending.serviceDate!)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('El diagnóstico no puede ser anterior al servicio.'),
        ),
      );
      return;
    }

    _submit(
      pending.copyWith(
        pregnancyCheckDate: _diagnosisDate,
        pregnancyResult: _diagnosisResult,
        expectedCalvingDate: _diagnosisResult == PregnancyCheckResult.positive
            ? pending.expectedCalvingDate ??
                  const ReproductionScheduler()
                      .estimate(serviceDate: pending.serviceDate!)
                      .dueDate
            : null,
      ),
    );
  }

  void _save() {
    if (_submitting || _loading || _loadError != null) return;
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

    if (_diagnosisMode) {
      _saveDiagnosis(messenger);
      return;
    }

    if (_expectedCalvingDate != null &&
        _expectedCalvingDate!.isBefore(_serviceDate)) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormReproductionExpectedAfterDate)),
      );
      return;
    }

    final external = _externalSireCtrl.text.trim();
    final record = (_editing ?? const ReproductionRecord()).copyWith(
      kind: ReproductionRecordKind.service,
      serviceDate: _serviceDate,
      serviceType: _serviceType,
      maleSireUuid: _selectedSire?.uuid,
      maleSireIdentifier: _selectedSire != null
          ? primaryAnimalLabel(_selectedSire!)
          : (external.isEmpty ? null : external),
      expectedCalvingDate: _expectedCalvingDate,
      notes: _serviceNotesCtrl.text.trim().isEmpty
          ? null
          : _serviceNotesCtrl.text.trim(),
    );
    _submit(record);
  }

  /// Runs after the calving itself is stored: updates the dam and offers to
  /// register the newborn with its parentage already filled in.
  Future<void> _syncAgenda() async {
    if (!locator.isRegistered<AgendaReminderSyncService>()) return;
    try {
      await locator<AgendaReminderSyncService>().sync();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registro guardado. La agenda se actualizará al abrirla.',
            ),
          ),
        );
    }
  }

  Future<void> _finishService() async {
    await _syncAgenda();
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _afterCalvingSaved() async {
    await _syncAgenda();
    late List<ReproductionRecord> records;
    try {
      records = await locator<ReproductionRecordRepository>()
          .getReproductionRecords(_selectedAnimal!.uuid);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'El parto está guardado. Vincula la cría desde su historial. $error',
            ),
          ),
        );
        Navigator.of(context).pop(true);
      }
      return;
    }
    final stored = records
        .where(
          (r) =>
              r.recordUuid == _submitted?.recordUuid ||
              (r.id != null && r.id == _submitted?.id),
        )
        .firstOrNull;
    if (!mounted) return;
    if (stored != null && stored.calvingOutcome == CalvingOutcome.liveBirth) {
      await editOffspring(context, _selectedAnimal!, stored);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  void _saveCalving(ScaffoldMessengerState messenger) {
    final cycle = _editing ?? _openCycle ?? _pendingDiagnosis;
    final record =
        (cycle ??
                const ReproductionRecord(kind: ReproductionRecordKind.calving))
            .copyWith(
              maleSireUuid: _selectedSire?.uuid,
              maleSireIdentifier: _selectedSire != null
                  ? primaryAnimalLabel(_selectedSire!)
                  : _externalSireCtrl.text.trim().isEmpty
                  ? null
                  : _externalSireCtrl.text.trim(),
              actualCalvingDate: _calvingDate,
              calvingOutcome: _calvingOutcome ?? CalvingOutcome.liveBirth,
              calvingEase: _calvingEase,
              calvingNotes: _calvingNotesCtrl.text.trim().isEmpty
                  ? null
                  : _calvingNotesCtrl.text.trim(),
            );
    _submit(record);
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
          unawaited(_finishService());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.detailFormReproductionSaved)),
          );
        } else if (state.status == RegistroStatus.failure) {
          setState(() => _submitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? l10n.errorGenericSave),
            ),
          );
          context.read<RegistroBloc>().add(const RegistroReset());
        }
      },
      child: AppFormScaffold(
        title: _calvingMode
            ? l10n.detailFormReproductionParicionTitle
            : _diagnosisMode
            ? 'Diagnóstico de preñez'
            : l10n.detailFormReproductionTitle,
        recordStyle: _calvingMode
            ? RecordFormStyle.birth
            : RecordFormStyle.reproduction,
        saving: _submitting,
        loading: _loading,
        errorMessage: _loadError,
        onRetry: _loadInitial,
        onSave: _save,
        saveLabel: _diagnosisMode
            ? 'Guardar diagnóstico'
            : _calvingMode
            ? 'Registrar parto'
            : l10n.actionSave,
        onCancel: () => Navigator.of(context).pop(),
        cancelLabel: l10n.actionCancel,
        fields: [
          if (widget.animalUuid == null)
            AnimalSelector(
              eligible: (a) =>
                  a.status.isInActiveHerd &&
                  a.sex == Sex.female &&
                  AnimalRegistrationPolicy.forSpecies(
                    a.species,
                  ).supportsReproduction,
              selectedAnimal: _selectedAnimal,
              onSelected: (a) => unawaited(_onAnimalSelected(a)),
            ),
          if (_selectedAnimal != null) ...[
            const SizedBox(height: 12),
            _CycleBanner(
              icon: Icons.child_friendly,
              title: _openCycle == null && _pendingDiagnosis == null
                  ? 'Registrar parto sin servicio conocido'
                  : 'Registrar el parto de este ciclo',
              subtitle: _openCycle == null
                  ? 'Sin servicio conocido: no se inventará una fecha de monta.'
                  : _cycleSubtitle(_openCycle!),
              value: _calvingMode,
              onChanged: (value) => setState(() {
                _calvingMode = value;
                if (value) _diagnosisMode = false;
              }),
            ),
          ],
          if (_pendingDiagnosis != null) ...[
            const SizedBox(height: 12),
            _CycleBanner(
              icon: Icons.pregnant_woman,
              title: 'Registrar diagnóstico de preñez',
              subtitle:
                  'Servicio del '
                  '${DateFormat('dd/MM/yyyy').format(_pendingDiagnosis!.serviceDate!)}'
                  ' sin diagnosticar',
              value: _diagnosisMode,
              onChanged: (value) => setState(() {
                _diagnosisMode = value;
                if (value) _calvingMode = false;
              }),
            ),
          ],
          // Picking the sire from the herd is what fills maleSireUuid, and
          // that is what links the calf's paternal side, feeds the bull's
          // own service history and lets the inbreeding check work.
          AnimalSelector(
            label: l10n.detailFormReproductionSire,
            selectedAnimal: _selectedSire,
            eligible: _isEligibleSire,
            onSelected: (sire) => setState(() {
              _selectedSire = sire;
              if (sire != null) _externalSireCtrl.clear();
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _externalSireCtrl,
            enabled: _selectedSire == null,
            decoration: const InputDecoration(
              labelText: 'O semental externo al hato',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _responsibleCtrl,
            decoration: const InputDecoration(
              labelText: 'Responsable',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (_diagnosisMode) ...[
            _DiagnosisFields(
              checkDate: _diagnosisDate,
              result: _diagnosisResult,
              onDateChanged: (value) => setState(() => _diagnosisDate = value),
              onResultChanged: (value) =>
                  setState(() => _diagnosisResult = value),
            ),
          ] else if (_calvingMode) ...[
            _CalvingFields(
              calvingDate: _calvingDate,
              outcome: _calvingOutcome,
              ease: _calvingEase,
              onDateChanged: (value) => setState(() => _calvingDate = value),
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
              controller: _calvingNotesCtrl,
            ),
            if (_editing?.hasCalved == true &&
                _editing?.calvingOutcome == CalvingOutcome.liveBirth)
              TextButton(
                onPressed: () =>
                    editOffspring(context, _selectedAnimal!, _editing!),
                child: const Text('Crear o vincular cría'),
              ),
          ] else ...[
            DropdownButtonFormField<ServiceType>(
              isExpanded: true,
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
            AppDateField(
              labelText: 'Fecha de servicio',
              value: _serviceDate,
              firstDate: DateTime(_serviceDate.year - 5),
              lastDate: DateTime(_serviceDate.year + 1),
              onChanged: (date) {
                if (date == null) return;
                setState(() {
                  _serviceDate = date;
                  _projectExpectedCalving();
                });
              },
            ),
            const SizedBox(height: 16),
            AppDateField(
              labelText: l10n.detailFormReproductionExpectedCalving,
              value: _expectedCalvingDate,
              emptyLabel: 'Sin fecha estimada',
              firstDate: DateTime(_serviceDate.year - 1),
              lastDate: DateTime(_serviceDate.year + 2),
              onChanged: (date) {
                if (date != null) setState(() => _expectedCalvingDate = date);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: l10n.detailFormReproductionNotes,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
              controller: _serviceNotesCtrl,
            ),
          ],
        ],
      ),
    );
  }
}

/// Announces what the selected female's cycle is waiting for, and switches the
/// form over to that step. The page is one form with three modes — service,
/// diagnosis, calving — chosen from her actual state rather than from a menu.
class _CycleBanner extends StatelessWidget {
  const _CycleBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title),
        subtitle: Text(subtitle),
        secondary: Icon(icon),
      ),
    );
  }
}

class _DiagnosisFields extends StatelessWidget {
  const _DiagnosisFields({
    required this.checkDate,
    required this.result,
    required this.onDateChanged,
    required this.onResultChanged,
  });

  final DateTime checkDate;
  final PregnancyCheckResult result;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<PregnancyCheckResult> onResultChanged;

  static String _label(PregnancyCheckResult value) {
    switch (value) {
      case PregnancyCheckResult.positive:
        return 'Preñada';
      case PregnancyCheckResult.negative:
        return 'Vacía';
      case PregnancyCheckResult.uncertain:
        return 'Dudoso — repetir chequeo';
      case PregnancyCheckResult.notChecked:
        return 'Sin revisar';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.event),
          label: Text('Chequeo: ${DateFormat('dd/MM/yyyy').format(checkDate)}'),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: checkDate,
              firstDate: DateTime(checkDate.year - 2),
              lastDate: DateTime.now().add(const Duration(days: 1)),
            );
            if (picked != null) onDateChanged(picked);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<PregnancyCheckResult>(
          isExpanded: true,
          initialValue: result,
          decoration: const InputDecoration(
            labelText: 'Resultado',
            border: OutlineInputBorder(),
          ),
          items: PregnancyCheckResult.values
              .map(
                (value) =>
                    DropdownMenuItem(value: value, child: Text(_label(value))),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onResultChanged(value);
          },
        ),
      ],
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
          isExpanded: true,
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
          isExpanded: true,
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
