import 'package:flutter/material.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_card.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';

import 'advisor/rules/rule_test_fixtures.dart';

void main() {
  testWidgets('footer stays compact and location remains tappable', (
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
      closeTo(49, 1),
    );
    await tester.tap(find.text('Potrero Norte'));

    expect(locationTapped, isTrue);
    expect(tester.takeException(), isNull);
  });
}
