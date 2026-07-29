/// features \u203a finanzas \u203a domain \u203a repositories \u203a finanzas_repository \u2014 abstract FinanzasRepository port.
library;

import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/domain/entities/general_expense_record.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';

/// Contrato para la persistencia y acceso de datos financieros generales.
abstract class FinanzasRepository {
  // Ingresos
  Future<List<IncomeRecord>> getIncomes(DateRange range);
  Future<IncomeRecord> addIncome(IncomeRecord record);
  Future<void> deleteIncome(String id);

  // Gastos generales
  Future<List<GeneralExpenseRecord>> getExpenses(DateRange range);
  Future<GeneralExpenseRecord> addExpense(GeneralExpenseRecord record);
  Future<void> deleteExpense(String id);

  // Sincronización (respaldo en la nube): dos colecciones comparten este
  // repositorio, por lo que se expone un par get/mark por cada una en vez de
  // un único SyncableRepository<T>.
  Future<List<IncomeRecord>> getUnsynchronizedIncomes();
  Future<void> markIncomeSynced(String id, String remoteId);
  Future<List<GeneralExpenseRecord>> getUnsynchronizedExpenses();
  Future<void> markExpenseSynced(String id, String remoteId);
}
