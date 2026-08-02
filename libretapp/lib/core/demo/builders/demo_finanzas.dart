/// core › demo › builders › demo_finanzas — six months of ranch-level
/// income and general expenses.
///
/// `IncomeRecord`/`GeneralExpenseRecord` are insert-only (no repository
/// exposes an update), so every note here starts with
/// [DemoPriceBook.demoNoteTag] — that prefix, not a `demo-*` uuid, is what
/// lets a reinstall find and replace exactly the rows this scenario owns
/// without touching anything a real user typed (see the tag's own doc
/// comment in `demo_price_book.dart`).
library;

import 'package:libretapp/core/demo/builders/demo_price_book.dart';
import 'package:libretapp/core/demo/demo_dates.dart';
import 'package:libretapp/features/finanzas/domain/entities/general_expense_record.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';

const int demoFinanzasMonths = 6;

List<IncomeRecord> buildDemoIncomes({required DateTime reference}) {
  final incomes = <IncomeRecord>[];

  for (var i = 0; i < demoFinanzasMonths; i++) {
    final date = monthsBefore(reference, i);
    incomes.add(
      IncomeRecord(
        date: DateTime(date.year, date.month, 5),
        type: IncomeType.milkSale,
        amount: DemoPriceBook.milkSaleMonthlyIncome,
        currency: DemoPriceBook.currency,
        notes: '${DemoPriceBook.demoNoteTag} Venta de leche del mes.',
      ),
    );
  }

  incomes.add(
    IncomeRecord(
      date: monthsBefore(reference, 3),
      type: IncomeType.subsidy,
      amount: DemoPriceBook.subsidyIncome,
      currency: DemoPriceBook.currency,
      notes: '${DemoPriceBook.demoNoteTag} Apoyo gubernamental ilustrativo.',
    ),
  );

  return incomes;
}

List<GeneralExpenseRecord> buildDemoExpenses({required DateTime reference}) {
  final expenses = <GeneralExpenseRecord>[];

  for (var i = 0; i < demoFinanzasMonths; i++) {
    final date = monthsBefore(reference, i);
    expenses.add(
      GeneralExpenseRecord(
        date: DateTime(date.year, date.month, 10),
        type: GeneralExpenseType.fuel,
        amount: DemoPriceBook.fuelMonthlyExpense,
        currency: DemoPriceBook.currency,
        notes:
            '${DemoPriceBook.demoNoteTag} Combustible para camioneta y '
            'maquinaria.',
      ),
    );
    expenses.add(
      GeneralExpenseRecord(
        date: DateTime(date.year, date.month, 15),
        type: GeneralExpenseType.utilities,
        amount: DemoPriceBook.utilitiesMonthlyExpense,
        currency: DemoPriceBook.currency,
        notes: '${DemoPriceBook.demoNoteTag} Energía eléctrica y agua.',
      ),
    );
  }

  expenses.add(
    GeneralExpenseRecord(
      date: monthsBefore(reference, 4),
      type: GeneralExpenseType.infrastructure,
      amount: DemoPriceBook.infrastructureRepairExpense,
      currency: DemoPriceBook.currency,
      notes: '${DemoPriceBook.demoNoteTag} Reparación de cerco perimetral.',
    ),
  );
  expenses.add(
    GeneralExpenseRecord(
      date: monthsBefore(reference, 2),
      type: GeneralExpenseType.equipment,
      amount: DemoPriceBook.equipmentExpense,
      currency: DemoPriceBook.currency,
      notes: '${DemoPriceBook.demoNoteTag} Herramienta de manejo.',
    ),
  );

  return expenses;
}
