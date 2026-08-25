/// features > directorio > animales > view > animal_health_form_page — full-screen health record form.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/features/directorio/animales/advisor/livestock_advisor.dart';
import 'package:libretapp/features/directorio/animales/advisor/widgets/advisor_tips_panel.dart';
import 'package:libretapp/core/assets/app_asset_paths.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/record_form_scaffold.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_record_assets.dart';
import 'package:libretapp/l10n/app_localizations.dart';
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
  late final TextEditingController _productController;
  late final TextEditingController _doseController;
  late final TextEditingController _appliedByController;
  late final TextEditingController _causeController;
  late final TextEditingController _notesController;

  HealthRecordType _type = HealthRecordType.vaccine;
  DateTime _date = DateTime.now();
  DateTime? _nextDate;
  bool _saving = false;
  bool _loading = false;
  AnimalEntity? _animal;
  HealthRecord? _lastRecord;
  HealthRecord? _editing;

  @override
  void initState() {
    super.initState();
    _productController = TextEditingController();
    _doseController = TextEditingController();
    _appliedByController = TextEditingController();
    _causeController = TextEditingController();
    _notesController = TextEditingController();
    _loadAnimal();
    if (widget.isEditing) _load();
  }

  /// Hydrates the form from the record being corrected.
  Future<void> _load() async {
    setState(() => _loading = true);
    final records = await locator<HealthRecordRepository>().getHealthRecords(
      widget.animalUuid,
    );
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
      _productController.text = record.product;
      _doseController.text = record.dose ?? '';
      _appliedByController.text = record.appliedBy ?? '';
      _causeController.text = record.cause ?? '';
      _notesController.text = record.notes ?? '';
      _type = record.type;
      _date = record.date;
      _nextDate = record.nextDueDate;
      _loading = false;
    });
  }

  Future<void> _loadAnimal() async {
    final animal = await locator<AnimalRepository>().getByUuid(
      widget.animalUuid,
    );
    final records = await locator<HealthRecordRepository>().getHealthRecords(
      widget.animalUuid,
    );
    if (!mounted) return;
    setState(() {
      _animal = animal;
      _lastRecord = records.isNotEmpty ? records.first : null;
    });
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
    _productController.dispose();
    _doseController.dispose();
    _appliedByController.dispose();
    _causeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || _loading || (widget.isEditing && _editing == null)) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_productController.text.trim().isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormHealthProductRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
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
        medicineBatch: edited?.medicineBatch,
        withdrawalDays: edited?.withdrawalDays,
        withdrawalEndDate: edited?.withdrawalEndDate,
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

    return RecordFormScaffold(
      title: widget.isEditing
          ? l10n.recordEditTitle
          : l10n.detailFormHealthTitle,
      saving: _saving,
      loading: _loading,
      onSave: _save,
      saveLabel: l10n.actionSave,
      assetPath: assetForHealthRecordType(_type) ?? AppAssetPaths.healthVaccine,
      fallbackIcon: fallbackIconForHealthRecordType(_type),
      fields: [
        if (_lastRecord != null) ...[
          ActionChip(
            avatar: const Icon(Icons.replay, size: 16),
            label: Text(
              'Repetir: ${_lastRecord!.product} · ${_lastRecord!.type.name}',
              overflow: TextOverflow.ellipsis,
            ),
            onPressed: _applyLastRecord,
            side: BorderSide.none,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          ),
          const SizedBox(height: 12),
        ],
        DropdownButtonFormField<HealthRecordType>(
          initialValue: _type,
          decoration: InputDecoration(
            labelText: l10n.detailFormHealthType,
            border: const OutlineInputBorder(),
          ),
          items: HealthRecordType.values
              .map(
                (t) => DropdownMenuItem(value: t, child: Text(t.displayName)),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _type = value);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _productController,
          decoration: InputDecoration(
            labelText: l10n.detailFormHealthProduct,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _doseController,
                decoration: InputDecoration(
                  labelText: l10n.detailFormHealthDose,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _appliedByController,
                decoration: InputDecoration(
                  labelText: l10n.detailFormHealthAppliedBy,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.today),
                label: Text(DateFormat('dd/MM/yyyy').format(_date)),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(_date.year - 5),
                    lastDate: DateTime(_date.year + 1),
                  );
                  if (picked == null) return;
                  setState(() => _date = picked);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.event_available),
                label: Text(
                  _nextDate == null
                      ? l10n.detailFormHealthNext
                      : DateFormat('dd/MM/yyyy').format(_nextDate!),
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _nextDate ?? _date,
                    firstDate: DateTime(_date.year),
                    lastDate: DateTime(_date.year + 5),
                  );
                  setState(() => _nextDate = picked);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _causeController,
          decoration: InputDecoration(
            labelText: l10n.detailFormHealthCause,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: l10n.fieldNotes,
            border: const OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
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
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
