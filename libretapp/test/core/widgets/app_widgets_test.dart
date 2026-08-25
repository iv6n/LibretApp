import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/theme/theme.dart';

Widget _testApp({required Widget child, ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? AppTheme.lightTheme,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('AppButton exposes primary action and loading state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        child: const AppButton(
          label: 'Guardar',
          icon: Icons.save_outlined,
          isLoading: true,
          loadingLabel: 'Guardando...',
        ),
      ),
    );

    expect(find.text('Guardando...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byTooltip('Guardar'), findsNothing);
  });

  testWidgets('AppIconButton has a tooltip and accessible target', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        child: AppIconButton(
          icon: Icons.search,
          tooltip: 'Buscar',
          onPressed: () {},
        ),
      ),
    );

    expect(find.byTooltip('Buscar'), findsOneWidget);
    expect(tester.getSize(find.byType(AppIconButton)), const Size(48, 48));
  });

  testWidgets('AppTextField renders the shared decoration and validation', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      _testApp(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              AppTextField(
                labelText: 'Nombre',
                requiredField: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              FilledButton(
                onPressed: () => formKey.currentState!.validate(),
                child: const Text('Validar'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Nombre *'), findsOneWidget);
    await tester.tap(find.text('Validar'));
    await tester.pump();
    expect(find.text('Campo requerido'), findsOneWidget);
  });

  testWidgets('AppSelectField supports light and dark themes', (tester) async {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      await tester.pumpWidget(
        _testApp(
          theme: theme,
          child: AppSelectField<String>(
            value: 'cattle',
            items: const ['cattle', 'equine'],
            itemLabel: (value) => value == 'cattle' ? 'Bovino' : 'Equino',
            labelText: 'Especie',
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Bovino'), findsOneWidget);
      expect(find.text('Especie'), findsOneWidget);
    }
  });
}
