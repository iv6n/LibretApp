import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libretapp/core/experience/registration_preferences.dart';
import 'package:libretapp/core/onboarding/profile_onboarding_service.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:libretapp/features/onboarding/profile_onboarding_page.dart';
import 'package:libretapp/theme/app_theme.dart';

import '../test/support/profile_onboarding_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final config =
        jsonDecode(await File('.dart_tool/package_config.json').readAsString())
            as Map;
    final flutter = (config['packages'] as List).cast<Map>().firstWhere(
      (package) => package['name'] == 'flutter',
    );
    final sdk = Directory.fromUri(
      Uri.parse(flutter['rootUri'] as String),
    ).parent.parent;
    for (final font in [
      (family: 'Roboto', name: 'roboto-regular.ttf'),
      (family: 'MaterialIcons', name: 'materialicons-regular.otf'),
    ]) {
      await (FontLoader(font.family)..addFont(
            File(
              '${sdk.path}/bin/cache/artifacts/material_fonts/${font.name}',
            ).readAsBytes().then(ByteData.sublistView),
          ))
          .load();
    }
  });

  testWidgets('previews del perfil opcional en tamaño OPPO', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 36, bottom: 32);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    // This tool runs under flutter test to render the real widgets.
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
    final prefs = SharedPrefsService(await SharedPreferences.getInstance());

    for (final dark in [false, true]) {
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: ProfileOnboardingPage(
              key: ValueKey('unified-$dark'),
              service: ProfileOnboardingService(
                workspace: const LocalWorkspace(
                  id: 'preview',
                  kind: WorkspaceKind.guest,
                ),
                preferences: prefs,
                repository: MemoryProfileRepository(),
              ),
              registrationPreferences: RegistrationPreferences.defaults,
              onFinished: () {},
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => precacheImage(
          const AssetImage('assets/images/record_care.webp'),
          key.currentContext!,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Ahora no').hitTestable(), findsOneWidget);

      Future<void> capture(String suffix) async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final folder = Directory('artifacts/onboarding-profile');
          await folder.create(recursive: true);
          await File(
            '${folder.path}/unificada${dark ? '-oscuro' : ''}$suffix.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capture('');
      await tester.ensureVisible(find.text('Añadir datos del rancho'));
      await tester.tap(find.text('Añadir datos del rancho'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('profile-upp')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await capture('-rancho');
    }
  });
}
