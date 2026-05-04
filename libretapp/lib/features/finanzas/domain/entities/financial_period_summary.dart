/// features \u203a finanzas \u203a domain \u203a entities \u203a financial_period_summary \u2014 aggregated financial summary for a date range.
library;

import 'package:equatable/equatable.dart';

/// Rango de fechas para filtrar períodos financieros.
///
/// [start] debe ser anterior o igual a [end]. Si [start] es posterior a [end]
/// la operación [contains] siempre retornará `false`.
class DateRange extends Equatable {
  const DateRange({required this.start, required this.end});
  final DateTime start;
  final DateTime end;

  bool contains(DateTime date) => !date.isBefore(start) && !date.isAfter(end);

  @override
  List<Object?> get props => [start, end];
}

/// Resumen financiero calculado para un período dado.
/// Este modelo no se persiste — se calcula en tiempo de ejecución.
class FinancialPeriodSummary extends Equatable {
  const FinancialPeriodSummary({
    required this.period,
    required this.totalIncome,
    required this.totalGeneralExpenses,
    required this.totalAnimalCosts,
    required this.totalAnimalSales,
  });

  final DateRange period;

  /// Ingresos generales (IncomeRecord) en el período.
  final double totalIncome;

  /// Gastos generales de la finca (GeneralExpenseRecord) en el período.
  final double totalGeneralExpenses;

  /// Suma de costos de animales (CostRecord) en el período.
  final double totalAnimalCosts;

  /// Suma de ventas de animales (CommercialRecord tipo sale) en el período.
  final double totalAnimalSales;

  /// Ingresos totales = ingresos generales + ventas de animales.
  double get totalRevenue => totalIncome + totalAnimalSales;

  /// Egresos totales = gastos generales + costos de animales.
  double get totalExpenses => totalGeneralExpenses + totalAnimalCosts;

  /// Ganancia neta = ingresos totales − egresos totales.
  double get netProfit => totalRevenue - totalExpenses;

  /// Margen de ganancia = [netProfit] / [totalRevenue].
  /// Puede ser negativo cuando los egresos superan los ingresos.
  /// Retorna 0.0 cuando [totalRevenue] es cero.
  double get profitMargin => totalRevenue > 0 ? netProfit / totalRevenue : 0.0;

  @override
  List<Object?> get props => [
    period,
    totalIncome,
    totalGeneralExpenses,
    totalAnimalCosts,
    totalAnimalSales,
  ];
}
