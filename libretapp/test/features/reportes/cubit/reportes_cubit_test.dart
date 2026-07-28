import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/domain/enums/financial_period_preset.dart';
import 'package:libretapp/features/finanzas/domain/finance_summary_service.dart';
import 'package:libretapp/features/reportes/cubit/reportes_cubit.dart';
import 'package:libretapp/features/reportes/data/report_summary.dart';
import 'package:libretapp/features/reportes/domain/report_summary_service.dart';

class _FakeReportSummaryService implements ReportSummaryService {
  bool shouldFail = false;
  int callCount = 0;

  @override
  Future<ReportSummary> loadSummary() async {
    callCount++;
    if (shouldFail) throw StateError('boom');
    return ReportSummary(
      totalAnimals: 5,
      bySpecies: const [],
      byCategory: const [],
      upcomingCalvings: const [],
      healthAlertsCount: 0,
      unvaccinatedCount: 0,
      underObservationCount: 0,
      recentMovements: const [],
      recentRecords: const [],
      generatedAt: DateTime(2026, 1, 1),
    );
  }
}

class _FakeFinanceSummaryService implements FinanceSummaryService {
  bool shouldFail = false;
  int callCount = 0;

  @override
  Future<FinanceSummaryDetail> loadForPreset({
    FinancialPeriodPreset preset = FinancialPeriodPreset.thisMonth,
    DateTime? now,
  }) async {
    callCount++;
    if (shouldFail) throw StateError('boom');
    return FinanceSummaryDetail(
      summary: FinancialPeriodSummary(
        period: preset.toDateRange(now: now),
        totalIncome: 100,
        totalGeneralExpenses: 40,
        totalAnimalCosts: 0,
        totalAnimalSales: 0,
      ),
      recentMovements: const [],
      expenseBreakdown: const [],
      recentSales: const [],
    );
  }

  @override
  Future<FinanceSummaryDetail> loadForPeriod(DateRange period) async {
    throw UnimplementedError();
  }
}

void main() {
  late _FakeReportSummaryService reportService;
  late _FakeFinanceSummaryService financeService;
  late ReportesCubit cubit;

  setUp(() {
    reportService = _FakeReportSummaryService();
    financeService = _FakeFinanceSummaryService();
    cubit = ReportesCubit(
      reportService: reportService,
      financeService: financeService,
    );
  });

  tearDown(() => cubit.close());

  group('loadReportes', () {
    test('loads the summary and moves to loaded', () async {
      await cubit.loadReportes();

      expect(cubit.state.reportStatus, ReportesLoadStatus.loaded);
      expect(cubit.state.reportSummary?.totalAnimals, 5);
    });

    test('does nothing if already loaded (no extra fetch)', () async {
      await cubit.loadReportes();
      await cubit.loadReportes();

      expect(reportService.callCount, 1);
    });

    test('emits an error state when the service throws', () async {
      reportService.shouldFail = true;

      await cubit.loadReportes();

      expect(cubit.state.reportStatus, ReportesLoadStatus.error);
      expect(cubit.state.errorMessage, isNotNull);
    });
  });

  group('loadFinanzas', () {
    test('loads the detail and moves to loaded', () async {
      await cubit.loadFinanzas();

      expect(cubit.state.financeStatus, ReportesLoadStatus.loaded);
      expect(cubit.state.financeDetail?.summary.totalIncome, 100);
    });

    test('does nothing if already loaded (no extra fetch)', () async {
      await cubit.loadFinanzas();
      await cubit.loadFinanzas();

      expect(financeService.callCount, 1);
    });

    test('emits an error state when the service throws', () async {
      financeService.shouldFail = true;

      await cubit.loadFinanzas();

      expect(cubit.state.financeStatus, ReportesLoadStatus.error);
    });
  });

  group('refreshReportes / refreshFinanzas', () {
    test('refreshReportes re-fetches even if already loaded', () async {
      await cubit.loadReportes();
      await cubit.refreshReportes();

      expect(reportService.callCount, 2);
      expect(cubit.state.reportStatus, ReportesLoadStatus.loaded);
    });

    test('refreshFinanzas re-fetches even if already loaded', () async {
      await cubit.loadFinanzas();
      await cubit.refreshFinanzas();

      expect(financeService.callCount, 2);
      expect(cubit.state.financeStatus, ReportesLoadStatus.loaded);
    });
  });

  test('reportes and finanzas state are independent of each other', () async {
    financeService.shouldFail = true;
    await cubit.loadFinanzas();
    await cubit.loadReportes();

    expect(cubit.state.financeStatus, ReportesLoadStatus.error);
    expect(cubit.state.reportStatus, ReportesLoadStatus.loaded);
  });
}
