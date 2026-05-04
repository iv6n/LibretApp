/// finanzas › application › FinanzasEvent
///
/// Sealed event hierarchy for [FinanzasBloc]. Each event corresponds to one
/// user-triggered action on the financial dashboard.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/domain/entities/general_expense_record.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';

/// Base class for all finanzas events.
sealed class FinanzasEvent extends Equatable {
  const FinanzasEvent();
}

/// Loads all financial data for the given [period].
///
/// Triggers a full data refresh: incomes, expenses, and per-animal
/// profitability calculations. Replaces the previous [FinanzasCubit.loadPeriod].
final class LoadPeriod extends FinanzasEvent {
  const LoadPeriod(this.period);

  /// The date range to filter all financial records by.
  final DateRange period;

  @override
  List<Object?> get props => [period];
}

/// Persists a new [IncomeRecord] and reloads the current period.
final class AddIncome extends FinanzasEvent {
  const AddIncome(this.record);

  final IncomeRecord record;

  @override
  List<Object?> get props => [record];
}

/// Persists a new [GeneralExpenseRecord] and reloads the current period.
final class AddExpense extends FinanzasEvent {
  const AddExpense(this.record);

  final GeneralExpenseRecord record;

  @override
  List<Object?> get props => [record];
}

/// Deletes the income with the given [id] and reloads the current period.
final class DeleteIncome extends FinanzasEvent {
  const DeleteIncome(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Deletes the expense with the given [id] and reloads the current period.
final class DeleteExpense extends FinanzasEvent {
  const DeleteExpense(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
