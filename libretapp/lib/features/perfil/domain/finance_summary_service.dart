/// features › perfil › domain › finance_summary_service — shared financial aggregates.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/domain/entities/general_expense_record.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';
import 'package:libretapp/features/finanzas/domain/enums/financial_period_preset.dart';
import 'package:libretapp/features/finanzas/domain/repositories/finanzas_repository.dart';

enum FinanceMovementKind { income, expense, sale, animalCost }

class FinanceMovementItem extends Equatable {
  const FinanceMovementItem({
    required this.kind,
    required this.label,
    required this.amount,
    required this.date,
    this.notes,
  });

  final FinanceMovementKind kind;
  final String label;
  final double amount;
  final DateTime date;
  final String? notes;

  bool get isPositive =>
      kind == FinanceMovementKind.income || kind == FinanceMovementKind.sale;

  @override
  List<Object?> get props => [kind, label, amount, date, notes];
}

class ExpenseCategoryBreakdown extends Equatable {
  const ExpenseCategoryBreakdown({
    required this.label,
    required this.amount,
  });

  final String label;
  final double amount;

  @override
  List<Object?> get props => [label, amount];
}

class FinanceSummaryDetail extends Equatable {
  const FinanceSummaryDetail({
    required this.summary,
    required this.recentMovements,
    required this.expenseBreakdown,
    required this.recentSales,
  });

  final FinancialPeriodSummary summary;
  final List<FinanceMovementItem> recentMovements;
  final List<ExpenseCategoryBreakdown> expenseBreakdown;
  final List<FinanceMovementItem> recentSales;

  @override
  List<Object?> get props => [
    summary,
    recentMovements,
    expenseBreakdown,
    recentSales,
  ];
}

class FinanceSummaryService {
  FinanceSummaryService({
    required FinanzasRepository finanzasRepository,
    required AnimalRepository animalRepository,
    required CostRecordRepository costRepo,
    required CommercialRecordRepository commercialRepo,
  }) : _finanzasRepository = finanzasRepository,
       _animalRepository = animalRepository,
       _costRepo = costRepo,
       _commercialRepo = commercialRepo;

  final FinanzasRepository _finanzasRepository;
  final AnimalRepository _animalRepository;
  final CostRecordRepository _costRepo;
  final CommercialRecordRepository _commercialRepo;

  Future<FinanceSummaryDetail> loadForPreset({
    FinancialPeriodPreset preset = FinancialPeriodPreset.thisMonth,
    DateTime? now,
  }) {
    return loadForPeriod(preset.toDateRange(now: now));
  }

  Future<FinanceSummaryDetail> loadForPeriod(DateRange period) async {
    final topResults = await Future.wait([
      _finanzasRepository.getIncomes(period),
      _finanzasRepository.getExpenses(period),
      _animalRepository.getAll(),
    ]);

    final incomes = topResults[0] as List<IncomeRecord>;
    final expenses = topResults[1] as List<GeneralExpenseRecord>;
    final animals = topResults[2] as List;

    double totalAnimalCosts = 0;
    double totalAnimalSales = 0;
    final categoryTotals = <String, double>{};
    final movements = <FinanceMovementItem>[];
    final sales = <FinanceMovementItem>[];

    for (final income in incomes) {
      movements.add(
        FinanceMovementItem(
          kind: FinanceMovementKind.income,
          label: income.type.label,
          amount: income.amount,
          date: income.date,
          notes: income.notes,
        ),
      );
    }

    for (final expense in expenses) {
      movements.add(
        FinanceMovementItem(
          kind: FinanceMovementKind.expense,
          label: expense.type.label,
          amount: expense.amount,
          date: expense.date,
          notes: expense.notes,
        ),
      );
      categoryTotals.update(
        expense.type.label,
        (v) => v + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final animalRecords = await Future.wait(
      animals.map((animal) async {
        final uuid = animal.uuid as String;
        final fetched = await Future.wait([
          _costRepo.getCostRecords(uuid),
          _commercialRepo.getCommercialRecords(uuid),
        ]);
        return (
          costs: fetched[0] as List<CostRecord>,
          commercials: fetched[1] as List<CommercialRecord>,
        );
      }),
    );

    for (final data in animalRecords) {
      for (final cost in data.costs.where((c) => period.contains(c.date))) {
        totalAnimalCosts += cost.amount;
        categoryTotals.update(
          _costTypeLabel(cost.type),
          (v) => v + cost.amount,
          ifAbsent: () => cost.amount,
        );
        movements.add(
          FinanceMovementItem(
            kind: FinanceMovementKind.animalCost,
            label: _costTypeLabel(cost.type),
            amount: cost.amount,
            date: cost.date,
            notes: cost.notes,
          ),
        );
      }

      for (final commercial in data.commercials.where(
        (c) =>
            c.type == CommercialRecordType.sale && period.contains(c.date),
      )) {
        final amount = commercial.amount ?? 0;
        totalAnimalSales += amount;
        final saleItem = FinanceMovementItem(
          kind: FinanceMovementKind.sale,
          label: 'Venta de animal',
          amount: amount,
          date: commercial.date,
          notes: commercial.notes,
        );
        sales.add(saleItem);
        movements.add(saleItem);
      }
    }

    movements.sort((a, b) => b.date.compareTo(a.date));
    sales.sort((a, b) => b.date.compareTo(a.date));

    final breakdown = categoryTotals.entries
        .map((e) => ExpenseCategoryBreakdown(label: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final summary = FinancialPeriodSummary(
      period: period,
      totalIncome: incomes.fold(0.0, (s, i) => s + i.amount),
      totalGeneralExpenses: expenses.fold(0.0, (s, e) => s + e.amount),
      totalAnimalCosts: totalAnimalCosts,
      totalAnimalSales: totalAnimalSales,
    );

    return FinanceSummaryDetail(
      summary: summary,
      recentMovements: movements.take(8).toList(growable: false),
      expenseBreakdown: breakdown.take(6).toList(growable: false),
      recentSales: sales.take(5).toList(growable: false),
    );
  }

  static String _costTypeLabel(CostType type) {
    switch (type) {
      case CostType.medication:
        return 'Medicina';
      case CostType.feeding:
        return 'Alimentación';
      case CostType.labor:
        return 'Mano de obra';
      case CostType.transport:
        return 'Transporte';
      case CostType.investment:
        return 'Inversión';
    }
  }
}
