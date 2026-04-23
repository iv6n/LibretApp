import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/app/app_index.dart';
import 'package:libretapp/core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

    const enableTracing = kDebugMode || kProfileMode;
    if (enableTracing) {
      // Start capturing frame timings to surface slow frame KPIs in logs.
      //PerformanceMonitor().attachFrameTimings(slowFrameThresholdMs: 120);
      // Capture global taps to correlate with slow frames.
      InteractionTracer().start();
      // Prepare navigation observer before router instantiation.
      NavigationTracer.initialize();
    }
    startupSpan.stop(context: {'phase': 'bootstrap'});

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
        child: const LibretApp(),
      ),
    );
  } catch (e, st) {
    LoggerService.e('Fatal startup failure: $e', tag: 'Main', stackTrace: st);
    runApp(const _StartupFailureApp());
  }
}

class LibretApp extends StatelessWidget {
  const LibretApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyApp();
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
