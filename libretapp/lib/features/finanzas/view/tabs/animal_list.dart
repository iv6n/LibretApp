/// finanzas › view › tabs › animal_list — per-animal profitability tab.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/features/finanzas/domain/entities/animal_profitability.dart';
import 'package:libretapp/features/finanzas/widgets/finanzas_empty_state.dart';

/// Renders a list of [AnimalProfitability] items showing per-animal net result.
class AnimalList extends StatelessWidget {
  const AnimalList({super.key, required this.profitabilities});

  final List<AnimalProfitability> profitabilities;

  @override
  Widget build(BuildContext context) {
    if (profitabilities.isEmpty) {
      return const FinanzasEmptyState(
        icon: Icons.pets,
        message: 'No hay animales con datos financieros.',
        hint: 'Registra costos o ventas en un animal para verlo aquí.',
      );
    }
    final fmt = NumberFormat('#,##0.00');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: profitabilities.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final p = profitabilities[i];
        final color = p.isProfitable ? Colors.green : Colors.red;
        final theme = Theme.of(context);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(
                    p.isProfitable ? Icons.trending_up : Icons.trending_down,
                    color: color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.animalName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Compra: ${fmt.format(p.purchaseCost)}  '
                        'Costos: ${fmt.format(p.totalCosts)}  '
                        'Ventas: ${fmt.format(p.saleRevenue)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${p.isProfitable ? '+' : ''}${fmt.format(p.netResult)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
