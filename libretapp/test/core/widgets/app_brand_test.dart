import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/widgets/app_brand.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final variant in AppBrandVariant.values) {
      testWidgets('$variant is readable and announced once in $brightness', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: Scaffold(
              body: Center(child: AppBrand(variant: variant, height: 32)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('LibretApp'), findsOneWidget);
        final image = tester.widget<SvgPicture>(find.byType(SvgPicture));
        final appearance = brightness == Brightness.dark ? 'dark' : 'light';
        expect(
          (image.bytesLoader as SvgAssetLoader).assetName,
          'assets/branding/${variant.name}-$appearance.svg',
        );
        expect(tester.getSize(find.byType(SvgPicture)).height, 32);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('nearby app text can provide the sole accessible name', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [AppBrand(excludeFromSemantics: true), Text('LibretApp')],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('LibretApp'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
