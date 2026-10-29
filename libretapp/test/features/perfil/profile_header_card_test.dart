import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/widgets/profile_header_card.dart';
import 'package:libretapp/theme/app_theme.dart';

void main() {
  testWidgets('el perfil vacío ofrece añadir datos opcionales', (tester) async {
    var opened = false;
    const empty = Perfil(
      id: 'local',
      nombre: '',
      apellido: '',
      email: '',
      telefono: '',
      finca: '',
      direccion: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ProfileHeaderCard(
            perfil: empty,
            onEditTap: () => opened = true,
          ),
        ),
      ),
    );

    expect(find.text('Mi perfil'), findsOneWidget);
    expect(find.text('Ganado y campo'), findsOneWidget);
    expect(find.text('Sin nombre'), findsNothing);
    await tester.tap(find.text('Añadir datos opcionales'));
    expect(opened, isTrue);
  });

  testWidgets(
    'un correo sin nombre ni UPP permite editar sin pedir completar',
    (tester) async {
      const profile = Perfil(
        id: 'local',
        nombre: '',
        apellido: '',
        email: 'ana@example.com',
        telefono: '',
        finca: '',
        direccion: '',
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: ProfileHeaderCard(perfil: profile, onEditTap: _noop),
          ),
        ),
      );
      expect(find.text('Mi perfil'), findsOneWidget);
      expect(find.text('Editar perfil'), findsOneWidget);
      expect(find.text('Añadir datos opcionales'), findsNothing);
      expect(find.textContaining('Completar'), findsNothing);
    },
  );

  testWidgets('la acción de editar perfil sigue visible con texto ampliado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    const profile = Perfil(
      id: 'local',
      nombre: 'Ana',
      apellido: 'Pérez',
      email: '',
      telefono: '',
      finca: 'El Rancho',
      direccion: '',
      upp: '1234',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const Scaffold(
          body: ProfileHeaderCard(perfil: profile, onEditTap: _noop),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Editar perfil'), findsOneWidget);
  });
}

void _noop() {}
