import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/onboarding/onboarding_page.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/app_theme.dart';

Widget _app({
  Future<void> Function()? guest,
  Future<void> Function(AppExperience)? demo,
  Future<void> Function()? phoneAccess,
  Future<void> Function(int)? progress,
  int page = 0,
  double scale = 1,
  ThemeMode mode = ThemeMode.light,
}) {
  final router = GoRouter(
    initialLocation: AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => OnboardingPage(
          initialPage: page,
          onStartEmpty: guest ?? () async {},
          onInstallDemo: demo ?? (_) async {},
          onAccessPhone: phoneAccess,
          onProgress: progress,
        ),
      ),
      GoRoute(
        path: AppRoutes.inicio,
        builder: (_, _) => const Scaffold(body: Text('Inicio listo')),
      ),
    ],
  );
  return MaterialApp.router(
    routerConfig: router,
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: mode,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
  );
}

Future<void> _tap(WidgetTester tester, String text) async {
  final target = find.text(text).first;
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _goToAccess(WidgetTester tester) async {
  await tester.drag(find.byType(PageView), const Offset(-480, 0));
  await tester.pumpAndSettle();
  await tester.drag(find.byType(PageView), const Offset(-480, 0));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('presenta tres pantallas deslizables con ejemplos variados', (
    tester,
  ) async {
    final progress = <int>[];
    await tester.pumpWidget(_app(progress: (page) async => progress.add(page)));

    expect(
      find.text('De la casa al campo,\ntodo lo que cuidas\nen un lugar.'),
      findsOneWidget,
    );
    expect(find.text('Guarda su historia'), findsOneWidget);
    expect(find.text('Planea cuidados'), findsOneWidget);
    expect(find.text('Recibe avisos'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Vaca, perro, gato y planta frente a una siembra, con un caballo y una cabra al fondo',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Pantalla 1 de 3'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-480, 0));
    await tester.pumpAndSettle();
    expect(find.text('Tus cuidados, de un vistazo.'), findsOneWidget);
    expect(find.text('VISTA PREVIA · DATOS FICTICIOS'), findsOneWidget);
    expect(find.text('Prieta'), findsOneWidget);
    expect(find.text('Capitán'), findsOneWidget);
    expect(find.text('Maíz blanco'), findsOneWidget);
    expect(find.text('Mi monstera'), findsOneWidget);
    expect(find.bySemanticsLabel('Pantalla 2 de 3'), findsOneWidget);
    expect(progress, [1]);

    await tester.drag(find.byType(PageView), const Offset(-480, 0));
    await tester.pumpAndSettle();
    expect(find.text('Empieza a tu manera.'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Persona organizando cuidados desde su teléfono junto a un perro y una siembra',
      ),
      findsOneWidget,
    );
    expect(find.text('Acceder con teléfono'), findsOneWidget);
    expect(find.text('Continuar como invitado'), findsOneWidget);
    expect(find.text('Ver demo'), findsOneWidget);
    expect(
      find.text(
        'Prueba fichas y actividades ficticias en un espacio separado.',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Pantalla 3 de 3'), findsOneWidget);
    expect(progress, [1, 2]);
  });

  testWidgets('continuar, volver y omitir mueven entre las tres pantallas', (
    tester,
  ) async {
    final progress = <int>[];
    await tester.pumpWidget(_app(progress: (page) async => progress.add(page)));

    await _tap(tester, 'Continuar');
    expect(find.text('Tus cuidados, de un vistazo.'), findsOneWidget);
    await _tap(tester, 'Volver');
    expect(
      find.text('De la casa al campo,\ntodo lo que cuidas\nen un lugar.'),
      findsOneWidget,
    );

    await _tap(tester, 'Omitir');
    expect(find.text('Empieza a tu manera.'), findsOneWidget);
    await _tap(tester, 'Volver');
    expect(find.text('Tus cuidados, de un vistazo.'), findsOneWidget);
    expect(progress, [1, 0, 2, 1]);
  });

  testWidgets('omitir desde la segunda pantalla va al acceso', (tester) async {
    await tester.pumpWidget(_app(page: 1));
    await _tap(tester, 'Omitir');
    expect(find.text('Empieza a tu manera.'), findsOneWidget);
  });

  testWidgets('entrar como invitado abre Inicio', (tester) async {
    var starts = 0;
    await tester.pumpWidget(_app(guest: () async => starts++));
    await _goToAccess(tester);
    await _tap(tester, 'Continuar como invitado');

    expect(starts, 1);
    expect(find.text('Inicio listo'), findsOneWidget);
  });

  testWidgets('demo abre ejemplos en un espacio separado', (tester) async {
    AppExperience? selected;
    await tester.pumpWidget(_app(demo: (value) async => selected = value));
    await _goToAccess(tester);
    await _tap(tester, 'Ver demo');

    expect(selected, AppExperience.complete);
    expect(find.text('Inicio listo'), findsOneWidget);
  });

  testWidgets('acceder con teléfono usa un único flujo', (tester) async {
    var accesses = 0;
    await tester.pumpWidget(_app(phoneAccess: () async => accesses++));
    await _goToAccess(tester);
    await _tap(tester, 'Acceder con teléfono');

    expect(accesses, 1);
    expect(
      find.text(
        'Accede con tu teléfono, empieza como invitado o explora la app con ejemplos.',
      ),
      findsOneWidget,
    );
    expect(find.text('Crear cuenta'), findsNothing);
    expect(find.text('Ya tengo cuenta'), findsNothing);
    expect(find.text('Empieza a tu manera.'), findsOneWidget);
  });

  testWidgets('explica si el acceso telefónico no está disponible', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await _goToAccess(tester);

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Acceder con teléfono'),
    );
    expect(button.onPressed, isNull);
    expect(
      find.text('El acceso por teléfono no está disponible en esta versión.'),
      findsOneWidget,
    );
    expect(
      find.text('Empieza como invitado o explora la app con ejemplos.'),
      findsOneWidget,
    );
    expect(find.text('Continuar como invitado'), findsOneWidget);
    expect(find.text('Ver demo'), findsOneWidget);
  });

  testWidgets('muestra errores recuperables al entrar como invitado', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(guest: () async => throw StateError('storage unavailable')),
    );
    await _goToAccess(tester);
    await _tap(tester, 'Continuar como invitado');

    expect(
      find.text(
        'No se pudo abrir el espacio. Tus registros siguen guardados. Intenta de nuevo.',
      ),
      findsOneWidget,
    );
    expect(find.text('Continuar como invitado'), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets(
      'las tres pantallas admiten 320 × 568 dp y texto al 200 % en $mode',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_app(scale: 2, mode: mode));
        expect(tester.takeException(), isNull);
        await _tap(tester, 'Continuar');
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Continuar'));
        await _tap(tester, 'Continuar');
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Ver demo'));
        expect(find.text('Continuar como invitado'), findsOneWidget);
        expect(
          find.text(
            'Tus registros se guardan en este dispositivo. Haz copias de seguridad periódicas.',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
