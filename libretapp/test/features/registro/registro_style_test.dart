import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/widgets/generated_asset_title.dart';
import 'package:libretapp/features/registro/widgets/registro_style.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('maps Registro menu actions to approved assets', () {
    expect(
      assetForRegistroAction('Parición'),
      'assets/images/health_birth.webp',
    );
    expect(
      assetForRegistroAction('Tratar lote'),
      'assets/images/health_treatment.webp',
    );
    expect(
      assetForRegistroAction('Sanitario'),
      'assets/images/health_vaccine.webp',
    );
    expect(assetForRegistroAction('Peso'), 'assets/images/health_weight.webp');
    expect(assetForRegistroAction('Costo'), 'assets/images/record_cost.webp');
    expect(
      assetForRegistroAction('Cambio de ubicación'),
      'assets/images/record_movement.webp',
    );
    expect(
      assetForRegistroAction('Producción'),
      'assets/images/record_production.webp',
    );
    expect(
      assetForRegistroAction('Ordeña'),
      'assets/images/health_milk_production.webp',
    );
    expect(
      assetForRegistroAction('Reproducción'),
      'assets/images/record_reproduction.webp',
    );
    expect(
      assetForRegistroAction('Comercial'),
      'assets/images/record_sale.webp',
    );
    expect(assetForRegistroAction('Cultivo'), 'assets/images/crop_field.webp');
    expect(
      assetForRegistroAction('Cosecha'),
      'assets/images/crop_harvested.webp',
    );
  });

  test('keeps Material fallback for actions without a specific asset', () {
    expect(assetForRegistroAction('Animal'), isNull);
    expect(assetForRegistroAction('Riego'), isNull);
    expect(assetForRegistroAction('Salud de cultivo'), isNull);
    expect(assetForRegistroAction('Tarea'), isNull);
  });

  test('bundles every asset used by Registro cards', () async {
    const assets = [
      'assets/images/health_birth.webp',
      'assets/images/health_treatment.webp',
      'assets/images/health_vaccine.webp',
      'assets/images/health_weight.webp',
      'assets/images/record_cost.webp',
      'assets/images/record_movement.webp',
      'assets/images/record_production.webp',
      'assets/images/health_milk_production.webp',
      'assets/images/record_reproduction.webp',
      'assets/images/record_sale.webp',
      'assets/images/crop_field.webp',
      'assets/images/crop_harvested.webp',
    ];

    for (final asset in assets) {
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(0), reason: asset);
    }
  });

  testWidgets('GeneratedAssetTitle falls back when assetPath is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const GeneratedAssetTitle(
              title: 'Registro',
              assetPath: null,
              fallbackIcon: Icons.event_note,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.event_note), findsOneWidget);
  });
}
