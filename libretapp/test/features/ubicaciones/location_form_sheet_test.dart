import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_form_sheet.dart';

void main() {
  testWidgets(
    'editing a location preserves its existing crop records',
    (tester) async {
      final crop = CropRecord(
        cropName: 'Maíz',
        plantingDate: DateTime(2026, 1, 1),
      );
      final original = LocationEntity(
        uuid: 'loc-1',
        name: 'Potrero norte',
        type: LocationType.pasture,
        surfaceArea: 10,
        capacity: 20,
        waterSource: 'Pozo',
        terrainType: 'Plano',
        crops: [crop],
      );

      LocationEntity? submitted;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationFormSheet(
              initial: original,
              onSubmit: (entity) => submitted = entity,
            ),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Guardar cambios'));
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      expect(submitted, isNotNull);
      expect(
        submitted!.crops.map((c) => c.uuid),
        equals([crop.uuid]),
        reason: 'editing a location must not silently drop its crop records',
      );
    },
  );
}
