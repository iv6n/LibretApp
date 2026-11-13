import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_card.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_directory_header.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/app_theme.dart';
import 'advisor/rules/rule_test_fixtures.dart';

void main() {
  void expectChipVisibleOrSemantic(
    WidgetTester tester,
    String label,
    String semantic,
  ) {
    final semantics = tester.ensureSemantics();
    expect(
      find.text(label).evaluate().isNotEmpty ||
          find.bySemanticsLabel(RegExp(semantic)).evaluate().isNotEmpty,
      isTrue,
    );
    semantics.dispose();
  }

  testWidgets(
    'identity chips keep breed and purpose ahead of optional status',
    (tester) async {
      Widget rowAt(double width) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: const AnimalIdentityChipRow(
                breedLabel: 'BRAHMAN X BRAHMAN DE REGISTRO',
                purposeLabel: 'DOBLE PROP.',
                breedAccentColor: Colors.blue,
                breedTextColor: Colors.blue,
                purposeAccentColor: Colors.green,
                purposeTextColor: Colors.green,
              ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(rowAt(140));
      expect(find.textContaining(RegExp(r'^\+\d+$')), findsNothing);
      expect(find.text('BRAHMAN X BRAHMAN DE REGISTRO'), findsOneWidget);
      expect(find.text('DOBLE PROP.'), findsOneWidget);
      final semantics = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(RegExp(r'Raza BRAHMAN X BRAHMAN DE REGISTRO')),
        findsOneWidget,
      );
      expect(
        find.text('DOBLE PROP.').evaluate().isNotEmpty ||
            find
                .bySemanticsLabel(RegExp(r'Propósito DOBLE PROP\.'))
                .evaluate()
                .isNotEmpty,
        isTrue,
      );
      semantics.dispose();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(rowAt(600));
      expect(find.text('BRAHMAN X BRAHMAN DE REGISTRO'), findsOneWidget);
      expect(find.text('DOBLE PROP.'), findsOneWidget);
      expect(
        (tester.getRect(find.text('BRAHMAN X BRAHMAN DE REGISTRO')).center.dy -
                tester.getRect(find.text('DOBLE PROP.')).center.dy)
            .abs(),
        lessThan(2),
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SizedBox(
              width: 600,
              child: AnimalIdentityChipRow(
                breedLabel: 'CEBÚ',
                purposeLabel: 'ENGORDA',
                statusLabel: 'ACTIVO',
                breedAccentColor: Colors.blue,
                breedTextColor: Colors.blue,
                purposeAccentColor: Colors.green,
                purposeTextColor: Colors.green,
              ),
            ),
          ),
        ),
      );
      expect(find.text('CEBÚ'), findsOneWidget);
      expect(find.text('ENGORDA'), findsOneWidget);
      expect(find.text('ACTIVO'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('CEBÚ')).dx,
        lessThan(tester.getTopLeft(find.text('ENGORDA')).dx),
      );
      expect(
        tester.getTopLeft(find.text('ENGORDA')).dx,
        lessThan(tester.getTopLeft(find.text('ACTIVO')).dx),
      );
      expect(tester.takeException(), isNull);

      for (final labels in [
        ('CEBÚ', 'REPRODUCTOR', 'ACTIVA'),
        ('CHAROLAIS', 'CRÍA', 'ACTIVO'),
      ]) {
        final labelSet = [labels.$1, labels.$2, labels.$3];
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SizedBox(
                width: 360,
                child: AnimalIdentityChipRow(
                  breedLabel: labels.$1,
                  purposeLabel: labels.$2,
                  statusLabel: labels.$3,
                  breedAccentColor: Colors.blue,
                  breedTextColor: Colors.blue,
                  purposeAccentColor: Colors.green,
                  purposeTextColor: Colors.green,
                ),
              ),
            ),
          ),
        );
        final requiredVisible = labelSet
            .take(2)
            .every((label) => find.text(label).evaluate().isNotEmpty);
        final statusVisible = find.text(labels.$3).evaluate().isNotEmpty;
        if (!requiredVisible) {
          expect(find.textContaining(RegExp(r'^\+\d+$')), findsOneWidget);
        }
        if (!statusVisible) {
          final semantics = tester.ensureSemantics();
          expect(
            find.bySemanticsLabel(RegExp('Estado ${labels.$3}')),
            findsOneWidget,
          );
          semantics.dispose();
        }
        for (final label in labelSet) {
          final finder = find.text(label);
          if (finder.evaluate().isNotEmpty) {
            expect(
              tester.renderObject<RenderParagraph>(finder).didExceedMaxLines,
              isFalse,
            );
          }
        }
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('livestock shows ear tag above name and keeps facts available', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: Scaffold(
          body: AnimalCard(
            animal: buildAnimal(ageMonths: 64).copyWith(
              productionPurpose: ProductionPurpose.breeding,
              customName: 'Nancy',
              earTagNumber: 'MZQ-0003',
              breed: 'Cebú',
            ),
            onMenuAction: (_) {},
          ),
        ),
      ),
    );

    final earTag = find.text('MZQ-0003');
    final name = find.textContaining('Nancy');
    expect(earTag, findsOneWidget);
    expect(name, findsOneWidget);
    final avatarFrame = find.byWidgetPredicate(
      (widget) =>
          widget is Material &&
          widget.borderRadius == BorderRadius.circular(10),
    );
    expect(tester.getSize(avatarFrame), const Size(56, 56));
    expect(tester.getTopLeft(earTag).dy, lessThan(tester.getTopLeft(name).dy));
    expect(
      (tester.getTopLeft(name).dy -
              tester.getTopLeft(find.textContaining(RegExp(r'^5.*4.*m'))).dy)
          .abs(),
      lessThan(2),
    );
    final ageParagraph = tester.renderObject<RenderParagraph>(
      find.textContaining(RegExp(r'^5.*4.*m')),
    );
    expect(ageParagraph.didExceedMaxLines, isFalse);
    final identityLabels = ['CEBÚ', 'CRÍA'];
    final requiredIdentityVisible = identityLabels
        .take(2)
        .every((label) => find.text(label).evaluate().isNotEmpty);
    expect(requiredIdentityVisible, isTrue);
    expect(find.textContaining(RegExp(r'^\+\d+$')), findsNothing);
    expectChipVisibleOrSemantic(tester, 'CEBÚ', r'Raza CEBÚ');
    expectChipVisibleOrSemantic(tester, 'CRÍA', r'Propósito CRÍA');
    expect(find.text('ACTIVO'), findsNothing);
    expect(find.text('VACA'), findsOneWidget);
    if (requiredIdentityVisible) {
      expect(
        tester.getTopLeft(find.text('CEBÚ')).dx,
        lessThan(tester.getTopLeft(find.text('CRÍA')).dx),
      );
    }
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(390, 800);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: Scaffold(
          body: AnimalCard(
            animal: buildAnimal(ageMonths: 64).copyWith(
              productionPurpose: ProductionPurpose.breeding,
              customName: 'Nancy',
              earTagNumber: 'MZQ-0003',
              breed: 'Cebú',
            ),
            onMenuAction: (_) {},
          ),
        ),
      ),
    );
    final identityLabels390 = ['CEBÚ', 'CRÍA'];
    final requiredIdentityVisible390 = identityLabels390
        .take(2)
        .every((label) => find.text(label).evaluate().isNotEmpty);
    expect(requiredIdentityVisible390, isTrue);
    expect(find.textContaining(RegExp(r'^\+\d+$')), findsNothing);
    expectChipVisibleOrSemantic(tester, 'CEBÚ', r'Raza CEBÚ');
    expectChipVisibleOrSemantic(tester, 'CRÍA', r'Propósito CRÍA');
    expect(find.text('ACTIVO'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pet without ear tag uses its name as primary identity', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: AnimalCard(
              animal: buildAnimal(
                species: Species.canine,
                category: Category.other,
                lifeStage: LifeStage.youngDog,
                productionPurpose: ProductionPurpose.companion,
              ).copyWith(earTagNumber: '', customName: 'Luna'),
              onMenuAction: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Luna'), findsOneWidget);
    expect(find.text('CANINO'), findsOneWidget);
    expect(find.text('3 años'), findsOneWidget);
    expect(
      (tester.getRect(find.text('Luna')).center.dy -
              tester.getRect(find.text('3 años')).center.dy)
          .abs(),
      lessThan(2),
    );
    expect(find.text('Arete pendiente'), findsNothing);
    // The test font is much wider than the real one, so the header keeps the
    // stage pill on its own row here; the guard only catches a runaway card.
    expect(tester.getSize(find.byType(Card)).height, lessThan(240));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'footer keeps critical withdrawal, dairy facts and health warning',
    (tester) async {
      tester.view.physicalSize = const Size(390, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: Scaffold(
            body: AnimalCard(
              animal: buildAnimal(
                productionPurpose: ProductionPurpose.dairy,
                reproductiveStatus: ReproductiveStatus.pregnant,
                lastServiceDate: DateTime.now().subtract(
                  const Duration(days: 120),
                ),
                healthStatus: HealthStatus.critical,
              ).copyWith(breed: 'Holstein'),
              indicatorSnapshot: AnimalIndicatorSnapshot(
                milkLitersPerDay: 15.3,
                withdrawalEndsOn: DateTime.now().add(const Duration(days: 5)),
              ),
              onMenuAction: (_) {},
            ),
          ),
        ),
      );

      final semantics = tester.ensureSemantics();
      expect(
        find.text('HOLSTEIN').evaluate().isNotEmpty ||
            find
                .bySemanticsLabel(RegExp(r'Raza HOLSTEIN'))
                .evaluate()
                .isNotEmpty,
        isTrue,
      );
      semantics.dispose();
      expect(find.text('LECHE'), findsOneWidget);
      expect(find.textContaining('RETIRO'), findsOneWidget);
      expect(find.textContaining('Crít'), findsOneWidget);
      expect(
        tester.getRect(find.textContaining('RETIRO')).top,
        greaterThanOrEqualTo(tester.getRect(find.text('Sin ubicación')).top),
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SizedBox(
              width: 230,
              child: AnimalIdentityChipRow(
                breedLabel: 'CEBÚ',
                purposeLabel: 'REPRODUCTOR',
                statusLabel: 'ACTIVA',
                breedAccentColor: Colors.blue,
                breedTextColor: Colors.blue,
                purposeAccentColor: Colors.green,
                purposeTextColor: Colors.green,
              ),
            ),
          ),
        ),
      );
      expect(find.text('CEBÚ'), findsOneWidget);
      expect(find.text('REPRODUCTOR'), findsOneWidget);
      expect(find.text('ACTIVA'), findsOneWidget);
      expect(find.textContaining(RegExp(r'^\+\d+$')), findsNothing);
      final narrowSemantics = tester.ensureSemantics();
      expect(find.bySemanticsLabel(RegExp(r'Estado ACTIVA')), findsOneWidget);
      narrowSemantics.dispose();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('dual purpose is identified accurately', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AnimalCard(
            animal: buildAnimal(productionPurpose: ProductionPurpose.dual),
            isPreview: true,
          ),
        ),
      ),
    );

    expect(find.text('DOBLE PROP.'), findsOneWidget);
    expect(find.text('REPRODUCTOR'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'sparse registration shows identity without neutral placeholders',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: Scaffold(
            body: AnimalCard(
              animal: buildAnimal(
                lifeStage: LifeStage.unknown,
                ageMonths: -1,
                healthStatus: HealthStatus.unknown,
                riskLevel: RiskLevel.low,
                productionPurpose: ProductionPurpose.undefined,
              ).copyWith(earTagNumber: 'QA001', breed: 'Desconocido'),
              onMenuAction: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('QA001'), findsOneWidget);
      expect(find.text('Sin ubicación'), findsOneWidget);
      expect(find.text('Desconocido'), findsNothing);
      expect(find.text('Sin dato'), findsNothing);
      expect(find.text('Bajo'), findsNothing);
      expect(find.text('POR DEFINIR'), findsNothing);
      expect(find.text('PROPÓSITO PENDIENTE'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [320.0, 360.0, 412.0, 600.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets(
        'animal card with long location at ${width.toInt()}dp, dark=$dark',
        (tester) async {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final textScale = width == 320 ? 2.0 : 1.0;
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('es'),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(textScale)),
                child: child!,
              ),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: AnimalCard(
                    animal:
                        buildAnimal(
                          healthStatus: HealthStatus.critical,
                          riskLevel: RiskLevel.critical,
                        ).copyWith(
                          customName:
                              'Animal con nombre extenso para identificar',
                        ),
                    location: const LocationEntity(
                      uuid: 'loc',
                      name: 'Potrero norte junto al camino de acceso',
                      type: LocationType.pasture,
                      surfaceArea: 10,
                      capacity: 30,
                      waterSource: 'Pozo',
                      terrainType: 'Plano',
                    ),
                    onLocationTap: () {},
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'header keeps the age on the name baseline and the stage pill level with '
    'the ear tag',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: AnimalDirectoryHeader(
              avatar: SizedBox(width: 56, height: 56),
              title: 'MZQ-0003',
              name: 'Nancy',
              age: '5 años',
              stage: 'Vaca',
              stageColor: Colors.blue,
              chips: SizedBox.shrink(),
              menu: Icon(Icons.more_vert),
            ),
          ),
        ),
      );

      double baselineOf(String text) =>
          tester.getTopLeft(find.text(text)).dy +
          tester
              .renderObject<RenderParagraph>(find.text(text))
              .computeDistanceToActualBaseline(TextBaseline.alphabetic);

      expect((baselineOf('Nancy') - baselineOf('5 años')).abs(), lessThan(0.5));

      final stagePill = tester.getRect(find.text('VACA'));
      final earTag = tester.getRect(find.text('MZQ-0003'));
      expect((stagePill.center.dy - earTag.center.dy).abs(), lessThan(1.5));

      // The age hugs the name instead of being pushed to the card's edge.
      expect(
        tester.getRect(find.text('5 años')).left -
            tester.getRect(find.text('Nancy')).right,
        lessThan(16),
      );
      expect(stagePill.right, greaterThan(earTag.left));
      expect(tester.takeException(), isNull);
    },
  );
}
