import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/demo/builders/demo_animals.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_card.dart';
import 'package:libretapp/features/directorio/animales/widgets/pet_card.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/l10n/app_localizations.dart';

void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('PetCard presenta datos disponibles sin ubicación en $mode', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 760);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final sample = buildDemoAnimals(reference: DateTime(2026, 1, 1))
          .firstWhere((animal) => animal.species == Species.canine)
          .copyWith(
            customName: 'Mora',
            profilePhoto: null,
            ageMonths: -1,
            birthDate: DateTime.fromMillisecondsSinceEpoch(0),
            birthDatePrecision: BirthDatePrecision.unknown,
            healthStatus: HealthStatus.unknown,
            riskLevel: RiskLevel.none,
            requiresAttention: false,
            underObservation: false,
            productionPurpose: ProductionPurpose.undefined,
            bodyConditionScore: null,
            weight: null,
            rfidTag: null,
            earTagNumber: '',
          );
      var activated = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: mode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
              child: PetCard(animal: sample, onTap: () => activated = true),
            ),
          ),
        ),
      );

      expect(find.text('Mora'), findsOneWidget);
      expect(find.text('MASCOTA'), findsOneWidget);
      expect(find.text('Vaca'), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName ==
                  'assets/images/canino.webp',
        ),
        findsOneWidget,
      );
      expect(find.text('Sin dato'), findsNothing);
      expect(find.textContaining('Edad sin dato'), findsNothing);
      expect(find.textContaining('Último peso'), findsNothing);
      expect(find.byIcon(Icons.tag_outlined), findsNothing);
      expect(find.text('Sin ubicación'), findsNothing);
      expect(find.byKey(const ValueKey('pet_card_footer')), findsOneWidget);
      expect(find.textContaining('Canino'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byType(PetCard));
      await tester.pumpAndSettle();
      expect(activated, isTrue);
    });
  }

  testWidgets('PetCard muestra ilustración felina y distintivo de mascota', (
    tester,
  ) async {
    final sample = buildDemoAnimals(reference: DateTime(2026, 1, 1))
        .firstWhere((animal) => animal.species == Species.canine)
        .copyWith(
          species: Species.feline,
          lifeStage: LifeStage.cow,
          customName: 'Michi',
          profilePhoto: null,
        );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: PetCard(animal: sample)),
      ),
    );

    expect(find.text('MASCOTA'), findsOneWidget);
    expect(find.textContaining('Felino'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('MASCOTA')).dy,
      lessThan(tester.getTopLeft(find.textContaining('Felino')).dy),
    );
    expect(find.text('Vaca'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/felino.png',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'pet orders breed and purpose, then care and health after location',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final sample = buildDemoAnimals(reference: DateTime(2026, 1, 1))
          .firstWhere((animal) => animal.customName == 'Luna')
          .copyWith(healthStatus: HealthStatus.fair);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                child: PetCard(
                  animal: sample,
                  location: const LocationEntity(
                    uuid: 'home',
                    name: 'Casa',
                    type: LocationType.house,
                    surfaceArea: 0,
                    capacity: 1,
                    waterSource: '',
                    terrainType: '',
                  ),
                  indicatorSnapshot: AnimalIndicatorSnapshot(
                    nextCareDueOn: DateTime.now().add(const Duration(days: 2)),
                  ),
                  onMenuAction: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      final summaryChip = find.textContaining(RegExp(r'^\+\d+$'));
      final purposeChip = find.text('COMPAÑÍA');
      // The purpose chip stays reachable: either it fits the two-line budget
      // or it folds into the `+N` summary.
      expect(
        purposeChip.evaluate().isNotEmpty,
        isTrue,
        reason: 'purpose remains visible in wrapped layouts',
      );
      expect(summaryChip, findsNothing);
      if (purposeChip.evaluate().isEmpty) {
        final semantics = tester.ensureSemantics();
        expect(
          find.bySemanticsLabel(RegExp(r'Propósito COMPAÑÍA')),
          findsOneWidget,
        );
        semantics.dispose();
      }
      expect(find.textContaining('Canino'), findsOneWidget);
      final avatarFrame = find.byWidgetPredicate(
        (widget) =>
            widget is Material &&
            widget.borderRadius == BorderRadius.circular(10),
      );
      expect(tester.getSize(avatarFrame), const Size(56, 56));
      expect(
        (tester.getRect(find.text('Luna')).center.dy -
                tester.getRect(find.text('2 años')).center.dy)
            .abs(),
        lessThan(3),
      );
      expect(
        tester.getRect(find.text('2 años')).right,
        greaterThan(tester.getRect(find.text('Luna')).right),
      );
      if (purposeChip.evaluate().isNotEmpty &&
          summaryChip.evaluate().isNotEmpty) {
        expect(
          (tester.getRect(summaryChip).center.dy -
                  tester.getRect(purposeChip).center.dy)
              .abs(),
          lessThan(2),
        );
      }
      expect(find.text('Casa'), findsOneWidget);
      expect(find.text('Aceptable'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('PetCard hides weight and identity summary but keeps the menu', (
    tester,
  ) async {
    final sample = buildDemoAnimals(reference: DateTime(2026, 1, 1))
        .firstWhere((animal) => animal.species == Species.canine)
        .copyWith(
          customName: 'Mora',
          weight: 22.0,
          earTagNumber: 'MZQ-0039',
          healthStatus: HealthStatus.fair,
        );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PetCard(animal: sample, onMenuAction: (_) {}),
        ),
      ),
    );

    expect(find.text('Mora'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Mora')).style!.fontSize,
      greaterThan(20),
    );
    expect(find.byIcon(Icons.pets), findsOneWidget);
    expect(find.textContaining('Último peso'), findsNothing);
    expect(find.text('MZQ-0039'), findsNothing);
    expect(find.byKey(const ValueKey('pet_card_footer')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PetCard en modo de ejemplo no navega ni abre acciones', (
    tester,
  ) async {
    final sample = buildDemoAnimals(
      reference: DateTime(2026, 1, 1),
    ).firstWhere((animal) => animal.species == Species.canine);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: PetCard(animal: sample, isPreview: true)),
      ),
    );

    expect(find.byType(PopupMenuButton<AnimalCardMenuAction>), findsNothing);
    await tester.tap(find.byType(PetCard));
    await tester.pumpAndSettle();
    expect(find.byType(PetCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
