/// finanzas › view › tabs › gastos_list — general expenses list tab.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/features/finanzas/domain/entities/general_expense_record.dart';
import 'package:libretapp/features/finanzas/widgets/finanzas_empty_state.dart';
import 'package:libretapp/features/finanzas/widgets/record_tile.dart';

/// Renders the list of [expenses] for the current period.
class GastosList extends StatelessWidget {
  const GastosList({super.key, required this.expenses, required this.onDelete});

  final List<GeneralExpenseRecord> expenses;
  final void Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const FinanzasEmptyState(
        icon: Icons.receipt_long,
        message: 'Sin gastos generales en este período.',
        hint: 'Usa el botón + para agregar un gasto.',
      );
    }
    final fmt = NumberFormat('#,##0.00');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: expenses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final r = expenses[i];
        return RecordTile(
          title: r.type.label,
          subtitle: r.notes,
          date: r.date,
          amount: '-${fmt.format(r.amount)}',
          amountColor: Colors.deepOrange,
          currency: r.currency,
          onDelete: r.id != null ? () => onDelete(r.id!) : null,
        );
      },
    );
  }
}
