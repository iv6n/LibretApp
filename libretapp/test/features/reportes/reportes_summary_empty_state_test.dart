import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/reportes/cubit/reportes_cubit.dart';
import 'package:libretapp/features/reportes/data/report_summary.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/reportes/view/tabs/reportes_summary_tab.dart';

void main() {
  testWidgets('empty herd state keeps add animal and Excel export actions', (
    tester,
  ) async {
    final cubit = _Reports(_summary(totalAnimals: 0));
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<ReportesCubit>.value(
            value: cubit,
            child: const ReportesSummaryTab(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Registrar primer animal'), findsOneWidget);
    expect(find.text('Exportar a Excel'), findsOneWidget);
  });

  testWidgets('all upcoming calvings can be expanded beyond the first five', (
    tester,
  ) async {
    final cubit = _Reports(_summary(totalAnimals: 6, calvingCount: 6));
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<ReportesCubit>.value(
            value: cubit,
            child: const ReportesSummaryTab(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TAG-6'), findsNothing);
    final expandButton = find.text('Ver todos los partos (6)');
    await tester.ensureVisible(expandButton);
    await tester.pumpAndSettle();
    await tester.tap(expandButton);
    await tester.pumpAndSettle();

    expect(find.text('TAG-6'), findsOneWidget);
  });
}

class _Reports extends Cubit<ReportesState> implements ReportesCubit {
  _Reports(ReportSummary summary)
    : super(
        ReportesState(
          reportStatus: ReportesLoadStatus.loaded,
          reportSummary: summary,
        ),
      );

  @override
  Future<void> loadReportes() async {}

  @override
  Future<void> refreshReportes() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ReportSummary _summary({required int totalAnimals, int calvingCount = 0}) {
  return ReportSummary(
    totalAnimals: totalAnimals,
    bySpecies: const [],
    byCategory: const [],
    upcomingCalvings: [
      for (var index = 1; index <= calvingCount; index++)
        CalvingItem(
          animalUuid: 'animal-$index',
          animalTag: 'TAG-$index',
          expectedDate: DateTime(2026, 11, index),
          daysRemaining: index,
        ),
    ],
    healthAlertsCount: 0,
    unvaccinatedCount: 0,
    underObservationCount: 0,
    recentMovements: const [],
    recentRecords: const [],
    generatedAt: DateTime(2026, 1, 1),
  );
}
