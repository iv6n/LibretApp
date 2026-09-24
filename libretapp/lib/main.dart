/// main — application entry point.
///
///
/// Bootstraps Flutter, configures GetIt dependency injection, and launches
/// [LibretApp].
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/app/app_index.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/core/demo/demo_scenario_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Opt-in gate for `DemoScenarioService.install()` at startup — never set in
/// a release build. `--dart-define=LIBRET_ENABLE_DEMO_DATA=true` at build
/// time is the only way to turn it on; unset, this is `false` in every
/// build, debug included.
const bool enableDemoDataOnStartup = bool.fromEnvironment(
  'LIBRET_ENABLE_DEMO_DATA',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
  }
  // Replace Flutter's empty error surface with an actionable recovery view.
  // The original exception is still logged below; this only prevents a
  // release build from leaving the user on a white screen.
  ErrorWidget.builder = (_) => const _RuntimeErrorRecovery();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    LoggerService.e(
      'Flutter framework error during startup/runtime: ${details.exceptionAsString()}',
      tag: 'Main',
      stackTrace: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    LoggerService.e(
      'Uncaught platform error: $error',
      tag: 'Main',
      stackTrace: stack,
    );
    return true;
  };

  try {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Draw UI behind system bars to let the content extend under the Android navigation bar.
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    final isDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        // Slight tint keeps the nav bar legible while stayi0ng edge-to-edge.
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
    );
    final startupSpan = PerformanceMonitor().startSpan('app.startup');
    LoggerService.i('Iniciando configuración de LibretApp', tag: 'Main');
    await setupLocator();
    // Opt-in only: never seeded silently in release, and only when the
    // caller explicitly asks for it via `--dart-define=LIBRET_ENABLE_DEMO_DATA=true`.
    // A debug-only action in the Perfil screen offers the same install/reset
    // without a rebuild. See DemoScenarioService for why this replaced the
    // old unconditional `seedMockAnimals()` call.
    if (!kReleaseMode && enableDemoDataOnStartup) {
      try {
        await locator<DemoScenarioService>().install();
      } catch (e, st) {
        LoggerService.e(
          'Error al instalar el escenario demo en el arranque: $e',
          tag: 'Main',
          stackTrace: st,
        );
      }
    }

    const enableTracing = kDebugMode || kProfileMode;
    if (enableTracing) {
      // Capture frame timings on physical profile builds so list/navigation
      // changes can be compared against a real 60 Hz frame budget. Keep the
      // callback registration here, before runApp, so it is installed once.
      PerformanceMonitor().attachFrameTimings(slowFrameThresholdMs: 16);
      // Capture global taps to correlate with slow frames.
      InteractionTracer().start();
      // Prepare navigation observer before router instantiation.
      NavigationTracer.initialize();
    }
    startupSpan.stop(context: {'phase': 'bootstrap'});

    final showWelcome = await OnboardingStartupService(
      preferences: locator<SharedPrefsService>(),
      animalRepository: locator<AnimalRepository>(),
    ).shouldShowWelcome();
    final appRouter = createAppRouter(
      initialLocation: showWelcome ? AppRoutes.onboarding : AppRoutes.inicio,
    );

    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ThemeBloc(
              repository: locator<ThemeRepository>(),
              platformBrightness:
                  WidgetsBinding.instance.platformDispatcher.platformBrightness,
            )..add(const ThemeStarted()),
          ),
          BlocProvider(
            create: (context) =>
                AppBloc(prefs: locator<SharedPrefsService>())
                  ..add(const AppStarted()),
          ),
        ],
        child: LibretApp(router: appRouter),
      ),
    );
  } catch (e, st) {
    LoggerService.e('Fatal startup failure: $e', tag: 'Main', stackTrace: st);
    runApp(const _StartupFailureApp());
  }
}

class LibretApp extends StatelessWidget {
  const LibretApp({super.key, this.router});

  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    return MyApp(
      router: router ?? createAppRouter(initialLocation: AppRoutes.inicio),
    );
  }
}

class _StartupFailureApp extends StatelessWidget {
  const _StartupFailureApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No se pudo iniciar la aplicacion. Revisa los logs para detalles.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _RuntimeErrorRecovery extends StatelessWidget {
  const _RuntimeErrorRecovery();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'No se pudo mostrar esta pantalla. Tus datos no se han borrado.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => Navigator.maybeOf(context)?.maybePop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
