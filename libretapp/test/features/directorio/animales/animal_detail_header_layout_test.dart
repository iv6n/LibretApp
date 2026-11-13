import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/widgets/detail_header.dart';
import 'package:libretapp/theme/app_theme.dart';

import 'advisor/rules/rule_test_fixtures.dart';

void main() {
  for (final config in [
    (320.0, 2.0, true),
    (390.0, 1.0, false),
    (600.0, 1.0, true),
    (1200.0, 1.0, false),
  ]) {
    testWidgets('identity remains readable while header collapses $config', (
      tester,
    ) async {
      tester.view.physicalSize = Size(config.$1, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final animal = buildAnimal(requiresAttention: true).copyWith(
        customName: config.$2 == 2
            ? 'Mezquite de la sierra del norte'
            : 'Nancy',
        earTagNumber: 'MZQ-0003',
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: config.$3 ? AppTheme.darkTheme : AppTheme.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(config.$2)),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: animalHeaderHeight(context, animal),
                    flexibleSpace: CollapsibleAnimalHeader(animal: animal),
                    actions: [
                      IconButton(
                        tooltip: 'Editar',
                        onPressed: () {},
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Actualizar',
                        onPressed: () {},
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 1000)),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.text(animal.customName!), findsOneWidget);
      expect(find.text('Requiere atención'), findsOneWidget);
      expect(find.byTooltip('Editar'), findsOneWidget);
      expect(find.byTooltip('Actualizar'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text(animal.customName!), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
