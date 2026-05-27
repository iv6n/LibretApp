/// finanzas › widgets › finanzas_fab — context-aware FAB for the financial tabs.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';

/// Floating Action Button whose appearance depends on the active tab index.
///
/// - Tab 1 (Ingresos): shows "Ingreso" button.
/// - Tab 2 (Gastos): shows "Gasto" button.
/// - All other tabs: renders [SizedBox.shrink].
class FinanzasFab extends StatefulWidget {
  const FinanzasFab({super.key, required this.tabController});

  final TabController tabController;

  @override
  State<FinanzasFab> createState() => _FinanzasFabState();
}

class _FinanzasFabState extends State<FinanzasFab> {
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
