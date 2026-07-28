/// registro › view › RegistroComercialPage
///
/// Form page for recording a commercial event (purchase, sale, price update).
/// Provides [RegistroBloc] and dispatches [RegistroComercialSubmitted].
///
/// Layer: view (presentation)
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/core/utils/number_parsing.dart';
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

/// Page wrapper that provides [RegistroBloc] for the commercial registration form.
class RegistroComercialPage extends StatelessWidget {
  const RegistroComercialPage({super.key});

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
      child: const _RegistroComercialView(),
    );
  }
}

/// Internal form view for commercial registration.
class _RegistroComercialView extends StatefulWidget {
  const _RegistroComercialView();

  @override
  State<_RegistroComercialView> createState() => _RegistroComercialViewState();
}

class _RegistroComercialViewState extends State<_RegistroComercialView> {
  final _amountCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController(text: 'USD');
  final _counterpartyCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  var _type = CommercialRecordType.purchase;
  var _date = DateTime.now();
  AnimalEntity? _selectedAnimal;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _currencyCtrl.dispose();
    _counterpartyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (_selectedAnimal == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormAnimalRequired)),
      );
      return;
    }

    final rawAmount = _amountCtrl.text.trim();
    final amount = parseFormDouble(rawAmount);
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
    context.read<RegistroBloc>().add(
      RegistroComercialSubmitted(
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.detailFormCommercialSaved)),
          );
          context.read<RegistroBloc>().add(const RegistroReset());
        } else if (state.status == RegistroStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? l10n.errorGenericSave)),
          );
          context.read<RegistroBloc>().add(const RegistroReset());
        }
      },
      child: Scaffold(
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
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.displayName)))
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
                label: Text(DateFormat('dd/MM/yyyy').format(_date)),
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
              BlocBuilder<RegistroBloc, RegistroState>(
                buildWhen: (prev, curr) => prev.status != curr.status,
                builder: (context, state) {
                  final isSaving = state.status == RegistroStatus.loading;
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isSaving ? null : _save,
                      child: isSaving
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
