import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/widgets/agenda_form_sheet.dart';

void main() {
  testWidgets('la tarea nueva exige tipo y se guarda sin hora', (tester) async {
    AgendaEntry? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgendaEntryForm(
            initialDate: DateTime(2026, 10, 29),
            onSave: (entry) => saved = entry,
          ),
        ),
      ),
    );

    expect(find.text('Sin hora · Añadir hora'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('agenda-task-title')),
      'Revisar cerca',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('agenda-task-save')));
    await tester.tap(find.byKey(const ValueKey('agenda-task-save')));
    await tester.pump();
    expect(saved, isNull);
    expect(find.text('Selecciona un tipo de tarea'), findsOneWidget);

    final typeField = find.byType(DropdownButtonFormField<String>).first;
    await tester.ensureVisible(typeField);
    await tester.tap(typeField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recordatorio').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('agenda-task-save')));
    await tester.tap(find.byKey(const ValueKey('agenda-task-save')));
    await tester.pump();
    expect(saved?.tipo, 'Recordatorio');
    expect(saved?.hasExplicitTime, isFalse);
    expect(saved?.fecha.hour, 0);
    expect(saved?.remindAt, isNull);
  });
}
