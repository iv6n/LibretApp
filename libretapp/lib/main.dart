/// main — application entry point.
///
///
/// Bootstraps Flutter, configures GetIt dependency injection, and launches
/// [LibretApp].
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:libretapp/app/app_index.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/app/workspace_app_host.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';
import 'package:libretapp/core/workspace/workspace_files.dart';
import 'package:libretapp/core/security/services/supabase_phone_auth.dart';
import 'package:libretapp/core/backup/automatic_backup.dart';
import 'package:libretapp/core/security/services/account_deletion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:go_router/go_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const _BootApp());
}

class _BootApp extends StatefulWidget {
  const _BootApp();

  @override
  State<_BootApp> createState() => _BootAppState();
}

class _BootAppState extends State<_BootApp> {
  Widget? _ready;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    // The first Flutter frame already contains the brand while services load.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _releaseNativeSplash();
      _bootstrap();
    });
  }

  Future<void> _releaseNativeSplash() async {
    try {
      await const MethodChannel(
        'libretapp/splash',
      ).invokeMethod<void>('flutterReady');
    } catch (_) {
      // Other platforms and widget tests have no Android splash channel.
    }
  }

  Future<void> _bootstrap() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
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
      final globalPrefs = SharedPrefsService(
        await SharedPreferences.getInstance(),
      );
      final registry = WorkspaceRegistry(globalPrefs);
      await registry.load();
      if (ReleaseFeatures.cloudBackupEnabled) {
        await AccountDeletionService.recoverLocal(registry);
      }
      for (final demo in registry.discardedDemos) {
        await discardDemoFiles(demo);
        await SharedPrefsService(
          await SharedPreferences.getInstance(),
          prefix: demo.preferencePrefix,
        ).clearWorkspace();
      }
      final manager = WorkspaceManager(
        registry: registry,
        auth: SupabasePhoneAuth(),
      );
      await AutomaticBackup.initialize();
      await setupLocator(workspace: registry.active ?? registry.guest);
      locator.registerSingleton<WorkspaceManager>(manager);
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
        preferences: globalPrefs,
        animalRepository: locator<AnimalRepository>(),
        hasOtherUserData: workspaceHasUserData,
      ).shouldShowWelcome();
      if (!registry.hadRegistry && !showWelcome) {
        await registry.replace(registry.spaces, registry.guest.id);
      }
      final showChoice =
          registry.active == null &&
          (registry.interruptedDemo ||
              globalPrefs.getBool(PrefsKeys.onboardingCompletedV1) == true);
      if (showChoice) await globalPrefs.setInt('onboarding.page.v2', 4);
      if (!mounted) return;
      setState(
        () => _ready = WorkspaceAppHost(
          manager: manager,
          initialLocation: (showWelcome || showChoice)
              ? AppRoutes.onboarding
              : AppRoutes.inicio,
        ),
      );
    } catch (e, st) {
      LoggerService.e('Fatal startup failure: $e', tag: 'Main', stackTrace: st);
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ready != null) return _ready!;
    if (_failed) return const _StartupFailureApp();
    final dark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: dark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: dark
            ? const Color(0xFF18362D)
            : const Color(0xFFF6F1E8),
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppBrand(height: 52),
              const SizedBox(height: 32),
              SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: dark
                      ? const Color(0xFFF6F1E8)
                      : const Color(0xFF2F5D50),
                  semanticsLabel: 'Cargando LibretApp',
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
