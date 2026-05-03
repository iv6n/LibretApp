import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/finanzas/application/finanzas_state.dart';
import 'package:libretapp/features/finanzas/domain/entities/animal_profitability.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/domain/entities/general_expense_record.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';
import 'package:libretapp/features/finanzas/domain/repositories/finanzas_repository.dart';

class FinanzasCubit extends Cubit<FinanzasState> {
  FinanzasCubit({
    required FinanzasRepository finanzasRepository,
    required AnimalRepository animalRepository,
  }) : _finanzasRepository = finanzasRepository,
       _animalRepository = animalRepository,
       super(const FinanzasState());

  final FinanzasRepository _finanzasRepository;
  final AnimalRepository _animalRepository;

  /// Carga todos los datos financieros para el [period] dado.
  ///
  /// Todos los registros de animales se obtienen en paralelo (sin N+1).
  /// Los costos y ventas por animal se filtran al mismo [period] que el
  /// resumen general para garantizar consistencia entre pestañas.
  Future<void> loadPeriod(DateRange period) async {
    emit(
      state.copyWith(
        status: FinanzasStatus.loading,
        period: period,
        error: null,
      ),
    );
    try {
      final topResults = await Future.wait([
        _finanzasRepository.getIncomes(period),
        _finanzasRepository.getExpenses(period),
        _animalRepository.getAll(),
      ]);

      final incomes = topResults[0] as List<IncomeRecord>;
      final expenses = topResults[1] as List<GeneralExpenseRecord>;
      final animals = topResults[2] as List;

      // Fetch all per-animal records concurrently (fix N+1 query).
      final animalRecords = await Future.wait(
        animals.map((animal) async {
          final uuid = animal.uuid as String;
          final fetched = await Future.wait([
            _animalRepository.getCostRecords(uuid),
            _animalRepository.getCommercialRecords(uuid),
          ]);
          return (
            animal: animal,
            costs: fetched[0] as List<CostRecord>,
            commercials: fetched[1] as List<CommercialRecord>,
          );
        }),
      );

      double totalAnimalCosts = 0;
      double totalAnimalSales = 0;
      final profitabilities = <AnimalProfitability>[];

      for (final data in animalRecords) {
        final animal = data.animal;
        final uuid = animal.uuid as String;
        final costs = data.costs;
        final commercials = data.commercials;

        // Period-scoped totals — used for both the summary and per-animal view
        // so that both tabs always show the same numbers for the same period.
        final costsInPeriod = costs
            .where((c) => period.contains(c.date))
            .fold<double>(0.0, (sum, c) => sum + c.amount);

        final salesInPeriod = commercials
            .where(
              (c) =>
                  c.type == CommercialRecordType.sale &&
                  period.contains(c.date),
            )
            .fold<double>(0.0, (sum, c) => sum + (c.amount ?? 0.0));

        totalAnimalCosts += costsInPeriod;
        totalAnimalSales += salesInPeriod;

        final purchaseCostNullable = animal.purchasePrice as double?;
        final purchaseCost =
            purchaseCostNullable ??
            commercials
                .where((c) => c.type == CommercialRecordType.purchase)
                .fold<double>(0.0, (sum, c) => sum + (c.amount ?? 0.0));

        profitabilities.add(
          AnimalProfitability(
            animalUuid: uuid,
            animalName:
                (animal.customName as String?) ??
                (animal.earTagNumber as String?) ??
                uuid,
            purchaseCost: purchaseCost,
            totalCosts: costsInPeriod,
            saleRevenue: salesInPeriod,
          ),
        );
      }

      profitabilities.sort((a, b) => b.netResult.compareTo(a.netResult));

      final totalIncome = incomes.fold(0.0, (sum, i) => sum + i.amount);
      final totalGeneralExpenses = expenses.fold(
        0.0,
        (sum, e) => sum + e.amount,
      );

      final summary = FinancialPeriodSummary(
        period: period,
        totalIncome: totalIncome,
        totalGeneralExpenses: totalGeneralExpenses,
        totalAnimalCosts: totalAnimalCosts,
        totalAnimalSales: totalAnimalSales,
      );

      emit(
        state.copyWith(
          status: FinanzasStatus.loaded,
          period: period,
          incomes: incomes,
          expenses: expenses,
          summary: summary,
          animalProfitabilities: profitabilities,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: FinanzasStatus.error, error: e.toString()));
    }
  }

  Future<void> addIncome(IncomeRecord record) async {
    await _finanzasRepository.addIncome(record);
    final period = state.period;
    if (period != null) await loadPeriod(period);
  }

  Future<void> addExpense(GeneralExpenseRecord record) async {
    await _finanzasRepository.addExpense(record);
    final period = state.period;
    if (period != null) await loadPeriod(period);
  }

  Future<void> deleteIncome(String id) async {
    await _finanzasRepository.deleteIncome(id);
    final period = state.period;
    if (period != null) await loadPeriod(period);
  }

  Future<void> deleteExpense(String id) async {
    await _finanzasRepository.deleteExpense(id);
    final period = state.period;
    if (period != null) await loadPeriod(period);
  }
}
