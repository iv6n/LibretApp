import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/widgets/app_directory_layout.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_card.dart';

const _location = LocationEntity(
  uuid: 'loc-1',
  name: 'Potrero A',
  type: LocationType.pasture,
  surfaceArea: 12.5,
  capacity: 40,
  waterSource: 'Pozo',
  terrainType: 'Plano',
);

/// Width of the outer padding the Directory frame adds around its cards.
const _framePadding = 16.0;

void _noop() {}

Future<void> _pumpCard(
  WidgetTester tester,
  double width, {
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: const Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: _framePadding),
          child: LocationCard(
            location: _location,
            animalCount: 2,
            standardizedDirectoryLayout: true,
            onTap: _noop,
          ),
        ),
      ),
    ),
  );
}

double _headerGap(WidgetTester tester) =>
    tester.getTopLeft(find.text('Potrero A')).dx -
    tester.getTopRight(find.byType(LocationTypeAvatar)).dx;

void main() {
  testWidgets('location card uses the phone scale at 360 dp', (tester) async {
    await _pumpCard(tester, 360);
    final metrics = AppDirectoryMetrics.forCardWidth(
      AppDirectoryMetrics.minCardWidth,
    );

    final avatar = tester.widget<LocationTypeAvatar>(
      find.byType(LocationTypeAvatar),
    );
    expect(avatar.radius, metrics.leadingAvatarRadius);
    expect(tester.getSize(find.byType(LocationTypeAvatar)).width, 56);
    expect(
      tester.getTopLeft(find.byType(LocationTypeAvatar)).dx,
      closeTo(_framePadding + metrics.cardPaddingH, 0.5),
    );
    expect(_headerGap(tester), closeTo(metrics.headerGap, 0.5));
  });

  testWidgets('location card grows with the widest column', (tester) async {
    await _pumpCard(tester, 1200);
    final metrics = AppDirectoryMetrics.forCardWidth(
      AppDirectoryMetrics.maxCardWidth,
    );

    final avatar = tester.widget<LocationTypeAvatar>(
      find.byType(LocationTypeAvatar),
    );
    expect(avatar.radius, metrics.leadingAvatarRadius);
    expect(tester.getSize(find.byType(LocationTypeAvatar)).width, 68);
    expect(
      tester.getTopLeft(find.byType(LocationTypeAvatar)).dx,
      closeTo(_framePadding + metrics.cardPaddingH, 0.5),
    );
    expect(_headerGap(tester), closeTo(metrics.headerGap, 0.5));
  });

  testWidgets('nested location cards keep a tighter leading avatar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LocationCard(
            location: _location,
            animalCount: 0,
            isNested: true,
            standardizedDirectoryLayout: true,
            onTap: _noop,
          ),
        ),
      ),
    );

    final metrics = AppDirectoryMetrics.forCardWidth(
      AppDirectoryMetrics.maxCardWidth,
    );
    final avatar = tester.widget<LocationTypeAvatar>(
      find.byType(LocationTypeAvatar),
    );
    expect(avatar.radius, metrics.compactAvatarRadius);
    expect(avatar.radius, lessThan(metrics.leadingAvatarRadius));
  });

  testWidgets('location card fits a 320 dp screen with enlarged text', (
    tester,
  ) async {
    await _pumpCard(tester, 320, textScaler: const TextScaler.linear(2));
    expect(tester.takeException(), isNull);
  });
}
