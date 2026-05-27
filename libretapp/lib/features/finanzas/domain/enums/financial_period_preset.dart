/// finanzas › domain › enums › financial_period_preset —
/// Named period presets for the financial dashboard filter.
library;

import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';

/// Pre-defined time-window options for the financial dashboard.
enum FinancialPeriodPreset {
  thisMonth,
  lastMonth,
  last3Months,
  thisYear;

  /// Human-readable Spanish label.
  String get label {
    switch (this) {
      case FinancialPeriodPreset.thisMonth:
        return 'Este mes';
      case FinancialPeriodPreset.lastMonth:
        return 'Mes anterior';
      case FinancialPeriodPreset.last3Months:
        return 'Últimos 3 meses';
      case FinancialPeriodPreset.thisYear:
        return 'Este año';
    }
  }

  /// Computes the [DateRange] corresponding to this preset relative to [now].
  ///
  /// Defaults to [DateTime.now] when [now] is omitted.
  DateRange toDateRange({DateTime? now}) {
    final n = now ?? DateTime.now();
    switch (this) {
      case FinancialPeriodPreset.thisMonth:
        return DateRange(
          start: DateTime(n.year, n.month, 1),
          end: DateTime(n.year, n.month + 1, 0, 23, 59, 59),
        );
      case FinancialPeriodPreset.lastMonth:
        return DateRange(
          start: DateTime(n.year, n.month - 1, 1),
          end: DateTime(n.year, n.month, 0, 23, 59, 59),
        );
      case FinancialPeriodPreset.last3Months:
        return DateRange(
          start: DateTime(n.year, n.month - 2, 1),
          end: DateTime(n.year, n.month + 1, 0, 23, 59, 59),
        );
      case FinancialPeriodPreset.thisYear:
        return DateRange(
          start: DateTime(n.year, 1, 1),
          end: DateTime(n.year, 12, 31, 23, 59, 59),
        );
    }
  }
}
