import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:libretapp/core/utils/color_contrast.dart';
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
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/core/security/ports/phone_auth_port.dart';
import 'package:libretapp/features/inicio/data/weather_preferences_service.dart';
import 'package:libretapp/features/inicio/data/weather_service.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:libretapp/theme/app_theme.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('Inicio responsive layout', () {
    testWidgets('guía inicial sustituye contadores vacíos', (tester) async {
      await _pumpInicio(tester, width: 360, firstRun: true, topInset: 24);
      expect(
        find.byKey(const ValueKey('complete-getting-started')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('complete-getting-started')),
          matching: find.text('Alta rápida'),
        ),
        findsOneWidget,
      );
      expect(find.text('Resumen del rancho'), findsNothing);
      expect(find.text('Prioridad de hoy'), findsNothing);
      expect(tester.getRect(find.byType(ListView)).top, 24);
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(ListView)).top, 24);
    });

    testWidgets(
      'dark priority text remains readable at 320dp and 200 percent text',
      (tester) async {
        await _pumpInicio(tester, width: 320, textScale: 2, dark: true);
        final label = find.text('Prioridad de hoy');
        final foreground = tester.widget<Text>(label).style!.color!;
        final card = tester.widget<Container>(
          find.ancestor(of: label, matching: find.byType(Container)).first,
        );
        final background = (card.decoration! as BoxDecoration).color!;
        expect(textContrast(foreground, background), greaterThanOrEqualTo(4.5));
        expect(
          tester
              .renderObject<RenderParagraph>(
                find.text('Revisar animales').first,
              )
              .didExceedMaxLines,
          isFalse,
        );
      },
    );
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

    testWidgets('keeps eight quick actions readable', (tester) async {
      await _pumpQuickActions(tester, width: 390, count: 8);

      final size = tester.getSize(
        find.byKey(const ValueKey<String>('quick-action-grid')),
      );

      expect(size.height, lessThan(500));
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

      expect(fourActionsHeight, lessThan(300));
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
        lessThan(400),
      );
    });

    for (final (width, scale, columns) in [
      (320.0, 1.0, 2),
      (390.0, 1.0, 2),
      (320.0, 2.0, 2),
    ]) {
      testWidgets(
        'quick actions use $columns columns at ${width}dp and ${scale}x text',
        (tester) async {
          await _pumpQuickActions(
            tester,
            width: width,
            count: 8,
            textScale: scale,
          );
          final lefts = defaultQuickActions()
              .take(8)
              .map(
                (action) => tester
                    .getRect(
                      find.byKey(ValueKey<String>('quick-action-${action.id}')),
                    )
                    .left,
              )
              .toSet();
          expect(lefts, hasLength(columns));
          for (final action in defaultQuickActions().take(8)) {
            final size = tester.getSize(
              find.byKey(ValueKey<String>('quick-action-${action.id}')),
            );
            expect(size.width, greaterThanOrEqualTo(48));
            expect(size.height, greaterThanOrEqualTo(48));
          }
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('quick actions keep icon and label contrast in dark mode', (
      tester,
    ) async {
      await _pumpQuickActions(tester, width: 390, count: 4, dark: true);
      final action = defaultQuickActions().first;
      final finder = find.byKey(ValueKey<String>('quick-action-${action.id}'));
      final ink = tester.widget<Ink>(
        find.descendant(of: finder, matching: find.byType(Ink)),
      );
      final background = (ink.decoration! as BoxDecoration).color!;
      final icon = tester.widget<Icon>(
        find.descendant(of: finder, matching: find.byType(Icon)),
      );
      expect(textContrast(icon.color!, background), greaterThanOrEqualTo(4.5));
    });

    testWidgets('Inicio keeps quick actions compact in the real dashboard', (
      tester,
    ) async {
      await _pumpInicio(tester, width: 390);

      final size = tester.getSize(
        find.byKey(const ValueKey<String>('quick-action-grid')),
      );

      expect(size.height, lessThan(500));
    });
  });
}

Future<void> _pumpInicio(
  WidgetTester tester, {
  required double width,
  double textScale = 1,
  bool dark = false,
  bool firstRun = false,
  double topInset = 0,
}) async {
  tester.view.physicalSize = Size(width, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({});
  final prefs = SharedPrefsService(await SharedPreferences.getInstance());
  if (locator.isRegistered<WeatherPreferencesService>()) {
    await locator.unregister<WeatherPreferencesService>();
  }
  if (locator.isRegistered<WorkspaceManager>()) {
    await locator.unregister<WorkspaceManager>();
  }
  locator.registerSingleton<WeatherPreferencesService>(
    WeatherPreferencesService(
      preferences: prefs,
      weatherService: LocalOnlyWeatherService(),
    ),
  );
  final experience = AppExperienceController(prefs);
  addTearDown(experience.dispose);
  final registry = WorkspaceRegistry(prefs);
  await registry.load();
  locator.registerSingleton<WorkspaceManager>(
    WorkspaceManager(registry: registry, auth: const UnavailablePhoneAuth()),
  );
  final bloc = InicioBloc(
    dashboardService: _FakeInicioDashboardService(firstRun: firstRun),
    configRepository: DashboardConfigRepository(prefs),
    financeService: _FakeFinanceSummaryService(),
    libraryRepository: _FakeLibraryRepository(),
  )..add(const LoadInicio());

  await tester.pumpWidget(
    AppExperienceScope(
      controller: experience,
      child: MaterialApp(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 1200),
            textScaler: TextScaler.linear(textScale),
            padding: EdgeInsets.only(top: topInset),
            viewPadding: EdgeInsets.only(top: topInset),
          ),
          child: BlocProvider<InicioBloc>.value(
            value: bloc,
            child: const Scaffold(body: InicioView()),
          ),
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
  bool dark = false,
}) async {
  tester.view.physicalSize = Size(width, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
  _FakeInicioDashboardService({this.firstRun = false});

  final bool firstRun;

  @override
  Future<InicioDashboardData> loadDashboard() async {
    return InicioDashboardData(
      profileName: 'Usuario de prueba',
      farmName: 'Rancho de prueba',
      totalAnimals: firstRun ? 0 : 12,
      totalAnimalCapacity: firstRun ? 0 : 30,
      attentionAnimals: 0,
      activeLotes: firstRun ? 0 : 3,
      totalLocations: firstRun ? 0 : 2,
      upcomingEventsCount: 0,
      upcomingEvents: const <AgendaEntry>[],
      alerts: firstRun
          ? const []
          : const <InicioAlertItem>[
              InicioAlertItem(
                title: 'Revisar animales',
                message: 'Hay animales que requieren atención.',
                severity: InicioAlertSeverity.warning,
                targetRoute: '/directorio',
              ),
            ],
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
