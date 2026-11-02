import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/perfil/bloc/perfil_bloc.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/view/perfil_settings_sheet.dart';
import 'package:libretapp/theme/app_theme.dart';

import '../../support/profile_onboarding_fakes.dart';

void main() {
  testWidgets('la elección de datos visibles se guarda sin borrar valores', (
    tester,
  ) async {
    final repository = MemoryProfileRepository();
    repository.value = repository.value.copyWith(
      upp: '001234-MX',
      email: 'ana@example.com',
      direccion: 'Calle 1',
    );
    final bloc = PerfilBloc(repository);
    addTearDown(bloc.close);
    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showPerfilEditor(context, repository.value),
                child: const Text('Abrir editor'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir editor'));
    await tester.pumpAndSettle();
    final uppSwitch = find.widgetWithText(SwitchListTile, 'UPP');
    await tester.ensureVisible(uppSwitch);
    await tester.tap(uppSwitch);
    final addressSwitch = find.widgetWithText(SwitchListTile, 'Dirección');
    await tester.ensureVisible(addressSwitch);
    await tester.tap(addressSwitch);
    await tester.ensureVisible(find.text('Guardar'));
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(repository.value.upp, '001234-MX');
    expect(repository.value.email, 'ana@example.com');
    expect(repository.value.showUpp, isFalse);
    expect(repository.value.showEmail, isTrue);
    expect(repository.value.showDireccion, isTrue);
    expect(Perfil.fromJson(repository.value.toJson()).showUpp, isFalse);
    expect(Perfil.fromJson(repository.value.toJson()).showDireccion, isTrue);
  });

  for (final field in [null, 'Teléfono', 'UPP']) {
    testWidgets(
      'el editor guarda ${field ?? 'todo vacío'} sin nombre ni apellido',
      (tester) async {
        final repository = MemoryProfileRepository();
        final bloc = PerfilBloc(repository);
        addTearDown(bloc.close);
        await tester.pumpWidget(
          BlocProvider.value(
            value: bloc,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () =>
                        showPerfilEditor(context, repository.value),
                    child: const Text('Abrir editor'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Abrir editor'));
        await tester.pumpAndSettle();
        final value = field == 'UPP' ? ' 001234-MX ' : ' +52 55-1234-5678 ';
        if (field != null) {
          final input = find.widgetWithText(TextFormField, field);
          await tester.ensureVisible(input);
          await tester.enterText(input, value);
        }
        await tester.ensureVisible(find.text('Guardar'));
        await tester.tap(find.text('Guardar'));
        await tester.pumpAndSettle();
        expect(repository.saveCalls, 1);
        expect(repository.value.nombre, isEmpty);
        expect(repository.value.apellido, isEmpty);
        if (field == 'UPP') {
          expect(repository.value.upp, value.trim());
        }
        if (field == 'Teléfono') {
          expect(repository.value.telefono, value.trim());
        }
        expect(find.text('Editar perfil'), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
