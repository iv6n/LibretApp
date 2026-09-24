/// features > directorio > animales > view > animal_movement_form_page — full-screen movement record form.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/assets/app_asset_paths.dart';
import 'package:libretapp/features/directorio/animales/advisor/livestock_advisor.dart';
import 'package:libretapp/features/directorio/animales/advisor/widgets/advisor_tips_panel.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/location/gps_capture_service.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/editable_record_repository.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/theme/theme.dart';

class AnimalMovementFormPage extends StatefulWidget {
  const AnimalMovementFormPage({
    required this.animalUuid,
    this.recordId,
    super.key,
  });

  final String animalUuid;

  /// Id of the movement being corrected, or null to add a new one.
  final String? recordId;

  bool get isEditing => recordId != null;

  @override
  State<AnimalMovementFormPage> createState() => _AnimalMovementFormPageState();
}

class _AnimalMovementFormPageState extends State<AnimalMovementFormPage> {
  late final TextEditingController _fromController;
  late final TextEditingController _toController;
  late final TextEditingController _notesController;
  late final TextEditingController _movedByController;

  MovementReason _reason = MovementReason.paddockRotation;
  DateTime _date = DateTime.now();
  bool _saving = false;
  bool _loading = false;
  bool _captureGps = false;
  AnimalEntity? _animal;
  MovementRecord? _editing;

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController();
    _toController = TextEditingController();
    _notesController = TextEditingController();
    _movedByController = TextEditingController();
    _loadAnimal();
    if (widget.isEditing) _load();
  }

  Future<void> _loadAnimal() async {
    final animal = await locator<AnimalRepository>().getByUuid(
      widget.animalUuid,
    );
    if (!mounted) return;
    setState(() => _animal = animal);
  }

  /// Hydrates the form from the movement being corrected.
  Future<void> _load() async {
    setState(() => _loading = true);
    final records = await locator<MovementRecordRepository>()
        .getMovementRecords(widget.animalUuid);
    if (!mounted) return;

    final record = records
        .where((candidate) => candidate.id == widget.recordId)
        .firstOrNull;
    if (record == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).recordEditNotFound),
        ),
      );
      context.pop(false);
      return;
    }

    setState(() {
      _editing = record;
      _fromController.text = record.fromLocation ?? '';
      _toController.text = record.toLocation;
      _notesController.text = record.notes ?? '';
      _movedByController.text = record.movedBy ?? '';
      _reason = record.reason;
      _date = record.date;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _notesController.dispose();
    _movedByController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || _loading || (widget.isEditing && _editing == null)) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_toController.text.trim().isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormMovementToRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final geo = _captureGps
          ? await locator<GpsCaptureService>().tryCapture()
          : null;
      final repository = locator<MovementRecordRepository>();
      final edited = _editing;

      if (edited != null &&
          repository is EditableRecordRepository<MovementRecord>) {
        await (repository as EditableRecordRepository<MovementRecord>)
            .updateRecord(
              widget.animalUuid,
              MovementRecord(
                id: edited.id,
                fromLocation: _fromController.text.trim().isEmpty
                    ? null
                    : _fromController.text.trim(),
                toLocation: _toController.text.trim(),
                date: _date,
                reason: _reason,
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
                movedBy: _movedByController.text.trim().isEmpty
                    ? null
                    : _movedByController.text.trim(),
                recordUuid: edited.recordUuid,
                updatedAt: edited.updatedAt,
                latitude: geo?.latitude ?? edited.latitude,
                longitude: geo?.longitude ?? edited.longitude,
                accuracyMeters: geo?.accuracyMeters ?? edited.accuracyMeters,
              ),
            );
      } else {
        await repository.addMovementRecord(
          widget.animalUuid,
          MovementRecord(
            id: null,
            fromLocation: _fromController.text.trim().isEmpty
                ? null
                : _fromController.text.trim(),
            toLocation: _toController.text.trim(),
            date: _date,
            reason: _reason,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            movedBy: _movedByController.text.trim().isEmpty
                ? null
                : _movedByController.text.trim(),
            latitude: geo?.latitude,
            longitude: geo?.longitude,
            accuracyMeters: geo?.accuracyMeters,
          ),
        );
      }
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            edited != null
                ? l10n.recordEditSaved
                : l10n.detailFormMovementSaved,
          ),
        ),
      );
      context.pop(true);
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGenericSave)));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppFormScaffold(
      title: widget.isEditing
          ? l10n.recordEditTitle
          : l10n.detailFormMovementTitle,
      saving: _saving,
      loading: _loading,
      onSave: _save,
      saveLabel: l10n.actionSave,
      assetPath: AppAssetPaths.recordMovement,
      fallbackIcon: Icons.swap_horiz,
      fields: [
        AppSelectField<MovementReason>(
          value: _reason,
          items: MovementReason.values,
          itemLabel: (reason) => reason.displayName,
          labelText: l10n.detailFormMovementReason,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _reason = value);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _fromController,
          labelText: l10n.detailFormMovementFrom,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _toController,
          labelText: l10n.detailFormMovementTo,
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
          controller: _notesController,
          labelText: l10n.fieldNotes,
          maxLines: 2,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _movedByController,
          labelText: l10n.detailFormMovementMovedBy,
        ),
        const SizedBox(height: 16),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _captureGps,
          onChanged: _saving
              ? null
              : (value) => setState(() => _captureGps = value),
          title: const Text('Capturar ubicación GPS'),
          subtitle: const Text(
            'Opcional; si falla, el movimiento se guarda manualmente.',
          ),
          secondary: const Icon(Icons.gps_fixed_outlined),
        ),
        const SizedBox(height: 16),
        if (_animal != null) ...[
          AdvisorTipsPanel(
            tips: LivestockAdvisor.forMovement(
              _animal!,
              MovementRecord(
                id: null,
                fromLocation: null,
                toLocation: _toController.text.trim(),
                date: _date,
                reason: _reason,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
