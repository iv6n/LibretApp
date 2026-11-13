import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/widgets/app_form_scaffold.dart';
import 'package:libretapp/core/widgets/record_form_style.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/app_theme.dart';

void main() {
  for (final width in [320.0, 390.0, 600.0, 1200.0]) {
    testWidgets('footer remains above keyboard at $width dp and text 200%', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _app(
          keyboard: 260,
          textScale: 2,
          child: AppFormScaffold(
            title: 'Registrar peso',
            saving: false,
            onSave: () {},
            onCancel: () {},
            saveLabel: 'Guardar peso',
            fields: [
              for (var i = 0; i < 16; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    key: ValueKey('field-$i'),
                    decoration: InputDecoration(labelText: 'Campo $i'),
                  ),
                ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final footer = find.byKey(const ValueKey('form-action-footer'));
      final save = find.widgetWithText(FilledButton, 'Guardar peso');
      final initialTop = tester.getTopLeft(footer).dy;
      expect(save.hitTestable(), findsOneWidget);
      expect(tester.getRect(footer).bottom, lessThanOrEqualTo(640));
      expect(tester.getSize(save).height, greaterThanOrEqualTo(48));
      expect(
        tester.getSize(find.widgetWithText(TextButton, 'Cancelar')).height,
        greaterThanOrEqualTo(48),
      );

      final lastField = find.byKey(const ValueKey('field-15'));
      await tester.ensureVisible(lastField);
      await tester.pumpAndSettle();
      expect(
        lastField.hitTestable(),
        findsOneWidget,
        reason:
            'field=${tester.getRect(lastField)}, footer=${tester.getRect(footer)}, scroll=${tester.getRect(find.byType(SingleChildScrollView))}',
      );
      expect(tester.getRect(lastField).bottom, lessThanOrEqualTo(initialTop));
      expect(tester.getTopLeft(footer).dy, initialTop);
      expect(save.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('footer saves once through the same form and names its context', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final formKey = GlobalKey<FormState>();
    var saves = 0;
    await tester.pumpWidget(
      _app(
        child: AppFormScaffold(
          title: 'Registrar peso',
          recordStyle: RecordFormStyle.weight,
          contextLabel: 'Nancy',
          saving: false,
          formKey: formKey,
          saveKey: const ValueKey('save-weight'),
          onSave: () {
            if (formKey.currentState!.validate()) saves++;
          },
          saveLabel: 'Guardar',
          fields: [
            TextFormField(
              key: const ValueKey('weight'),
              validator: (value) => value == '451' ? null : 'Peso requerido',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final save = find.byKey(const ValueKey('save-weight'));
    expect(find.widgetWithText(FilledButton, 'Guardar'), findsOneWidget);
    final data = tester.getSemantics(save).getSemanticsData();
    expect(data.label, contains('Guardar peso: Nancy'));
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(saves, 0);
    expect(find.text('Peso requerido'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('weight')), '451');
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(saves, 1);
    semantics.dispose();
  });

  testWidgets('loading and error states do not expose save or cancel', (
    tester,
  ) async {
    for (final loading in [true, false]) {
      await tester.pumpWidget(
        _app(
          child: AppFormScaffold(
            title: 'Registrar peso',
            saving: false,
            loading: loading,
            errorMessage: loading ? null : 'No se pudo cargar',
            onRetry: () {},
            onSave: () {},
            onCancel: () {},
            saveLabel: 'Guardar peso',
            fields: const [Text('Campos')],
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const ValueKey('form-action-footer')), findsNothing);
      expect(find.text('Guardar peso'), findsNothing);
      expect(find.text('Cancelar'), findsNothing);
      if (!loading) expect(find.text('Reintentar'), findsOneWidget);
    }
  });

  testWidgets('footer cancel respects unsaved capture confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        child: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => AppFormScaffold(
                    title: 'Formulario',
                    saving: false,
                    protectUnsavedChanges: true,
                    onSave: () {},
                    saveLabel: 'Guardar',
                    fields: [TextFormField(key: const ValueKey('capture'))],
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
    await tester.enterText(find.byKey(const ValueKey('capture')), 'Capturado');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('¿Descartar los cambios?'), findsOneWidget);
    await tester.tap(find.text('Seguir capturando'));
    await tester.pumpAndSettle();
    expect(find.text('Capturado'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salir sin guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Abrir'), findsOneWidget);
  });
}

Widget _app({
  required Widget child,
  double keyboard = 0,
  double textScale = 1,
}) => MaterialApp(
  theme: AppTheme.lightTheme,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('es'),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      viewInsets: EdgeInsets.only(bottom: keyboard),
      textScaler: TextScaler.linear(textScale),
    ),
    child: child!,
  ),
  home: child,
);
