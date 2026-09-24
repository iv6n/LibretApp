/// registro › view › RegistroMovimientoPage
///
/// Form page for recording an animal movement/location transfer.
/// Provides [RegistroBloc] and dispatches [RegistroMovimientoSubmitted].
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
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/theme.dart';

/// Page wrapper that provides [RegistroBloc] for the movement registration form.
class RegistroMovimientoPage extends StatelessWidget {
  const RegistroMovimientoPage({super.key});

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
      child: const _RegistroMovimientoView(),
    );
  }
}

/// Internal form view for movement registration.
class _RegistroMovimientoView extends StatefulWidget {
  const _RegistroMovimientoView();

  @override
  State<_RegistroMovimientoView> createState() =>
      _RegistroMovimientoViewState();
}

class _RegistroMovimientoViewState extends State<_RegistroMovimientoView> {
  final _formKey = GlobalKey<FormState>();
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _movedByCtrl = TextEditingController();
  var _reason = MovementReason.paddockRotation;
  var _date = DateTime.now();
  AnimalEntity? _selectedAnimal;
  bool _captureGps = false;

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _notesCtrl.dispose();
    _movedByCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (_selectedAnimal == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormAnimalRequired)),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_toCtrl.text.trim().isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormMovementToRequired)),
      );
      return;
    }

    final fromText = _fromCtrl.text.trim();
    final toText = _toCtrl.text.trim();
    if (fromText.isNotEmpty && fromText.toLowerCase() == toText.toLowerCase()) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormMovementDifferentLocations)),
      );
      return;
    }

    final geo = _captureGps
        ? await locator<GpsCaptureService>().tryCapture()
        : null;
    if (!mounted) return;
    final record = MovementRecord(
      fromLocation: fromText.isEmpty ? null : fromText,
      toLocation: toText,
      date: _date,
      reason: _reason,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      movedBy: _movedByCtrl.text.trim().isEmpty
          ? null
          : _movedByCtrl.text.trim(),
      latitude: geo?.latitude,
      longitude: geo?.longitude,
      accuracyMeters: geo?.accuracyMeters,
    );
    context.read<RegistroBloc>().add(
      RegistroMovimientoSubmitted(
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
          ).showSnackBar(SnackBar(content: Text(l10n.detailFormMovementSaved)));
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
            title: l10n.detailFormMovementTitle,
            assetPath: AppAssetPaths.recordMovement,
            fallbackIcon: Icons.swap_horiz,
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
              AppSelectField<MovementReason>(
                value: _reason,
                labelText: l10n.detailFormMovementReason,
                requiredField: true,
                items: MovementReason.values,
                itemLabel: (reason) => reason.displayName,
                onChanged: (v) {
                  if (v != null) setState(() => _reason = v);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _captureGps,
                onChanged: isSaving
                    ? null
                    : (value) => setState(() => _captureGps = value),
                title: const Text('Capturar ubicación GPS'),
                subtitle: const Text(
                  'Opcional; si falla, el movimiento se guarda manualmente.',
                ),
                secondary: const Icon(Icons.gps_fixed_outlined),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _fromCtrl,
                labelText: l10n.detailFormMovementFrom,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _toCtrl,
                labelText: l10n.detailFormMovementTo,
                requiredField: true,
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.detailFormMovementToRequired
                    : null,
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
                controller: _movedByCtrl,
                labelText: l10n.detailFormMovementMovedBy,
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
