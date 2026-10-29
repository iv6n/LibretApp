import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/widgets/app_empty_state.dart';
import 'package:libretapp/theme/app_theme.dart';

void main() {
  for (final size in [
    const Size(360, 800),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    for (final dark in [false, true]) {
      testWidgets('illustrated empty state fits $size, dark=$dark', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var pressed = false;

        await tester.pumpWidget(MaterialApp(
          theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(size.width == 320 ? 2 : 1),
            ),
            child: child!,
          ),
          home: Scaffold(
            body: SizedBox(
              height: size.height * .55,
              child: AppEmptyState(
                illustrationAsset: 'assets/images/location_garden.webp',
                title: 'Empieza a cuidar tus plantas y cultivos',
                message: 'Organiza una planta, un huerto o una siembra.',
                action: FilledButton(
                  onPressed: () => pressed = true,
                  child: const Text('Agregar planta o cultivo'),
                ),
              ),
            ),
          ),
        ));

        await tester.ensureVisible(find.text('Agregar planta o cultivo'));
        await tester.tap(find.text('Agregar planta o cultivo'));
        await tester.pump();
        expect(pressed, isTrue);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
