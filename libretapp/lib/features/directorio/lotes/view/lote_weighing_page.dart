/// Rapid, field-friendly weighing screen for a lot.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/application/lote_weighing_cubit.dart';
import 'package:libretapp/features/directorio/lotes/domain/services/weight_performance_calculator.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class LoteWeighingPage extends StatelessWidget {
  LoteWeighingPage({
    required this.loteUuid,
    AnimalRepository? animalRepository,
    LotesRepository? lotesRepository,
    WeightRecordRepository? weightRepository,
    super.key,
  }) : animalRepository = animalRepository ?? locator<AnimalRepository>(),
       lotesRepository = lotesRepository ?? locator<LotesRepository>(),
       weightRepository = weightRepository ?? locator<WeightRecordRepository>();

  final String loteUuid;
  final AnimalRepository animalRepository;
  final LotesRepository lotesRepository;
  final WeightRecordRepository weightRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoteWeighingCubit(
        animalRepository: animalRepository,
        lotesRepository: lotesRepository,
        weightRepository: weightRepository,
      )..load(loteUuid),
      child: const _LoteWeighingView(),
    );
  }
}

class _LoteWeighingView extends StatefulWidget {
  const _LoteWeighingView();

  @override
  State<_LoteWeighingView> createState() => _LoteWeighingViewState();
}

class _LoteWeighingViewState extends State<_LoteWeighingView> {
  final _controllers = <String, TextEditingController>{};
  final _focusNodes = <String, FocusNode>{};

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShellChromeScope(
      visible: false,
      child: BlocListener<LoteWeighingCubit, LoteWeighingState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          if (state.status == LoteWeighingStatus.saved) {
            context.pop(true);
            return;
          }
          if (state.errorMessage != null &&
              state.status != LoteWeighingStatus.failure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).loteWeightTitle),
            actions: [
              IconButton(
                tooltip: AppLocalizations.of(context).loteWeightDate,
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: () => _pickDate(context),
              ),
            ],
          ),
          body: BlocBuilder<LoteWeighingCubit, LoteWeighingState>(
            builder: (context, state) {
              if (state.isLoading ||
                  state.status == LoteWeighingStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == LoteWeighingStatus.failure &&
                  state.animals.isEmpty) {
                return _MessageState(
                  message:
                      state.errorMessage ??
                      AppLocalizations.of(context).loteWeightLoadError,
                );
              }
              if (state.animals.isEmpty) {
                return _MessageState(
                  message: AppLocalizations.of(
                    context,
                  ).loteWeightNoActiveAnimals,
                );
              }

              return _buildBody(context, state);
            },
          ),
          bottomNavigationBar:
              BlocBuilder<LoteWeighingCubit, LoteWeighingState>(
                builder: (context, state) => SafeArea(
                  minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: FilledButton.icon(
                    onPressed: state.isSaving
                        ? null
                        : () => context.read<LoteWeighingCubit>().save(),
                    icon: state.isSaving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      state.isSaving
                          ? AppLocalizations.of(context).loteWeightSaving
                          : AppLocalizations.of(context).loteWeightSave,
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, LoteWeighingState state) {
    final cubit = context.read<LoteWeighingCubit>();
    final l10n = AppLocalizations.of(context);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: state.animals.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _Header(
            loteName: state.lote?.name ?? 'Lote',
            measuredAt: state.measuredAt,
            onPickDate: () => _pickDate(context),
            capturedLabel: l10n.loteWeightCaptured(
              state.weights.length,
              state.animals.length,
            ),
          );
        }
        final animal = state.animals[index - 1];
        return _AnimalWeightRow(
          animal: animal,
          controller: _controllerFor(animal, state),
          focusNode: _focusNodeFor(animal.uuid),
          previousWeight: cubit.previousWeight(animal.uuid),
          preview: cubit.preview(animal.uuid),
          errorText: state.errors[animal.uuid],
          onChanged: (value) => cubit.setWeight(animal.uuid, value),
          onSubmitted: (_) => _focusNext(index - 1, state.animals),
        );
      },
    );
  }

  TextEditingController _controllerFor(
    AnimalEntity animal,
    LoteWeighingState state,
  ) {
    return _controllers.putIfAbsent(
      animal.uuid,
      () => TextEditingController(
        text: state.weights[animal.uuid]?.toString() ?? '',
      ),
    );
  }

  FocusNode _focusNodeFor(String uuid) =>
      _focusNodes.putIfAbsent(uuid, FocusNode.new);

  void _focusNext(int index, List<AnimalEntity> animals) {
    if (index + 1 >= animals.length) return;
    final next = _focusNodeFor(animals[index + 1].uuid);
    FocusScope.of(context).requestFocus(next);
  }

  Future<void> _pickDate(BuildContext context) async {
    final cubit = context.read<LoteWeighingCubit>();
    final initial = cubit.state.measuredAt ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDate: initial,
    );
    if (selected != null && context.mounted) cubit.setMeasuredAt(selected);
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.loteName,
    required this.measuredAt,
    required this.onPickDate,
    required this.capturedLabel,
  });

  final String loteName;
  final DateTime? measuredAt;
  final VoidCallback onPickDate;
  final String capturedLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loteName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  capturedLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onPickDate,
            icon: const Icon(Icons.event_outlined, size: 18),
            label: Text(_dateLabel(measuredAt)),
          ),
        ],
      ),
    );
  }
}

class _AnimalWeightRow extends StatelessWidget {
  const _AnimalWeightRow({
    required this.animal,
    required this.controller,
    required this.focusNode,
    required this.previousWeight,
    required this.preview,
    required this.errorText,
    required this.onChanged,
    required this.onSubmitted,
  });

  final AnimalEntity animal;
  final TextEditingController controller;
  final FocusNode focusNode;
  final double? previousWeight;
  final AnimalWeightPerformance? preview;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final gain = preview?.gainKg;
    final adg = preview?.adgKgPerDay;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Text(
                animal.earTagNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.next,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.loteWeightKg,
                  suffixText: 'kg',
                  errorText: errorText,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 94,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    previousWeight == null
                        ? l10n.loteWeightPrevious
                        : '${l10n.loteWeightPrevious}: ${_kg(previousWeight)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (gain != null)
                    Text(
                      '${l10n.loteWeightGain}: ${_signed(gain)} kg',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: gain >= 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if (adg != null)
                    Text(
                      '${l10n.loteWeightAdg}: ${_signed(adg)} kg/d',
                      style: theme.textTheme.labelSmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );
}

String _dateLabel(DateTime? value) {
  if (value == null) return 'Sin fecha';
  return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}';
}

String _kg(double? value) => value == null ? '—' : value.toStringAsFixed(1);

String _signed(double value) =>
    '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}';
