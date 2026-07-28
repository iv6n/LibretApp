import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/domain/entities/general_expense_record.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';
import 'package:libretapp/features/finanzas/infrastructure/isar_finanzas_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'libretapp_finanzas_isar_test_',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          return tempDir.path;
        });
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    await IsarDatabase().close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() async {
    // Every test in this file shares the same on-disk Isar directory (set
    // once in setUpAll), so without an explicit clear, records written by
    // one test leak into the next test's date-range/count assertions.
    // Start every test from a clean slate instead.
    final db = IsarDatabase();
    await db.initialize();
    await db.clearAllCollections();
  });

  tearDown(() async {
    await IsarDatabase().close();
  });

  // ─── Helper ───────────────────────────────────────────────────────────────

  Future<IsarFinanzasRepository> _openRepo() async {
    final db = IsarDatabase();
    await db.initialize();
    return IsarFinanzasRepository(db);
  }

  // ─── IncomeRecord ─────────────────────────────────────────────────────────

  group('IsarFinanzasRepository — ingresos', () {
    test(
      'addIncome persiste un ingreso y getIncomes lo retorna con campos correctos',
      () async {
        final repo = await _openRepo();
        final range = DateRange(
          start: DateTime(2025, 1, 1),
          end: DateTime(2025, 12, 31),
        );

        final saved = await repo.addIncome(
          IncomeRecord(
            date: DateTime(2025, 6, 15),
            type: IncomeType.milkSale,
            amount: 320.0,
            currency: 'USD',
            notes: 'Venta semanal de leche',
          ),
        );

        expect(saved.id, isNotNull);

        final records = await repo.getIncomes(range);

        expect(records, hasLength(1));
        expect(records.first.type, IncomeType.milkSale);
        expect(records.first.amount, 320.0);
        expect(records.first.currency, 'USD');
        expect(records.first.notes, 'Venta semanal de leche');
      },
      skip: !_canRunIsarNative(),
    );

    test(
      'getIncomes filtra por rango de fechas y excluye registros fuera del rango',
      () async {
        final repo = await _openRepo();

        await repo.addIncome(
          IncomeRecord(
            date: DateTime(2025, 3, 10),
            type: IncomeType.service,
            amount: 500.0,
          ),
        );
        await repo.addIncome(
          IncomeRecord(
            date: DateTime(2025, 9, 20),
            type: IncomeType.subsidy,
            amount: 200.0,
          ),
        );

        final q1Range = DateRange(
          start: DateTime(2025, 1, 1),
          end: DateTime(2025, 6, 30),
        );
        final q1Records = await repo.getIncomes(q1Range);

        expect(q1Records, hasLength(1));
        expect(q1Records.first.type, IncomeType.service);
      },
      skip: !_canRunIsarNative(),
    );

    test(
      'deleteIncome elimina el ingreso del almacenamiento',
      () async {
        final repo = await _openRepo();
        final range = DateRange(
          start: DateTime(2025, 1, 1),
          end: DateTime(2025, 12, 31),
        );

        final saved = await repo.addIncome(
          IncomeRecord(
            date: DateTime(2025, 7, 1),
            type: IncomeType.woolSale,
            amount: 150.0,
          ),
        );

        await repo.deleteIncome(saved.id!);
        final records = await repo.getIncomes(range);

        expect(records, isEmpty);
      },
      skip: !_canRunIsarNative(),
    );

    test(
      'deleteIncome lanza ArgumentError para un id no numérico',
      () async {
        final repo = await _openRepo();

        expect(
          () => repo.deleteIncome('id-no-valido'),
          throwsA(isA<ArgumentError>()),
        );
      },
      skip: !_canRunIsarNative(),
    );
  });

  // ─── GeneralExpenseRecord ─────────────────────────────────────────────────

  group('IsarFinanzasRepository — gastos generales', () {
    test(
      'addExpense persiste un gasto y getExpenses lo retorna con campos correctos',
      () async {
        final repo = await _openRepo();
        final range = DateRange(
          start: DateTime(2025, 1, 1),
          end: DateTime(2025, 12, 31),
        );

        final saved = await repo.addExpense(
          GeneralExpenseRecord(
            date: DateTime(2025, 5, 20),
            type: GeneralExpenseType.fuel,
            amount: 85.0,
            currency: 'USD',
            notes: 'Combustible para tractor',
          ),
        );

        expect(saved.id, isNotNull);

        final records = await repo.getExpenses(range);

        expect(records, hasLength(1));
        expect(records.first.type, GeneralExpenseType.fuel);
        expect(records.first.amount, 85.0);
        expect(records.first.currency, 'USD');
        expect(records.first.notes, 'Combustible para tractor');
      },
      skip: !_canRunIsarNative(),
    );

    test(
      'getExpenses filtra por rango de fechas y excluye registros fuera del rango',
      () async {
        final repo = await _openRepo();

        await repo.addExpense(
          GeneralExpenseRecord(
            date: DateTime(2025, 2, 5),
            type: GeneralExpenseType.labor,
            amount: 400.0,
          ),
        );
        await repo.addExpense(
          GeneralExpenseRecord(
            date: DateTime(2025, 11, 15),
            type: GeneralExpenseType.taxes,
            amount: 600.0,
          ),
        );

        final firstHalf = DateRange(
          start: DateTime(2025, 1, 1),
          end: DateTime(2025, 6, 30),
        );
        final records = await repo.getExpenses(firstHalf);

        expect(records, hasLength(1));
        expect(records.first.type, GeneralExpenseType.labor);
      },
      skip: !_canRunIsarNative(),
    );

    test(
      'deleteExpense elimina el gasto del almacenamiento',
      () async {
        final repo = await _openRepo();
        final range = DateRange(
          start: DateTime(2025, 1, 1),
          end: DateTime(2025, 12, 31),
        );

        final saved = await repo.addExpense(
          GeneralExpenseRecord(
            date: DateTime(2025, 4, 10),
            type: GeneralExpenseType.equipment,
            amount: 950.0,
          ),
        );

        await repo.deleteExpense(saved.id!);
        final records = await repo.getExpenses(range);

        expect(records, isEmpty);
      },
      skip: !_canRunIsarNative(),
    );

    test(
      'deleteExpense lanza ArgumentError para un id no numérico',
      () async {
        final repo = await _openRepo();

        expect(
          () => repo.deleteExpense('id-no-valido'),
          throwsA(isA<ArgumentError>()),
        );
      },
      skip: !_canRunIsarNative(),
    );
  });
}

bool _canRunIsarNative() {
  if (!Platform.isWindows) return true;
  final candidates = <File>[
    File('isar.dll'),
    File('${Directory.current.path}\\isar.dll'),
  ];
  return candidates.any((file) => file.existsSync());
}
