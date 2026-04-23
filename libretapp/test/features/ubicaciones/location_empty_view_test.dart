import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_empty_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationEmptyView', () {
    testWidgets('muestra CTA de crear y botón recargar', (tester) async {
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

      expect(find.text('No hay ubicaciones registradas'), findsOneWidget);
      expect(find.text('Crear ubicación'), findsOneWidget);
      expect(find.text('Recargar'), findsOneWidget);

      await tester.tap(find.text('Crear ubicación'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
