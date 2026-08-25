import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/agenda/widgets/agenda_style.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('assetForTipo', () {
    test('resolves the approved task assets', () {
      expect(assetForTipo('Ordeña'), 'assets/images/task_milking.webp');
      expect(
        assetForTipo('Baño garrapaticida'),
        'assets/images/task_tick_bath.webp',
      );
      expect(
        assetForTipo('Suplemento/Vitaminas'),
        'assets/images/task_vitamins.webp',
      );
      expect(
        assetForTipo('Revisión de casco'),
        'assets/images/task_hoof_check.webp',
      );
      expect(
        assetForTipo('Chequeo reproductivo'),
        'assets/images/task_reproductive_check.webp',
      );
      expect(
        assetForTipo('Fertilización'),
        'assets/images/task_fertilization.webp',
      );
      expect(assetForTipo('Fumigación'), 'assets/images/task_fumigation.webp');
      expect(assetForTipo('Cosecha'), 'assets/images/task_harvest.webp');
      expect(
        assetForTipo('Desparasitación'),
        'assets/images/task_deworming.webp',
      );
      expect(
        assetForTipo('Vacunación anual'),
        'assets/images/task_annual_vaccination.webp',
      );
      expect(
        assetForTipo('Vacunación'),
        'assets/images/task_annual_vaccination.webp',
      );
      expect(assetForTipo('Pesaje'), 'assets/images/health_weight.webp');
      expect(
        assetForTipo('Revisión veterinaria'),
        'assets/images/health_diagnosis.webp',
      );
      expect(assetForTipo('Sanidad'), 'assets/images/health_diagnosis.webp');
      expect(assetForTipo('Sanitario'), 'assets/images/health_diagnosis.webp');
      expect(assetForTipo('Parto'), 'assets/images/health_birth.webp');
      expect(
        assetForTipo('Gestación'),
        'assets/images/health_reproduction.webp',
      );
      expect(
        assetForTipo('Inseminación'),
        'assets/images/health_reproduction.webp',
      );
      expect(
        assetForTipo('Movimiento de lote'),
        'assets/images/record_movement.webp',
      );
      expect(assetForTipo('Comercial'), 'assets/images/record_sale.webp');
      expect(assetForTipo('Cultivo'), 'assets/images/crop_field.webp');
      expect(
        assetForTipo('Mantenimiento'),
        'assets/images/inventory_tool.webp',
      );
      expect(
        assetForTipo('Suplemento / Vitaminas'),
        'assets/images/task_vitamins.webp',
      );
      expect(assetForTipo('Riego'), isNull);
      expect(assetForTipo('Administrativo'), isNull);
    });
  });

  group('assetForEstado', () {
    test('resolves operational and connectivity status assets', () {
      expect(assetForEstado('pendiente'), 'assets/images/status_pending.webp');
      expect(
        assetForEstado('completado'),
        'assets/images/status_completed.webp',
      );
      expect(assetForEstado('vencido'), 'assets/images/status_overdue.webp');
      expect(
        assetForEstado('en_progreso'),
        'assets/images/status_in_progress.webp',
      );
      expect(assetForEstado('cancelado'), 'assets/images/status_canceled.webp');
      expect(assetForEstado('crítico'), 'assets/images/status_critical.webp');
      expect(
        assetForEstado('en cuarentena'),
        'assets/images/status_quarantine.webp',
      );
      expect(
        assetForEstado('sincronizado'),
        'assets/images/status_synced.webp',
      );
      expect(
        assetForEstado('sin conexión'),
        'assets/images/status_offline.webp',
      );
      expect(assetForEstado('borrador'), isNull);
    });
  });

  test('all mapped assets are bundled', () async {
    const assets = [
      'assets/images/task_milking.webp',
      'assets/images/task_tick_bath.webp',
      'assets/images/task_vitamins.webp',
      'assets/images/task_hoof_check.webp',
      'assets/images/task_reproductive_check.webp',
      'assets/images/task_fertilization.webp',
      'assets/images/task_fumigation.webp',
      'assets/images/task_harvest.webp',
      'assets/images/task_deworming.webp',
      'assets/images/task_annual_vaccination.webp',
      'assets/images/health_weight.webp',
      'assets/images/health_diagnosis.webp',
      'assets/images/health_birth.webp',
      'assets/images/health_reproduction.webp',
      'assets/images/record_movement.webp',
      'assets/images/record_sale.webp',
      'assets/images/crop_field.webp',
      'assets/images/inventory_tool.webp',
      'assets/images/status_pending.webp',
      'assets/images/status_completed.webp',
      'assets/images/status_overdue.webp',
      'assets/images/status_in_progress.webp',
      'assets/images/status_canceled.webp',
      'assets/images/status_critical.webp',
      'assets/images/status_quarantine.webp',
      'assets/images/status_synced.webp',
      'assets/images/status_offline.webp',
    ];

    for (final asset in assets) {
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(0), reason: asset);
    }
  });

  testWidgets('falls back to Material icon when the asset is missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AgendaAssetIcon(
            assetPath: 'assets/images/missing_agenda_asset.png',
            fallbackIcon: Icons.event_note,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.event_note), findsOneWidget);
  });
}
