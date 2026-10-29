/// registro › view › RegistroProduccionPage
///
/// Form page for recording a production record (weight gain, milk, body condition).
/// Provides [RegistroBloc] and dispatches [RegistroProduccionSubmitted].
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

/// Page wrapper that provides [RegistroBloc] for the production registration form.
class RegistroProduccionPage extends StatelessWidget {
  const RegistroProduccionPage({super.key});

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
      child: const _RegistroProduccionView(),
    );
  }
}

/// Internal form view for production registration.
class _RegistroProduccionView extends StatefulWidget {
  const _RegistroProduccionView();

  @override
  State<_RegistroProduccionView> createState() =>
      _RegistroProduccionViewState();
}

class _RegistroProduccionViewState extends State<_RegistroProduccionView> {
  final _formKey = GlobalKey<FormState>();
  final _valueCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _scoreCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  var _type = ProductionRecordType.weighing;
  var _date = DateTime.now();
  AnimalEntity? _selectedAnimal;

  @override
  void dispose() {
    _valueCtrl.dispose();
    _unitCtrl.dispose();
    _scoreCtrl.dispose();
    _notesCtrl.dispose();
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

    final rawValue = _valueCtrl.text.trim();
    final parsedValue = parseFormDouble(rawValue);
    if (rawValue.isNotEmpty && parsedValue == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormNumberInvalid)),
      );
      return;
    }
    if (parsedValue != null && parsedValue <= 0) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormAmountPositive)),
      );
      return;
    }

    final rawScore = _scoreCtrl.text.trim();
    final parsedScore = parseFormInt(rawScore);
    if (rawScore.isNotEmpty && parsedScore == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormProductionScoreInvalid)),
      );
      return;
    }
    if (parsedScore != null && (parsedScore < 0 || parsedScore > 9)) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormProductionScoreRange)),
      );
      return;
    }

    if (_type == ProductionRecordType.bodyConditionScore &&
        parsedScore == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormProductionScoreRequired)),
      );
      return;
    }

    if ((_type == ProductionRecordType.weighing ||
            _type == ProductionRecordType.weightGain ||
            _type == ProductionRecordType.production) &&
        parsedValue == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormProductionValueRequired)),
      );
      return;
    }

    final hasUnit = _unitCtrl.text.trim().isNotEmpty;
    final hasNotes = _notesCtrl.text.trim().isNotEmpty;
    if (_type == ProductionRecordType.fatteningStart &&
        parsedValue == null &&
        parsedScore == null &&
        !hasUnit &&
        !hasNotes) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormProductionDataRequired)),
      );
      return;
    }

    if (_type == ProductionRecordType.fatteningEnd &&
        parsedValue == null &&
        parsedScore == null &&
        !hasUnit &&
        !hasNotes) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormProductionDataRequired)),
      );
      return;
    }

    final record = ProductionRecord(
      date: _date,
      type: _type,
      value: parsedValue,
      unit: _unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim(),
      score: parsedScore,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    context.read<RegistroBloc>().add(
      RegistroProduccionSubmitted(
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
            SnackBar(content: Text(l10n.detailFormProductionSaved)),
          );
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
            recordStyle: RecordFormStyle.production,
            title: l10n.detailFormProductionTitle,
            assetPath: AppAssetPaths.recordProduction,
            fallbackIcon: Icons.agriculture_outlined,
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
              AppSelectField<ProductionRecordType>(
                value: _type,
                labelText: l10n.detailFormProductionType,
                requiredField: true,
                items: ProductionRecordType.values,
                itemLabel: (type) => type.displayName,
                onChanged: (v) {
                  if (v != null) setState(() => _type = v);
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
                controller: _valueCtrl,
                labelText: l10n.detailFormProductionValue,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final raw = value?.trim() ?? '';
                  final parsed = parseFormDouble(raw);
                  final requiresValue =
                      _type == ProductionRecordType.weighing ||
                      _type == ProductionRecordType.weightGain ||
                      _type == ProductionRecordType.production;
                  if (requiresValue && raw.isEmpty) {
                    return l10n.detailFormProductionValueRequired;
                  }
                  if (raw.isNotEmpty && parsed == null) {
                    return l10n.detailFormNumberInvalid;
                  }
                  return parsed != null && parsed <= 0
                      ? l10n.detailFormAmountPositive
                      : null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _unitCtrl,
                labelText: l10n.detailFormProductionUnit,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _scoreCtrl,
                labelText: l10n.detailFormProductionScore,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final raw = value?.trim() ?? '';
                  final parsed = parseFormInt(raw);
                  if (_type == ProductionRecordType.bodyConditionScore &&
                      raw.isEmpty) {
                    return l10n.detailFormProductionScoreRequired;
                  }
                  if (raw.isNotEmpty && parsed == null) {
                    return l10n.detailFormProductionScoreInvalid;
                  }
                  return parsed != null && (parsed < 0 || parsed > 9)
                      ? l10n.detailFormProductionScoreRange
                      : null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _notesCtrl,
                labelText: l10n.fieldNotes,
                maxLines: 2,
              ),
            ],
          );
        },
      ),
    );
  }
}
