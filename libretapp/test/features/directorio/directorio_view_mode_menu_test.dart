import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/bloc/directorio_state.dart';
import 'package:libretapp/features/directorio/view/directorio_view.dart';

void main() {
  testWidgets('animal view menu changes and marks the selected mode', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _ViewModeMenuHost()));

    await tester.tap(find.byKey(const Key('open_animal_view_menu')));
    await tester.pumpAndSettle();

    expect(find.text('Vista de animales'), findsOneWidget);
    expect(find.text('Tarjetas'), findsOneWidget);
    expect(find.text('Lista compacta'), findsOneWidget);

    await tester.tap(find.byKey(const Key('animal_view_mode_compact')));
    await tester.pumpAndSettle();

    final host = tester.state<_ViewModeMenuHostState>(
      find.byType(_ViewModeMenuHost),
    );
    expect(host.mode, AnimalDirectoryViewMode.compact);

    await tester.tap(find.byKey(const Key('open_animal_view_menu')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _ViewModeMenuHost extends StatefulWidget {
  const _ViewModeMenuHost();

  @override
  State<_ViewModeMenuHost> createState() => _ViewModeMenuHostState();
}

class _ViewModeMenuHostState extends State<_ViewModeMenuHost> {
  AnimalDirectoryViewMode mode = AnimalDirectoryViewMode.cards;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          MenuAnchor(
            menuChildren: [
              AnimalDirectoryViewMenuContent(
                viewMode: mode,
                onChanged: (value) => setState(() => mode = value),
              ),
            ],
            builder: (context, controller, child) => IconButton(
              key: const Key('open_animal_view_menu'),
              onPressed: controller.open,
              icon: const Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
    );
  }
}
