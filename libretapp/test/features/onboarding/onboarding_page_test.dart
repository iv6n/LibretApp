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
  Future<void> Function()? createPhone,
  Future<void> Function()? signInPhone,
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
          onCreatePhone: createPhone,
          onSignInPhone: signInPhone,
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

void main() {
  testWidgets('presenta dos pantallas y omitir abre la vista previa', (
    tester,
  ) async {
    var lastProgress = -1;
    await tester.pumpWidget(
      _app(progress: (page) async => lastProgress = page),
    );

    expect(find.text('Todo lo que cuidas,\nen un lugar.'), findsOneWidget);
    expect(find.text('Fichas'), findsOneWidget);
    expect(find.text('Actividades'), findsOneWidget);
    expect(find.text('Avisos'), findsOneWidget);
    expect(find.text('¿Qué vas a registrar?'), findsNothing);

    await _tap(tester, 'Omitir');

    expect(lastProgress, 1);
    expect(find.text('Cada cuidado,\nbien organizado.'), findsOneWidget);
    expect(find.text('VISTA PREVIA · DATOS FICTICIOS'), findsOneWidget);
    expect(find.text('Luna'), findsOneWidget);
    expect(find.text('Mi monstera'), findsOneWidget);
    expect(find.text('Riego · Mañana'), findsOneWidget);
    expect(find.text('Empezar sin cuenta'), findsOneWidget);
    expect(find.text('Probar con ejemplos'), findsOneWidget);
    expect(find.text('¿Qué vas a registrar?'), findsNothing);
  });

  testWidgets('volver y continuar conservan el progreso', (tester) async {
    final progress = <int>[];
    await tester.pumpWidget(_app(progress: (page) async => progress.add(page)));

    await _tap(tester, 'Continuar');
    expect(find.text('Cada cuidado,\nbien organizado.'), findsOneWidget);
    await _tap(tester, 'Volver');
    expect(find.text('Todo lo que cuidas,\nen un lugar.'), findsOneWidget);
    expect(progress, [1, 0]);
  });

  testWidgets('entrar como invitado abre Inicio sin pedir preferencias', (
    tester,
  ) async {
    var starts = 0;
    await tester.pumpWidget(_app(guest: () async => starts++));
    await _tap(tester, 'Continuar');
    await _tap(tester, 'Empezar sin cuenta');

    expect(starts, 1);
    expect(find.text('Inicio listo'), findsOneWidget);
  });

  testWidgets('mantiene la demo aislada y abre la experiencia completa', (
    tester,
  ) async {
    AppExperience? selected;
    await tester.pumpWidget(_app(demo: (value) async => selected = value));
    await _tap(tester, 'Continuar');
    await _tap(tester, 'Probar con ejemplos');

    expect(selected, AppExperience.complete);
    expect(find.text('Inicio listo'), findsOneWidget);
  });

  testWidgets('ofrece acceso telefónico desde un panel secundario', (
    tester,
  ) async {
    var creates = 0;
    var signsIn = 0;
    await tester.pumpWidget(
      _app(
        page: 1,
        createPhone: () async => creates++,
        signInPhone: () async => signsIn++,
      ),
    );

    await _tap(tester, 'Acceder con teléfono');
    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('Ya tengo cuenta'), findsOneWidget);
    await _tap(tester, 'Crear cuenta');
    expect(creates, 1);
    expect(signsIn, 0);
    expect(find.text('Cada cuidado,\nbien organizado.'), findsOneWidget);

    await _tap(tester, 'Acceder con teléfono');
    await _tap(tester, 'Ya tengo cuenta');
    expect(signsIn, 1);
  });

  testWidgets('muestra errores recuperables si falla la entrada', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(guest: () async => throw StateError('storage unavailable')),
    );
    await _tap(tester, 'Continuar');
    await _tap(tester, 'Empezar sin cuenta');

    expect(
      find.text(
        'No se pudo abrir el espacio. Tus registros siguen guardados. Intenta de nuevo.',
      ),
      findsOneWidget,
    );
    expect(find.text('Empezar sin cuenta'), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets(
      'ambas pantallas se adaptan a 320 × 568 dp y texto al 200 % en $mode',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_app(scale: 2, mode: mode));
        expect(tester.takeException(), isNull);
        await _tap(tester, 'Continuar');
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Empezar sin cuenta'));
        expect(find.text('Probar con ejemplos'), findsOneWidget);
        expect(
          find.text(
            'Tus registros se guardan aquí. Haz copias periódicas fuera del teléfono.',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
