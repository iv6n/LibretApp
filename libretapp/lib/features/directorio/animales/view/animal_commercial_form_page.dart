/// features > directorio > animales > view > animal_commercial_form_page — full-screen commercial record form.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/assets/app_asset_paths.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/record_form_scaffold.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/editable_record_repository.dart';

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
  CommercialRecord? _editing;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _currencyController = TextEditingController(text: 'USD');
    _counterpartyController = TextEditingController();
    _notesController = TextEditingController();
    if (widget.isEditing) _load();
  }

  /// Hydrates the form from the record being corrected.
  Future<void> _load() async {
    setState(() => _loading = true);
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
      final amount = double.tryParse(_amountController.text.trim());
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
    final l10n = AppLocalizations.of(context);

    return RecordFormScaffold(
      title: widget.isEditing
          ? l10n.recordEditTitle
          : l10n.detailFormCommercialTitle,
      saving: _saving,
      loading: _loading,
      onSave: _save,
      saveLabel: l10n.actionSave,
      assetPath: AppAssetPaths.recordSale,
      fallbackIcon: Icons.sell_outlined,
      fields: [
        DropdownButtonFormField<CommercialRecordType>(
          initialValue: _type,
          decoration: InputDecoration(
            labelText: l10n.detailFormCommercialType,
            border: const OutlineInputBorder(),
          ),
          items: CommercialRecordType.values
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
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.detailFormCommercialAmount,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _currencyController,
                decoration: InputDecoration(
                  labelText: l10n.detailFormCommercialCurrency,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
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
        const SizedBox(height: 12),
        TextField(
          controller: _counterpartyController,
          decoration: InputDecoration(
            labelText: l10n.detailFormCommercialCounterparty,
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
      ],
    );
  }
}
