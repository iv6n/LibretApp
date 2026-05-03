import 'package:equatable/equatable.dart';
import 'package:libretapp/features/finanzas/domain/entities/animal_profitability.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/domain/entities/general_expense_record.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';

enum FinanzasStatus { initial, loading, loaded, error }

// Sentinel used by copyWith to distinguish "not provided" from explicit null.
const _kUnset = Object();

class FinanzasState extends Equatable {
  const FinanzasState({
    this.status = FinanzasStatus.initial,
    this.period,
    this.incomes = const [],
    this.expenses = const [],
    this.summary,
    this.animalProfitabilities = const [],
    this.error,
  });

  final FinanzasStatus status;
  final DateRange? period;
  final List<IncomeRecord> incomes;
  final List<GeneralExpenseRecord> expenses;
  final FinancialPeriodSummary? summary;
  final List<AnimalProfitability> animalProfitabilities;
  final String? error;

  FinanzasState copyWith({
    FinanzasStatus? status,
    // Use [_kUnset] sentinel so callers can explicitly pass null to clear a
    // field (e.g. copyWith(error: null) to reset a previous error message).
    Object? period = _kUnset,
    List<IncomeRecord>? incomes,
    List<GeneralExpenseRecord>? expenses,
    Object? summary = _kUnset,
    List<AnimalProfitability>? animalProfitabilities,
    Object? error = _kUnset,
  }) {
    return FinanzasState(
      status: status ?? this.status,
      period: identical(period, _kUnset) ? this.period : period as DateRange?,
      incomes: incomes ?? this.incomes,
      expenses: expenses ?? this.expenses,
      summary: identical(summary, _kUnset)
          ? this.summary
          : summary as FinancialPeriodSummary?,
      animalProfitabilities:
          animalProfitabilities ?? this.animalProfitabilities,
      error: identical(error, _kUnset) ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    period,
    incomes,
    expenses,
    summary,
    animalProfitabilities,
    error,
  ];
}
