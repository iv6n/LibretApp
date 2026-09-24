import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/theme/app_theme.dart';

void main() {
  testWidgets('renders the segmented tab bar style and changes tabs on tap', (
    tester,
  ) async {
    late TabController controller;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: DefaultTabController(
          length: 3,
          child: Builder(
            builder: (context) {
              controller = DefaultTabController.of(context);

              return Scaffold(
                appBar: AppBar(
                  bottom: AppSegmentedTabBar(
                    keyPrefix: 'directorio_segmented_tab',
                    controller: controller,
                    items: const [
                      AppSegmentedTabItem(label: 'Animales', icon: Icons.pets),
                      AppSegmentedTabItem(label: 'Lotes', icon: Icons.fence),
                      AppSegmentedTabItem(
                        label: 'Ubicaciones',
                        icon: Icons.location_on_outlined,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Animales'), findsOneWidget);
    expect(find.text('Lotes'), findsOneWidget);
    expect(find.text('Ubicaciones'), findsOneWidget);
    expect(find.byIcon(Icons.pets), findsOneWidget);
    expect(find.byIcon(Icons.fence), findsOneWidget);
    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    expect(controller.index, 0);

    final activeBackground = tester.widget<AnimatedContainer>(
      find.byKey(
        const ValueKey<String>('directorio_segmented_tab_background_0'),
      ),
    );
    final activeDecoration = activeBackground.decoration! as BoxDecoration;
    expect(activeDecoration.color, LightColors.background);

    final inactiveBackground = tester.widget<AnimatedContainer>(
      find.byKey(
        const ValueKey<String>('directorio_segmented_tab_background_1'),
      ),
    );
    final inactiveDecoration = inactiveBackground.decoration! as BoxDecoration;
    expect(inactiveDecoration.color, Colors.transparent);

    final activeIcon = tester.widget<Icon>(find.byIcon(Icons.pets));
    expect(activeIcon.color, AppColors.primary);

    await tester.tap(
      find.byKey(const ValueKey<String>('directorio_segmented_tab_button_1')),
    );
    await tester.pumpAndSettle();

    expect(controller.index, 1);

    final selectedLotesBackground = tester.widget<AnimatedContainer>(
      find.byKey(
        const ValueKey<String>('directorio_segmented_tab_background_1'),
      ),
    );
    final selectedLotesDecoration =
        selectedLotesBackground.decoration! as BoxDecoration;
    expect(selectedLotesDecoration.color, LightColors.background);
  });

  testWidgets('colorAccented renders category colors and keeps selection', (
    tester,
  ) async {
    late TabController controller;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: DefaultTabController(
          length: 4,
          child: Builder(
            builder: (context) {
              controller = DefaultTabController.of(context);
              return Scaffold(
                appBar: AppBar(
                  bottom: AppSegmentedTabBar(
                    variant: AppSegmentedTabBarVariant.colorAccented,
                    controller: controller,
                    items: const [
                      AppSegmentedTabItem(
                        label: 'Animales',
                        icon: Icons.pets,
                        accentColor: Color(0xFFA65332),
                      ),
                      AppSegmentedTabItem(
                        label: 'Lotes',
                        icon: Icons.fence,
                        accentColor: AppColors.primary,
                      ),
                      AppSegmentedTabItem(
                        label: 'Cultivos',
                        icon: Icons.eco_outlined,
                        accentColor: AppColors.amber,
                      ),
                      AppSegmentedTabItem(
                        label: 'Ubicaciones',
                        icon: Icons.location_on_outlined,
                        accentColor: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(
      tester
          .widget<AppSegmentedTabBar>(find.byType(AppSegmentedTabBar))
          .preferredSize
          .height,
      AppSegmentedTabBar.accentedTotalHeight,
    );
    final selectedBackground = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey<String>('segmented_tab_background_0')),
    );
    final selectedDecoration = selectedBackground.decoration! as BoxDecoration;
    expect(selectedDecoration.color, isNot(LightColors.background));

    final animalIcon = tester.widget<Icon>(find.byIcon(Icons.pets));
    expect(animalIcon.color, const Color(0xFFA65332));

    await tester.tap(find.text('Cultivos'));
    await tester.pumpAndSettle();
    expect(controller.index, 2);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.eco_outlined)).color,
      AppColors.amber,
    );
  });

  testWidgets('colorAccented adapts icon badges for dark theme', (
    tester,
  ) async {
    late TabController controller;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: DefaultTabController(
          length: 1,
          child: Builder(
            builder: (context) {
              controller = DefaultTabController.of(context);
              return Scaffold(
                appBar: AppBar(
                  bottom: AppSegmentedTabBar(
                    variant: AppSegmentedTabBarVariant.colorAccented,
                    controller: controller,
                    items: const [
                      AppSegmentedTabItem(
                        label: 'Animales',
                        icon: Icons.pets,
                        accentColor: Color(0xFFE58A67),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(controller.index, 0);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.pets)).color,
      const Color(0xFFE58A67),
    );
    expect(find.byType(Container), findsWidgets);
  });
}
