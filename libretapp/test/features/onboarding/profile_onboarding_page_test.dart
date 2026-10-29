import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libretapp/core/experience/registration_preferences.dart';
import 'package:libretapp/core/onboarding/profile_onboarding_service.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:libretapp/features/onboarding/profile_onboarding_page.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/theme/app_theme.dart';
import '../../support/profile_onboarding_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MemoryProfileRepository repository;
  late SharedPrefsService preferences;
  late ProfileOnboardingService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = SharedPrefsService(
      await SharedPreferences.getInstance(),
      prefix: 'workspace.guest.',
    );
    repository = MemoryProfileRepository();
    service = ProfileOnboardingService(
      workspace: const LocalWorkspace(id: 'guest', kind: WorkspaceKind.guest),
      preferences: preferences,
      repository: repository,
    );
  });

  Future<void> pump(
    WidgetTester tester, {
    RegistrationPreferences? registrationPreferences,
    ThemeMode theme = ThemeMode.light,
    double scale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: theme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => ProfileOnboardingPage(
            service: service,
            registrationPreferences:
                registrationPreferences ?? RegistrationPreferences.defaults,
            onFinished: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: Text('Inicio listo')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester, String field, String value) async {
    final target = find.byKey(ValueKey('profile-$field'));
    await tester.ensureVisible(target);
    await tester.enterText(target, value);
  }

  testWidgets('es opcional y permite guardar todo vacío', (tester) async {
    await pump(tester);
    expect(find.text('Un toque personal'), findsOneWidget);
    expect(find.text('Opcional'), findsOneWidget);
    expect(find.textContaining('de 2'), findsNothing);
    await tap(tester, 'Guardar y empezar');
    expect(find.text('Inicio listo'), findsOneWidget);
    expect(repository.value, emptyProfile);
    expect(preferences.getBool(PrefsKeys.profileOnboardingResolvedV1), isTrue);
  });

  testWidgets('Ahora no descarta los datos escritos', (tester) async {
    await pump(
      tester,
      registrationPreferences: RegistrationPreferences(
        preferredSpecies: const {Species.canine, Species.feline},
        includePlants: true,
      ),
    );
    await fill(tester, 'nombre', 'No se guarda');
    await tap(tester, 'Ahora no');
    expect(repository.saveCalls, 0);
    expect(repository.value, emptyProfile);
    expect(find.text('Inicio listo'), findsOneWidget);
  });

  for (final example in [
    (field: 'nombre', value: ' Ana '),
    (field: 'telefono', value: '+52 55-1234-5678'),
    (field: 'email', value: 'ana@example.com'),
  ]) {
    testWidgets('guarda solamente ${example.field} sin pedir más campos', (
      tester,
    ) async {
      await pump(tester);
      await fill(tester, example.field, example.value);
      await tap(tester, 'Guardar y empezar');
      expect(find.text('Inicio listo'), findsOneWidget);
      expect(repository.value.toJson()[example.field], example.value.trim());
      expect(repository.value.apellido, isEmpty);
    });
  }

  testWidgets(
    'rancho empieza plegado y permite guardar solamente UPP con ceros',
    (tester) async {
      await pump(tester);
      expect(find.text('UPP'), findsNothing);
      await tap(tester, 'Añadir datos del rancho');
      await fill(tester, 'upp', '001234-MX');
      await tap(tester, 'Guardar y empezar');
      expect(repository.value.upp, '001234-MX');
      expect(repository.value.nombre, isEmpty);
      expect(repository.value.apellido, isEmpty);
      expect(find.text('Inicio listo'), findsOneWidget);
    },
  );

  testWidgets('Mascotas y plantas omite campos ganaderos', (tester) async {
    await pump(
      tester,
      registrationPreferences: RegistrationPreferences(
        preferredSpecies: const {Species.canine, Species.feline},
        includePlants: true,
      ),
    );
    expect(find.text('Añadir datos del rancho'), findsNothing);
    expect(find.byKey(const ValueKey('profile-upp')), findsNothing);
    await fill(tester, 'nombre', 'Mora');
    await tap(tester, 'Guardar y empezar');
    expect(find.text('Inicio listo'), findsOneWidget);
    expect(repository.saveCalls, 1);
    expect(repository.value.nombre, 'Mora');
    expect(repository.value.finca, isEmpty);
    expect(repository.value.upp, isEmpty);
  });

  testWidgets(
    'omitir descarta texto sin confirmar, incluso un correo inválido',
    (tester) async {
      await pump(tester);
      await fill(tester, 'email', 'incorrecto');
      await tap(tester, 'Guardar y empezar');
      expect(
        find.text('Revisa el correo o deja este campo vacío.'),
        findsOneWidget,
      );
      expect(repository.saveCalls, 0);
      await tap(tester, 'Ahora no');
      expect(find.text('Inicio listo'), findsOneWidget);
      expect(repository.value, emptyProfile);
    },
  );

  testWidgets('un error conserva los campos y deja reintentar', (tester) async {
    repository.failSave = true;
    await pump(tester);
    await fill(tester, 'nombre', 'Ana');
    await tap(tester, 'Guardar y empezar');
    expect(
      find.text(
        'No se pudieron guardar tus datos. Intenta de nuevo o elige Ahora no.',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('profile-nombre')))
          .controller!
          .text,
      'Ana',
    );
    repository.failSave = false;
    await tap(tester, 'Guardar y empezar');
    expect(find.text('Inicio listo'), findsOneWidget);
    expect(repository.value.nombre, 'Ana');
  });

  testWidgets('un error de lectura no impide omitir', (tester) async {
    repository.failLoad = true;
    await pump(tester);
    expect(
      find.text(
        'No se pudieron leer tus datos. Puedes reintentar o hacerlo después.',
      ),
      findsOneWidget,
    );
    await tap(tester, 'Ahora no');
    expect(find.text('Inicio listo'), findsOneWidget);
  });

  testWidgets('bloquea envíos repetidos mientras guarda', (tester) async {
    final gate = Completer<void>();
    repository.saveGate = gate.future;
    await pump(tester);
    await tester.tap(find.text('Guardar y empezar'));
    await tester.pump();
    await tester.tap(find.text('Ahora no'));
    expect(repository.saveCalls, 1);
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.text('Inicio listo'), findsOneWidget);
  });

  testWidgets('Atrás primero cierra teclado y luego omite', (tester) async {
    addTearDown(tester.view.resetViewInsets);
    await pump(tester);
    await fill(tester, 'nombre', 'Sin guardar');
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('Inicio listo'), findsNothing);
    expect(preferences.getBool(PrefsKeys.profileOnboardingResolvedV1), isNull);
    tester.view.resetViewInsets();
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Inicio listo'), findsOneWidget);
    expect(repository.saveCalls, 0);
  });

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets(
      'texto 200 %, pantalla pequeña y teclado accesibles en $theme',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        await pump(tester, theme: theme, scale: 2);
        await fill(tester, 'nombre', 'Ana');
        tester.view.viewInsets = const FakeViewPadding(bottom: 220);
        await tester.pump();
        expect(find.text('Ahora no').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        tester.view.resetViewInsets();
        await tester.pump();
        await tap(tester, 'Ahora no');
        expect(find.text('Inicio listo'), findsOneWidget);
      },
    );
  }

  testWidgets(
    'campos y acciones tienen etiquetas y objetivos táctiles accesibles',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await pump(tester);
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      } finally {
        semantics.dispose();
      }
    },
  );
}
