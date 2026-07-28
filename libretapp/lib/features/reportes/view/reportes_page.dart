/// features > reportes > view > reportes_page — reports hub.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/finanzas/domain/finance_summary_service.dart';
import 'package:libretapp/features/reportes/cubit/reportes_cubit.dart';
import 'package:libretapp/features/reportes/domain/report_summary_service.dart';
import 'package:libretapp/features/reportes/view/tabs/reportes_finanzas_tab.dart';
import 'package:libretapp/features/reportes/view/tabs/reportes_summary_tab.dart';

class ReportesPage extends StatelessWidget {
  const ReportesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportesCubit(
        reportService: locator<ReportSummaryService>(),
        financeService: locator<FinanceSummaryService>(),
      ),
      child: const _ReportesView(),
    );
  }
}

class _ReportesView extends StatefulWidget {
  const _ReportesView();

  @override
  State<_ReportesView> createState() => _ReportesViewState();
}

class _ReportesViewState extends State<_ReportesView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        bottom: AppSegmentedTabBar(
          controller: _tabController,
          items: const [
            AppSegmentedTabItem(
              label: 'Reportes',
              icon: Icons.analytics_outlined,
            ),
            AppSegmentedTabItem(
              label: 'Finanzas',
              icon: Icons.account_balance_wallet_outlined,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [ReportesSummaryTab(), ReportesFinanzasTab()],
      ),
    );
  }
}
