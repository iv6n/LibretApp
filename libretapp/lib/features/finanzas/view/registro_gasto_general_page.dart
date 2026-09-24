/// features > finanzas > view > registro_gasto_general_page \u2014 page for recording a general expense.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/core/utils/number_parsing.dart';
import 'package:libretapp/features/finanzas/application/finanzas_bloc.dart';
import 'package:libretapp/features/finanzas/application/finanzas_event.dart';
import 'package:libretapp/features/finanzas/domain/entities/general_expense_record.dart';
import 'package:libretapp/features/finanzas/domain/repositories/finanzas_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/theme.dart';

class RegistroGastoGeneralPage extends StatefulWidget {
  const RegistroGastoGeneralPage({super.key});

  @override
  State<RegistroGastoGeneralPage> createState() =>
      _RegistroGastoGeneralPageState();
}

class _RegistroGastoGeneralPageState extends State<RegistroGastoGeneralPage> {
  final _amountCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController(text: 'USD');
  final _notesCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _type = GeneralExpenseType.fuel;
  var _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _currencyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = parseFormDouble(_amountCtrl.text);
    if (amount == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.financeAmountInvalid)),
      );
      return;
    }
    if (amount <= 0) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.financeAmountPositive)),
      );
      return;
    }

    setState(() => _saving = true);

    final record = GeneralExpenseRecord(
      date: _date,
      type: _type,
      amount: amount,
      currency: _currencyCtrl.text.trim().isEmpty
          ? null
          : _currencyCtrl.text.trim().toUpperCase(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    try {
      final finanzasBloc = context.read<FinanzasBloc?>();
      if (finanzasBloc != null) {
        finanzasBloc.add(AddExpense(record));
      } else {
        await locator<FinanzasRepository>().addExpense(record);
      }
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.financeExpenseSaved)));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGenericSave)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppFormScaffold(
      title: l10n.financeRegisterExpense,
      formKey: _formKey,
      saving: _saving,
      onSave: _save,
      saveLabel: l10n.actionSave,
      saveKey: const ValueKey('finance-expense-save'),
      onCancel: () => Navigator.of(context).pop(),
      cancelLabel: l10n.actionCancel,
      fields: [
        AppSelectField<GeneralExpenseType>(
          value: _type,
          labelText: l10n.financeExpenseType,
          requiredField: true,
          items: GeneralExpenseType.values,
          itemLabel: (type) => type.label,
          onChanged: (value) {
            if (value != null) setState(() => _type = value);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _amountCtrl,
          key: const ValueKey('finance-expense-amount'),
          labelText: l10n.financeAmount,
          hintText: '0.00',
          requiredField: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            final amount = parseFormDouble(value ?? '');
            if (amount == null) return l10n.financeAmountInvalid;
            if (amount <= 0) return l10n.financeAmountPositive;
            return null;
          },
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _currencyCtrl,
          key: const ValueKey('finance-expense-currency'),
          labelText: l10n.financeCurrency,
          hintText: 'USD',
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: AppSpacing.md),
        AppDateField(
          value: _date,
          labelText: l10n.fieldDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          onChanged: (value) {
            if (value != null) setState(() => _date = value);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _notesCtrl,
          labelText: l10n.fieldNotesOptional,
          hintText: l10n.financeDescriptionHint,
          maxLines: 3,
        ),
      ],
    );
  }
}
