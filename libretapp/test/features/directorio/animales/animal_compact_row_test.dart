import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_compact_row.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_card_presentation.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';

import 'advisor/rules/rule_test_fixtures.dart';

void main() {
  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets('renders in $brightness theme at narrow width', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: Scaffold(
            body: AnimalCompactRow(
              animal: buildAnimal(healthStatus: HealthStatus.critical),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Crítico'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('shows ear tag before name and species before location', (
    tester,
  ) async {
    final animal = buildAnimal().copyWith(
      earTagNumber: 'MZQ-0003',
      customName: 'Nancy',
    );
    const location = LocationEntity(
      uuid: 'north',
      name: 'Potrero Norte',
      type: LocationType.pasture,
      surfaceArea: 10,
      capacity: 30,
      waterSource: 'Pozo',
      terrainType: 'Plano',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AnimalCompactRow(
              animal: animal,
              location: location,
              onTap: () {},
              onLocationTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('#MZQ-0003 · Nancy'), findsOneWidget);
    expect(find.text('Bovino · Potrero Norte'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(
      tester.getSize(find.byType(AnimalCompactRow)).height,
      greaterThanOrEqualTo(64),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses the pending tag fallback when tag is absent', (
    tester,
  ) async {
    final animal = buildAnimal().copyWith(earTagNumber: '', customName: '');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimalCompactRow(animal: animal, onTap: () {}),
        ),
      ),
    );

    expect(find.textContaining('Arete pendiente · Bovino'), findsOneWidget);
    expect(find.textContaining('Sin ubicación'), findsOneWidget);
    expect(find.text('Bueno'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wraps naturally on a narrow screen at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
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
          body: SingleChildScrollView(
            child: AnimalCompactRow(
              animal: buildAnimal().copyWith(
                earTagNumber: 'MZQ-00000000000123',
                customName: 'Animal con nombre de registro muy extenso',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(AnimalCompactRow)).height,
      greaterThan(64),
    );
  });

  test('critical production indicator outranks an attention health status', () {
    final animal = buildAnimal(healthStatus: HealthStatus.poor);
    final snapshot = AnimalIndicatorSnapshot(
      withdrawalEndsOn: DateTime.now().add(const Duration(days: 3)),
    );

    final alert = compactAnimalAlert(animal, snapshot: snapshot);

    expect(alert?.severity, IndicatorSeverity.critical);
    expect(alert?.label, startsWith('Retiro'));
  });

  test(
    'critical health status wins a severity tie with production warnings',
    () {
      final animal = buildAnimal(healthStatus: HealthStatus.critical);
      final snapshot = AnimalIndicatorSnapshot(
        withdrawalEndsOn: DateTime.now().add(const Duration(days: 3)),
      );

      final alert = compactAnimalAlert(animal, snapshot: snapshot);

      expect(alert?.severity, IndicatorSeverity.critical);
      expect(alert?.label, HealthStatus.critical.displayName);
    },
  );
}
