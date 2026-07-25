/// Tab B — financial summary.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/widgets/app_empty_state.dart';
import 'package:libretapp/features/finanzas/widgets/kpi_card.dart';
import 'package:libretapp/features/perfil/cubit/perfil_tabs_cubit.dart';
import 'package:libretapp/features/perfil/domain/finance_summary_service.dart';
import 'package:libretapp/features/reportes/widgets/widgets.dart';
import 'package:libretapp/theme/app_theme.dart';

class ReportesFinanzasTab extends StatefulWidget {
  const ReportesFinanzasTab({super.key});

  @override
  State<ReportesFinanzasTab> createState() => _ReportesFinanzasTabState();
}

class _ReportesFinanzasTabState extends State<ReportesFinanzasTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<PerfilTabsCubit>().loadFinanzas();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bottomInset = ShellInsets.bottomSafePadding(context);
    final listPadding = EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.sm,
      AppSpacing.md,
      bottomInset + 8,
    );
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return BlocBuilder<PerfilTabsCubit, PerfilTabsState>(
      builder: (context, state) {
        if (state.financeStatus == PerfilTabLoadStatus.loading) {
          return Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state.financeStatus == PerfilTabLoadStatus.error) {
          return Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: AppEmptyState(
              icon: Icons.error_outline,
              title: 'No se pudieron cargar finanzas',
              message: state.errorMessage,
              action: FilledButton(
                onPressed: () =>
                    context.read<PerfilTabsCubit>().refreshFinanzas(),
                child: const Text('Reintentar'),
              ),
            ),
          );
        }

        final detail = state.financeDetail;
        if (detail == null) return const SizedBox.shrink();

        final s = detail.summary;
        final balance = s.netProfit;

        return RefreshIndicator(
          onRefresh: () => context.read<PerfilTabsCubit>().refreshFinanzas(),
          child: ListView(
            padding: listPadding,
            children: [
              ReportSectionCard(
                title: 'Balance del mes',
                child: Column(
                  children: [
                    KpiCard(
                      label: 'Balance del mes',
                      value: fmt.format(balance),
                      icon: balance >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: balance >= 0
                          ? AppColors.success
                          : AppColors.error,
                      large: true,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: KpiCard(
                            label: 'Ingresos',
                            value: fmt.format(s.totalRevenue),
                            icon: Icons.arrow_downward,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: KpiCard(
                            label: 'Egresos',
                            value: fmt.format(s.totalExpenses),
                            icon: Icons.arrow_upward,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ReportSectionCard(
                title: 'Pulso financiero',
                child: _FinancePulse(
                  balance: balance,
                  revenue: s.totalRevenue,
                  expenses: s.totalExpenses,
                  formatter: fmt,
                ),
              ),
              ReportSectionCard(
                title: 'Acciones rápidas',
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            context.push(AppRoutes.registroIngreso),
                        icon: const Icon(Icons.add),
                        label: const Text('Ingreso'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            context.push(AppRoutes.registroGastoGeneral),
                        icon: const Icon(Icons.remove),
                        label: const Text('Egreso'),
                      ),
                    ),
                  ],
                ),
              ),
              ReportSectionCard(
                title: 'Categorías principales',
                child: detail.expenseBreakdown.isEmpty
                    ? const AppEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'Sin gastos este mes',
                        message: 'Registra egresos para ver el desglose.',
                      )
                    : Column(
                        children: detail.expenseBreakdown
                            .map(
                              (c) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(c.label)),
                                    Text(
                                      fmt.format(c.amount),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
              ReportSectionCard(
                title: 'Últimos movimientos',
                child: detail.recentMovements.isEmpty
                    ? const AppEmptyState(
                        icon: Icons.swap_horiz,
                        title: 'Sin movimientos',
                        message:
                            'Aún no hay ingresos ni egresos este mes.',
                      )
                    : Column(
                        children: detail.recentMovements
                            .map((m) => _movementTile(m, fmt))
                            .toList(),
                      ),
              ),
              FilledButton.icon(
                onPressed: () => context.push(AppRoutes.finanzas),
                icon: const Icon(Icons.account_balance_wallet_outlined),
                label: const Text('Ver finanzas completas'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _movementTile(FinanceMovementItem m, NumberFormat fmt) {
    final sign = m.isPositive ? '+' : '-';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            m.isPositive ? Icons.arrow_downward : Icons.arrow_upward,
            color: m.isPositive ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  DateFormat('d MMM yyyy').format(m.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$sign${fmt.format(m.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: m.isPositive ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancePulse extends StatelessWidget {
  const _FinancePulse({
    required this.balance,
    required this.revenue,
    required this.expenses,
    required this.formatter,
  });

  final double balance;
  final double revenue;
  final double expenses;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final positive = balance >= 0;
    final total = revenue + expenses;
    final revenueShare = total <= 0 ? 0.0 : revenue / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              positive ? Icons.savings_outlined : Icons.priority_high,
              color: positive ? AppColors.success : AppColors.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                positive ? 'Margen positivo este mes' : 'Mes bajo presión',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              formatter.format(balance.abs()),
              style: theme.textTheme.labelLarge?.copyWith(
                color: positive ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 7,
            value: revenueShare.clamp(0.0, 1.0),
            backgroundColor: AppColors.error.withValues(alpha: 0.14),
            valueColor: const AlwaysStoppedAnimation(AppColors.success),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          total <= 0
              ? 'Registra ingresos o egresos para ver el pulso financiero.'
              : 'Ingresos contra egresos, calculado con movimientos del periodo.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
