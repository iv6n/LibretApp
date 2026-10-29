import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_empty_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationEmptyView', () {
    testWidgets('muestra ilustración y una sola acción de crear', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationEmptyView(
              onCreate: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Da un lugar a cada registro'), findsOneWidget);
      expect(find.text('Crear ubicación'), findsOneWidget);
      expect(find.text('Recargar'), findsNothing);
      expect(find.byType(Image), findsOneWidget);

      await tester.tap(find.text('Crear ubicación'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
