import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/onboarding/onboarding_page.dart';

Widget _testApp({
  required Future<void> Function() onStartEmpty,
  required Future<void> Function() onInstallDemo,
}) {
  final router = GoRouter(
    initialLocation: AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => OnboardingPage(
          onStartEmpty: onStartEmpty,
          onInstallDemo: onInstallDemo,
        ),
      ),
      GoRoute(
        path: AppRoutes.inicio,
        builder: (_, _) => const Scaffold(body: Text('Inicio listo')),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  testWidgets('starts empty and enters the shell destination', (tester) async {
    var completed = false;
    await tester.pumpWidget(
      _testApp(
        onStartEmpty: () async => completed = true,
        onInstallDemo: () async {},
      ),
    );

    expect(tester.widget<PopScope>(find.byType(PopScope)).canPop, isFalse);
    await tester.tap(find.text('Comenzar vacío'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    expect(find.text('Inicio listo'), findsOneWidget);
  });

  testWidgets('a successful demo install enters the app', (tester) async {
    var installed = false;
    await tester.pumpWidget(
      _testApp(
        onStartEmpty: () async {},
        onInstallDemo: () async => installed = true,
      ),
    );

    await tester.tap(find.text('Instalar escenario demo'));
    await tester.pumpAndSettle();

    expect(installed, isTrue);
    expect(find.text('Inicio listo'), findsOneWidget);
  });

  testWidgets('a failed demo install stays undecided and can retry', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      _testApp(
        onStartEmpty: () async {},
        onInstallDemo: () async {
          attempts++;
          throw StateError('seed failed');
        },
      ),
    );

    await tester.tap(find.text('Instalar escenario demo'));
    await tester.pumpAndSettle();

    expect(attempts, 1);
    expect(find.text('Bienvenido a LibretApp'), findsOneWidget);
    expect(
      find.text('No se pudo preparar el escenario demo. Intenta de nuevo.'),
      findsOneWidget,
    );
    final retry = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Instalar escenario demo'),
    );
    expect(retry.onPressed, isNotNull);
  });
}
