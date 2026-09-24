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
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/registro/bloc/index.dart';
import 'package:libretapp/features/registro/widgets/animal_selector.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_record_assets.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/theme.dart';

/// Page wrapper that provides [RegistroBloc] for the sanitary registration form.
class RegistroSanitarioPage extends StatelessWidget {
  const RegistroSanitarioPage({super.key});

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
  final _formKey = GlobalKey<FormState>();
  final _productCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _appliedByCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _causeCtrl = TextEditingController();
  final _medicineBatchCtrl = TextEditingController();
  final _withdrawalDaysCtrl = TextEditingController();
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
    _medicineBatchCtrl.dispose();
    _withdrawalDaysCtrl.dispose();
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

    final withdrawalDays = int.tryParse(_withdrawalDaysCtrl.text.trim());
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
      medicineBatch: _medicineBatchCtrl.text.trim().isEmpty
          ? null
          : _medicineBatchCtrl.text.trim(),
      withdrawalDays: withdrawalDays,
      withdrawalEndDate: withdrawalDays == null || withdrawalDays == 0
          ? null
          : _date.add(Duration(days: withdrawalDays)),
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
            title: l10n.detailFormHealthTitle,
            assetPath: assetForHealthRecordType(_type),
            fallbackIcon: fallbackIconForHealthRecordType(_type),
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
              AppSelectField<HealthRecordType>(
                value: _type,
                labelText: l10n.detailFormHealthType,
                requiredField: true,
                items: HealthRecordType.values,
                itemLabel: (type) => type.displayName,
                onChanged: (v) {
                  if (v != null) setState(() => _type = v);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _productCtrl,
                labelText: l10n.detailFormHealthProduct,
                requiredField: true,
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.detailFormHealthProductRequired
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _doseCtrl,
                labelText: l10n.detailFormHealthDose,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _appliedByCtrl,
                labelText: l10n.detailFormHealthAppliedBy,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _medicineBatchCtrl,
                labelText: l10n.detailFormHealthMedicineBatch,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _withdrawalDaysCtrl,
                labelText: l10n.detailFormHealthWithdrawalDays,
                helperText: l10n.detailFormHealthWithdrawalHelper,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final days = int.tryParse(value.trim());
                  return days == null || days < 0
                      ? l10n.detailFormNumberInvalid
                      : null;
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
              AppDateField(
                value: _nextDate,
                labelText: l10n.detailFormHealthNext,
                emptyLabel: l10n.detailFormHealthNext,
                clearTooltip: l10n.actionClearDate,
                firstDate: _date,
                lastDate: DateTime(_date.year + 5),
                allowClear: true,
                validator: (value) => value != null && value.isBefore(_date)
                    ? l10n.detailFormHealthNextAfterDate
                    : null,
                onChanged: (value) => setState(() => _nextDate = value),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _causeCtrl,
                labelText: l10n.detailFormHealthCause,
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
