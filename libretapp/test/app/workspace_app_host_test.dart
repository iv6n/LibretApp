import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/app/workspace_app_host.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/security/ports/phone_auth_port.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp;
  late WorkspaceManager manager;
  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('libretapp/lite_reminders'),
          (_) async => null,
        );
    temp = await Directory.systemTemp.createTemp('libretapp_workspace_host_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => temp.path,
        );
    SharedPreferences.setMockInitialValues({});
    final registry = WorkspaceRegistry(
      SharedPrefsService(await SharedPreferences.getInstance()),
    );
    await registry.load();
    manager = WorkspaceManager(
      registry: registry,
      auth: const UnavailablePhoneAuth(),
    );
    await setupLocator(workspace: registry.guest);
    locator.registerSingleton<WorkspaceManager>(manager);
  });
  tearDown(() async {
    await disposeLocator();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('libretapp/lite_reminders'),
          null,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  testWidgets('router and blocs are rebuilt on account changes and logout', (
    tester,
  ) async {
    await tester.runAsync(
      () => tester.pumpWidget(
        WorkspaceAppHost(
          manager: manager,
          initialLocation: AppRoutes.onboarding,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Todo lo que cuidas,\nen un lugar.'), findsOneWidget);
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(
        await workspaceHasUserData(),
        isFalse,
        reason:
            'Technical startup defaults must not skip a resumed introduction.',
      );
    });
    Future<void> transition(Future<void> Function() operation) async {
      await tester.runAsync(() async {
        var completed = false;
        Object? failure;
        unawaited(
          operation().then<void>(
            (_) {
              completed = true;
            },
            onError: (Object error) {
              failure = error;
              completed = true;
            },
          ),
        );
        for (var frame = 0; frame < 200 && !completed; frame++) {
          await tester.pump(const Duration(milliseconds: 20));
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
        expect(
          completed,
          isTrue,
          reason:
              'The workspace transition must finish without keeping an old router alive.',
        );
        if (failure != null) throw failure!;
      });
      await tester.runAsync(() async {
        for (var frame = 0; frame < 40; frame++) {
          await tester.pump(const Duration(milliseconds: 25));
          await Future<void>.delayed(const Duration(milliseconds: 25));
        }
      });
    }

    await transition(
      () => manager.openAccount(
        const VerifiedPhoneIdentity(
          userId: 'test-account',
          phone: '+525555123456',
        ),
      ),
    );
    expect(find.text('¿Qué vas a registrar?'), findsNothing);
    expect(find.text('Un toque personal'), findsNothing);
    expect(find.text('Empezar sin cuenta'), findsNothing);
    expect(manager.current!.kind, WorkspaceKind.account);
    await transition(manager.signOut);
    expect(find.text('Empezar sin cuenta'), findsOneWidget);
    expect(find.text('Crear cuenta con teléfono'), findsNothing);
    expect(manager.current, isNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
