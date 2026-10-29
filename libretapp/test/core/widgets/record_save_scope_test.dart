import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/widgets/record_save_scope.dart';

void main() {
  testWidgets('failure keeps input, retry commits once and only then closes', (
    tester,
  ) async {
    final controller = TextEditingController();
    var calls = 0;
    var committed = false;
    final gate = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<String>(
                  builder: (_) => Scaffold(
                    body: RecordSaveScope(
                      onSave: (value) async {
                        calls++;
                        if (calls == 1) throw StateError('disk');
                        await gate.future;
                        committed = true;
                      },
                      child: Builder(
                        builder: (context) => Column(
                          children: [
                            TextField(controller: controller),
                            FilledButton(
                              onPressed: () =>
                                  submitRecordForm(context, controller.text),
                              child: const Text('Guardar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Notas conservadas');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tus datos siguen aquí'), findsOneWidget);
    expect(controller.text, 'Notas conservadas');
    await tester.tap(find.text('Guardar'));
    await tester.pump();
    await tester.tap(find.text('Guardar'), warnIfMissed: false);
    await tester.pump();
    expect(calls, 2);
    expect(committed, isFalse);
    gate.complete();
    await tester.pumpAndSettle();
    expect(committed, isTrue);
    expect(find.byType(TextField), findsNothing);
    controller.dispose();
  });
}
