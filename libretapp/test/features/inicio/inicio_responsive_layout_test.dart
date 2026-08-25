import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/biblioteca/data/book_content.dart';
import 'package:libretapp/features/biblioteca/data/library_manifest.dart';
import 'package:libretapp/features/biblioteca/data/library_repository.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/domain/enums/financial_period_preset.dart';
import 'package:libretapp/features/finanzas/domain/finance_summary_service.dart';
import 'package:libretapp/features/inicio/bloc/inicio_bloc.dart';
import 'package:libretapp/features/inicio/bloc/inicio_event.dart';
import 'package:libretapp/features/inicio/data/dashboard_config_repository.dart';
import 'package:libretapp/features/inicio/data/dashboard_quick_action.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_service.dart';
import 'package:libretapp/features/inicio/view/inicio_view.dart';
import 'package:libretapp/features/inicio/widgets/dashboard/quick_action_grid.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:libretapp/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('Inicio responsive layout', () {
    testWidgets('keeps a single column below the tablet breakpoint', (
      tester,
    ) async {
      await _pumpInicio(tester, width: 599);

      final health = _widgetRect(tester, 'healthAlerts');
      final calvings = _widgetRect(tester, 'upcomingCalvings');
      final events = _widgetRect(tester, 'upcomingEvents');

      expect(health.left, closeTo(16, 0.5));
      expect(calvings.left, closeTo(16, 0.5));
      expect(events.left, closeTo(16, 0.5));
      expect(calvings.top, greaterThanOrEqualTo(health.bottom));
      expect(events.top, greaterThanOrEqualTo(calvings.bottom));
      expect(find.text('Ver todas'), findsNothing);
    });

    testWidgets('uses two columns from the tablet breakpoint', (tester) async {
      await _pumpInicio(tester, width: 600);

      final health = _widgetRect(tester, 'healthAlerts');
      final calvings = _widgetRect(tester, 'upcomingCalvings');
      final events = _widgetRect(tester, 'upcomingEvents');

      expect(health.left, closeTo(20, 0.5));
      expect(health.width, closeTo(560, 0.5));
      expect(calvings.left, closeTo(20, 0.5));
      expect(events.left, closeTo(306, 0.5));
      expect(calvings.width, closeTo(274, 0.5));
      expect(events.width, closeTo(274, 0.5));
      expect(events.top, closeTo(calvings.top, 0.5));
      expect(find.text('Ver todas'), findsWidgets);
    });

    testWidgets('keeps full-width cards and centers wide content', (
      tester,
    ) async {
      await _pumpInicio(tester, width: 1400);

      final health = _widgetRect(tester, 'healthAlerts');
      final calvings = _widgetRect(tester, 'upcomingCalvings');
      final events = _widgetRect(tester, 'upcomingEvents');
      final pending = _widgetRect(tester, 'pendingTasks');

      expect(health.left, closeTo(120, 0.5));
      expect(health.width, closeTo(1160, 0.5));
      expect(calvings.width, closeTo(574, 0.5));
      expect(events.left, closeTo(706, 0.5));
      expect(pending.left, closeTo(120, 0.5));
      expect(pending.width, closeTo(1160, 0.5));
    });

    testWidgets('does not overflow with accessible text scaling', (
      tester,
    ) async {
      await _pumpInicio(tester, width: 800, textScale: 1.4);

      expect(tester.takeException(), isNull);
      expect(find.byKey(_widgetKey('healthAlerts')), findsOneWidget);
      expect(find.byKey(_widgetKey('pendingTasks')), findsOneWidget);
    });

    testWidgets('keeps eight quick actions compact', (tester) async {
      await _pumpQuickActions(tester, width: 390, count: 8);

      final size = tester.getSize(
        find.byKey(const ValueKey<String>('quick-action-grid')),
      );

      expect(size.height, lessThan(260));
    });

    testWidgets('shrinks the quick action card for four and one action', (
      tester,
    ) async {
      await _pumpQuickActions(tester, width: 390, count: 4);
      final fourActionsHeight = tester
          .getSize(find.byKey(const ValueKey<String>('quick-action-grid')))
          .height;

      await _pumpQuickActions(tester, width: 390, count: 1);
      final oneActionHeight = tester
          .getSize(find.byKey(const ValueKey<String>('quick-action-grid')))
          .height;

      expect(fourActionsHeight, lessThan(180));
      expect(oneActionHeight, lessThan(180));
    });

    testWidgets('quick actions respect accessible text scaling', (
      tester,
    ) async {
      await _pumpQuickActions(tester, width: 800, count: 8, textScale: 1.4);

      expect(tester.takeException(), isNull);
      expect(
        tester
            .getSize(find.byKey(const ValueKey<String>('quick-action-grid')))
            .height,
        lessThan(300),
      );
    });

    testWidgets('Inicio keeps quick actions compact in the real dashboard', (
      tester,
    ) async {
      await _pumpInicio(tester, width: 390);

      final size = tester.getSize(
        find.byKey(const ValueKey<String>('quick-action-grid')),
      );

      expect(size.height, lessThan(260));
    });
  });
}

Future<void> _pumpInicio(
  WidgetTester tester, {
  required double width,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({});
  final prefs = SharedPrefsService(await SharedPreferences.getInstance());
  final bloc = InicioBloc(
    dashboardService: _FakeInicioDashboardService(),
    configRepository: DashboardConfigRepository(prefs),
    financeService: _FakeFinanceSummaryService(),
    libraryRepository: _FakeLibraryRepository(),
  )..add(const LoadInicio());

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 1200),
          textScaler: TextScaler.linear(textScale),
        ),
        child: BlocProvider<InicioBloc>.value(
          value: bloc,
          child: const Scaffold(body: InicioView()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpQuickActions(
  WidgetTester tester, {
  required double width,
  required int count,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 1200),
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topCenter,
              child: QuickActionGrid(
                actions: defaultQuickActions().take(count).toList(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Rect _widgetRect(WidgetTester tester, String id) {
  return tester.getRect(find.byKey(_widgetKey(id)));
}

Key _widgetKey(String id) => ValueKey<String>('dashboard-widget-$id');

class _FakeInicioDashboardService implements InicioDashboardService {
  @override
  Future<InicioDashboardData> loadDashboard() async {
    return InicioDashboardData(
      profileName: 'Usuario de prueba',
      farmName: 'Rancho de prueba',
      totalAnimals: 12,
      totalAnimalCapacity: 30,
      attentionAnimals: 0,
      activeLotes: 3,
      totalLocations: 2,
      upcomingEventsCount: 0,
      upcomingEvents: const <AgendaEntry>[],
      alerts: const <InicioAlertItem>[],
      tasks: const <InicioTaskItem>[],
      lastUpdated: DateTime(2026, 1, 1),
      categoryBreakdown: const [],
      upcomingCalvings: const [],
    );
  }
}

class _FakeFinanceSummaryService implements FinanceSummaryService {
  @override
  Future<FinanceSummaryDetail> loadForPreset({
    FinancialPeriodPreset preset = FinancialPeriodPreset.thisMonth,
    DateTime? now,
  }) async {
    return loadForPeriod(preset.toDateRange(now: now));
  }

  @override
  Future<FinanceSummaryDetail> loadForPeriod(DateRange period) async {
    return FinanceSummaryDetail(
      summary: FinancialPeriodSummary(
        period: period,
        totalIncome: 0,
        totalGeneralExpenses: 0,
        totalAnimalCosts: 0,
        totalAnimalSales: 0,
      ),
      recentMovements: const [],
      expenseBreakdown: const [],
      recentSales: const [],
    );
  }
}

class _FakeLibraryRepository implements LibraryRepository {
  @override
  Future<List<LibraryManifestBook>> getAll() async => const [];

  @override
  Future<List<LibraryManifestBook>> search(String query) async => const [];

  @override
  Future<BookContent> loadBookContent(LibraryManifestBook book) {
    throw UnimplementedError('not exercised by responsive layout tests');
  }
}
