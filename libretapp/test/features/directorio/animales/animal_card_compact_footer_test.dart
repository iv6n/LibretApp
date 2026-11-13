import 'package:flutter/material.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_card.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_card_presentation.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_purpose_indicators.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_purpose.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';

import 'advisor/rules/rule_test_fixtures.dart';

void main() {
  testWidgets('footer aligns and orders purpose facts at 360dp', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> pumpFooter({
      required ProductionPurpose purpose,
      required List<PurposeIndicator> indicators,
      CompactAnimalAlert? alert,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalCardFooter(
              key: const ValueKey('animal_card_footer'),
              locationLabel: 'Potrero',
              indicators: indicators,
              purpose: purpose,
              healthAlert: alert,
            ),
          ),
        ),
      );
    }

    final locationIcon = find.byIcon(Icons.place_outlined);
    final footer = find.byKey(const ValueKey('animal_card_footer'));

    await pumpFooter(
      purpose: ProductionPurpose.meat,
      indicators: const [
        PurposeIndicator(kind: PurposeIndicatorKind.weight, label: '500 kg'),
        PurposeIndicator(
          kind: PurposeIndicatorKind.dailyGain,
          label: '+1 kg/día',
        ),
      ],
    );
    final gain = find.text('+1 KG/DÍA');
    final weight = find.text('500 KG');
    final weightChip = find
        .ancestor(of: weight, matching: find.byType(Container))
        .first;
    expect(gain, findsOneWidget);
    expect(weight, findsOneWidget);
    expect(
      tester.getRect(gain).center.dx,
      lessThan(tester.getRect(weight).center.dx),
    );
    expect(
      tester.getRect(locationIcon).left,
      closeTo(tester.getRect(footer).left + 12, 1),
    );
    expect(
      tester.getRect(weightChip).right,
      closeTo(tester.getRect(footer).right - 12, 2),
    );

    await pumpFooter(
      purpose: ProductionPurpose.dairy,
      indicators: const [
        PurposeIndicator(kind: PurposeIndicatorKind.milkPerDay, label: 'LECHE'),
        PurposeIndicator(
          kind: PurposeIndicatorKind.daysPregnant,
          label: 'PREÑEZ',
        ),
        PurposeIndicator(kind: PurposeIndicatorKind.daysInMilk, label: 'SEC'),
      ],
    );
    final pregnancy = find.text('PREÑEZ');
    final milk = find.text('LECHE');
    expect(pregnancy, findsOneWidget);
    expect(milk, findsOneWidget);
    expect(
      tester.getRect(pregnancy).center.dx,
      lessThan(tester.getRect(milk).center.dx),
    );

    await pumpFooter(
      purpose: ProductionPurpose.dual,
      indicators: const [
        PurposeIndicator(kind: PurposeIndicatorKind.weight, label: 'PESO'),
        PurposeIndicator(kind: PurposeIndicatorKind.milkPerDay, label: 'LECHE'),
        PurposeIndicator(
          kind: PurposeIndicatorKind.daysPregnant,
          label: 'PREÑEZ',
        ),
        PurposeIndicator(
          kind: PurposeIndicatorKind.dailyGain,
          label: 'GANANCIA',
        ),
      ],
    );
    final gainDual = find.text('GANANCIA');
    final weightDual = find.text('PESO');
    final milkDual = find.text('LECHE');
    final pregnancyDual = find.text('PREÑEZ');
    expect(gainDual, findsOneWidget);
    expect(weightDual, findsOneWidget);
    expect(milkDual, findsOneWidget);
    expect(pregnancyDual, findsOneWidget);
    expect(
      tester.getRect(milkDual).center.dx,
      lessThan(tester.getRect(pregnancyDual).center.dx),
    );

    await pumpFooter(
      purpose: ProductionPurpose.meat,
      indicators: const [
        PurposeIndicator(kind: PurposeIndicatorKind.weight, label: 'PESO'),
        PurposeIndicator(
          kind: PurposeIndicatorKind.milkWithdrawal,
          label: 'Retiro 5 días',
          severity: IndicatorSeverity.critical,
        ),
      ],
      alert: const CompactAnimalAlert(
        label: 'Crítico',
        severity: IndicatorSeverity.critical,
        accentColor: Colors.red,
        icon: Icons.health_and_safety_outlined,
      ),
    );
    final weightMedical = find.text('PESO');
    final withdrawal = find.textContaining('RETIRO');
    final healthAlert = find.text('Crítico');
    final healthAlertPill = find
        .ancestor(of: healthAlert, matching: find.byType(Container))
        .first;
    expect(withdrawal, findsOneWidget);
    expect(healthAlert, findsOneWidget);
    if (weightMedical.evaluate().isNotEmpty) {
      expect(
        tester.getRect(weightMedical).center.dx,
        lessThan(tester.getRect(withdrawal).center.dx),
      );
    }
    expect(
      tester.getRect(withdrawal).center.dx,
      lessThan(tester.getRect(healthAlert).center.dx),
    );
    expect(
      tester.getRect(healthAlertPill).right,
      closeTo(tester.getRect(footer).right - 12, 2),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('footer wraps its facts and location remains tappable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var locationTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: AnimalCard(
              animal: buildAnimal(),
              indicatorSnapshot: const AnimalIndicatorSnapshot(
                lastWeightKg: 420,
                averageDailyGainKg: 0.9,
              ),
              location: const LocationEntity(
                uuid: 'north',
                name: 'Potrero Norte',
                type: LocationType.pasture,
                surfaceArea: 10,
                capacity: 30,
                waterSource: 'Pozo',
                terrainType: 'Plano',
              ),
              onTap: () {},
              onLocationTap: () => locationTapped = true,
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('animal_card_footer'))).height,
      inInclusiveRange(48, 180),
      reason: 'additional indicators can wrap onto another phone row',
    );
    expect(find.textContaining('KG'), findsAtLeastNWidgets(1));
    final footerChips = find.descendant(
      of: find.byKey(const ValueKey('animal_card_footer')),
      matching: find.byType(TagChip),
    );
    expect(footerChips, findsAtLeastNWidgets(1));
    final chipTops = [
      for (var i = 0; i < footerChips.evaluate().length; i++)
        tester.getTopLeft(footerChips.at(i)).dy,
    ];
    expect(
      (chipTops.reduce((a, b) => a < b ? a : b) -
              chipTops.reduce((a, b) => a > b ? a : b))
          .abs(),
      greaterThan(1.5),
      reason: 'overflowing facts wrap onto a following row on narrow cards',
    );
    final locationRect = tester.getRect(find.text('Potrero Norte'));
    final chipRect = tester.getRect(footerChips.first);
    expect(chipRect.top, greaterThanOrEqualTo(locationRect.top));
    await tester.tap(find.text('Potrero Norte'));

    expect(locationTapped, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wrapped facts stay aligned with the location text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimalCardFooter(
            key: ValueKey('animal_card_footer'),
            locationLabel: 'Potrero Norte',
            purpose: ProductionPurpose.dual,
            indicators: [
              PurposeIndicator(
                kind: PurposeIndicatorKind.weight,
                label: 'Peso 420 kg',
              ),
              PurposeIndicator(
                kind: PurposeIndicatorKind.dailyGain,
                label: '+0.9 kg/día',
              ),
              PurposeIndicator(
                kind: PurposeIndicatorKind.daysPregnant,
                label: 'Preñez 269 días',
              ),
            ],
          ),
        ),
      ),
    );

    final footer = find.byKey(const ValueKey('animal_card_footer'));
    final chips = find.descendant(of: footer, matching: find.byType(TagChip));
    expect(chips, findsAtLeastNWidgets(2));
    final locationLeft = tester.getRect(find.byIcon(Icons.place_outlined)).left;
    expect(locationLeft, closeTo(tester.getRect(footer).left + 12, 1));

    var leftmost = double.infinity;
    for (var index = 0; index < chips.evaluate().length; index++) {
      final left = tester.getRect(chips.at(index)).left;
      expect(left, greaterThanOrEqualTo(locationLeft - 0.5));
      leftmost = left < leftmost ? left : leftmost;
    }
    expect(leftmost, closeTo(locationLeft, 1));
    expect(tester.takeException(), isNull);
  });
}
