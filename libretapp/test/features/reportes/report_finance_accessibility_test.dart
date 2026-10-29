import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/reportes/cubit/reportes_cubit.dart';
import 'package:libretapp/features/reportes/view/tabs/reportes_finanzas_tab.dart';
import 'package:libretapp/features/finanzas/domain/finance_summary_service.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/domain/enums/financial_period_preset.dart';

class _LoadedReports extends Cubit<ReportesState> implements ReportesCubit {
  _LoadedReports() : super(ReportesState(financeStatus:ReportesLoadStatus.loaded,
    financeDetail:FinanceSummaryDetail(
      summary:FinancialPeriodSummary(period:FinancialPeriodPreset.thisMonth.toDateRange(now:DateTime(2026,10,22)),
        totalIncome:1000000000000, totalGeneralExpenses:500000000000,
        totalAnimalCosts:0, totalAnimalSales:0),
      recentMovements:[FinanceMovementItem(kind:FinanceMovementKind.income,
        label:'Ingreso de una venta de animales con descripción larga', amount:1000000000000,date:DateTime(2026,10,22))],
      expenseBreakdown:const [ExpenseCategoryBreakdown(label:'Alimentación del ganado y otros insumos del rancho',amount:500000000000)],
      recentSales:const [],
    )));
  @override
  Future<void> loadFinanzas() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final width in [320.0,360.0,412.0]) {
    testWidgets('finance reports fit large currency at 200 percent, width $width', (tester) async {
      tester.view.physicalSize=Size(width,900); tester.view.devicePixelRatio=1;
      addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
      final cubit = _LoadedReports(); addTearDown(cubit.close);
      await tester.pumpWidget(MaterialApp(home:MediaQuery(
        data:MediaQueryData(size:Size(width,900),textScaler:const TextScaler.linear(2)),
        child:Scaffold(body:BlocProvider<ReportesCubit>.value(value:cubit,
          child:const ReportesFinanzasTab())),
      )));
      await tester.pumpAndSettle();
      expect(tester.takeException(),isNull);
      await tester.scrollUntilVisible(find.text('Categorías principales'),300);
      await tester.pumpAndSettle();
      expect(tester.takeException(),isNull);
      await tester.scrollUntilVisible(find.text('Ver finanzas completas'),300);
      await tester.pumpAndSettle();
      expect(tester.takeException(),isNull);
    });
  }
}
