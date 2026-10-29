import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/app_shell.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/app_theme.dart';

void main() {
  testWidgets('320dp navigation keeps labels apart at 200 percent text', (
    tester,
  ) async {
    final router = _layoutRouter();
    addTearDown(router.dispose);
    await _pumpLayout(
      tester,
      router,
      size: const Size(320, 700),
      safeBottom: 0,
      textScale: 2,
      dark: true,
    );
    router.go(_branchPaths[2]);
    await tester.pumpAndSettle();
    expect(find.text('Registrar'), findsNothing);
    expect(
      tester
          .widgetList<Semantics>(find.byType(Semantics))
          .any((s) => s.properties.label == 'Registrar'),
      isTrue,
    );
    final rectangles =
        [
            'Directorio',
            'Agenda',
            'Reportes',
            'Perfil',
          ].map((label) => tester.getRect(find.text(label))).toList()
          ..sort((a, b) => a.left.compareTo(b.left));
    for (var i = 1; i < rectangles.length; i++) {
      expect(rectangles[i - 1].right, lessThanOrEqualTo(rectangles[i].left));
    }
    expect(tester.takeException(), isNull);
  });
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

  for (final size in const [Size(320, 568), Size(390, 844), Size(800, 1024)]) {
    for (final safeBottom in [0.0, 34.0]) {
      testWidgets(
        'fixed footers keep their height at $size with inset $safeBottom',
        (tester) async {
          var taps = 0;
          final router = _layoutRouter(onTap: () => taps++);
          addTearDown(router.dispose);
          await _pumpLayout(tester, router, size: size, safeBottom: safeBottom);

          for (var index = 0; index < _branchPaths.length; index++) {
            router.go(_branchPaths[index]);
            await tester.pumpAndSettle();

            final nav = tester.getRect(find.byType(AppBottomNavBar));
            final footer = find.byKey(ValueKey('footer-$index'));
            expect(nav.bottom, closeTo(size.height - safeBottom, 0.01));
            expect(tester.getRect(footer).bottom, closeTo(nav.top, 0.01));
            expect(
              ShellInsets.bottomSafePadding(tester.element(footer)),
              0,
              reason:
                  'The footer SafeArea has already consumed the dock inset.',
            );
            expect(footer.hitTestable(), findsOneWidget);
            await tester.tap(footer);

            await _scrollToEnd(tester);
            final lastRow = find.byKey(ValueKey('last-row-$index'));
            expect(tester.getRect(lastRow).bottom, lessThan(nav.top));
            expect(lastRow.hitTestable(), findsOneWidget);
            await tester.tap(lastRow);
            expect(taps, (index + 1) * 2);
            expect(tester.takeException(), isNull);
          }
        },
      );

      testWidgets(
        'long lists stay above navigation at $size, inset $safeBottom',
        (tester) async {
          var taps = 0;
          final router = _layoutRouter(showFooter: false, onTap: () => taps++);
          addTearDown(router.dispose);
          await _pumpLayout(tester, router, size: size, safeBottom: safeBottom);

          for (var index = 0; index < _branchPaths.length; index++) {
            router.go(_branchPaths[index]);
            await tester.pumpAndSettle();

            final nav = tester.getRect(find.byType(AppBottomNavBar));
            final list = find.byType(ListView);
            expect(tester.getRect(list).bottom, closeTo(size.height, 0.01));
            expect(tester.getRect(list).bottom, greaterThan(nav.top));
            expect(
              ShellInsets.bottomSafePadding(tester.element(list)),
              closeTo(
                ShellInsets.defaultBarHeight +
                    ShellInsets.defaultBarBottomGap +
                    safeBottom,
                0.01,
              ),
              reason: 'Extended content receives the dock inset for its tail.',
            );

            await _scrollToEnd(tester);
            final lastRow = find.byKey(ValueKey('last-row-$index'));
            expect(tester.getRect(lastRow).bottom, closeTo(nav.top - 16, 0.01));
            expect(lastRow.hitTestable(), findsOneWidget);
            await tester.tap(lastRow);
            expect(taps, index + 1);
            expect(tester.takeException(), isNull);
          }
        },
      );
    }
  }

  testWidgets(
    'short pages keep their footer above the dock without scrolling',
    (tester) async {
      final router = _layoutRouter(rowCount: 1);
      addTearDown(router.dispose);
      await _pumpLayout(tester, router);
      final nav = tester.getRect(find.byType(AppBottomNavBar));
      final footer = find.byKey(const ValueKey('footer-0'));
      expect(tester.getRect(footer).bottom, closeTo(nav.top, 0.01));
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(scrollable.position.maxScrollExtent, 0);
      expect(footer.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('scrolling content stays clear of the shell floating action', (
    tester,
  ) async {
    var taps = 0;
    final router = _layoutRouter(showFab: true, onTap: () => taps++);
    addTearDown(router.dispose);

    for (final safeBottom in [0.0, 34.0]) {
      await _pumpLayout(tester, router, safeBottom: safeBottom);
      await _scrollToEnd(tester);

      final lastRow = find.byKey(const ValueKey('last-row-0'));
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      final scrim = find.byKey(const ValueKey('shell_dock_scrim'));
      expect(scrim, findsOneWidget);
      final decoration = tester.widget<Container>(scrim).decoration!;
      expect(decoration, isA<BoxDecoration>());
      expect((decoration as BoxDecoration).gradient, isA<LinearGradient>());
      expect(
        find
            .ancestor(of: scrim, matching: find.byType(IgnorePointer))
            .evaluate()
            .any((element) => (element.widget as IgnorePointer).ignoring),
        isTrue,
      );
      expect(tester.getRect(lastRow).bottom, lessThan(tester.getRect(fab).top));
      expect(lastRow.hitTestable(), findsOneWidget);
      await tester.tap(lastRow);
      expect(tester.takeException(), isNull);
    }
    expect(taps, 2);
  });

  testWidgets('keyboard hides navigation and resizes nested scaffolds once', (
    tester,
  ) async {
    final router = _layoutRouter();
    addTearDown(router.dispose);
    await _pumpLayout(tester, router);
    final originalFooter = tester.getRect(
      find.byKey(const ValueKey('footer-0')),
    );

    await _pumpLayout(tester, router, keyboardHeight: 300);
    final footer = find.byKey(const ValueKey('footer-0'));
    expect(find.byType(AppBottomNavBar), findsNothing);
    expect(tester.getRect(footer).bottom, closeTo(844 - 300, 0.01));
    expect(MediaQuery.viewInsetsOf(tester.element(footer)).bottom, 0);
    expect(ShellInsets.bottomSafePadding(tester.element(footer)), 0);
    expect(footer.hitTestable(), findsOneWidget);

    await _pumpLayout(tester, router);
    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(tester.getRect(footer), originalFooter);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail and register routes reclaim the navigation space', (
    tester,
  ) async {
    final router = _layoutRouter();
    addTearDown(router.dispose);
    await _pumpLayout(tester, router);

    for (final path in ['/directorio/animales/demo', '/registro']) {
      final navigation = router.push<void>(path);
      await tester.pumpAndSettle();

      final footer = find.byKey(const ValueKey('footer-overlay'));
      expect(find.byType(AppBottomNavBar), findsNothing);
      expect(tester.getRect(footer).bottom, closeTo(844 - 34, 0.01));
      expect(footer.hitTestable(), findsOneWidget);

      router.pop();
      await navigation;
      await tester.pumpAndSettle();
      final nav = tester.getRect(find.byType(AppBottomNavBar));
      expect(
        tester.getRect(find.byKey(const ValueKey('footer-0'))).bottom,
        closeTo(nav.top, 0.01),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('hiding chrome from a page leaves no reserved navigation gap', (
    tester,
  ) async {
    final chromeVisible = ValueNotifier(true);
    addTearDown(chromeVisible.dispose);
    final router = _layoutRouter(chromeVisible: chromeVisible);
    addTearDown(router.dispose);
    await _pumpLayout(tester, router);

    chromeVisible.value = false;
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomNavBar), findsNothing);
    expect(
      tester.getRect(find.byKey(const ValueKey('footer-0'))).bottom,
      closeTo(844 - 34, 0.01),
    );

    chromeVisible.value = true;
    await tester.pumpAndSettle();
    final nav = tester.getRect(find.byType(AppBottomNavBar));
    expect(
      tester.getRect(find.byKey(const ValueKey('footer-0'))).bottom,
      closeTo(nav.top, 0.01),
    );
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(320, 568), Size(390, 844), Size(800, 1024)]) {
    for (final safeBottom in [0.0, 34.0]) {
      for (final rootNavigator in [true, false]) {
        testWidgets(
          'panels cover navigation at $size, inset $safeBottom, root $rootNavigator',
          (tester) async {
            final router = _layoutRouter();
            addTearDown(router.dispose);
            await _pumpLayout(
              tester,
              router,
              size: size,
              safeBottom: safeBottom,
            );

            for (var index = 0; index < _branchPaths.length; index++) {
              router.go(_branchPaths[index]);
              await tester.pumpAndSettle();
              final nav = tester.getRect(find.byType(AppBottomNavBar));
              // This context is inside a SafeArea that already consumed the
              // dock padding. Panel placement must still account for the dock.
              final result = showAppBottomSheet<int>(
                context: tester.element(find.byKey(ValueKey('footer-$index'))),
                useRootNavigator: rootNavigator,
                builder: (context) => SafeArea(
                  top: false,
                  child: SizedBox(
                    height: 180,
                    child: TextButton(
                      key: const ValueKey('panel-action'),
                      onPressed: () => Navigator.pop(context, 7),
                      child: const Text('Guardar panel'),
                    ),
                  ),
                ),
              );
              await tester.pumpAndSettle();

              expect(
                tester.getRect(find.byType(BottomSheet)).bottom,
                closeTo(size.height, 0.01),
              );
              final action = find.byKey(const ValueKey('panel-action'));
              expect(
                tester.getRect(action).bottom,
                closeTo(size.height - safeBottom, 0.01),
              );
              expect(MediaQuery.paddingOf(tester.element(action)).bottom, 0);
              expect(action.hitTestable(), findsOneWidget);
              expect(nav.bottom, lessThanOrEqualTo(size.height));
              expect(find.byType(AppBottomNavBar).hitTestable(), findsNothing);
              await tester.tap(action);
              await tester.pumpAndSettle();
              expect(await result, 7);
              expect(tester.takeException(), isNull);
            }
          },
        );
      }
    }
  }

  testWidgets('nested root panels cover the navigation space once', (
    tester,
  ) async {
    final router = _layoutRouter();
    addTearDown(router.dispose);
    await _pumpLayout(tester, router);
    final first = showAppBottomSheet<void>(
      context: tester.element(find.byKey(const ValueKey('footer-0'))),
      builder: (_) => const SizedBox(
        key: ValueKey('first-panel'),
        height: 200,
        width: double.infinity,
      ),
    );
    await tester.pumpAndSettle();
    final second = showAppBottomSheet<void>(
      context: tester.element(find.byKey(const ValueKey('first-panel'))),
      builder: (_) => const SizedBox(
        key: ValueKey('nested-panel'),
        height: 140,
        width: double.infinity,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(const ValueKey('nested-panel'))).bottom,
      closeTo(844 - 34, 0.01),
    );
    router.pop();
    await second;
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(const ValueKey('first-panel'))).bottom,
      closeTo(844 - 34, 0.01),
    );
    router.pop();
    await first;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'panel keyboard padding replaces navigation space and restores it',
    (tester) async {
      final router = _layoutRouter();
      addTearDown(router.dispose);
      await _pumpLayout(tester, router);
      await _pumpLayout(tester, router, keyboardHeight: 300);
      final panel = showAppBottomSheet<void>(
        context: tester.element(find.byKey(const ValueKey('footer-0'))),
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: const SizedBox(
            key: ValueKey('keyboard-panel'),
            height: 180,
            child: TextField(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final content = find.byKey(const ValueKey('keyboard-panel'));
      expect(tester.getRect(content).bottom, closeTo(844 - 300, 0.01));
      await _pumpLayout(tester, router);
      expect(tester.getRect(content).bottom, closeTo(844 - 34, 0.01));

      await _pumpLayout(tester, router, keyboardHeight: 300);
      expect(find.byType(AppBottomNavBar), findsNothing);
      expect(tester.getRect(content).bottom, closeTo(844 - 300, 0.01));
      expect(MediaQuery.viewInsetsOf(tester.element(content)).bottom, 300);

      await _pumpLayout(tester, router);
      expect(tester.getRect(content).bottom, closeTo(844 - 34, 0.01));
      await _pumpLayout(
        tester,
        router,
        size: const Size(844, 390),
        safeBottom: 0,
      );
      expect(tester.getRect(content).bottom, closeTo(390, 0.01));
      router.pop();
      await panel;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('panels on detail routes keep only the system safe area', (
    tester,
  ) async {
    final router = _layoutRouter();
    addTearDown(router.dispose);
    await _pumpLayout(tester, router);
    router.go('/directorio/animales/demo');
    await tester.pumpAndSettle();
    final panel = showAppBottomSheet<void>(
      context: tester.element(find.byKey(const ValueKey('footer-overlay'))),
      builder: (_) => const SafeArea(
        top: false,
        child: SizedBox(
          key: ValueKey('detail-panel'),
          height: 180,
          width: double.infinity,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomNavBar), findsNothing);
    expect(tester.getRect(find.byType(BottomSheet)).bottom, 844);
    expect(
      tester.getRect(find.byKey(const ValueKey('detail-panel'))).bottom,
      844 - 34,
    );
    router.pop();
    await panel;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('floating snackbars stay above navigation and the shell action', (
    tester,
  ) async {
    final router = _layoutRouter(showFab: true);
    addTearDown(router.dispose);
    await _pumpLayout(tester, router);
    ScaffoldMessenger.of(tester.element(find.byType(ListView))).showSnackBar(
      const SnackBar(
        content: Text('Guardado'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    await tester.pumpAndSettle();
    final snack = tester.getRect(find.byType(SnackBar));
    expect(
      snack.bottom,
      lessThan(tester.getRect(find.byType(AppBottomNavBar)).top),
    );
    expect(
      snack.bottom,
      lessThanOrEqualTo(tester.getRect(find.byType(FloatingActionButton)).top),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'draggable panels expand over the dock and keep actions in the safe area',
    (tester) async {
      final router = _layoutRouter();
      addTearDown(router.dispose);
      await _pumpLayout(tester, router);
      final panel = showAppBottomSheet<void>(
        context: tester.element(find.byKey(const ValueKey('footer-0'))),
        isScrollControlled: true,
        builder: (_) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4,
          minChildSize: 0.25,
          maxChildSize: 0.85,
          builder: (_, controller) => ListView(
            controller: controller,
            children: [
              for (var index = 0; index < 30; index++)
                SizedBox(height: 60, child: Text('Opción $index')),
              TextButton(
                key: const ValueKey('last-panel-action'),
                onPressed: () {},
                child: const Text('Aplicar'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final initialHeight = tester.getSize(find.byType(BottomSheet)).height;
      final panelList = find.descendant(
        of: find.byType(DraggableScrollableSheet),
        matching: find.byType(ListView),
      );
      await tester.drag(panelList, const Offset(0, -450));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(BottomSheet)).height,
        greaterThan(initialHeight),
      );
      expect(
        tester.getRect(find.byType(BottomSheet)).bottom,
        closeTo(844, 0.01),
      );
      final scrollable = tester.state<ScrollableState>(
        find.descendant(of: panelList, matching: find.byType(Scrollable)),
      );
      scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
      await tester.pumpAndSettle();
      final lastAction = find.byKey(const ValueKey('last-panel-action'));
      expect(tester.getRect(lastAction).bottom, closeTo(844 - 34, 0.01));
      expect(lastAction.hitTestable(), findsOneWidget);

      // The panel covers navigation; the exposed barrier still dismisses it.
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
      await panel;
      expect(find.byType(BottomSheet), findsNothing);
      expect(router.routeInformationProvider.value.uri.path, '/directorio');
      expect(tester.takeException(), isNull);
    },
  );
}

const _branchPaths = [
  '/directorio',
  '/agenda',
  '/inicio',
  '/reportes',
  '/perfil',
];

Future<void> _pumpLayout(
  WidgetTester tester,
  GoRouter router, {
  Size size = const Size(390, 844),
  double safeBottom = 34,
  double keyboardHeight = 0,
  double textScale = 1,
  bool dark = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp.router(
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: EdgeInsets.only(
            top: 24,
            bottom: keyboardHeight > 0 ? 0 : safeBottom,
          ),
          viewPadding: EdgeInsets.only(top: 24, bottom: safeBottom),
          viewInsets: EdgeInsets.only(bottom: keyboardHeight),
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      routerConfig: router,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _scrollToEnd(WidgetTester tester) async {
  final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
  scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
  await tester.pumpAndSettle();
}

GoRouter _layoutRouter({
  VoidCallback? onTap,
  bool showFab = false,
  bool showFooter = true,
  int rowCount = 20,
  ValueNotifier<bool>? chromeVisible,
}) => GoRouter(
  initialLocation: _branchPaths.first,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        for (var index = 0; index < _branchPaths.length; index++)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: _branchPaths[index],
                builder: (context, state) {
                  final page = _LayoutPage(
                    id: '$index',
                    onTap: onTap,
                    showFab: showFab,
                    showFooter: showFooter,
                    rowCount: rowCount,
                  );
                  if (chromeVisible == null) return page;
                  return ValueListenableBuilder<bool>(
                    valueListenable: chromeVisible,
                    builder: (context, visible, child) =>
                        ShellChromeScope(visible: visible, child: child!),
                    child: page,
                  );
                },
                routes: [
                  if (index == 0)
                    GoRoute(
                      path: 'animales/demo',
                      builder: (context, state) =>
                          const _LayoutPage(id: 'overlay'),
                    ),
                ],
              ),
              if (index == 2)
                GoRoute(
                  path: '/registro',
                  builder: (context, state) => const _LayoutPage(id: 'overlay'),
                ),
            ],
          ),
      ],
    ),
  ],
);

class _LayoutPage extends StatelessWidget {
  const _LayoutPage({
    required this.id,
    this.onTap,
    this.showFab = false,
    this.showFooter = true,
    this.rowCount = 20,
  });

  final String id;
  final VoidCallback? onTap;
  final bool showFab;
  final bool showFooter;
  final int rowCount;

  @override
  Widget build(BuildContext context) => ShellFabConfigScope(
    config: showFab
        ? ShellFabConfig(
            id: 'layout-$id',
            label: 'Nuevo',
            icon: Icons.add,
            onPressed: () {},
          )
        : null,
    child: Scaffold(
      appBar: AppBar(title: Text('Pantalla $id')),
      // Directory tabs also nest a Scaffold inside the branch's Scaffold.
      body: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Builder(
                builder: (context) => ListView(
                  padding: EdgeInsets.only(
                    bottom:
                        (showFooter && !showFab
                            ? 0
                            : ShellInsets.bottomSafePadding(context)) +
                        (showFab ? ShellInsets.fabContentClearance : 16),
                  ),
                  children: [
                    for (var row = 0; row < rowCount; row++)
                      SizedBox(
                        key: ValueKey('row-$id-$row'),
                        height: 80,
                        child: Text('Elemento $row'),
                      ),
                    SizedBox(
                      height: 60,
                      child: TextButton(
                        key: ValueKey('last-row-$id'),
                        onPressed: onTap ?? () {},
                        child: const Text('Último elemento'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showFooter && !showFab)
              SafeArea(
                top: false,
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: TextButton(
                    key: ValueKey('footer-$id'),
                    onPressed: onTap ?? () {},
                    child: const Text('Guardar'),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
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
