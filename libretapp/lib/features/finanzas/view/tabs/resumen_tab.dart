/// finanzas › view › tabs › resumen_tab — summary tab of the financial dashboard.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/widgets/kpi_card.dart';

/// Displays aggregate KPI cards for the given [summary].
class ResumenTab extends StatelessWidget {
  const ResumenTab({super.key, required this.summary});

  final FinancialPeriodSummary? summary;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    if (s == null) {
      return const Center(child: Text('Sin datos para el período.'));
    }
    final fmt = NumberFormat('#,##0.00');
    final isProfit = s.netProfit >= 0;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        KpiCard(
          label: 'Ganancia neta',
          value: '${isProfit ? '+' : ''}${fmt.format(s.netProfit)}',
          icon: isProfit ? Icons.trending_up : Icons.trending_down,
          color: isProfit ? Colors.green : Colors.red,
          large: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: KpiCard(
                label: 'Ingresos generales',
                value: fmt.format(s.totalIncome),
                icon: Icons.attach_money,
                color: Colors.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                label: 'Ventas de animales',
                value: fmt.format(s.totalAnimalSales),
                icon: Icons.store,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: KpiCard(
                label: 'Costos de animales',
                value: fmt.format(s.totalAnimalCosts),
                icon: Icons.pets,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                label: 'Gastos generales',
                value: fmt.format(s.totalGeneralExpenses),
                icon: Icons.receipt_long,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        KpiCard(
          label: 'Ingresos totales',
          value: fmt.format(s.totalRevenue),
          icon: Icons.account_balance_wallet,
          color: Colors.indigo,
        ),
        const SizedBox(height: 12),
        KpiCard(
          label: 'Egresos totales',
          value: fmt.format(s.totalExpenses),
          icon: Icons.money_off,
          color: Colors.brown,
        ),
        if (s.totalRevenue > 0) ...[
          const SizedBox(height: 12),
          KpiCard(
            label: 'Margen de ganancia',
            value: '${(s.profitMargin * 100).toStringAsFixed(1)}%',
            icon: Icons.pie_chart,
            color: isProfit ? Colors.green : Colors.red,
          ),
        ],
      ],
    );
  }
}
