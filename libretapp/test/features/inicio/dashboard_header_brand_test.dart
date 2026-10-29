import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:libretapp/core/widgets/app_brand.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/inicio/widgets/dashboard/dashboard_header.dart';
import 'package:libretapp/features/inicio/widgets/dashboard/inicio_weather_card.dart';
import 'package:libretapp/theme/app_theme.dart';

const _profileName = 'María Fernanda del Rosario González de la Fuente';
const _farmName = 'Rancho San Francisco de los Altos del Mezquital';

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  for (final brightness in Brightness.values) {
    for (final (width, scale) in [(320.0, 1.0), (320.0, 2.0), (390.0, 1.2)]) {
      testWidgets(
        'brand, long names and weather fit at ${width}px / $scale / $brightness',
        (tester) async {
          tester.view.physicalSize = Size(width, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            MaterialApp(
              theme: brightness == Brightness.dark
                  ? AppTheme.darkTheme
                  : AppTheme.lightTheme,
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 1000),
                  textScaler: TextScaler.linear(scale),
                ),
                child: Scaffold(
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DashboardHeader(
                      data: InicioDashboardData(
                        profileName: _profileName,
                        farmName: _farmName,
                        totalAnimals: 12,
                        totalAnimalCapacity: 30,
                        attentionAnimals: 0,
                        activeLotes: 3,
                        totalLocations: 2,
                        upcomingEventsCount: 0,
                        upcomingEvents: const [],
                        alerts: const [],
                        tasks: const [],
                        lastUpdated: DateTime(2026, 1, 1),
                        categoryBreakdown: const [],
                        upcomingCalvings: const [],
                        weather: const WeatherData(
                          temperature: 38,
                          maxTemperature: 42,
                          condition: 'Lluvia con intervalos de tormenta',
                          humidity: 100,
                          windSpeed: 100,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.bySemanticsLabel('LibretApp'), findsOneWidget);
          expect(find.textContaining(_profileName), findsOneWidget);
          expect(find.text(_farmName), findsOneWidget);
          expect(find.byType(InicioWeatherCard), findsOneWidget);
          expect(find.text('38°'), findsOneWidget);
          expect(tester.getSize(find.byType(AppBrand)).height, 24);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
