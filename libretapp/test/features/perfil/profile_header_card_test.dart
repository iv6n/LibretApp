import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          body: SingleChildScrollView(
            child: ProfileHeaderCard(perfil: profile, onEditTap: _noop),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Editar perfil'), findsOneWidget);
  });

  testWidgets('un toque en UPP copia el valor completo', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    const profile = Perfil(
      id: 'local',
      nombre: '',
      apellido: '',
      email: '',
      telefono: '',
      finca: '',
      direccion: '',
      upp: '001234-MX',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: ProfileHeaderCard(perfil: profile)),
      ),
    );

    await tester.tap(find.text('001234-MX'));
    await tester.pump();
    expect(copied, '001234-MX');
    expect(find.text('UPP copiado'), findsOneWidget);
  });

  testWidgets('solo muestra los datos seleccionados y con valor', (
    tester,
  ) async {
    const profile = Perfil(
      id: 'local',
      nombre: '',
      apellido: '',
      email: 'ana@example.com',
      telefono: '5551234567',
      finca: '',
      direccion: 'Calle 1',
      upp: '001234-MX',
      showUpp: false,
      showEmail: false,
      showDireccion: true,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: ProfileHeaderCard(perfil: profile)),
      ),
    );
    expect(find.text('001234-MX'), findsNothing);
    expect(find.text('ana@example.com'), findsNothing);
    expect(find.text('5551234567'), findsOneWidget);
    expect(find.text('Calle 1'), findsOneWidget);
  });
}

void _noop() {}
