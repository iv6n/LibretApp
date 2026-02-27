import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/app/app_index.dart';
import 'package:libretapp/core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Draw UI behind system bars to let the content extend under the Android navigation bar.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final isDark =
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // Slight tint keeps the nav bar legible while staying edge-to-edge.
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
}

class LibretApp extends StatelessWidget {
  const LibretApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}
