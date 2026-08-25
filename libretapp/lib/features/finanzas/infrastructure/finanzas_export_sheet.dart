/// Writes all farm income and expense records to the "Finanzas" sheet.
library;

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/services/exportable_sheet.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/finanzas/domain/entities/general_expense_record.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';
import 'package:libretapp/features/finanzas/domain/repositories/finanzas_repository.dart';

class FinanzasExportSheet implements ExportableSheet {
  const FinanzasExportSheet({
    required FinanzasRepository finanzasRepository,
    required AnimalRepository animalRepository,
  }) : _finanzasRepository = finanzasRepository,
       _animalRepository = animalRepository;

  final FinanzasRepository _finanzasRepository;
  final AnimalRepository _animalRepository;

  @override
  String get key => 'finances';

  @override
  String get title => 'Finanzas';

  @override
  String get description => 'Ingresos y gastos, categoría, monto y moneda.';

  @override
  Future<void> writeTo(Excel excel) async {
    final incomes = await _finanzasRepository.getAllIncomes();
    final expenses = await _finanzasRepository.getAllExpenses();
    final animals = await _animalRepository.getAllIncludingInactive();
    final tags = {
      for (final animal in animals) animal.uuid: animal.earTagNumber,
    };
    final rows = <_FinanceRow>[
      ...incomes.map(_FinanceRow.income),
      ...expenses.map(_FinanceRow.expense),
    ]..sort((a, b) => b.date.compareTo(a.date));

    final sheet = excel['Finanzas'];
    writeExcelRow(sheet, 0, [
      'ID Registro',
      'UUID Registro',
      'Fecha',
      'Dirección',
      'Categoría',
      'Monto',
      'Moneda',
      'UUID Animal',
      'Caravana',
      'Notas',
    ], header: true);
    for (var index = 0; index < rows.length; index++) {
      final row = rows[index];
      writeExcelRow(sheet, index + 1, [
        row.id,
        row.recordUuid,
        DateFormat('yyyy-MM-dd HH:mm').format(row.date.toLocal()),
        row.direction,
        row.category,
        row.amount,
        row.currency,
        row.animalUuid,
        row.animalUuid == null ? '' : tags[row.animalUuid] ?? '',
        row.notes,
      ]);
    }
  }
}

class _FinanceRow {
  const _FinanceRow({
    required this.id,
    required this.recordUuid,
    required this.date,
    required this.direction,
    required this.category,
    required this.amount,
    required this.currency,
    required this.animalUuid,
    required this.notes,
  });

  factory _FinanceRow.income(IncomeRecord record) => _FinanceRow(
    id: record.id,
    recordUuid: record.recordUuid,
    date: record.date,
    direction: 'Ingreso',
    category: record.type.name,
    amount: record.amount,
    currency: record.currency,
    animalUuid: record.animalUuid,
    notes: record.notes,
  );

  factory _FinanceRow.expense(GeneralExpenseRecord record) => _FinanceRow(
    id: record.id,
    recordUuid: record.recordUuid,
    date: record.date,
    direction: 'Gasto',
    category: record.type.name,
    amount: record.amount,
    currency: record.currency,
    animalUuid: null,
    notes: record.notes,
  );

  final String? id;
  final String? recordUuid;
  final DateTime date;
  final String direction;
  final String category;
  final double amount;
  final String? currency;
  final String? animalUuid;
  final String? notes;
}
