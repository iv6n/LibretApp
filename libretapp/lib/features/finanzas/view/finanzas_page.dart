/// finanzas › view › FinanzasPage
///
/// Entry point for the financial dashboard. Provides [FinanzasBloc] and
/// renders a 4-tab view: summary, incomes, expenses, and per-animal results.
///
/// Layer: view (presentation)
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/finanzas/application/finanzas_bloc.dart';
import 'package:libretapp/features/finanzas/application/finanzas_event.dart';
import 'package:libretapp/features/finanzas/application/finanzas_state.dart';
import 'package:libretapp/features/finanzas/domain/entities/animal_profitability.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/domain/entities/general_expense_record.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';
import 'package:libretapp/features/finanzas/domain/repositories/finanzas_repository.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';

// ─── Presets de período ───────────────────────────────────────────────────────

enum _PeriodPreset { thisMonth, lastMonth, last3Months, thisYear }

extension _PeriodPresetLabel on _PeriodPreset {
  String get label {
    switch (this) {
      case _PeriodPreset.thisMonth:
        return 'Este mes';
      case _PeriodPreset.lastMonth:
        return 'Mes anterior';
      case _PeriodPreset.last3Months:
        return 'Últimos 3 meses';
      case _PeriodPreset.thisYear:
        return 'Este año';
    }
  }

  DateRange toDateRange() {
    final now = DateTime.now();
    switch (this) {
      case _PeriodPreset.thisMonth:
        return DateRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case _PeriodPreset.lastMonth:
        final firstOfLast = DateTime(now.year, now.month - 1, 1);
        return DateRange(
          start: firstOfLast,
          end: DateTime(now.year, now.month, 0, 23, 59, 59),
        );
      case _PeriodPreset.last3Months:
        return DateRange(
          start: DateTime(now.year, now.month - 2, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case _PeriodPreset.thisYear:
        return DateRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31, 23, 59, 59),
        );
    }
  }
}

// ─── Page wrapper ─────────────────────────────────────────────────────────────

/// Page wrapper that creates and provides [FinanzasBloc] to the subtree.
class FinanzasPage extends StatelessWidget {
  const FinanzasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FinanzasBloc(
        finanzasRepository: locator<FinanzasRepository>(),
        animalRepository: locator<AnimalRepository>(),
      )..add(LoadPeriod(_PeriodPreset.thisMonth.toDateRange())),
      child: const _FinanzasView(),
    );
  }
}

// ─── View ────────────────────────────────────────────────────────────────────

class _FinanzasView extends StatefulWidget {
  const _FinanzasView();

  @override
  State<_FinanzasView> createState() => _FinanzasViewState();
}

class _FinanzasViewState extends State<_FinanzasView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  _PeriodPreset _preset = _PeriodPreset.thisMonth;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _changePeriod(_PeriodPreset preset) {
    setState(() => _preset = preset);
    context.read<FinanzasBloc>().add(LoadPeriod(preset.toDateRange()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButton<_PeriodPreset>(
              value: _preset,
              underline: const SizedBox.shrink(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              items: _PeriodPreset.values
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                  .toList(),
              onChanged: (p) {
                if (p != null) _changePeriod(p);
              },
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'Ingresos'),
            Tab(text: 'Gastos'),
            Tab(text: 'Por animal'),
          ],
        ),
      ),
      body: BlocBuilder<FinanzasBloc, FinanzasState>(
        builder: (context, state) {
          if (state.status == FinanzasStatus.loading ||
              state.status == FinanzasStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == FinanzasStatus.error) {
            return Center(child: Text('Error: ${state.error}'));
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _ResumenTab(summary: state.summary),
              _IngresosList(
                incomes: state.incomes,
                onDelete: (id) =>
                    context.read<FinanzasBloc>().add(DeleteIncome(id)),
              ),
              _GastosList(
                expenses: state.expenses,
                onDelete: (id) =>
                    context.read<FinanzasBloc>().add(DeleteExpense(id)),
              ),
              _AnimalList(profitabilities: state.animalProfitabilities),
            ],
          );
        },
      ),
      floatingActionButton: _FinanzasFab(tabController: _tabController),
    );
  }
}

// ─── FAB contextual por tab ───────────────────────────────────────────────────

class _FinanzasFab extends StatefulWidget {
  const _FinanzasFab({required this.tabController});
  final TabController tabController;

  @override
  State<_FinanzasFab> createState() => _FinanzasFabState();
}

class _FinanzasFabState extends State<_FinanzasFab> {
  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_onTabChange);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChange);
    super.dispose();
  }

  void _onTabChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final index = widget.tabController.index;
    if (index == 1) {
      return FloatingActionButton.extended(
        heroTag: 'finanzas_fab_ingreso',
        onPressed: () => context.pushNamed(AppRoutes.nameRegistroIngreso),
        icon: const Icon(Icons.add),
        label: const Text('Ingreso'),
      );
    }
    if (index == 2) {
      return FloatingActionButton.extended(
        heroTag: 'finanzas_fab_gasto',
        onPressed: () => context.pushNamed(AppRoutes.nameRegistroGastoGeneral),
        icon: const Icon(Icons.add),
        label: const Text('Gasto'),
      );
    }
    return const SizedBox.shrink();
  }
}

// ─── Tab Resumen ──────────────────────────────────────────────────────────────

class _ResumenTab extends StatelessWidget {
  const _ResumenTab({required this.summary});
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
        _KpiCard(
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
              child: _KpiCard(
                label: 'Ingresos generales',
                value: fmt.format(s.totalIncome),
                icon: Icons.attach_money,
                color: Colors.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
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
              child: _KpiCard(
                label: 'Costos de animales',
                value: fmt.format(s.totalAnimalCosts),
                icon: Icons.pets,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                label: 'Gastos generales',
                value: fmt.format(s.totalGeneralExpenses),
                icon: Icons.receipt_long,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _KpiCard(
          label: 'Ingresos totales',
          value: fmt.format(s.totalRevenue),
          icon: Icons.account_balance_wallet,
          color: Colors.indigo,
        ),
        const SizedBox(height: 12),
        _KpiCard(
          label: 'Egresos totales',
          value: fmt.format(s.totalExpenses),
          icon: Icons.money_off,
          color: Colors.brown,
        ),
        if (s.totalRevenue > 0) ...[
          const SizedBox(height: 12),
          _KpiCard(
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

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.large = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(large ? 20 : 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: large ? 24 : 18,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: large ? 24 : 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: large
                        ? theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )
                        : theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab Ingresos ─────────────────────────────────────────────────────────────

class _IngresosList extends StatelessWidget {
  const _IngresosList({required this.incomes, required this.onDelete});
  final List<IncomeRecord> incomes;
  final void Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    if (incomes.isEmpty) {
      return const _EmptyState(
        icon: Icons.attach_money,
        message: 'Sin ingresos registrados en este período.',
        hint: 'Usa el botón + para agregar un ingreso.',
      );
    }
    final fmt = NumberFormat('#,##0.00');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: incomes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final r = incomes[i];
        return _RecordTile(
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

// ─── Tab Gastos ───────────────────────────────────────────────────────────────

class _GastosList extends StatelessWidget {
  const _GastosList({required this.expenses, required this.onDelete});
  final List<GeneralExpenseRecord> expenses;
  final void Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const _EmptyState(
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
        return _RecordTile(
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

// ─── Tab Por Animal ───────────────────────────────────────────────────────────

class _AnimalList extends StatelessWidget {
  const _AnimalList({required this.profitabilities});
  final List<AnimalProfitability> profitabilities;

  @override
  Widget build(BuildContext context) {
    if (profitabilities.isEmpty) {
      return const _EmptyState(
        icon: Icons.pets,
        message: 'No hay animales con datos financieros.',
        hint: 'Registra costos o ventas en un animal para verlo aquí.',
      );
    }
    final fmt = NumberFormat('#,##0.00');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: profitabilities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
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

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.title,
    required this.date,
    required this.amount,
    required this.amountColor,
    this.subtitle,
    this.currency,
    this.onDelete,
  });

  final String title;
  final String? subtitle;
  final DateTime date;
  final String amount;
  final Color amountColor;
  final String? currency;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('dd MMM yyyy', 'es');
    return Card(
      child: ListTile(
        title: Text(title, style: theme.textTheme.bodyMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFmt.format(date),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (subtitle != null)
              Text(subtitle!, style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${amount}${currency != null ? ' ${currency!}' : ''}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: onDelete,
                color: theme.colorScheme.error,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.hint,
  });
  final IconData icon;
  final String message;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
