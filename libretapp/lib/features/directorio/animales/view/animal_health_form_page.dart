/// features > directorio > animales > view > animal_health_form_page — full-screen health record form.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/features/directorio/animales/advisor/livestock_advisor.dart';
import 'package:libretapp/features/directorio/animales/advisor/widgets/advisor_tips_panel.dart';
import 'package:libretapp/core/assets/app_asset_paths.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_record_assets.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/theme.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/editable_record_repository.dart';

class AnimalHealthFormPage extends StatefulWidget {
  const AnimalHealthFormPage({
    required this.animalUuid,
    this.recordId,
    super.key,
  });

  final String animalUuid;

  /// Id of the health record being corrected, or null to add a new one.
  final String? recordId;

  bool get isEditing => recordId != null;

  @override
  State<AnimalHealthFormPage> createState() => _AnimalHealthFormPageState();
}

class _AnimalHealthFormPageState extends State<AnimalHealthFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _productController;
  late final TextEditingController _doseController;
  late final TextEditingController _appliedByController;
  late final TextEditingController _causeController;
  late final TextEditingController _notesController;

  final _medicineBatchController = TextEditingController();
  final _withdrawalController = TextEditingController();
  HealthRecordType _type = HealthRecordType.vaccine;
  DateTime _date = DateTime.now();
  DateTime? _nextDate;
  bool _saving = false;
  bool _loading = false;
  AnimalEntity? _animal;
  HealthRecord? _lastRecord;
  HealthRecord? _editing;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _productController = TextEditingController();
    _doseController = TextEditingController();
    _appliedByController = TextEditingController();
    _causeController = TextEditingController();
    _notesController = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final animal = await locator<AnimalRepository>().getByUuid(
        widget.animalUuid,
      );
      if (animal == null) throw StateError('Animal no encontrado.');
      final records = await locator<HealthRecordRepository>().getHealthRecords(
        widget.animalUuid,
      );
      final record = widget.isEditing
          ? records.where((r) => r.id == widget.recordId).firstOrNull
          : null;
      if (widget.isEditing && record == null)
        throw StateError('El registro ya no existe.');
      if (!mounted) return;
      setState(() {
        _animal = animal;
        _lastRecord = records.firstOrNull;
        _editing = record;
        if (record != null) {
          _productController.text = record.product;
          _medicineBatchController.text = record.medicineBatch ?? '';
          _withdrawalController.text = record.withdrawalDays?.toString() ?? '';
          _doseController.text = record.dose ?? '';
          _appliedByController.text = record.appliedBy ?? '';
          _causeController.text = record.cause ?? '';
          _notesController.text = record.notes ?? '';
          _type = record.type;
          _date = record.date;
          _nextDate = record.nextDueDate;
        }
      });
    } catch (error) {
      if (mounted) setState(() => _loadError = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyLastRecord() {
    final last = _lastRecord;
    if (last == null) return;
    setState(() {
      _type = last.type;
      _productController.text = last.product;
      _doseController.text = last.dose ?? '';
      _appliedByController.text = last.appliedBy ?? '';
      _causeController.text = last.cause ?? '';
      _notesController.text = '';
      _nextDate = null;
    });
  }

  @override
  void dispose() {
    _medicineBatchController.dispose();
    _withdrawalController.dispose();
    _productController.dispose();
    _doseController.dispose();
    _appliedByController.dispose();
    _causeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving ||
        _loading ||
        _loadError != null ||
        (widget.isEditing && _editing == null))
      return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    try {
      final animal =
          _animal ??
          await locator<AnimalRepository>().getByUuid(widget.animalUuid);
      if (animal == null) throw StateError('Animal no encontrado.');
      AnimalRecordValidation.operation(
        animal,
        _date,
        editing: widget.isEditing,
      );
      final repository = locator<HealthRecordRepository>();
      final edited = _editing;
      final record = HealthRecord(
        id: edited?.id,
        date: _date,
        type: _type,
        product: _productController.text.trim(),
        dose: _doseController.text.trim().isEmpty
            ? null
            : _doseController.text.trim(),
        appliedBy: _appliedByController.text.trim().isEmpty
            ? null
            : _appliedByController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        nextDueDate: _nextDate,
        cause: _causeController.text.trim().isEmpty
            ? null
            : _causeController.text.trim(),
        medicineBatch: _medicineBatchController.text.trim().isEmpty
            ? null
            : _medicineBatchController.text.trim(),
        withdrawalDays: int.tryParse(_withdrawalController.text.trim()),
        withdrawalEndDate:
            (int.tryParse(_withdrawalController.text.trim()) ?? 0) > 0
            ? _date.add(
                Duration(days: int.parse(_withdrawalController.text.trim())),
              )
            : null,
        recordUuid: edited?.recordUuid,
        updatedAt: edited?.updatedAt,
      );

      if (edited != null &&
          repository is EditableRecordRepository<HealthRecord>) {
        await (repository as EditableRecordRepository<HealthRecord>)
            .updateRecord(widget.animalUuid, record);
      } else {
        await repository.addHealthRecord(widget.animalUuid, record);
      }
      var agendaNeedsRetry = false;
      try {
        final animal = _animal;
        if (animal != null) {
          await locator<HealthCareCycleService>().replace(
            animal: animal,
            previous: edited,
            current: record,
          );
        }
        // HealthRecord remains the source of truth; Agenda is reconciled from
        // it immediately so an explicit next date appears in both views.
        await locator<AgendaReminderSyncService>().sync();
      } catch (error, stackTrace) {
        // The health record is already durable at this point. A failure in the
        // derived care/calendar projection must not tell the user that the
        // health operation failed or prevent returning the successful result.
        agendaNeedsRetry = true;
        LoggerService.e(
          'Registro sanitario guardado, pero Agenda requiere reconciliación: $error',
          tag: 'AnimalHealthFormPage',
          stackTrace: stackTrace,
        );
      }
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            agendaNeedsRetry
                ? 'Registro guardado; Agenda se actualizará al sincronizar.'
                : edited != null
                ? l10n.recordEditSaved
                : l10n.detailFormHealthSaved,
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
      recordStyle: RecordFormStyle.health,
      onCancel: () => Navigator.of(context).pop(),
      title: widget.isEditing
          ? l10n.recordEditTitle
          : l10n.detailFormHealthTitle,
      contextLabel: animalRecordContextLabel(_animal),
      contextIcon: Icons.pets_outlined,
      saving: _saving,
      loading: _loading,
      formKey: _formKey,
      onSave: _save,
      saveLabel: l10n.actionSave,
      assetPath: assetForHealthRecordType(_type) ?? AppAssetPaths.healthVaccine,
      fallbackIcon: fallbackIconForHealthRecordType(_type),
      fields: [
        if (_loadError != null) ...[
          Text(_loadError!),
          TextButton(onPressed: _load, child: const Text('Reintentar')),
        ],
        if (_lastRecord != null) ...[
          AppChip(
            icon: Icons.replay,
            label:
                'Repetir: ${_lastRecord!.product} · ${_lastRecord!.type.name}',
            tone: AppChipTone.info,
            onTap: _applyLastRecord,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        AppSelectField<HealthRecordType>(
          value: _type,
          labelText: l10n.detailFormHealthType,
          requiredField: AnimalRecordValidation.requiresProduct(_type),
          items: HealthRecordType.values,
          itemLabel: (type) => type.displayName,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _type = value);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _productController,
          labelText: l10n.detailFormHealthProduct,
          requiredField: AnimalRecordValidation.requiresProduct(_type),
          validator: (value) =>
              AnimalRecordValidation.requiresProduct(_type) &&
                  (value == null || value.trim().isEmpty)
              ? l10n.detailFormHealthProductRequired
              : null,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _doseController,
                labelText: l10n.detailFormHealthDose,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppTextField(
                controller: _appliedByController,
                labelText: l10n.detailFormHealthAppliedBy,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _medicineBatchController,
          labelText: l10n.detailFormHealthMedicineBatch,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _withdrawalController,
          labelText: l10n.detailFormHealthWithdrawalDays,
          helperText: l10n.detailFormHealthWithdrawalHelper,
          keyboardType: TextInputType.number,
          validator: (value) => value == null || value.trim().isEmpty
              ? null
              : (int.tryParse(value.trim()) == null ||
                        int.parse(value.trim()) < 0
                    ? l10n.detailFormNumberInvalid
                    : null),
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
          controller: _causeController,
          labelText: l10n.detailFormHealthCause,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _notesController,
          labelText: l10n.fieldNotes,
          maxLines: 2,
        ),
        const SizedBox(height: AppSpacing.md),
        if (_animal != null) ...[
          AdvisorTipsPanel(
            tips: LivestockAdvisor.forHealth(
              _animal!,
              HealthRecord(
                date: _date,
                type: _type,
                product: _productController.text.trim().isEmpty
                    ? 'N/A'
                    : _productController.text.trim(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
