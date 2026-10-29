/// features > directorio > animales > view > animal_weight_form_page — full-screen weight record form.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/assets/app_asset_paths.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/platform/release_features.dart';
import 'package:libretapp/core/utils/number_parsing.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/editable_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/rfid/rfid.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/theme.dart';

class AnimalWeightFormPage extends StatefulWidget {
  const AnimalWeightFormPage({
    required this.animalUuid,
    this.recordId,
    super.key,
  });

  final String animalUuid;

  /// Id of the weighing being corrected, or null to add a new one.
  final String? recordId;

  bool get isEditing => recordId != null;

  @override
  State<AnimalWeightFormPage> createState() => _AnimalWeightFormPageState();
}

class _AnimalWeightFormPageState extends State<AnimalWeightFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weightController;
  late final TextEditingController _notesController;

  WeightMethod _method = WeightMethod.scale;
  DateTime _date = DateTime.now();
  bool _saving = false;
  bool _loading = false;
  String? _loadError;
  WeightRecord? _editing;
  AnimalEntity? _animal;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _notesController = TextEditingController();
    _loadAnimal();
    if (widget.isEditing) _load();
  }

  Future<void> _loadAnimal() async {
    if (!locator.isRegistered<AnimalRepository>()) return;
    try {
      final animal = await locator<AnimalRepository>().getByUuid(
        widget.animalUuid,
      );
      if (mounted) setState(() => _animal = animal);
    } catch (_) {
      // The form can still show a safe missing-animal label.
    }
  }

  /// Hydrates the form from the record being corrected.
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final records = await locator<WeightRecordRepository>().getWeightRecords(
        widget.animalUuid,
      );
      if (!mounted) return;

      final record = records
          .where((candidate) => candidate.id == widget.recordId)
          .firstOrNull;
      if (record == null) {
        // Deleted from another screen while this one was opening.
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
        _weightController.text = record.weight.toString();
        _notesController.text = record.notes ?? '';
        _method = record.method;
        _date = record.date;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadError = 'load');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || _loading || (widget.isEditing && _editing == null)) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final parsed = parseFormDouble(_weightController.text);
    if (parsed == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormWeightErrorInvalid)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final notes = _notesController.text.trim();
      final repository = locator<WeightRecordRepository>();
      final edited = _editing;
      final animal = locator.isRegistered<AnimalRepository>()
          ? await locator<AnimalRepository>().getByUuid(widget.animalUuid)
          : null;

      if (edited != null &&
          repository is EditableRecordRepository<WeightRecord>) {
        await (repository as EditableRecordRepository<WeightRecord>)
            .updateRecord(
              widget.animalUuid,
              WeightRecord(
                id: edited.id,
                date: _date,
                weight: parsed,
                method: _method,
                notes: notes.isEmpty ? null : notes,
                measuredBy: edited.measuredBy,
                recordUuid: edited.recordUuid,
                updatedAt: edited.updatedAt,
                animalUuid: edited.animalUuid ?? widget.animalUuid,
                lotUuid: edited.lotUuid,
                createdAt: edited.createdAt,
              ),
            );
      } else {
        await repository.addWeightRecord(
          widget.animalUuid,
          WeightRecord(
            id: null,
            date: _date,
            weight: parsed,
            method: _method,
            notes: notes.isEmpty ? null : notes,
            animalUuid: widget.animalUuid,
            lotUuid: animal?.batchUuid,
            createdAt: DateTime.now(),
          ),
        );
      }
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            edited != null ? l10n.recordEditSaved : l10n.detailFormWeightSaved,
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

  Future<void> _readFromScale() async {
    try {
      final adapter = locator<ScaleAdapter>();
      final devices = await adapter.discover();
      if (devices.isNotEmpty) await adapter.connect(devices.first);
      final reading = await adapter.readStable();
      if (!mounted) return;
      _weightController.text = reading.valueKg.toStringAsFixed(1);
      setState(() => _method = WeightMethod.scale);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lectura de báscula cargada.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo leer la báscula.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) return RecordLoadFailure(onRetry: _load);
    final l10n = AppLocalizations.of(context);

    return AppFormScaffold(
      recordStyle: RecordFormStyle.weight,
      onCancel: () => Navigator.of(context).pop(),
      title: widget.isEditing
          ? l10n.recordEditTitle
          : l10n.detailFormWeightTitle,
      contextLabel: animalRecordContextLabel(_animal),
      contextIcon: Icons.pets_outlined,
      saving: _saving,
      loading: _loading,
      formKey: _formKey,
      onSave: _save,
      saveLabel: l10n.actionSave,
      assetPath: AppAssetPaths.healthWeight,
      fallbackIcon: Icons.monitor_weight_outlined,
      fields: [
        if (ReleaseFeatures.hardwareIntegrationsEnabled) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _saving || _loading ? null : _readFromScale,
              icon: const Icon(Icons.sensors_outlined),
              label: const Text('Tomar lectura de báscula'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        AppTextField(
          controller: _weightController,
          labelText: l10n.detailFormWeightValue,
          requiredField: true,
          validator: (value) {
            final parsed = parseFormDouble(value ?? '');
            return parsed == null || parsed <= 0
                ? l10n.detailFormWeightErrorInvalid
                : null;
          },
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
            if (value == null) return;
            setState(() => _method = value);
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
          controller: _notesController,
          labelText: l10n.fieldNotesOptional,
          maxLines: 2,
        ),
      ],
    );
  }
}
