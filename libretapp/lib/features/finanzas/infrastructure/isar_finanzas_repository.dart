/// features \u203a finanzas \u203a infrastructure \u203a isar_finanzas_repository \u2014 Isar implementation of FinanzasRepository.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/domain/entities/general_expense_record.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';
import 'package:libretapp/features/finanzas/domain/repositories/finanzas_repository.dart';
import 'package:libretapp/features/finanzas/infrastructure/isar/isar_general_expense_record.dart';
import 'package:libretapp/features/finanzas/infrastructure/isar/isar_income_record.dart';

class IsarFinanzasRepository implements FinanzasRepository {
  IsarFinanzasRepository(this._db);

  final IsarDatabase _db;

  Isar get _isar => _db.isar;

  // ─── Ingresos ──────────────────────────────────────────────────────────────

  @override
  Future<List<IncomeRecord>> getIncomes(DateRange range) async {
    final records = await _isar.isarIncomeRecords
        .filter()
        .dateBetween(range.start, range.end)
        .findAll();
    return records.map((r) => r.toEntity()).toList();
  }

  @override
  Future<IncomeRecord> addIncome(IncomeRecord record) async {
    final model = record.toIsar();
    await _isar.writeTxn(() async {
      await _isar.isarIncomeRecords.put(model);
    });
    return model.toEntity();
  }

  @override
  Future<void> deleteIncome(String id) async {
    final isarId = int.tryParse(id);
    if (isarId == null)
      throw ArgumentError.value(id, 'id', 'Income ID is not a valid integer');
    await _isar.writeTxn(() async {
      await _isar.isarIncomeRecords.delete(isarId);
    });
  }

  // ─── Gastos generales ──────────────────────────────────────────────────────

  @override
  Future<List<GeneralExpenseRecord>> getExpenses(DateRange range) async {
    final records = await _isar.isarGeneralExpenseRecords
        .filter()
        .dateBetween(range.start, range.end)
        .findAll();
    return records.map((r) => r.toEntity()).toList();
  }

  @override
  Future<GeneralExpenseRecord> addExpense(GeneralExpenseRecord record) async {
    final model = record.toIsar();
    await _isar.writeTxn(() async {
      await _isar.isarGeneralExpenseRecords.put(model);
    });
    return model.toEntity();
  }

  @override
  Future<void> deleteExpense(String id) async {
    final isarId = int.tryParse(id);
    if (isarId == null)
      throw ArgumentError.value(id, 'id', 'Expense ID is not a valid integer');
    await _isar.writeTxn(() async {
      await _isar.isarGeneralExpenseRecords.delete(isarId);
    });
  }
}
