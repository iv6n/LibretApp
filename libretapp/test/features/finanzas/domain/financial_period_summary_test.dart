import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';

void main() {
  final period = DateRange(
    start: DateTime(2025, 1, 1),
    end: DateTime(2025, 1, 31),
  );

  FinancialPeriodSummary _make({
    double totalIncome = 0,
    double totalGeneralExpenses = 0,
    double totalAnimalCosts = 0,
    double totalAnimalSales = 0,
  }) {
    return FinancialPeriodSummary(
      period: period,
      totalIncome: totalIncome,
      totalGeneralExpenses: totalGeneralExpenses,
      totalAnimalCosts: totalAnimalCosts,
      totalAnimalSales: totalAnimalSales,
    );
  }

  group('FinancialPeriodSummary.totalRevenue', () {
    test('equals totalIncome + totalAnimalSales', () {
      final s = _make(totalIncome: 500, totalAnimalSales: 300);
      expect(s.totalRevenue, 800.0);
    });

    test('is zero when no income and no animal sales', () {
      expect(_make().totalRevenue, 0.0);
    });
  });

  group('FinancialPeriodSummary.totalExpenses', () {
    test('equals totalGeneralExpenses + totalAnimalCosts', () {
      final s = _make(totalGeneralExpenses: 100, totalAnimalCosts: 50);
      expect(s.totalExpenses, 150.0);
    });

    test('is zero when no expenses', () {
      expect(_make().totalExpenses, 0.0);
    });
  });

  group('FinancialPeriodSummary.netProfit', () {
    test('equals totalRevenue minus totalExpenses (profitable period)', () {
      final s = _make(
        totalIncome: 500,
        totalAnimalSales: 300,
        totalGeneralExpenses: 100,
        totalAnimalCosts: 50,
      );
      // totalRevenue = 800, totalExpenses = 150 → netProfit = 650
      expect(s.netProfit, 650.0);
    });

    test('is negative when expenses exceed revenue (loss period)', () {
      final s = _make(
        totalIncome: 100,
        totalGeneralExpenses: 300,
        totalAnimalCosts: 200,
      );
      // totalRevenue = 100, totalExpenses = 500 → netProfit = -400
      expect(s.netProfit, -400.0);
    });

    test('is zero when all amounts are zero', () {
      expect(_make().netProfit, 0.0);
    });
  });

  group('FinancialPeriodSummary.profitMargin', () {
    test('is netProfit / totalRevenue when revenue > 0 (positive margin)', () {
      final s = _make(
        totalIncome: 600,
        totalAnimalSales: 400,
        totalGeneralExpenses: 100,
        totalAnimalCosts: 100,
      );
      // totalRevenue = 1000, netProfit = 800, margin = 0.8
      expect(s.profitMargin, closeTo(0.8, 1e-10));
    });

    test('is zero when totalRevenue is zero', () {
      final s = _make(totalGeneralExpenses: 200, totalAnimalCosts: 100);
      expect(s.profitMargin, 0.0);
    });

    test('is negative when running at a loss with revenue > 0', () {
      final s = _make(totalIncome: 100, totalGeneralExpenses: 500);
      // totalRevenue = 100, netProfit = -400, margin = -4.0
      expect(s.profitMargin, closeTo(-4.0, 1e-10));
    });

    test('is 1.0 when there are no expenses', () {
      final s = _make(totalIncome: 100);
      expect(s.profitMargin, closeTo(1.0, 1e-10));
    });
  });

  group('FinancialPeriodSummary equality', () {
    test('two summaries with same values are equal', () {
      final a = _make(totalIncome: 100, totalGeneralExpenses: 50);
      final b = _make(totalIncome: 100, totalGeneralExpenses: 50);
      expect(a, equals(b));
    });

    test('different income makes summaries unequal', () {
      expect(_make(totalIncome: 100), isNot(equals(_make(totalIncome: 200))));
    });
  });
}
