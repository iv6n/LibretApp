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
import 'package:libretapp/features/eventos/data/eventos_model.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_service.dart';
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
      attentionAnimals: 0,
      unsyncedAnimals: 0,
      activeLotes: 0,
      totalLocations: 0,
      upcomingEventsCount: 0,
      upcomingEvents: const <Evento>[],
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
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    if (!locator.isRegistered<InicioDashboardService>()) {
      locator.registerLazySingleton<InicioDashboardService>(
        _FakeInicioDashboardService.new,
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
