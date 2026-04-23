import 'package:flutter/material.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/index.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart'
    hide AnimalStatus;
import 'package:libretapp/features/directorio/animales/infrastructure/infrastructure.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/infrastructure.dart';
import 'package:libretapp/features/registro/widgets/animal_selector.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class RegistroComercialPage extends StatefulWidget {
  const RegistroComercialPage({super.key});

  @override
  State<RegistroComercialPage> createState() => _RegistroComercialPageState();
}

class _RegistroComercialPageState extends State<RegistroComercialPage> {
  late final AnimalBloc _bloc;
  final _amountCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController(text: 'USD');
  final _counterpartyCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  var _type = CommercialRecordType.purchase;
  var _date = DateTime.now();
  AnimalEntity? _selectedAnimal;
  bool _saving = false;

  double? _parseDouble(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  @override
  void initState() {
    super.initState();
    _bloc = AnimalBloc(
      animalRepository: locator<AnimalRepository>(),
      lotesRepository: locator<LotesRepository>(),
    );
  }

  @override
  void dispose() {
    _bloc.close();
    _amountCtrl.dispose();
    _currencyCtrl.dispose();
    _counterpartyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context);

    if (_selectedAnimal == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormAnimalRequired)),
      );
      return;
    }

    final rawAmount = _amountCtrl.text.trim();
    final amount = _parseDouble(rawAmount);
    if (rawAmount.isNotEmpty && amount == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormNumberInvalid)),
      );
      return;
    }

    final amountRequired =
        _type == CommercialRecordType.purchase ||
        _type == CommercialRecordType.sale ||
        _type == CommercialRecordType.priceUpdate;
    if (amountRequired && amount == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormCommercialAmountRequired)),
      );
      return;
    }
    if (amount != null && amount <= 0) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormAmountPositive)),
      );
      return;
    }

    setState(() => _saving = true);

    final record = CommercialRecord(
      date: _date,
      type: _type,
      amount: amount,
      currency: _currencyCtrl.text.trim().isEmpty
          ? null
          : _currencyCtrl.text.trim().toUpperCase(),
      counterparty: _counterpartyCtrl.text.trim().isEmpty
          ? null
          : _counterpartyCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    _bloc.add(
      AddCommercialRecord(animalUuid: _selectedAnimal!.uuid, record: record),
    );

    final nextState = await _bloc.stream.firstWhere(
      (s) => s.status != AnimalStatus.loading,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (nextState.status == AnimalStatus.success) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormCommercialSaved)),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(nextState.errorMessage ?? 'Error al guardar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.detailFormCommercialTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimalSelector(
              selectedAnimal: _selectedAnimal,
              onSelected: (a) => setState(() => _selectedAnimal = a),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CommercialRecordType>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: l10n.detailFormCommercialType,
                border: const OutlineInputBorder(),
              ),
              items: CommercialRecordType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _type = v);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountCtrl,
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
                    controller: _currencyCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.detailFormCommercialCurrency,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _counterpartyCtrl,
              decoration: InputDecoration(
                labelText: l10n.detailFormCommercialCounterparty,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.today),
              label: Text('${_date.year}-${_date.month}-${_date.day}'),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(_date.year - 5),
                  lastDate: DateTime(_date.year + 1),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration: InputDecoration(
                labelText: l10n.fieldNotes,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.actionSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
