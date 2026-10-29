import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_card.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/app_theme.dart';
import 'advisor/rules/rule_test_fixtures.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'animal card with long location, 320dp and 2x text, dark=$dark',
      (tester) async {
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('es'),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
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
