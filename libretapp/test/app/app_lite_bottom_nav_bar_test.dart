import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/app/widgets/app_bottom_nav_bar.dart';
import 'package:libretapp/app/widgets/app_lite_bottom_nav_bar.dart';
import 'package:libretapp/theme/app_theme.dart';

const _fiveItems = <AppNavItemConfig>[
  AppNavItemConfig(index: 2, icon: Icons.home_outlined, label: 'Inicio'),
  AppNavItemConfig(index: 0, icon: Icons.pets_outlined, label: 'Mascotas'),
  AppNavItemConfig(
    index: 1,
    icon: Icons.calendar_month_outlined,
    label: 'Agenda',
  ),
  AppNavItemConfig(index: 3, icon: Icons.eco_outlined, label: 'Plantas'),
  AppNavItemConfig(index: 4, icon: Icons.person_outline, label: 'Perfil'),
];

Future<void> _pumpBar(
  WidgetTester tester, {
  required double width,
  required double height,
  required double safeBottom,
  required double textScale,
  required bool showPlants,
  required ValueChanged<int> onSelected,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final items = showPlants
      ? _fiveItems
      : _fiveItems.where((item) => item.index != 3).toList();
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: EdgeInsets.only(bottom: safeBottom),
          viewPadding: EdgeInsets.only(bottom: safeBottom),
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: Scaffold(
        body: const Center(child: Text('Contenido Lite')),
        bottomNavigationBar: SafeArea(
          top: false,
          child: AppLiteBottomNavBar(
            items: items,
            selectedIndex: 2,
            onItemSelected: onSelected,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [320.0, 360.0, 390.0, 800.0]) {
    for (final textScale in [1.0, 1.5, 2.0]) {
      testWidgets('Lite dock fits ${width}dp at ${textScale}x text', (
        tester,
      ) async {
        final selections = <int>[];
        await _pumpBar(
          tester,
          width: width,
          height: 760,
          safeBottom: 34,
          textScale: textScale,
          showPlants: true,
          onSelected: selections.add,
        );

        final dock = tester.getRect(find.byType(AppLiteBottomNavBar));
        expect(dock.bottom, closeTo(726, 0.01));
        expect(dock.width, width);
        for (final item in _fiveItems) {
          final destination = find.byKey(ValueKey('lite-nav-${item.index}'));
          expect(destination, findsOneWidget);
          final size = tester.getSize(destination);
          expect(size.width, greaterThanOrEqualTo(48));
          expect(size.height, greaterThanOrEqualTo(48));
          expect(destination.hitTestable(), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const ValueKey('lite-nav-0')));
        expect(selections, [0]);
      });
    }
  }

  testWidgets('plants can be hidden without a center gap', (tester) async {
    await _pumpBar(
      tester,
      width: 320,
      height: 700,
      safeBottom: 0,
      textScale: 1,
      showPlants: false,
      onSelected: (_) {},
    );
    expect(find.byKey(const ValueKey('lite-nav-3')), findsNothing);
    final rects = [2, 0, 1, 4]
        .map((index) => tester.getRect(find.byKey(ValueKey('lite-nav-$index'))))
        .toList();
    for (var i = 1; i < rects.length; i++) {
      expect(rects[i - 1].right, closeTo(rects[i].left, 0.01));
    }
  });

  testWidgets('large text keeps every destination accessible', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpBar(
      tester,
      width: 320,
      height: 700,
      safeBottom: 34,
      textScale: 2,
      showPlants: true,
      onSelected: (_) {},
    );
    for (final item in _fiveItems) {
      expect(
        tester
            .widgetList<Semantics>(find.byType(Semantics))
            .any(
              (widget) =>
                  widget.properties.label == item.label &&
              widget.properties.button == true &&
              widget.properties.onTap != null,
            ),
        isTrue,
      );
    }
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Mascotas'), findsNothing);
    handle.dispose();
  });
}
