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
  Future<void> Function(BuildContext)? phoneAccess,
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

    expect(find.text('Animales, plantas y tareas'), findsOneWidget);
    expect(
      find.text(
        'Organiza lo que cuidas y descubre qué necesita atención cada día.',
      ),
      findsOneWidget,
    );
    expect(find.text('Fichas de animales'), findsOneWidget);
    expect(find.text('Agenda de cuidados'), findsOneWidget);
    expect(find.text('Plantas y siembras'), findsOneWidget);
    expect(find.text('Ver un ejemplo'), findsOneWidget);
    expect(find.text('Guarda su historia'), findsNothing);
    expect(
      find.bySemanticsLabel(
        'Vaca, perro, gato y planta frente a una siembra, con un caballo y una cabra al fondo',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Pantalla 1 de 3'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-480, 0));
    await tester.pumpAndSettle();
    expect(find.text('Fichas y próximos cuidados'), findsOneWidget);
    expect(find.text('VISTA PREVIA · DATOS FICTICIOS'), findsOneWidget);
    expect(find.text('Prieta'), findsOneWidget);
    expect(find.text('Capitán'), findsOneWidget);
    expect(find.text('Maíz blanco'), findsOneWidget);
    expect(find.text('Mi monstera'), findsOneWidget);
    expect(find.text('Mañana en tu agenda'), findsOneWidget);
    expect(find.text('Revisión de Capitán'), findsOneWidget);
    expect(find.bySemanticsLabel('Pantalla 2 de 3'), findsOneWidget);
    expect(progress, [1]);

    await tester.drag(find.byType(PageView), const Offset(-480, 0));
    await tester.pumpAndSettle();
    expect(find.text('Elige cómo empezar'), findsOneWidget);
    expect(
      find.text(
        'Empieza con tus registros o explora la demo con datos ficticios.',
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        'Persona organizando cuidados desde su teléfono junto a un perro y una siembra',
      ),
      findsOneWidget,
    );
    expect(find.text('Acceder con teléfono'), findsNothing);
    expect(find.text('Continuar como invitado'), findsOneWidget);
    expect(find.text('Ver demo'), findsOneWidget);
    expect(find.bySemanticsLabel('Pantalla 3 de 3'), findsOneWidget);
    expect(progress, [1, 2]);
  });

  testWidgets('continuar, volver y omitir mueven entre las tres pantallas', (
    tester,
  ) async {
    final progress = <int>[];
    await tester.pumpWidget(_app(progress: (page) async => progress.add(page)));

    await _tap(tester, 'Ver un ejemplo');
    expect(find.text('Fichas y próximos cuidados'), findsOneWidget);
    await _tap(tester, 'Volver');
    expect(find.text('Animales, plantas y tareas'), findsOneWidget);

    await _tap(tester, 'Omitir');
    expect(find.text('Elige cómo empezar'), findsOneWidget);
    await _tap(tester, 'Volver');
    expect(find.text('Fichas y próximos cuidados'), findsOneWidget);
    expect(progress, [1, 0, 2, 1]);
  });

  testWidgets('omitir desde la segunda pantalla va al acceso', (tester) async {
    await tester.pumpWidget(_app(page: 1));
    await _tap(tester, 'Omitir');
    expect(find.text('Elige cómo empezar'), findsOneWidget);
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
    await tester.pumpWidget(_app(phoneAccess: (_) async => accesses++));
    await _goToAccess(tester);
    await _tap(tester, 'Acceder con teléfono');

    expect(accesses, 1);
    expect(find.text('Crear cuenta'), findsNothing);
    expect(find.text('Ya tengo cuenta'), findsNothing);
    expect(find.text('Elige cómo empezar'), findsOneWidget);
  });

  testWidgets('acceder con teléfono puede abrir una hoja modal', (
    tester,
  ) async {
    // Reproduce el armado real del router (`pageBuilder`) para asegurar que el
    // contexto entregado al acceso telefónico vive bajo un Navigator.
    final router = GoRouter(
      initialLocation: AppRoutes.onboarding,
      routes: [
        GoRoute(
          path: AppRoutes.onboarding,
          pageBuilder: (context, state) => MaterialPage<void>(
            child: OnboardingPage(
              initialPage: 2,
              onStartEmpty: () async {},
              onInstallDemo: (_) async {},
              onAccessPhone: (pageContext) => showModalBottomSheet<void>(
                context: pageContext,
                useRootNavigator: true,
                builder: (_) => const SizedBox(
                  height: 120,
                  child: Text('Hoja de acceso lista'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );

    await tester.ensureVisible(find.text('Acceder con teléfono').first);
    await tester.tap(find.text('Acceder con teléfono').first);
    // La bienvenida espera a que se cierre la hoja, así que no puede usarse
    // `pumpAndSettle` (el indicador de progreso anima sin parar).
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Hoja de acceso lista'), findsOneWidget);
  });

  testWidgets('oculta el acceso telefónico cuando no está disponible', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await _goToAccess(tester);

    expect(find.text('Acceder con teléfono'), findsNothing);
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
        await _tap(tester, 'Ver un ejemplo');
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Continuar'));
        await _tap(tester, 'Continuar');
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Ver demo'));
        expect(find.text('Continuar como invitado'), findsOneWidget);
        expect(
          find.text(
            'Tus datos están en este teléfono. Crea una copia de seguridad.',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
