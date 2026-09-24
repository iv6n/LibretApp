/// features > directorio > animales > view > animal_cost_form_page — full-screen cost record form.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/assets/app_asset_paths.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/editable_record_repository.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/theme/theme.dart';

class AnimalCostFormPage extends StatefulWidget {
  const AnimalCostFormPage({
    required this.animalUuid,
    this.recordId,
    super.key,
  });

  final String animalUuid;

  /// Id of the record being corrected, or null to add a new one.
  final String? recordId;

  bool get isEditing => recordId != null;

  @override
  State<AnimalCostFormPage> createState() => _AnimalCostFormPageState();
}

class _AnimalCostFormPageState extends State<AnimalCostFormPage> {
  late final TextEditingController _amountController;
  late final TextEditingController _currencyController;
  late final TextEditingController _notesController;

  CostType _type = CostType.medication;
  DateTime _date = DateTime.now();
  bool _saving = false;
  bool _loading = false;
  CostRecord? _editing;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _currencyController = TextEditingController(text: 'USD');
    _notesController = TextEditingController();
    if (widget.isEditing) _load();
  }

  /// Hydrates the form from the record being corrected.
  Future<void> _load() async {
    setState(() => _loading = true);
    final records = await locator<CostRecordRepository>().getCostRecords(
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
      _amountController.text = record.amount.toString();
      _currencyController.text = record.currency ?? '';
      _notesController.text = record.notes ?? '';
      _type = record.type;
      _date = record.date;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || _loading || (widget.isEditing && _editing == null)) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormCostAmountRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repository = locator<CostRecordRepository>();
      final edited = _editing;

      if (edited != null &&
          repository is EditableRecordRepository<CostRecord>) {
        await (repository as EditableRecordRepository<CostRecord>).updateRecord(
          widget.animalUuid,
          CostRecord(
            id: edited.id,
            date: _date,
            type: _type,
            amount: amount,
            currency: _currencyController.text.trim().isEmpty
                ? null
                : _currencyController.text.trim(),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          ),
        );
      } else {
        await repository.addCostRecord(
          widget.animalUuid,
          CostRecord(
            id: null,
            date: _date,
            type: _type,
            amount: amount,
            currency: _currencyController.text.trim().isEmpty
                ? null
                : _currencyController.text.trim(),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          ),
        );
      }
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            edited != null ? l10n.recordEditSaved : l10n.detailFormCostSaved,
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
      title: widget.isEditing ? l10n.recordEditTitle : l10n.detailFormCostTitle,
      saving: _saving,
      loading: _loading,
      onSave: _save,
      saveLabel: l10n.actionSave,
      assetPath: AppAssetPaths.recordCost,
      fallbackIcon: Icons.payments_outlined,
      fields: [
        AppSelectField<CostType>(
          value: _type,
          items: CostType.values,
          itemLabel: (type) => type.displayName,
          labelText: l10n.detailFormCostType,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _type = value);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _amountController,
          labelText: l10n.detailFormCostAmount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _currencyController,
          labelText: l10n.detailFormCostCurrency,
          textCapitalization: TextCapitalization.characters,
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
      ],
    );
  }
}
