/// finanzas › view › tabs › ingresos_list — income list tab.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';
import 'package:libretapp/features/finanzas/widgets/finanzas_empty_state.dart';
import 'package:libretapp/features/finanzas/widgets/record_tile.dart';

/// Renders the list of [incomes] for the current period.
///
/// Each tile exposes an [onDelete] callback wired to the BLoC event.
class IngresosList extends StatelessWidget {
  const IngresosList({
    super.key,
    required this.incomes,
    required this.onDelete,
  });

  final List<IncomeRecord> incomes;
  final void Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    if (incomes.isEmpty) {
      return const FinanzasEmptyState(
        icon: Icons.attach_money,
        message: 'Sin ingresos registrados en este período.',
        hint: 'Usa el botón + para agregar un ingreso.',
      );
    }
    final fmt = NumberFormat('#,##0.00');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: incomes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final r = incomes[i];
        return RecordTile(
          title: r.type.label,
          subtitle: r.notes,
          date: r.date,
          amount: fmt.format(r.amount),
          amountColor: Colors.teal,
          currency: r.currency,
          onDelete: r.id != null ? () => onDelete(r.id!) : null,
        );
      },
    );
  }
}
