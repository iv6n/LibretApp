import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/index.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/finanzas/application/finanzas_bloc.dart';
import 'package:libretapp/features/finanzas/application/finanzas_event.dart';
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

  _FakeAnimalRepository({List<AnimalEntity>? animals})
    : _animals = animals ?? [];
  final List<AnimalEntity> _animals;

  @override
  Future<List<AnimalEntity>> getAll() async => _animals;

  @override
  Stream<List<AnimalEntity>> watchAll() => const Stream.empty();

  @override
  Stream<void> watchChanges() => const Stream.empty();

  @override
  Future<List<AnimalEntity>> getPage({
    required int offset,
    required int limit,
  }) async => _animals.skip(offset).take(limit).toList();

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
  Future<List<AnimalEntity>> getByBatchUuid(String batchUuid) =>
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
}

class _FakeCostRecordRepository implements CostRecordRepository {

  _FakeCostRecordRepository({Map<String, List<CostRecord>>? costs})
    : _costs = costs ?? {};
  final Map<String, List<CostRecord>> _costs;

  @override
  Future<List<CostRecord>> getCostRecords(String animalUuid) async =>
      _costs[animalUuid] ?? [];

  @override
  Future<CostRecord> addCostRecord(String animalUuid, CostRecord record) =>
      throw UnimplementedError();
  @override
  Future<void> deleteCostRecord(String recordId) => throw UnimplementedError();
}

class _FakeCommercialRecordRepository implements CommercialRecordRepository {

  _FakeCommercialRecordRepository({
    Map<String, List<CommercialRecord>>? commercials,
  }) : _commercials = commercials ?? {};
  final Map<String, List<CommercialRecord>> _commercials;

  @override
  Future<List<CommercialRecord>> getCommercialRecords(
    String animalUuid,
  ) async => _commercials[animalUuid] ?? [];

  @override
  Future<CommercialRecord> addCommercialRecord(
    String animalUuid,
    CommercialRecord record,
  ) => throw UnimplementedError();
  @override
  Future<void> deleteCommercialRecord(String recordId) =>
      throw UnimplementedError();
}

// ─── Helper factories ─────────────────────────────────────────────────────────

AnimalEntity _makeAnimal({
  required String uuid,
  String? customName,
  double? purchasePrice,
  DateTime? creationDate,
}) {
  final now = creationDate ?? DateTime.now();
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

/// Compatibility extension so existing Cubit-style test calls work with [FinanzasBloc].
extension _FinanzasBlocCompat on FinanzasBloc {
  Future<void> loadPeriod(DateRange period) async {
    add(LoadPeriod(period));
    await stream.firstWhere((s) => s.status != FinanzasStatus.loading);
  }

  Future<void> addIncome(IncomeRecord record) async {
    add(AddIncome(record));
    if (state.period != null) {
      await stream.firstWhere((s) => s.status != FinanzasStatus.loading);
    }
  }

  Future<void> addExpense(GeneralExpenseRecord record) async {
    add(AddExpense(record));
    if (state.period != null) {
      await stream.firstWhere((s) => s.status != FinanzasStatus.loading);
    }
  }

  Future<void> deleteIncome(String id) async {
    add(DeleteIncome(id));
    await stream.firstWhere((s) => s.status != FinanzasStatus.loading);
  }

  Future<void> deleteExpense(String id) async {
    add(DeleteExpense(id));
    await stream.firstWhere((s) => s.status != FinanzasStatus.loading);
  }
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  final period = DateRange(
    start: DateTime(2025, 1, 1),
    end: DateTime(2025, 1, 31),
  );

  late _FakeFinanzasRepository finanzasRepo;
  late _FakeAnimalRepository animalRepo;
  late _FakeCostRecordRepository costRepo;
  late _FakeCommercialRecordRepository commercialRepo;

  setUp(() {
    finanzasRepo = _FakeFinanzasRepository();
    animalRepo = _FakeAnimalRepository();
    costRepo = _FakeCostRecordRepository();
    commercialRepo = _FakeCommercialRecordRepository();
  });

  FinanzasBloc cubit0() => FinanzasBloc(
    finanzasRepository: finanzasRepo,
    animalRepository: animalRepo,
    costRepo: costRepo,
    commercialRepo: commercialRepo,
  );

  group('FinanzasCubit initial state', () {
    test('status is initial', () {
      expect(cubit0().state.status, FinanzasStatus.initial);
    });

    test('incomes, expenses and profitabilities are empty', () {
      final s = cubit0().state;
      expect(s.incomes, isEmpty);
      expect(s.expenses, isEmpty);
      expect(s.animalProfitabilities, isEmpty);
    });

    test('period and summary are null', () {
      final s = cubit0().state;
      expect(s.period, isNull);
      expect(s.summary, isNull);
    });
  });

  group('FinanzasCubit.loadPeriod', () {
    test('emits loading then loaded', () async {
      final cubit = cubit0();

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
      final cubit = cubit0();
      await cubit.loadPeriod(period);
      expect(cubit.state.period, period);
      await cubit.close();
    });

    test('with no records produces all-zero summary', () async {
      final cubit = cubit0();
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
      final cubit = cubit0();
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

        final cubit = FinanzasBloc(
          finanzasRepository: repo,
          animalRepository: animalRepo,
          costRepo: costRepo,
          commercialRepo: commercialRepo,
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

      final cubit = FinanzasBloc(
        finanzasRepository: finanzasRepo,
        animalRepository: _FakeAnimalRepository(animals: [animal]),
        costRepo: _FakeCostRecordRepository(
          costs: {
            'a1': [
              _makeCost(date: inPeriod, amount: 80),
              _makeCost(date: outOfPeriod, amount: 999),
            ],
          },
        ),
        commercialRepo: _FakeCommercialRecordRepository(
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

      final cubit = FinanzasBloc(
        finanzasRepository: finanzasRepo,
        animalRepository: _FakeAnimalRepository(animals: [animal]),
        costRepo: _FakeCostRecordRepository(
          costs: {
            'a1': [
              _makeCost(date: inPeriod, amount: 80),
              _makeCost(date: outOfPeriod, amount: 500),
            ],
          },
        ),
        commercialRepo: _FakeCommercialRecordRepository(
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

    test(
      'AnimalProfitability.purchaseCost only hits the period the purchase happened in',
      () async {
        final animal = _makeAnimal(
          uuid: 'a1',
          purchasePrice: 500,
          creationDate: DateTime(2025, 1, 10), // purchased in "this month"
        );

        final cubit = FinanzasBloc(
          finanzasRepository: finanzasRepo,
          animalRepository: _FakeAnimalRepository(animals: [animal]),
          costRepo: costRepo,
          commercialRepo: commercialRepo,
        );

        // "Este mes": the purchase falls inside the period — deducted once.
        await cubit.loadPeriod(period);
        expect(cubit.state.animalProfitabilities.single.purchaseCost, 500.0);

        // "Mes anterior": same animal, different period — must NOT deduct
        // the same purchase price again.
        final previousMonth = DateRange(
          start: DateTime(2024, 12, 1),
          end: DateTime(2024, 12, 31),
        );
        await cubit.loadPeriod(previousMonth);
        expect(
          cubit.state.animalProfitabilities.single.purchaseCost,
          0.0,
          reason:
              'a one-time purchase must not be deducted from every period '
              'the animal is viewed under',
        );
        await cubit.close();
      },
    );

    test(
      'AnimalProfitability.purchaseCost falls back to period-scoped purchase records',
      () async {
        final inPeriod = DateTime(2025, 1, 12);
        final outOfPeriod = DateTime(2025, 3, 1);
        final animal = _makeAnimal(uuid: 'a1'); // no purchasePrice set

        final cubit = FinanzasBloc(
          finanzasRepository: finanzasRepo,
          animalRepository: _FakeAnimalRepository(animals: [animal]),
          costRepo: costRepo,
          commercialRepo: _FakeCommercialRecordRepository(
            commercials: {
              'a1': [
                CommercialRecord(
                  date: outOfPeriod,
                  type: CommercialRecordType.purchase,
                  amount: 999,
                ),
              ],
            },
          ),
        );
        await cubit.loadPeriod(period);

        expect(
          cubit.state.animalProfitabilities.single.purchaseCost,
          0.0,
          reason: 'an out-of-period purchase record must not count either',
        );

        final commercialRepoInPeriod = _FakeCommercialRecordRepository(
          commercials: {
            'a1': [
              CommercialRecord(
                date: inPeriod,
                type: CommercialRecordType.purchase,
                amount: 350,
              ),
            ],
          },
        );
        final cubit2 = FinanzasBloc(
          finanzasRepository: finanzasRepo,
          animalRepository: _FakeAnimalRepository(animals: [animal]),
          costRepo: costRepo,
          commercialRepo: commercialRepoInPeriod,
        );
        await cubit2.loadPeriod(period);
        expect(cubit2.state.animalProfitabilities.single.purchaseCost, 350.0);

        await cubit.close();
        await cubit2.close();
      },
    );

    test('AnimalProfitability uses customName when available', () async {
      final animal = _makeAnimal(uuid: 'a2', customName: 'Conchita');
      final cubit = FinanzasBloc(
        finanzasRepository: finanzasRepo,
        animalRepository: _FakeAnimalRepository(animals: [animal]),
        costRepo: costRepo,
        commercialRepo: commercialRepo,
      );
      await cubit.loadPeriod(period);

      expect(cubit.state.animalProfitabilities.first.animalName, 'Conchita');
      await cubit.close();
    });

    test(
      'AnimalProfitability falls back to earTagNumber when customName is null',
      () async {
        final animal = _makeAnimal(uuid: 'a3');
        final cubit = FinanzasBloc(
          finanzasRepository: finanzasRepo,
          animalRepository: _FakeAnimalRepository(animals: [animal]),
          costRepo: costRepo,
          commercialRepo: commercialRepo,
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

      final cubit = FinanzasBloc(
        finanzasRepository: finanzasRepo,
        animalRepository: _FakeAnimalRepository(animals: animals),
        costRepo: costRepo,
        commercialRepo: _FakeCommercialRecordRepository(
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
      final cubit = cubit0();

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
      final cubit = cubit0();
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
      final cubit = cubit0();
      await cubit.loadPeriod(period);
      expect(cubit.state.incomes, isEmpty);

      await cubit.addIncome(_makeIncome(date: DateTime(2025, 1, 5)));
      expect(cubit.state.status, FinanzasStatus.loaded);
      expect(cubit.state.incomes, hasLength(1));
      await cubit.close();
    });

    test('does not reload when no period has been set', () async {
      final cubit = cubit0();
      // No loadPeriod called — period is null
      await cubit.addIncome(_makeIncome(date: DateTime(2025, 1, 5)));
      expect(cubit.state.status, FinanzasStatus.initial);
      await cubit.close();
    });
  });

  group('FinanzasCubit.addExpense', () {
    test('adds expense to repository and reloads period', () async {
      final cubit = cubit0();
      await cubit.loadPeriod(period);
      expect(cubit.state.expenses, isEmpty);

      await cubit.addExpense(_makeExpense(date: DateTime(2025, 1, 5)));
      expect(cubit.state.status, FinanzasStatus.loaded);
      expect(cubit.state.expenses, hasLength(1));
      await cubit.close();
    });

    test('does not reload when no period has been set', () async {
      final cubit = cubit0();
      await cubit.addExpense(_makeExpense(date: DateTime(2025, 1, 5)));
      expect(cubit.state.status, FinanzasStatus.initial);
      await cubit.close();
    });
  });

  group('FinanzasCubit.deleteIncome', () {
    test('removes income from repository and reloads period', () async {
      final income = _makeIncome(date: DateTime(2025, 1, 8), id: 'del-1');
      await finanzasRepo.addIncome(income);

      final cubit = cubit0();
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

      final cubit = cubit0();
      await cubit.loadPeriod(period);
      expect(cubit.state.expenses, hasLength(1));

      await cubit.deleteExpense('del-2');
      expect(cubit.state.expenses, isEmpty);
      await cubit.close();
    });
  });
}
