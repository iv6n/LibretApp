import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/demo/builders/demo_animals.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_card.dart';
import 'package:libretapp/features/directorio/animales/widgets/pet_card.dart';
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
      expect(find.text('Sin dato'), findsOneWidget);
      expect(find.textContaining('Edad sin dato'), findsOneWidget);
      expect(find.textContaining('Último peso'), findsNothing);
      expect(find.byIcon(Icons.tag_outlined), findsNothing);
      expect(find.text('Sin ubicación'), findsNothing);
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
    expect(find.text('FELINO'), findsOneWidget);
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

  testWidgets('PetCard hides weight and identity summary but keeps the menu', (
    tester,
  ) async {
    final sample = buildDemoAnimals(reference: DateTime(2026, 1, 1))
        .firstWhere((animal) => animal.species == Species.canine)
        .copyWith(customName: 'Mora', weight: 22.0, earTagNumber: 'MZQ-0039');

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
