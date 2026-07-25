// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/app/theme/theme_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/services/theme_repository.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/domain/enums/financial_period_preset.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/inicio/data/dashboard_config_repository.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_service.dart';
import 'package:libretapp/features/perfil/data/library_item.dart';
import 'package:libretapp/features/perfil/data/library_repository.dart';
import 'package:libretapp/features/perfil/domain/finance_summary_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:libretapp/main.dart';
import 'package:libretapp/app/app_bloc.dart';

class _FakeInicioDashboardService implements InicioDashboardService {
  @override
  Future<InicioDashboardData> loadDashboard() async {
    return InicioDashboardData(
      profileName: 'Test User',
      farmName: 'Test Farm',
      totalAnimals: 0,
      totalAnimalCapacity: 0,
      attentionAnimals: 0,
      unsyncedAnimals: 0,
      activeLotes: 0,
      totalLocations: 0,
      upcomingEventsCount: 0,
      upcomingEvents: const <AgendaEntry>[],
      alerts: const <InicioAlertItem>[
        InicioAlertItem(
          title: 'OK',
          message: 'Sin alertas',
          severity: InicioAlertSeverity.info,
          targetRoute: '/',
        ),
      ],
      tasks: const <InicioTaskItem>[
        InicioTaskItem(
          title: 'Sin pendientes',
          message: 'Todo en orden',
          targetRoute: '/',
        ),
      ],
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
    return FinanceSummaryDetail(
      summary: FinancialPeriodSummary(
        period: preset.toDateRange(now: now),
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
  Future<List<LibraryItem>> byCategory(LibraryCategory category) async =>
      const [];

  @override
  Future<List<LibraryItem>> getAll() async => const [];

  @override
  Future<List<LibraryItem>> search(String query) async => const [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = SharedPrefsService(await SharedPreferences.getInstance());
    if (!locator.isRegistered<SharedPrefsService>()) {
      locator.registerSingleton<SharedPrefsService>(prefs);
    }
    if (!locator.isRegistered<InicioDashboardService>()) {
      locator.registerLazySingleton<InicioDashboardService>(
        _FakeInicioDashboardService.new,
      );
    }
    if (!locator.isRegistered<DashboardConfigRepository>()) {
      locator.registerLazySingleton<DashboardConfigRepository>(
        () => DashboardConfigRepository(prefs),
      );
    }
    if (!locator.isRegistered<FinanceSummaryService>()) {
      locator.registerLazySingleton<FinanceSummaryService>(
        _FakeFinanceSummaryService.new,
      );
    }
    if (!locator.isRegistered<LibraryRepository>()) {
      locator.registerLazySingleton<LibraryRepository>(
        _FakeLibraryRepository.new,
      );
    }
  });

  tearDownAll(() async {
    await locator.reset();
  });

  testWidgets('LibretApp opens successfully', (WidgetTester tester) async {
    final prefs = SharedPrefsService(await SharedPreferences.getInstance());
    final themeRepository = ThemeRepository(prefs);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                ThemeBloc(repository: themeRepository)
                  ..add(const ThemeStarted()),
          ),
          BlocProvider(
            create: (context) => AppBloc(prefs: prefs)..add(const AppStarted()),
          ),
        ],
        child: const LibretApp(),
      ),
    );

    // Verify that app renders without error
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
