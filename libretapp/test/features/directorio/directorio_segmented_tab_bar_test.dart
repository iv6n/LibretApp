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
                      AppSegmentedTabItem(
                        label: 'Animales',
                        icon: Icons.pets,
                      ),
                      AppSegmentedTabItem(
                        label: 'Lotes',
                        icon: Icons.fence,
                      ),
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
}
