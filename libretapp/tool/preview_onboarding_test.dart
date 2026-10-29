import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/onboarding/onboarding_page.dart';
import 'package:libretapp/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final config =
        jsonDecode(await File('.dart_tool/package_config.json').readAsString())
            as Map;
    final flutter = (config['packages'] as List).cast<Map>().firstWhere(
      (p) => p['name'] == 'flutter',
    );
    final sdk = Directory.fromUri(
      Uri.parse(flutter['rootUri'] as String),
    ).parent.parent;
    final font = File(
      '${sdk.path}/bin/cache/artifacts/material_fonts/roboto-regular.ttf',
    );
    final loader = FontLoader(
      'Roboto',
    )..addFont(font.readAsBytes().then((bytes) => ByteData.sublistView(bytes)));
    await loader.load();
    final icons = File(
      '${sdk.path}/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    );
    await (FontLoader('MaterialIcons')..addFont(
          icons.readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
        ))
        .load();
  });
  testWidgets('renders Android sized first launch previews without layout errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    for (final preview in [
      (
        name: 'bienvenida-propuesta-implementada',
        page: 0,
        width: 390.0,
        height: 844.0,
      ),
      (
        name: 'vista-previa-propuesta-implementada',
        page: 1,
        width: 390.0,
        height: 844.0,
      ),
      (
        name: 'vista-previa-propuesta-oppo',
        page: 1,
        width: 360.0,
        height: 800.0,
      ),
    ]) {
      final oppo = preview.name.endsWith('-oppo');
      tester.view.physicalSize = Size(preview.width, preview.height);
      tester.view.padding = oppo
          ? const FakeViewPadding(top: 36, bottom: 32)
          : const FakeViewPadding(top: 26, bottom: 24);
      for (final dark in [false, true]) {
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundaryKey,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              home: OnboardingPage(
                key: ValueKey('${preview.name}-$dark'),
                initialPage: preview.page,
                onStartEmpty: () async {},
                onInstallDemo: (_) async {},
                onCreatePhone: () async {},
                onSignInPhone: () async {},
              ),
            ),
          ),
        );
        await tester.runAsync(
          () => Future.wait([
            for (final asset in [
              'onboarding_welcome_group.png',
              'vaca.webp',
              'onboarding_monstera_illustration.png',
            ])
              precacheImage(
                AssetImage('assets/images/$asset'),
                boundaryKey.currentContext!,
              ),
          ]).timeout(const Duration(seconds: 10)),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (oppo) {
          final note = find.text(
            'Tus registros se guardan aquí. Haz copias periódicas fuera del teléfono.',
          );
          expect(
            tester.getBottomRight(note).dy,
            lessThanOrEqualTo(768),
            reason:
                'El aviso debe caber por encima de la barra inferior sin desplazamiento.',
          );
        }
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary
              .toImage(pixelRatio: 1.5)
              .timeout(const Duration(seconds: 10));
          final bytes = await image
              .toByteData(format: ui.ImageByteFormat.png)
              .timeout(const Duration(seconds: 10));
          final dir = Directory('artifacts/onboarding');
          await dir.create(recursive: true);
          await File(
            '${dir.path}/${preview.name}${dark ? '-oscuro' : ''}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    }
    tester.view.resetPadding();
  });
}
