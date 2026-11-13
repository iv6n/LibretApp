import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/bloc/directorio_state.dart';
import 'package:libretapp/features/directorio/view/directorio_view.dart';

void main() {
  testWidgets('animal view toggles directly from the app bar', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _ViewModeHost()));

    expect(
      find.byKey(const Key('directorio-animal-view-toggle')),
      findsOneWidget,
    );
    expect(find.text('Vista de animales'), findsNothing);
    expect(find.text('Tarjetas'), findsNothing);
    expect(find.text('Lista compacta'), findsNothing);

    await tester.tap(find.byKey(const Key('directorio-animal-view-toggle')));
    await tester.pumpAndSettle();

    final host = tester.state<_ViewModeHostState>(find.byType(_ViewModeHost));
    expect(host.mode, AnimalDirectoryViewMode.compact);
    expect(find.byTooltip('Cambiar a tarjetas'), findsOneWidget);

    await tester.tap(find.byKey(const Key('directorio-animal-view-toggle')));
    await tester.pumpAndSettle();
    expect(host.mode, AnimalDirectoryViewMode.cards);
    expect(tester.takeException(), isNull);
  });
}

class _ViewModeHost extends StatefulWidget {
  const _ViewModeHost();

  @override
  State<_ViewModeHost> createState() => _ViewModeHostState();
}

class _ViewModeHostState extends State<_ViewModeHost> {
  AnimalDirectoryViewMode mode = AnimalDirectoryViewMode.cards;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          AnimalDirectoryViewToggleButton(
            viewMode: mode,
            onChanged: (value) => setState(() => mode = value),
          ),
        ],
      ),
    );
  }
}
