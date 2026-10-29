import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/security/ports/phone_auth_port.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';
import 'package:libretapp/features/onboarding/phone_auth_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Auth implements PhoneAuthPort {
  @override
  bool available = true;
  bool fail = false;
  int requests = 0;
  int verifications = 0;
  String? requestedPhone;
  @override
  Future<void> requestCode(
    String phone, {
    PhoneAccessIntent intent = PhoneAccessIntent.createAccount,
  }) async {
    requests++;
    requestedPhone = phone;
  }

  @override
  Future<VerifiedPhoneIdentity> verifyCode(String phone, String code) async {
    verifications++;
    if (fail)
      throw const PhoneAuthFailure('El código es incorrecto o ya venció.');
    return VerifiedPhoneIdentity(userId: 'verified', phone: phone);
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Auth auth;
  late WorkspaceManager manager;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final registry = WorkspaceRegistry(
      SharedPrefsService(await SharedPreferences.getInstance()),
    );
    await registry.load();
    auth = _Auth();
    manager = WorkspaceManager(registry: registry, auth: auth)
      ..opener = (_, {required enterApp}) async {};
  });
  Future<void> request(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PhoneAuthSheet(manager: manager)),
      ),
    );
    await tester.enterText(find.byType(TextField).first, '55 5512 3456');
    await tester.ensureVisible(find.text('Enviar código por SMS'));
    await tester.tap(find.text('Enviar código por SMS'));
    await tester.pumpAndSettle();
  }

  testWidgets('request and resend wait do not create or link a local account', (
    tester,
  ) async {
    await request(tester);
    expect(auth.requestedPhone, '+525555123456');
    expect(manager.registry.active, isNull);
    expect(find.text('Reenviar en 60 s'), findsOneWidget);
    await tester.ensureVisible(find.text('Reenviar en 60 s'));
    await tester.tap(find.text('Reenviar en 60 s'));
    expect(auth.requests, 1);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('wrong code keeps guest data and ownership intact', (
    tester,
  ) async {
    await manager.openGuest();
    final guestId = manager.current!.id;
    auth.fail = true;
    await request(tester);
    await tester.enterText(find.byType(TextField), '000000');
    await tester.ensureVisible(find.text('Verificar y entrar'));
    await tester.tap(find.text('Verificar y entrar'));
    await tester.pumpAndSettle();
    expect(find.text('El código es incorrecto o ya venció.'), findsOneWidget);
    expect(manager.current!.id, guestId);
    expect(manager.current!.kind, WorkspaceKind.guest);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('unavailable account leaves guest and demo usable elsewhere', (
    tester,
  ) async {
    auth.available = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PhoneAuthSheet(manager: manager)),
      ),
    );
    expect(find.textContaining('todavía no está disponible'), findsOneWidget);
    expect(find.text('Enviar código por SMS'), findsNothing);
    expect(auth.requests, 0);
    expect(manager.registry.active, isNull);
  });
}
