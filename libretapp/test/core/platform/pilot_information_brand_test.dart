import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/platform/pilot_information.dart';
import 'package:libretapp/theme/app_theme.dart';

void main() {
  testWidgets('support identity and information remain accessible at 200%', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const MediaQuery(
          data: MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: Scaffold(body: PilotInformationSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('LibretApp'), findsOneWidget);
    expect(find.text('Primeros pasos'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('Puedes eliminar registros'),
      300,
    );
    final paragraph = tester.getRect(
      find.textContaining('Puedes eliminar registros'),
    );
    final viewport = tester.getRect(find.byType(ListView));
    expect(paragraph.overlaps(viewport), isTrue);
    expect(tester.takeException(), isNull);
  });
}
