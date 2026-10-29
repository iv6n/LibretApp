import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/app/widgets/workspace_demo_frame.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';

void main() {
  testWidgets('demo banner keeps the top safe area and compact exit action', (
    tester,
  ) async {
    final manager = _WorkspaceManagerStub();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            viewPadding: const EdgeInsets.only(top: 24, bottom: 24),
          ),
          child: child!,
        ),
        home: WorkspaceDemoFrame(
          manager: manager,
          child: const Scaffold(body: Text('Contenido')),
        ),
      ),
    );

    final row = tester.getRect(
      find.byKey(const ValueKey('workspace_demo_banner_row')),
    );
    expect(row.top, 24);
    expect(row.height, 40);
    expect(find.text('Modo demo · Datos ficticios'), findsOneWidget);

    await tester.tap(find.text('Salir de la demo'));
    await tester.pumpAndSettle();
    expect(manager.exitCalls, 1);
    expect(tester.takeException(), isNull);
  });
}

class _WorkspaceManagerStub implements WorkspaceManager {
  int exitCalls = 0;

  @override
  Future<void> exitDemo() async {
    exitCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
