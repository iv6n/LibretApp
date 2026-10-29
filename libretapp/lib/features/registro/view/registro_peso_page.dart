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
import 'package:libretapp/core/utils/number_parsing.dart';
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
import 'package:libretapp/theme/theme.dart';

/// Page wrapper that provides [RegistroBloc] for the weight registration form.
class RegistroPesoPage extends StatelessWidget {
  const RegistroPesoPage({super.key});

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
  final _formKey = GlobalKey<FormState>();
  final _weightCtrl = TextEditingController();
  var _method = WeightMethod.scale;
  var _date = DateTime.now();
  String? _notes;
  AnimalEntity? _selectedAnimal;
  bool _readingScale = false;

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

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final parsed = parseFormDouble(_weightCtrl.text);
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
      animalUuid: _selectedAnimal!.uuid,
      lotUuid: _selectedAnimal!.batchUuid,
      createdAt: DateTime.now(),
    );
    context.read<RegistroBloc>().add(
      RegistroPesoSubmitted(animalUuid: _selectedAnimal!.uuid, record: record),
    );
  }

  Future<void> _readFromScale() async {
    if (_readingScale || !ReleaseFeatures.hardwareIntegrationsEnabled) return;
    setState(() => _readingScale = true);
    try {
      final adapter = locator<ScaleAdapter>();
      final devices = await adapter.discover();
      if (devices.isEmpty) throw StateError('No hay básculas disponibles.');
      await adapter.connect(devices.first);
      final reading = await adapter.readStable();
      if (!mounted) return;
      if (!reading.stable) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Lectura inestable'),
            content: const Text(
              'La báscula todavía no está estable. ¿Quieres usar esta lectura?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Usar lectura'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
      }
      if (!mounted) return;
      _weightCtrl.text = reading.valueKg.toStringAsFixed(1);
      setState(() => _method = WeightMethod.scale);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lectura de báscula cargada.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo leer la báscula.')),
      );
    } finally {
      if (mounted) setState(() => _readingScale = false);
    }
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
            SnackBar(
              content: Text(state.errorMessage ?? l10n.errorGenericSave),
            ),
          );
          context.read<RegistroBloc>().add(const RegistroReset());
        }
      },
      child: BlocBuilder<RegistroBloc, RegistroState>(
        buildWhen: (prev, curr) => prev.status != curr.status,
        builder: (context, state) {
          final isSaving = state.status == RegistroStatus.loading;
          return AppFormScaffold(
            recordStyle: RecordFormStyle.weight,
            title: l10n.detailFormWeightTitle,
            assetPath: AppAssetPaths.healthWeight,
            fallbackIcon: Icons.monitor_weight_outlined,
            formKey: _formKey,
            saving: isSaving,
            onSave: _save,
            saveLabel: l10n.actionSave,
            onCancel: () => Navigator.of(context).pop(),
            cancelLabel: l10n.actionCancel,
            fields: [
              AnimalSelector(
                selectedAnimal: _selectedAnimal,
                onSelected: (a) => setState(() => _selectedAnimal = a),
              ),
              const SizedBox(height: AppSpacing.md),
              if (ReleaseFeatures.hardwareIntegrationsEnabled) Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: isSaving || _readingScale ? null : _readFromScale,
                  icon: _readingScale
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sensors_outlined),
                  label: const Text('Tomar lectura de báscula'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _weightCtrl,
                labelText: l10n.detailFormWeightValue,
                requiredField: true,
                validator: (value) {
                  final parsed = parseFormDouble(value ?? '');
                  if (parsed == null) return l10n.detailFormWeightErrorInvalid;
                  return parsed <= 0 ? l10n.detailFormAmountPositive : null;
                },
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSelectField<WeightMethod>(
                value: _method,
                labelText: l10n.detailFormWeightMethod,
                requiredField: true,
                items: WeightMethod.values,
                itemLabel: (method) => method == WeightMethod.scale
                    ? l10n.detailFormWeightMethodScale
                    : l10n.detailFormWeightMethodEstimated,
                onChanged: (value) {
                  if (value != null) setState(() => _method = value);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppDateField(
                value: _date,
                labelText: l10n.fieldDate,
                firstDate: DateTime(_date.year - 5),
                lastDate: DateTime(_date.year + 1),
                onChanged: (value) {
                  if (value != null) setState(() => _date = value);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                labelText: l10n.fieldNotesOptional,
                maxLines: 2,
                onChanged: (value) => _notes = value,
              ),
            ],
          );
        },
      ),
    );
  }
}
