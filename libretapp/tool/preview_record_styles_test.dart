// Run with: flutter test tool/preview_record_styles_test.dart
// Writes the shared record form preview to build/record_style_audit/.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/theme/app_theme.dart';

void main() {
  setUpAll(() async {
    final fontDirectory =
        Platform.environment['FLUTTER_FONT_DIR'] ??
        '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts';
    for (final font in [
      ('Roboto', 'roboto-regular.ttf'),
      ('MaterialIcons', 'materialicons-regular.otf'),
    ]) {
      final file = File('$fontDirectory/${font.$2}');
      final loader = FontLoader(font.$1)
        ..addFont(Future.value(ByteData.sublistView(await file.readAsBytes())));
      await loader.load();
    }
  });
  for (final dark in [false, true]) {
    testWidgets('preview record forms, dark=$dark', (tester) async {
      tester.view.physicalSize = const Size(1160, 840);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundaryKey = GlobalKey();
      final theme = dark ? AppTheme.darkTheme : AppTheme.lightTheme;
      final examples = [
        (style: RecordFormStyle.weight, field: 'Peso (kg)', value: '325.5'),
        (style: RecordFormStyle.health, field: 'Producto', value: ''),
        (
          style: RecordFormStyle.harvest,
          field: 'Rendimiento (kg)',
          value: '1500',
        ),
      ];
      await tester.pumpWidget(
        MaterialApp(
          theme: theme.copyWith(
            // Custom title styles need an explicit family in the test engine.
            appBarTheme: theme.appBarTheme.copyWith(
              titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
                fontFamily: 'Roboto',
              ),
            ),
          ),
          home: RepaintBoundary(
            key: boundaryKey,
            child: ColoredBox(
              color: dark ? DarkColors.surfaceAlt : LightColors.elevated,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < examples.length; i++) ...[
                      if (i > 0) const SizedBox(width: 16),
                      Expanded(
                        child: AppFormScaffold(
                          title:
                              'Registrar ${examples[i].style.label.toLowerCase()}',
                          recordStyle: examples[i].style,
                          contextLabel: i < 2
                              ? 'Arete 024 · Luna'
                              : 'Maíz · Parcela norte',
                          contextIcon: i < 2
                              ? Icons.pets_outlined
                              : Icons.grass,
                          saving: false,
                          onSave: () {},
                          onCancel: () {},
                          saveLabel: 'Guardar',
                          fields: [
                            AppTextField(
                              labelText: examples[i].field,
                              initialValue: examples[i].value,
                              requiredField: true,
                            ),
                            const SizedBox(height: 16),
                            AppDateField(
                              value: DateTime(2026, 10, 15),
                              labelText: 'Fecha',
                              onChanged: (_) {},
                            ),
                            const SizedBox(height: 16),
                            const AppTextField(
                              labelText: 'Notas (opcional)',
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        final context = tester.element(find.byType(AppFormScaffold).first);
        for (final example in examples) {
          await precacheImage(AssetImage(example.style.assetPath!), context);
        }
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final rendered = await boundary.toImage();
        final png = await rendered.toByteData(format: ui.ImageByteFormat.png);
        final directory = Directory('build/record_style_audit');
        await directory.create(recursive: true);
        await File(
          '${directory.path}/${dark ? 'dark' : 'light'}.png',
        ).writeAsBytes(png!.buffer.asUint8List());
        rendered.dispose();
      });
    });
  }
}
