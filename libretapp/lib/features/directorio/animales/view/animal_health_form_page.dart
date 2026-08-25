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
import 'package:libretapp/features/directorio/animales/domain/entities/care_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_rule.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/care_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/record_form_scaffold.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_record_assets.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class AnimalHealthFormPage extends StatefulWidget {
  const AnimalHealthFormPage({required this.animalUuid, super.key});

  final String animalUuid;

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
  AnimalEntity? _animal;
  HealthRecord? _lastRecord;

  @override
  void initState() {
    super.initState();
    _productController = TextEditingController();
    _doseController = TextEditingController();
    _appliedByController = TextEditingController();
    _causeController = TextEditingController();
    _notesController = TextEditingController();
    _loadAnimal();
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
    if (_saving) return;
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
      final record = HealthRecord(
        id: null,
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
      );
      await locator<HealthRecordRepository>().addHealthRecord(
        widget.animalUuid,
        record,
      );
      var agendaNeedsRetry = false;
      try {
        await _registerMatchingCareCycle(record);
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

  Future<void> _registerMatchingCareCycle(HealthRecord record) async {
    final animal = _animal;
    final careType = switch (record.type) {
      HealthRecordType.vaccine => CareType.vaccination,
      HealthRecordType.deworming => CareType.deworming,
      HealthRecordType.tickBath => CareType.tickBath,
      HealthRecordType.vitamins => CareType.supplement,
      _ => null,
    };
    if (animal == null || careType == null) return;

    CareRule? rule;
    for (final candidate in await locator<CareRepository>().getRules()) {
      if (candidate.type != careType) continue;
      if (candidate.species != null && candidate.species != animal.species) {
        continue;
      }
      if (candidate.sex != null && candidate.sex != animal.sex) continue;
      if (candidate.minAgeMonths != null &&
          animal.ageMonths < candidate.minAgeMonths!) {
        continue;
      }
      if (candidate.maxAgeMonths != null &&
          animal.ageMonths > candidate.maxAgeMonths!) {
        continue;
      }
      rule = candidate;
      break;
    }
    if (rule == null) return;
    await locator<CareRepository>().saveRecord(
      CareRecord(
        id: 'health-care:${animal.uuid}:${record.type.name}:${record.date.millisecondsSinceEpoch}',
        animalId: animal.uuid,
        ruleId: rule.id,
        type: rule.type,
        performedAt: record.date,
        notes: record.notes,
        performedBy: record.appliedBy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return RecordFormScaffold(
      title: l10n.detailFormHealthTitle,
      saving: _saving,
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
