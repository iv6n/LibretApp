/// finanzas › view › FinanzasPage
///
/// Entry point for the financial dashboard. Provides [FinanzasBloc] and
/// renders a 4-tab view: summary, incomes, expenses, and per-animal results.
///
/// Layer: view (presentation)
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/finanzas/application/finanzas_bloc.dart';
import 'package:libretapp/features/finanzas/application/finanzas_event.dart';
import 'package:libretapp/features/finanzas/application/finanzas_state.dart';
import 'package:libretapp/features/finanzas/domain/enums/financial_period_preset.dart';
import 'package:libretapp/features/finanzas/domain/repositories/finanzas_repository.dart';
import 'package:libretapp/features/finanzas/view/tabs/animal_list.dart';
import 'package:libretapp/features/finanzas/view/tabs/gastos_list.dart';
import 'package:libretapp/features/finanzas/view/tabs/ingresos_list.dart';
import 'package:libretapp/features/finanzas/view/tabs/resumen_tab.dart';
import 'package:libretapp/features/finanzas/widgets/finanzas_fab.dart';

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
        costRepo: locator<CostRecordRepository>(),
        commercialRepo: locator<CommercialRecordRepository>(),
      )..add(LoadPreset(FinancialPeriodPreset.thisMonth)),
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
  FinancialPeriodPreset _preset = FinancialPeriodPreset.thisMonth;

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

  void _changePeriod(FinancialPeriodPreset preset) {
    setState(() => _preset = preset);
    context.read<FinanzasBloc>().add(LoadPreset(preset));
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
            child: DropdownButton<FinancialPeriodPreset>(
              value: _preset,
              underline: const SizedBox.shrink(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              items: FinancialPeriodPreset.values
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
              ResumenTab(summary: state.summary),
              IngresosList(
                incomes: state.incomes,
                onDelete: (id) =>
                    context.read<FinanzasBloc>().add(DeleteIncome(id)),
              ),
              GastosList(
                expenses: state.expenses,
                onDelete: (id) =>
                    context.read<FinanzasBloc>().add(DeleteExpense(id)),
              ),
              AnimalList(profitabilities: state.animalProfitabilities),
            ],
          );
        },
      ),
      floatingActionButton: FinanzasFab(tabController: _tabController),
    );
  }
}
