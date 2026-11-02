/// Tab B — financial summary.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/widgets/app_empty_state.dart';
import 'package:libretapp/features/finanzas/widgets/kpi_card.dart';
import 'package:libretapp/features/finanzas/domain/finance_summary_service.dart';
import 'package:libretapp/features/finanzas/domain/enums/financial_period_preset.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/reportes/cubit/reportes_cubit.dart';
import 'package:libretapp/features/reportes/widgets/widgets.dart';
import 'package:libretapp/features/reportes/widgets/report_tiles.dart';
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
    context.read<ReportesCubit>().loadFinanzas();
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
    final locale = Localizations.localeOf(context).toLanguageTag();

    return BlocBuilder<ReportesCubit, ReportesState>(
      builder: (context, state) {
        if (state.financeStatus == ReportesLoadStatus.loading) {
          return Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state.financeStatus == ReportesLoadStatus.error) {
          return Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: AppEmptyState(
              icon: Icons.error_outline,
              title: 'No se pudieron cargar finanzas',
              message: state.errorMessage,
              action: FilledButton(
                onPressed: () =>
                    context.read<ReportesCubit>().refreshFinanzas(),
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
          onRefresh: () => context.read<ReportesCubit>().refreshFinanzas(),
          child: ListView(
            padding: listPadding,
            children: [
              ReportSectionCard(
                title: s.invalidRecordCount > 0
                    ? 'Balance parcial'
                    : 'Balance del periodo',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: DropdownButton<FinancialPeriodPreset>(
                            value: state.financePreset,
                            isExpanded: true,
                            underline: const SizedBox.shrink(),
                            items: FinancialPeriodPreset.values
                                .map(
                                  (preset) => DropdownMenuItem(
                                    value: preset,
                                    child: Text(preset.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (preset) {
                              if (preset != null) {
                                context
                                    .read<ReportesCubit>()
                                    .changeFinancePreset(preset);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _formatPeriod(s.period, locale),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    KpiCard(
                      label: 'Balance del periodo',
                      value: fmt.format(balance),
                      icon: balance >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: balance >= 0 ? AppColors.success : AppColors.error,
                      large: true,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    KpiCard(
                      label: 'Ingresos',
                      value: fmt.format(s.totalRevenue),
                      icon: Icons.arrow_downward,
                      color: AppColors.success,
                    ),
                    KpiCard(
                      label: 'Egresos',
                      value: fmt.format(s.totalExpenses),
                      icon: Icons.arrow_upward,
                      color: AppColors.error,
                    ),
                    if (s.invalidRecordCount > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${s.invalidRecordCount} registros con importes inválidos '
                        'no se incluyeron en el balance.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => context.push(AppRoutes.finanzas),
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: const Text('Revisar en Finanzas'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ReportSectionCard(
                title: 'Ingresos y egresos',
                child: _FinanceComparison(
                  revenue: s.totalRevenue,
                  expenses: s.totalExpenses,
                  formatter: fmt,
                ),
              ),
              ReportSectionCard(
                title: 'Acciones rápidas',
                child: ReportTiles(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.push(AppRoutes.registroIngreso),
                      icon: const Icon(Icons.add),
                      label: const Text('Ingreso'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.push(AppRoutes.registroGastoGeneral),
                      icon: const Icon(Icons.remove),
                      label: const Text('Egreso'),
                    ),
                  ],
                ),
              ),
              ReportSectionCard(
                title: 'Categorías principales',
                child: detail.expenseBreakdown.isEmpty
                    ? const AppEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'Sin gastos en este periodo',
                        message: 'Registra egresos para ver el desglose.',
                      )
                    : Column(
                        children: detail.expenseBreakdown
                            .map(
                              (c) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.label),
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
                            'Aún no hay ingresos ni egresos en este periodo.',
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

  String _formatPeriod(DateRange period, String locale) {
    final dateFormat = DateFormat('d MMM yyyy', locale);
    return '${dateFormat.format(period.start)} – ${dateFormat.format(period.end)}';
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  DateFormat(
                    'd MMM yyyy',
                    Localizations.localeOf(context).toLanguageTag(),
                  ).format(m.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          ),
        ],
      ),
    );
  }
}

class _FinanceComparison extends StatelessWidget {
  const _FinanceComparison({
    required this.revenue,
    required this.expenses,
    required this.formatter,
  });

  final double revenue;
  final double expenses;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = math.max(revenue, expenses).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FinanceBar(
          label: 'Ingresos',
          amount: revenue,
          scale: scale,
          color: AppColors.success,
          formatter: formatter,
        ),
        const SizedBox(height: AppSpacing.md),
        _FinanceBar(
          label: 'Egresos',
          amount: expenses,
          scale: scale,
          color: AppColors.error,
          formatter: formatter,
        ),
        if (scale == 0) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sin movimientos en este periodo.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _FinanceBar extends StatelessWidget {
  const _FinanceBar({
    required this.label,
    required this.amount,
    required this.scale,
    required this.color,
    required this.formatter,
  });

  final String label;
  final double amount;
  final double scale;
  final Color color;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = Text(
      formatter.format(amount),
      softWrap: true,
      maxLines: 2,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w800,
      ),
    );
    final labelText = Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 18;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (largeText) ...[
          labelText,
          value,
        ] else
          Row(
            children: [
              Expanded(child: labelText),
              value,
            ],
          ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: scale <= 0 ? 0 : (amount / scale).clamp(0.0, 1.0),
            backgroundColor: color.withValues(alpha: 0.14),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
