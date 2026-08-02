/// core › demo › builders › demo_price_book — single source of MXN amounts
/// for the demo scenario.
///
/// Every peso figure the scenario writes anywhere (animal costs, general
/// expenses, income, sale prices) comes from here, so the numbers repeated
/// across builders stay consistent and so the report at the end of
/// `DemoScenarioService.install` can point at one place that explains them.
/// All figures are illustrative placeholders for a fictional ranch, not real
/// market prices.
library;

abstract final class DemoPriceBook {
  static const String currency = 'MXN';

  /// Marker prepended to every `IncomeRecord`/`GeneralExpenseRecord.notes`
  /// this scenario writes.
  ///
  /// Those two collections are ranch-level, not animal-scoped, so there is no
  /// `demo-*` uuid to filter on when a reinstall needs to delete-and-reinsert
  /// them (unlike animal-linked records, which are always found through a
  /// `demo-*` animal uuid). The notes prefix is what keeps a reinstall from
  /// ever touching an entry a real user typed.
  static const String demoNoteTag = '[DEMO]';

  // ── Milk / dairy ──────────────────────────────────────────────────────
  static const double milkSaleMonthlyIncome = 4200.0;

  // ── Animal sale (the historical calf sale) ──────────────────────────────
  static const double historicalCalfSalePrice = 6500.0;

  // ── Per-animal costs (CostRecord) ───────────────────────────────────────
  static const double antibioticTreatmentCost = 480.0;
  static const double feedingCostPerAnimal = 950.0;
  static const double transportCostForSale = 850.0;
  static const double studLaborCost = 600.0;
  static const double breedingInvestmentCost = 3500.0;

  // ── General farm expenses (GeneralExpenseRecord) ────────────────────────
  static const double fuelMonthlyExpense = 1800.0;
  static const double utilitiesMonthlyExpense = 650.0;
  static const double infrastructureRepairExpense = 3500.0;
  static const double equipmentExpense = 1200.0;

  // ── Other income ─────────────────────────────────────────────────────
  static const double subsidyIncome = 5000.0;

  // ── Inventory unit costs ─────────────────────────────────────────────
  static const double hayBaleUnitCost = 95.0;
  static const double dewormerUnitCost = 150.0;
  static const double mineralSaltUnitCost = 22.0;
}
