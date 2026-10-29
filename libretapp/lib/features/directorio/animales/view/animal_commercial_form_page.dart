/// features > directorio > animales > view > animal_commercial_form_page — full-screen commercial record form.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/assets/app_asset_paths.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/utils/number_parsing.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/editable_record_repository.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/theme/theme.dart';

class AnimalCommercialFormPage extends StatefulWidget {
  const AnimalCommercialFormPage({
    required this.animalUuid,
    this.recordId,
    super.key,
  });

  final String animalUuid;

  /// Id of the record being corrected, or null to add a new one.
  final String? recordId;

  bool get isEditing => recordId != null;

  @override
  State<AnimalCommercialFormPage> createState() =>
      _AnimalCommercialFormPageState();
}

class _AnimalCommercialFormPageState extends State<AnimalCommercialFormPage> {
  late final TextEditingController _amountController;
  late final TextEditingController _currencyController;
  late final TextEditingController _counterpartyController;
  late final TextEditingController _notesController;

  CommercialRecordType _type = CommercialRecordType.purchase;
  DateTime _date = DateTime.now();
  bool _saving = false;
  bool _loading = false;
  String? _loadError;
  CommercialRecord? _editing;
  AnimalEntity? _animal;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _currencyController = TextEditingController(text: 'USD');
    _counterpartyController = TextEditingController();
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
      final records = await locator<CommercialRecordRepository>()
          .getCommercialRecords(widget.animalUuid);
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
        _amountController.text = record.amount?.toString() ?? '';
        _currencyController.text = record.currency ?? '';
        _counterpartyController.text = record.counterparty ?? '';
        _notesController.text = record.notes ?? '';
        _type = record.type;
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
    _amountController.dispose();
    _currencyController.dispose();
    _counterpartyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || _loading || (widget.isEditing && _editing == null)) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _saving = true);
    try {
      final amount = parseFormDouble(_amountController.text);
      final repository = locator<CommercialRecordRepository>();
      final edited = _editing;

      if (edited != null &&
          repository is EditableRecordRepository<CommercialRecord>) {
        await (repository as EditableRecordRepository<CommercialRecord>)
            .updateRecord(
              widget.animalUuid,
              CommercialRecord(
                id: edited.id,
                date: _date,
                type: _type,
                amount: amount,
                currency: _currencyController.text.trim().isEmpty
                    ? null
                    : _currencyController.text.trim(),
                counterparty: _counterpartyController.text.trim().isEmpty
                    ? null
                    : _counterpartyController.text.trim(),
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
              ),
            );
      } else {
        await repository.addCommercialRecord(
          widget.animalUuid,
          CommercialRecord(
            id: null,
            date: _date,
            type: _type,
            amount: amount,
            currency: _currencyController.text.trim().isEmpty
                ? null
                : _currencyController.text.trim(),
            counterparty: _counterpartyController.text.trim().isEmpty
                ? null
                : _counterpartyController.text.trim(),
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
            edited != null
                ? l10n.recordEditSaved
                : l10n.detailFormCommercialSaved,
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
    if (_loadError != null) return RecordLoadFailure(onRetry: _load);
    final l10n = AppLocalizations.of(context);

    return AppFormScaffold(
      recordStyle: RecordFormStyle.commercial,
      onCancel: () => Navigator.of(context).pop(),
      title: widget.isEditing
          ? l10n.recordEditTitle
          : l10n.detailFormCommercialTitle,
      contextLabel: animalRecordContextLabel(_animal),
      contextIcon: Icons.pets_outlined,
      saving: _saving,
      loading: _loading,
      onSave: _save,
      saveLabel: l10n.actionSave,
      assetPath: AppAssetPaths.recordSale,
      fallbackIcon: Icons.sell_outlined,
      fields: [
        AppSelectField<CommercialRecordType>(
          value: _type,
          items: CommercialRecordType.values,
          itemLabel: (type) => type.displayName,
          labelText: l10n.detailFormCommercialType,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _type = value);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _amountController,
          labelText: l10n.detailFormCommercialAmount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _currencyController,
          labelText: l10n.detailFormCommercialCurrency,
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
          controller: _counterpartyController,
          labelText: l10n.detailFormCommercialCounterparty,
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
