import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/production_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/index.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/finanzas/application/finanzas_cubit.dart';
import 'package:libretapp/features/finanzas/application/finanzas_state.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/domain/entities/general_expense_record.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';
import 'package:libretapp/features/finanzas/domain/repositories/finanzas_repository.dart';

// ─── Fake Implementations ────────────────────────────────────────────────────

class _FakeFinanzasRepository implements FinanzasRepository {
  final List<IncomeRecord> _incomes = [];
  final List<GeneralExpenseRecord> _expenses = [];
  bool failOnGet = false;

  @override
  Future<List<IncomeRecord>> getIncomes(DateRange range) async {
    if (failOnGet) throw Exception('simulated repository error');
    return _incomes.where((r) => range.contains(r.date)).toList();
  }

  @override
  Future<IncomeRecord> addIncome(IncomeRecord record) async {
    _incomes.add(record);
    return record;
  }

  @override
  Future<void> deleteIncome(String id) async {
    _incomes.removeWhere((r) => r.id == id);
  }

  @override
  Future<List<GeneralExpenseRecord>> getExpenses(DateRange range) async {
    if (failOnGet) throw Exception('simulated repository error');
    return _expenses.where((r) => range.contains(r.date)).toList();
  }

  @override
  Future<GeneralExpenseRecord> addExpense(GeneralExpenseRecord record) async {
    _expenses.add(record);
    return record;
  }

  @override
  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((r) => r.id == id);
  }
}

class _FakeAnimalRepository implements AnimalRepository {
  final List<AnimalEntity> _animals;
  final Map<String, List<CostRecord>> _costs;
  final Map<String, List<CommercialRecord>> _commercials;

  _FakeAnimalRepository({
    List<AnimalEntity>? animals,
    Map<String, List<CostRecord>>? costs,
    Map<String, List<CommercialRecord>>? commercials,
  }) : _animals = animals ?? [],
       _costs = costs ?? {},
       _commercials = commercials ?? {};

  @override
  Future<List<AnimalEntity>> getAll() async => _animals;

  @override
  Future<List<CostRecord>> getCostRecords(String animalUuid) async =>
      _costs[animalUuid] ?? [];

  @override
  Future<List<CommercialRecord>> getCommercialRecords(
    String animalUuid,
  ) async => _commercials[animalUuid] ?? [];

  @override
  Stream<List<AnimalEntity>> watchAll() => const Stream.empty();

  // ─── Unused stubs ──────────────────────────────────────────────────────────

  @override
  Future<bool> refreshFromRemote({bool force = false}) =>
      throw UnimplementedError();
  @override
  Future<AnimalEntity?> getByUuid(String uuid) => throw UnimplementedError();
  @override
  Future<List<AnimalEntity>> getBySpecies(String speciesName) =>
      throw UnimplementedError();
  @override
  Future<List<AnimalEntity>> getByPaddock(String paddockId) =>
      throw UnimplementedError();
  @override
  Future<List<AnimalEntity>> getAnimalsRequiringAttention() =>
      throw UnimplementedError();
  @override
  Future<List<AnimalEntity>> getUnsynchronized() => throw UnimplementedError();
  @override
  Future<AnimalEntity> save(AnimalEntity animal) => throw UnimplementedError();
  @override
  Future<AnimalEntity> update(AnimalEntity animal) =>
      throw UnimplementedError();
  @override
  Future<void> markAsSynced(String uuid, String remoteId) =>
      throw UnimplementedError();
  @override
  Future<void> markAsUnsynchronized(String uuid) => throw UnimplementedError();
  @override
  Future<void> delete(String uuid) => throw UnimplementedError();
  @override
  Future<void> clearAll() => throw UnimplementedError();
  @override
  Future<int> count() => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> getStatistics() => throw UnimplementedError();
  @override
  Future<List<WeightRecord>> getWeightRecords(String animalUuid) =>
      throw UnimplementedError();
  @override
  Future<WeightRecord> addWeightRecord(
    String animalUuid,
    WeightRecord record,
  ) => throw UnimplementedError();
  @override
  Future<void> deleteWeightRecord(String recordId) =>
      throw UnimplementedError();
  @override
  Future<List<ProductionRecord>> getProductionRecords(String animalUuid) =>
      throw UnimplementedError();
  @override
  Future<ProductionRecord> addProductionRecord(
    String animalUuid,
    ProductionRecord record,
  ) => throw UnimplementedError();
  @override
  Future<void> deleteProductionRecord(String recordId) =>
      throw UnimplementedError();
  @override
  Future<List<HealthRecord>> getHealthRecords(String animalUuid) =>
      throw UnimplementedError();
  @override
  Future<HealthRecord> addHealthRecord(
    String animalUuid,
    HealthRecord record,
  ) => throw UnimplementedError();
  @override
  Future<void> addHealthRecordToMultiple(
    List<String> animalUuids,
    HealthRecord record,
  ) => throw UnimplementedError();
  @override
  Future<void> deleteHealthRecord(String recordId) =>
      throw UnimplementedError();
  @override
  Future<CommercialRecord> addCommercialRecord(
    String animalUuid,
    CommercialRecord record,
  ) => throw UnimplementedError();
  @override
  Future<void> deleteCommercialRecord(String recordId) =>
      throw UnimplementedError();
  @override
  Future<List<MovementRecord>> getMovementRecords(String animalUuid) =>
      throw UnimplementedError();
  @override
  Future<MovementRecord> addMovementRecord(
    String animalUuid,
    MovementRecord record,
  ) => throw UnimplementedError();
  @override
  Future<void> deleteMovementRecord(String recordId) =>
      throw UnimplementedError();
  @override
  Future<CostRecord> addCostRecord(String animalUuid, CostRecord record) =>
      throw UnimplementedError();
  @override
  Future<void> deleteCostRecord(String recordId) => throw UnimplementedError();
  @override
  Future<List<ReproductionRecord>> getReproductionRecords(String animalUuid) =>
      throw UnimplementedError();
  @override
  Future<ReproductionRecord> addReproductionRecord(
    String animalUuid,
    ReproductionRecord record,
  ) => throw UnimplementedError();
  @override
  Future<void> deleteReproductionRecord(String recordId) =>
      throw UnimplementedError();
}

// ─── Helper factories ─────────────────────────────────────────────────────────

AnimalEntity _makeAnimal({
  required String uuid,
  String? customName,
  double? purchasePrice,
}) {
  final now = DateTime.now();
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: 'TAG-$uuid',
    customName: customName,
    purchasePrice: purchasePrice,
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: 'Test',
    birthDate: DateTime(2020, 1, 1),
    ageMonths: 60,
    healthStatus: HealthStatus.good,
    vaccinated: true,
    dewormed: true,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.undefined,
    productionStage: ProductionStage.unknown,
    productionSystem: ProductionSystem.unknown,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.low,
    gallery: const [],
    synced: true,
    creationDate: now,
    lastUpdateDate: now,
  );
}

IncomeRecord _makeIncome({
  required DateTime date,
  double amount = 100,
  String id = '1',
}) {
  return IncomeRecord(
    date: date,
    type: IncomeType.milkSale,
    amount: amount,
    id: id,
  );
}

GeneralExpenseRecord _makeExpense({
  required DateTime date,
  double amount = 50,
  String id = '1',
}) {
  return GeneralExpenseRecord(
    date: date,
    type: GeneralExpenseType.fuel,
    amount: amount,
    id: id,
  );
}

CostRecord _makeCost({required DateTime date, double amount = 30}) {
  return CostRecord(date: date, type: CostType.feeding, amount: amount);
}

CommercialRecord _makeSale({required DateTime date, double amount = 500}) {
  return CommercialRecord(
    date: date,
    type: CommercialRecordType.sale,
    amount: amount,
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  final period = DateRange(
    start: DateTime(2025, 1, 1),
    end: DateTime(2025, 1, 31),
  );

  late _FakeFinanzasRepository finanzasRepo;
  late _FakeAnimalRepository animalRepo;

  setUp(() {
    finanzasRepo = _FakeFinanzasRepository();
    animalRepo = _FakeAnimalRepository();
  });

  FinanzasCubit _cubit() => FinanzasCubit(
    finanzasRepository: finanzasRepo,
    animalRepository: animalRepo,
  );

  group('FinanzasCubit initial state', () {
    test('status is initial', () {
      expect(_cubit().state.status, FinanzasStatus.initial);
    });

    test('incomes, expenses and profitabilities are empty', () {
      final s = _cubit().state;
      expect(s.incomes, isEmpty);
      expect(s.expenses, isEmpty);
      expect(s.animalProfitabilities, isEmpty);
    });

    test('period and summary are null', () {
      final s = _cubit().state;
      expect(s.period, isNull);
      expect(s.summary, isNull);
    });
  });

  group('FinanzasCubit.loadPeriod', () {
    test('emits loading then loaded', () async {
      final cubit = _cubit();

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          predicate<FinanzasState>(
            (s) => s.status == FinanzasStatus.loading,
            'loading state',
          ),
          predicate<FinanzasState>(
            (s) => s.status == FinanzasStatus.loaded,
            'loaded state',
          ),
        ]),
      );

      await cubit.loadPeriod(period);
      await expectation;
      await cubit.close();
    });

    test('loaded state has the correct period', () async {
      final cubit = _cubit();
      await cubit.loadPeriod(period);
      expect(cubit.state.period, period);
      await cubit.close();
    });

    test('with no records produces all-zero summary', () async {
      final cubit = _cubit();
      await cubit.loadPeriod(period);

      final s = cubit.state.summary!;
      expect(s.totalIncome, 0.0);
      expect(s.totalGeneralExpenses, 0.0);
      expect(s.totalAnimalCosts, 0.0);
      expect(s.totalAnimalSales, 0.0);
      expect(s.netProfit, 0.0);
      await cubit.close();
    });

    test('with no animals produces empty profitabilities list', () async {
      final cubit = _cubit();
      await cubit.loadPeriod(period);
      expect(cubit.state.animalProfitabilities, isEmpty);
      await cubit.close();
    });

    test(
      'sums income and expense records within period, ignores out-of-period records',
      () async {
        final inPeriod = DateTime(2025, 1, 15);
        final outOfPeriod = DateTime(2025, 3, 1);

        final repo = _FakeFinanzasRepository();
        await repo.addIncome(_makeIncome(date: inPeriod, amount: 200, id: '1'));
        await repo.addIncome(
          _makeIncome(date: outOfPeriod, amount: 999, id: '2'),
        );
        await repo.addExpense(
          _makeExpense(date: inPeriod, amount: 80, id: '3'),
        );

        final cubit = FinanzasCubit(
          finanzasRepository: repo,
          animalRepository: animalRepo,
        );
        await cubit.loadPeriod(period);

        final s = cubit.state.summary!;
        expect(
          s.totalIncome,
          200.0,
          reason: 'out-of-period income should be excluded',
        );
        expect(s.totalGeneralExpenses, 80.0);
        await cubit.close();
      },
    );

    test('sums animal costs and sales within period for summary', () async {
      final inPeriod = DateTime(2025, 1, 10);
      final outOfPeriod = DateTime(2025, 3, 1);
      final animal = _makeAnimal(uuid: 'a1', purchasePrice: 500);

      final cubit = FinanzasCubit(
        finanzasRepository: finanzasRepo,
        animalRepository: _FakeAnimalRepository(
          animals: [animal],
          costs: {
            'a1': [
              _makeCost(date: inPeriod, amount: 80),
              _makeCost(date: outOfPeriod, amount: 999),
            ],
          },
          commercials: {
            'a1': [
              _makeSale(date: inPeriod, amount: 400),
              _makeSale(date: outOfPeriod, amount: 9999),
            ],
          },
        ),
      );
      await cubit.loadPeriod(period);

      final s = cubit.state.summary!;
      expect(s.totalAnimalCosts, 80.0);
      expect(s.totalAnimalSales, 400.0);
      await cubit.close();
    });

    test('AnimalProfitability uses period-scoped costs and sales', () async {
      final inPeriod = DateTime(2025, 1, 10);
      final outOfPeriod = DateTime(2025, 3, 1);
      final animal = _makeAnimal(uuid: 'a1', purchasePrice: 300);

      final cubit = FinanzasCubit(
        finanzasRepository: finanzasRepo,
        animalRepository: _FakeAnimalRepository(
          animals: [animal],
          costs: {
            'a1': [
              _makeCost(date: inPeriod, amount: 80),
              _makeCost(date: outOfPeriod, amount: 500),
            ],
          },
          commercials: {
            'a1': [
              _makeSale(date: inPeriod, amount: 400),
              _makeSale(date: outOfPeriod, amount: 9000),
            ],
          },
        ),
      );
      await cubit.loadPeriod(period);

      final profs = cubit.state.animalProfitabilities;
      expect(profs, hasLength(1));
      final p = profs.first;
      expect(p.totalCosts, 80.0, reason: 'only in-period cost');
      expect(p.saleRevenue, 400.0, reason: 'only in-period sale');
      await cubit.close();
    });

    test('AnimalProfitability uses customName when available', () async {
      final animal = _makeAnimal(uuid: 'a2', customName: 'Conchita');
      final cubit = FinanzasCubit(
        finanzasRepository: finanzasRepo,
        animalRepository: _FakeAnimalRepository(animals: [animal]),
      );
      await cubit.loadPeriod(period);

      expect(cubit.state.animalProfitabilities.first.animalName, 'Conchita');
      await cubit.close();
    });

    test(
      'AnimalProfitability falls back to earTagNumber when customName is null',
      () async {
        final animal = _makeAnimal(uuid: 'a3');
        final cubit = FinanzasCubit(
          finanzasRepository: finanzasRepo,
          animalRepository: _FakeAnimalRepository(animals: [animal]),
        );
        await cubit.loadPeriod(period);

        expect(cubit.state.animalProfitabilities.first.animalName, 'TAG-a3');
        await cubit.close();
      },
    );

    test('profitabilities are sorted by netResult descending', () async {
      final inPeriod = DateTime(2025, 1, 10);
      final animals = [
        _makeAnimal(uuid: 'low', purchasePrice: 0),
        _makeAnimal(uuid: 'high', purchasePrice: 0),
        _makeAnimal(uuid: 'mid', purchasePrice: 0),
      ];

      final cubit = FinanzasCubit(
        finanzasRepository: finanzasRepo,
        animalRepository: _FakeAnimalRepository(
          animals: animals,
          commercials: {
            'low': [_makeSale(date: inPeriod, amount: 100)],
            'high': [_makeSale(date: inPeriod, amount: 900)],
            'mid': [_makeSale(date: inPeriod, amount: 500)],
          },
        ),
      );
      await cubit.loadPeriod(period);

      final names = cubit.state.animalProfitabilities
          .map((p) => p.animalUuid)
          .toList();
      expect(names, ['high', 'mid', 'low']);
      await cubit.close();
    });

    test('emits error state when repository throws', () async {
      finanzasRepo.failOnGet = true;
      final cubit = _cubit();

      await cubit.loadPeriod(period);
      // Yield to the microtask queue so the stream delivers the error state.
      await Future<void>.value();

      expect(cubit.state.status, FinanzasStatus.error);
      expect(cubit.state.error, isNotNull);
      await cubit.close();
    });

    test('clears previous error when reloading successfully', () async {
      // First load fails
      finanzasRepo.failOnGet = true;
      final cubit = _cubit();
      await cubit.loadPeriod(period);
      expect(cubit.state.status, FinanzasStatus.error);

      // Second load succeeds
      finanzasRepo.failOnGet = false;
      await cubit.loadPeriod(period);
      expect(cubit.state.status, FinanzasStatus.loaded);
      expect(cubit.state.error, isNull);
      await cubit.close();
    });
  });

  group('FinanzasCubit.addIncome', () {
    test('adds income to repository and reloads period', () async {
      final cubit = _cubit();
      await cubit.loadPeriod(period);
      expect(cubit.state.incomes, isEmpty);

      await cubit.addIncome(_makeIncome(date: DateTime(2025, 1, 5)));
      expect(cubit.state.status, FinanzasStatus.loaded);
      expect(cubit.state.incomes, hasLength(1));
      await cubit.close();
    });

    test('does not reload when no period has been set', () async {
      final cubit = _cubit();
      // No loadPeriod called — period is null
      await cubit.addIncome(_makeIncome(date: DateTime(2025, 1, 5)));
      expect(cubit.state.status, FinanzasStatus.initial);
      await cubit.close();
    });
  });

  group('FinanzasCubit.addExpense', () {
    test('adds expense to repository and reloads period', () async {
      final cubit = _cubit();
      await cubit.loadPeriod(period);
      expect(cubit.state.expenses, isEmpty);

      await cubit.addExpense(_makeExpense(date: DateTime(2025, 1, 5)));
      expect(cubit.state.status, FinanzasStatus.loaded);
      expect(cubit.state.expenses, hasLength(1));
      await cubit.close();
    });

    test('does not reload when no period has been set', () async {
      final cubit = _cubit();
      await cubit.addExpense(_makeExpense(date: DateTime(2025, 1, 5)));
      expect(cubit.state.status, FinanzasStatus.initial);
      await cubit.close();
    });
  });

  group('FinanzasCubit.deleteIncome', () {
    test('removes income from repository and reloads period', () async {
      final income = _makeIncome(date: DateTime(2025, 1, 8), id: 'del-1');
      await finanzasRepo.addIncome(income);

      final cubit = _cubit();
      await cubit.loadPeriod(period);
      expect(cubit.state.incomes, hasLength(1));

      await cubit.deleteIncome('del-1');
      expect(cubit.state.incomes, isEmpty);
      await cubit.close();
    });
  });

  group('FinanzasCubit.deleteExpense', () {
    test('removes expense from repository and reloads period', () async {
      final expense = _makeExpense(date: DateTime(2025, 1, 8), id: 'del-2');
      await finanzasRepo.addExpense(expense);

      final cubit = _cubit();
      await cubit.loadPeriod(period);
      expect(cubit.state.expenses, hasLength(1));

      await cubit.deleteExpense('del-2');
      expect(cubit.state.expenses, isEmpty);
      await cubit.close();
    });
  });
}
