import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/app_shell.dart';
import 'package:libretapp/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'keeps the top system inset available to branch routes without the banner',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: const EdgeInsets.only(top: 24, bottom: 34),
              viewPadding: const EdgeInsets.only(top: 24, bottom: 34),
            ),
            child: child!,
          ),
          routerConfig: _buildRouter(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('24.0'), findsOneWidget);
      expect(find.text('Pantalla de prueba'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/test',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/test',
                builder: (context, state) => Builder(
                  builder: (context) => Stack(
                    children: [
                      Positioned.fill(
                        child: Scaffold(
                          appBar: AppBar(
                            title: const Text('Pantalla de prueba'),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Text(
                          MediaQuery.paddingOf(context).top.toString(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
