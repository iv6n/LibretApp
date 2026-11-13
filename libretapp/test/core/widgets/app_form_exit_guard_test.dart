import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/widgets/app_form_exit_guard.dart';

void main() {
  testWidgets('clean form exits without confirmation', (tester) async {
    await _pumpLanding(tester);
    await _openForm(tester);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('¿Descartar los cambios?'), findsNothing);
    expect(find.text('Inicio'), findsOneWidget);
  });

  testWidgets('restoring the initial values exits without confirmation', (
    tester,
  ) async {
    await _pumpLanding(tester);
    await _openForm(tester);
    await tester.enterText(find.byKey(const ValueKey('capture')), 'cambiado');
    await tester.enterText(find.byKey(const ValueKey('capture')), 'original');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('¿Descartar los cambios?'), findsNothing);
    expect(find.text('Inicio'), findsOneWidget);
  });

  testWidgets('dirty form can cancel exit and keep captured text', (
    tester,
  ) async {
    await _pumpLanding(tester);
    await _openForm(tester);
    await tester.enterText(find.byKey(const ValueKey('capture')), 'capturado');
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('¿Descartar los cambios?'), findsOneWidget);
    await tester.tap(find.text('Seguir capturando'));
    await tester.pumpAndSettle();

    expect(find.text('Formulario'), findsOneWidget);
    expect(find.text('capturado'), findsOneWidget);
    expect(find.text('Inicio'), findsNothing);
  });

  testWidgets('dirty form exits only after discard is confirmed', (
    tester,
  ) async {
    await _pumpLanding(tester);
    await _openForm(tester);
    await tester.enterText(find.byKey(const ValueKey('capture')), 'capturado');
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('¿Descartar los cambios?'), findsOneWidget);
    await tester.tap(find.text('Salir sin guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Formulario'), findsNothing);
  });

  testWidgets(
    'saving blocks back and successful completion returns its result',
    (tester) async {
      await _pumpLanding(tester);
      await _openForm(tester, saving: true);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Formulario'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('complete')));
      await tester.pumpAndSettle();
      expect(find.text('resultado guardado'), findsOneWidget);
    },
  );
}

Future<void> _pumpLanding(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: _LandingPage()));
}

Future<void> _openForm(WidgetTester tester, {bool saving = false}) async {
  await tester.tap(find.text(saving ? 'Abrir guardando' : 'Abrir formulario'));
  await tester.pumpAndSettle();
}

class _LandingPage extends StatefulWidget {
  const _LandingPage();

  @override
  State<_LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<_LandingPage> {
  String? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Inicio'),
            if (_result != null) Text(_result!),
            TextButton(
              onPressed: () async {
                final result = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => const _GuardedPage(saving: false),
                  ),
                );
                if (mounted) setState(() => _result = result);
              },
              child: const Text('Abrir formulario'),
            ),
            TextButton(
              onPressed: () async {
                final result = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => const _GuardedPage(saving: true),
                  ),
                );
                if (mounted) setState(() => _result = result);
              },
              child: const Text('Abrir guardando'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuardedPage extends StatelessWidget {
  const _GuardedPage({required this.saving});

  final bool saving;

  @override
  Widget build(BuildContext context) {
    return AppFormExitGuard(
      enabled: true,
      saving: saving,
      child: Scaffold(
        appBar: AppBar(title: const Text('Formulario')),
        body: Form(
          onChanged: () => AppFormExitGuard.refreshFromForm(context),
          child: Column(
            children: [
              TextFormField(
                key: const ValueKey('capture'),
                initialValue: 'original',
              ),
              TextButton(
                key: const ValueKey('complete'),
                onPressed: () =>
                    AppFormExitGuard.complete(context, 'resultado guardado'),
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
