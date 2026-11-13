import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/widgets/app_form_fields.dart';

void main() {
  testWidgets('required text field exposes its label to accessibility', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppTextField(labelText: 'Título', requiredField: true)),
      ),
    );
    expect(find.bySemanticsLabel('Título *'), findsOneWidget);
    handle.dispose();
  });
}
