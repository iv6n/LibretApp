import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/app_shell.dart';
import 'package:libretapp/app/widgets/app_bottom_nav_bar.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/app_theme.dart';

void main() {
  testWidgets('unified routes and list actions stay clear of the dock', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const paths = ['/directorio', '/agenda', '/inicio', '/reportes', '/perfil'];
    final router = GoRouter(
      initialLocation: '/inicio',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) => AppShell(navigationShell: shell),
          branches: [
            for (var index = 0; index < paths.length; index++)
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: paths[index],
                    builder: (_, _) => _TestPage(index: index),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.lightTheme,
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: const EdgeInsets.only(top: 24, bottom: 34),
            viewPadding: const EdgeInsets.only(top: 24, bottom: 34),
          ),
          child: child!,
        ),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    final dock = find.byType(AppBottomNavBar);
    expect(dock, findsOneWidget);
    expect(find.byKey(const ValueKey('page-2')), findsOneWidget);
    for (final label in ['Directorio', 'Agenda', 'Reportes', 'Perfil']) {
      expect(find.text(label), findsOneWidget);
    }
    await tester.tap(find.text('Directorio'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('page-0')), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('last-action-0')),
      300,
    );
    await tester.pumpAndSettle();
    final last = find.byKey(const ValueKey('last-action-0'));
    expect(
      tester.getRect(last).bottom,
      lessThanOrEqualTo(tester.getRect(dock).top),
    );
    expect(last.hitTestable(), findsOneWidget);
    await tester.tap(last);
    await tester.pump();
    expect(
      tester.state<_TestPageState>(find.byType(_TestPage)).pressed,
      isTrue,
    );

    expect(tester.takeException(), isNull);
  });
}

class _TestPage extends StatefulWidget {
  const _TestPage({required this.index});
  final int index;

  @override
  State<_TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<_TestPage> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    key: ValueKey('page-${widget.index}'),
    appBar: AppBar(title: Text('Pestaña ${widget.index}')),
    body: ListView(
      key: ValueKey('page-list-${widget.index}'),
      children: [
        for (var i = 0; i < 20; i++)
          SizedBox(height: 72, child: Text('Registro $i')),
        TextButton(
          key: ValueKey('last-action-${widget.index}'),
          onPressed: () => setState(() => pressed = true),
          child: const Text('Última acción'),
        ),
        if (pressed) const Text('Acción pulsada'),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {},
      child: const Icon(Icons.add),
    ),
  );
}
