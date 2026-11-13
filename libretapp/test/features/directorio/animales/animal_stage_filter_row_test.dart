import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_stage_filter_row.dart';

void main() {
  for (final width in [320.0, 360.0, 412.0]) {
    testWidgets(
      'category stages scroll at ${width.toInt()} dp with large text',
      (tester) async {
        tester.view.physicalSize = Size(width, 240);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: AnimalStageFilterRow(
                  species: Species.cattle,
                  counts: const {
                    LifeStage.calf: 5,
                    LifeStage.calfFemale: 2,
                    LifeStage.heifer: 4,
                    LifeStage.cow: 3,
                    LifeStage.bull: 1,
                  },
                  selectedStages: const {},
                  onChanged: _ignoreStages,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Todas'), findsOneWidget);
        expect(find.byType(ListView), findsOneWidget);
        await tester.drag(find.byType(ListView), const Offset(-2400, 0));
        await tester.pumpAndSettle();
        expect(find.text('Toro'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('selecting a stage filters and Todas clears the stage filter', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Set<LifeStage>? selectedStages;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimalStageFilterRow(
            species: Species.cattle,
            counts: const {
              LifeStage.calf: 5,
              LifeStage.calfFemale: 2,
              LifeStage.heifer: 4,
              LifeStage.cow: 3,
              LifeStage.bull: 1,
            },
            selectedStages: const {},
            onChanged: (stages) => selectedStages = stages,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Becerro / Becerra'), findsOneWidget);
    expect(find.text('Vaquilla'), findsOneWidget);
    expect(find.text('Vaca'), findsOneWidget);
    expect(find.text('Toro'), findsOneWidget);

    await tester.tap(find.text('Vaca'));
    expect(selectedStages, {LifeStage.cow});
    await tester.tap(find.text('Todas'));
    expect(selectedStages, isEmpty);
  });

  testWidgets('companion stage row includes available pet stages', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimalStageFilterRow(
            species: null,
            companionOnly: true,
            counts: {LifeStage.puppy: 2, LifeStage.cat: 1},
            selectedStages: {},
            onChanged: _ignoreStages,
          ),
        ),
      ),
    );

    expect(find.text('Cachorro'), findsOneWidget);
    expect(find.text('Gato'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _ignoreStages(Set<LifeStage> _) {}
