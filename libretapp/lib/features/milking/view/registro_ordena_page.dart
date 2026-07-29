library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/milking/application/milking_cubit.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class RegistroOrdenaPage extends StatelessWidget {
  const RegistroOrdenaPage({this.initialAnimalUuid, super.key});

  final String? initialAnimalUuid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MilkingCubit(
        repository: locator<MilkingRepository>(),
        animalRepository: locator<AnimalRepository>(),
        lotesRepository: locator<LotesRepository>(),
      )..load(presetAnimalUuid: initialAnimalUuid),
      child: const _RegistroOrdenaView(),
    );
  }
}

class _RegistroOrdenaView extends StatefulWidget {
  const _RegistroOrdenaView();

  @override
  State<_RegistroOrdenaView> createState() => _RegistroOrdenaViewState();
}

class _RegistroOrdenaViewState extends State<_RegistroOrdenaView> {
  final _individualAmountCtrl = TextEditingController();
  final Map<String, TextEditingController> _groupControllers = {};
  String? _selectedAnimalUuid;
  bool _presetApplied = false;

  @override
  void dispose() {
    _individualAmountCtrl.dispose();
    for (final controller in _groupControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  int? _parseMilliliters(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    final liters = double.tryParse(normalized);
    if (liters == null || !liters.isFinite || liters <= 0) return null;
    return (liters * 1000).round();
  }

  String _formatLiters(int milliliters) {
    final value = milliliters / 1000;
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
  }

  String _animalLabel(AnimalEntity animal) {
    final name = animal.customName?.trim();
    return name == null || name.isEmpty
        ? animal.earTagNumber
        : '${animal.earTagNumber} · $name';
  }

  AnimalEntity? _animalByUuid(MilkingState state, String uuid) {
    for (final animal in state.animals) {
      if (animal.uuid == uuid) return animal;
    }
    return null;
  }

  Future<bool> _confirmUnusualAmount(int milliliters) async {
    if (milliliters <= 100000) return true;
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.detailFormMilkingUnusualAmountTitle),
            content: Text(
              l10n.detailFormMilkingUnusualAmountMessage(
                _formatLiters(milliliters),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.detailFormMilkingReviewAgain),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.actionConfirm),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _saveVolume(String animalUuid, String raw) async {
    final milliliters = _parseMilliliters(raw);
    if (milliliters == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).detailFormMilkingInvalidVolume),
        ),
      );
      return false;
    }
    if (!await _confirmUnusualAmount(milliliters) || !mounted) return false;
    final cubit = context.read<MilkingCubit>();
    await cubit.upsertAnimalVolume(
      animalUuid: animalUuid,
      volumeMilliliters: milliliters,
    );
    // A failure here is already surfaced by the BlocConsumer's listener
    // (which shows state.errorMessage in a SnackBar), so just report
    // success/failure back to the caller without duplicating that.
    return cubit.state.status != MilkingLoadStatus.failure;
  }

  Future<bool> _addIndividual() async {
    final animalUuid = _selectedAnimalUuid;
    if (animalUuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).detailFormMilkingSelectAnimalFirst,
          ),
        ),
      );
      return false;
    }
    final saved = await _saveVolume(animalUuid, _individualAmountCtrl.text);
    if (saved && mounted) {
      setState(() {
        _selectedAnimalUuid = null;
        _individualAmountCtrl.clear();
      });
    }
    return saved;
  }

  Future<bool> _commitGroup(MilkingState state) async {
    final animals = state.animalsForLote(state.session?.sourceLoteUuid);
    for (final animal in animals) {
      final controller = _groupControllers[animal.uuid];
      if (controller == null) continue;
      final raw = controller.text.trim();
      final existing = state.entryForAnimal(animal.uuid);
      if (raw.isEmpty) {
        if (existing != null) {
          await context.read<MilkingCubit>().removeAnimal(animal.uuid);
        }
        continue;
      }
      final parsed = _parseMilliliters(raw);
      if (parsed == null) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).detailFormMilkingCheckAnimalVolume(_animalLabel(animal)),
            ),
          ),
        );
        return false;
      }
      if (existing?.volumeMilliliters != parsed) {
        final confirmed = await _confirmUnusualAmount(parsed);
        if (!mounted) return false;
        if (!confirmed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                ).detailFormMilkingReviewBeforeContinue,
              ),
            ),
          );
          return false;
        }
        final cubit = context.read<MilkingCubit>();
        await cubit.upsertAnimalVolume(
          animalUuid: animal.uuid,
          volumeMilliliters: parsed,
        );
        // A failure here is already surfaced by the BlocConsumer's listener.
        if (cubit.state.status == MilkingLoadStatus.failure) return false;
      }
    }
    return true;
  }

  Future<void> _finalize(MilkingState state) async {
    FocusScope.of(context).unfocus();
    if (state.captureMode == MilkingCaptureMode.group) {
      if (!await _commitGroup(state) || !mounted) return;
    } else if (_selectedAnimalUuid != null &&
        _individualAmountCtrl.text.trim().isNotEmpty) {
      if (!await _addIndividual()) return;
    }
    if (!mounted) return;
    await context.read<MilkingCubit>().finalize();
  }

  Future<AnimalEntity?> _showAnimalPicker(MilkingState state) async {
    var query = '';
    final l10n = AppLocalizations.of(context);
    return showModalBottomSheet<AnimalEntity>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final filtered = state.animals.where((animal) {
            final haystack = [
              animal.earTagNumber,
              animal.customName ?? '',
              animal.visualId ?? '',
            ].join(' ').toLowerCase();
            return haystack.contains(query.toLowerCase());
          }).toList();
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.72,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: l10n.detailFormMilkingSearchHint,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) => setSheetState(() => query = value),
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(child: Text(l10n.detailFormMilkingNoResults))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final animal = filtered[index];
                              return ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.pets),
                                ),
                                title: Text(_animalLabel(animal)),
                                subtitle: Text(
                                  '${animal.breed} · '
                                  '${animal.productionStage.displayName}',
                                ),
                                trailing:
                                    animal.productionStage ==
                                        ProductionStage.lactating
                                    ? Chip(
                                        label: Text(
                                          animal.productionStage.displayName,
                                        ),
                                      )
                                    : null,
                                onTap: () => Navigator.pop(context, animal),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDate(MilkingSession session) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: session.occurredAt,
      firstDate: DateTime(session.occurredAt.year - 5),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;
    final combined = DateTime(
      picked.year,
      picked.month,
      picked.day,
      session.occurredAt.hour,
      session.occurredAt.minute,
    );
    if (combined.isAfter(DateTime.now())) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).detailFormMilkingFutureDateTime,
          ),
        ),
      );
      return;
    }
    await context.read<MilkingCubit>().updateSchedule(occurredAt: combined);
  }

  Future<void> _pickTime(MilkingSession session) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(session.occurredAt),
    );
    if (picked == null || !mounted) return;
    final combined = DateTime(
      session.occurredAt.year,
      session.occurredAt.month,
      session.occurredAt.day,
      picked.hour,
      picked.minute,
    );
    if (combined.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).detailFormMilkingFutureDateTime,
          ),
        ),
      );
      return;
    }
    await context.read<MilkingCubit>().updateSchedule(
      occurredAt: combined,
      shift: MilkingShift.fromTime(combined),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MilkingCubit, MilkingState>(
      listener: (context, state) {
        if (!_presetApplied &&
            state.status == MilkingLoadStatus.ready &&
            state.presetAnimalUuid != null) {
          _presetApplied = true;
          final exists = state.animals.any(
            (animal) => animal.uuid == state.presetAnimalUuid,
          );
          if (exists) {
            setState(() => _selectedAnimalUuid = state.presetAnimalUuid);
          }
        }
        if (state.status == MilkingLoadStatus.completed) {
          final messenger = ScaffoldMessenger.of(context);
          final l10n = AppLocalizations.of(context);
          Navigator.of(context).pop(true);
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.detailFormMilkingSaved)),
          );
        } else if (state.status == MilkingLoadStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        if (state.status == MilkingLoadStatus.initial ||
            state.status == MilkingLoadStatus.loading) {
          return const Scaffold(
            appBar: _MilkingAppBar(),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.session == null) {
          return Scaffold(
            appBar: const _MilkingAppBar(),
            body: Center(
              child: FilledButton(
                onPressed: () => context.read<MilkingCubit>().load(),
                child: Text(AppLocalizations.of(context).actionRetry),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: const _MilkingAppBar(),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(MilkingState state) {
    final session = state.session!;
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _buildScheduleCard(session),
        const SizedBox(height: 16),
        SegmentedButton<MilkingCaptureMode>(
          segments: [
            ButtonSegment(
              value: MilkingCaptureMode.individual,
              icon: const Icon(Icons.pets),
              label: Text(l10n.detailFormMilkingIndividualMode),
            ),
            ButtonSegment(
              value: MilkingCaptureMode.group,
              icon: const Icon(Icons.groups),
              label: Text(l10n.detailFormMilkingGroupMode),
            ),
          ],
          selected: {state.captureMode},
          onSelectionChanged: (selection) =>
              context.read<MilkingCubit>().setCaptureMode(selection.first),
        ),
        const SizedBox(height: 16),
        if (state.captureMode == MilkingCaptureMode.individual)
          _buildIndividualCapture(state)
        else
          _buildGroupCapture(state),
        const SizedBox(height: 18),
        _buildSummary(state),
        if (state.entries.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            l10n.detailFormMilkingRegisteredCows,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...state.entries.map((entry) => _buildSavedEntry(state, entry)),
        ],
        const SizedBox(height: 20),
        _buildSaveButton(state),
      ],
    );
  }

  Widget _buildScheduleCard(MilkingSession session) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(session),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      DateFormat('dd/MM/yyyy').format(session.occurredAt),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(session),
                    icon: const Icon(Icons.schedule),
                    label: Text(DateFormat('HH:mm').format(session.occurredAt)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<MilkingShift>(
              initialValue: session.shift,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).detailFormMilkingShift,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: MilkingShift.values
                  .map(
                    (shift) => DropdownMenuItem(
                      value: shift,
                      child: Text(shift.label),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (shift) {
                if (shift != null) {
                  context.read<MilkingCubit>().updateSchedule(shift: shift);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualCapture(MilkingState state) {
    final selected = _selectedAnimalUuid == null
        ? null
        : _animalByUuid(state, _selectedAnimalUuid!);
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.detailFormMilkingRegisterCow,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final animal = await _showAnimalPicker(state);
                if (animal == null || !mounted) return;
                final existing = state.entryForAnimal(animal.uuid);
                setState(() {
                  _selectedAnimalUuid = animal.uuid;
                  _individualAmountCtrl.text = existing == null
                      ? ''
                      : _formatLiters(existing.volumeMilliliters);
                });
              },
              icon: const Icon(Icons.search),
              label: Text(
                selected == null
                    ? l10n.detailFormMilkingSelectAnimal
                    : _animalLabel(selected),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _individualAmountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: InputDecoration(
                labelText: l10n.detailFormMilkingLitersLabel,
                suffixText: 'L',
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _addIndividual(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _addIndividual,
              icon: const Icon(Icons.add),
              label: Text(l10n.detailFormMilkingAddContinue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCapture(MilkingState state) {
    final session = state.session!;
    final animals = state.animalsForLote(session.sourceLoteUuid);
    LoteEntity? selectedLote;
    for (final lote in state.lotes) {
      if (lote.uuid == session.sourceLoteUuid) selectedLote = lote;
    }
    for (final animal in animals) {
      final existing = state.entryForAnimal(animal.uuid);
      _groupControllers.putIfAbsent(
        animal.uuid,
        () => TextEditingController(
          text: existing == null
              ? ''
              : _formatLiters(existing.volumeMilliliters),
        ),
      );
    }
    final excluded = selectedLote == null
        ? 0
        : selectedLote.animalUuids.length - animals.length;
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: session.sourceLoteUuid,
          decoration: InputDecoration(
            labelText: l10n.detailFormMilkingGroupLabel,
            border: const OutlineInputBorder(),
          ),
          items: state.lotes
              .map(
                (lote) => DropdownMenuItem(
                  value: lote.uuid,
                  child: Text('${lote.name} (${lote.animalUuids.length})'),
                ),
              )
              .toList(growable: false),
          onChanged: context.read<MilkingCubit>().selectLote,
        ),
        if (excluded > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.detailFormMilkingExcludedAnimals(excluded),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 12),
        if (session.sourceLoteUuid == null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(l10n.detailFormMilkingSelectLotePrompt),
            ),
          )
        else if (animals.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(l10n.detailFormMilkingEmptyLote),
            ),
          )
        else
          ...animals.map((animal) => _buildGroupAnimalRow(state, animal)),
        if (session.sourceLoteUuid != null)
          TextButton.icon(
            onPressed: () => context.read<MilkingCubit>().setCaptureMode(
              MilkingCaptureMode.individual,
            ),
            icon: const Icon(Icons.add),
            label: Text(l10n.detailFormMilkingAddOutsideLote),
          ),
      ],
    );
  }

  Widget _buildGroupAnimalRow(MilkingState state, AnimalEntity animal) {
    final controller = _groupControllers[animal.uuid]!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_animalLabel(animal)),
                  Text(
                    animal.productionStage.displayName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 112,
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  ).detailFormMilkingLitersShort,
                  suffixText: 'L',
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (raw) async {
                  if (raw.trim().isEmpty) {
                    await context.read<MilkingCubit>().removeAnimal(
                      animal.uuid,
                    );
                  } else {
                    await _saveVolume(animal.uuid, raw);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(MilkingState state) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.water_drop, size: 34),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_formatLiters(state.totalMilliliters)} L',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).detailFormMilkingCowCount(state.entries.length),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedEntry(MilkingState state, MilkingEntry entry) {
    final animal = _animalByUuid(state, entry.animalUuid);
    final l10n = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.pets),
        title: Text(animal == null ? entry.animalUuid : _animalLabel(animal)),
        subtitle: Text('${_formatLiters(entry.volumeMilliliters)} L'),
        trailing: IconButton(
          tooltip: l10n.actionDelete,
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.detailFormMilkingRemoveEntryTitle),
                content: Text(l10n.detailFormMilkingRemoveEntryMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.actionCancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(l10n.actionRemove),
                  ),
                ],
              ),
            );
            if (confirmed == true && mounted) {
              await context.read<MilkingCubit>().removeAnimal(entry.animalUuid);
              _groupControllers[entry.animalUuid]?.clear();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSaveButton(MilkingState state) {
    final saving = state.status == MilkingLoadStatus.saving;
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: saving ? null : () => _finalize(state),
        icon: saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.check),
        label: Text(
          saving
              ? l10n.detailFormMilkingSaving
              : l10n.detailFormMilkingFinalize,
        ),
      ),
    );
  }
}

class _MilkingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MilkingAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context).detailFormMilkingTitle),
    );
  }
}
