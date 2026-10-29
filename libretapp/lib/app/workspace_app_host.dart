import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/app_bloc.dart';
import 'package:libretapp/app/app.dart';
import 'package:libretapp/app/app_router.dart';
import 'package:libretapp/app/theme/theme_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/demo/demo_scenario_service.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/workspace/workspace_files.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:libretapp/core/services/theme_repository.dart';
import 'package:libretapp/theme/app_theme.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/core/experience/registration_preferences.dart';
import 'package:libretapp/core/experience/care_profile.dart';
import 'package:libretapp/features/lite/lite_notification_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/inicio/data/weather_alerts_service.dart';

/// Unmounts the entire old router and its BLoCs before closing their database.
class WorkspaceAppHost extends StatefulWidget {
  const WorkspaceAppHost({
    super.key,
    required this.manager,
    required this.initialLocation,
  });
  final WorkspaceManager manager;
  final String initialLocation;
  @override
  State<WorkspaceAppHost> createState() => _WorkspaceAppHostState();
}

class _WorkspaceAppHostState extends State<WorkspaceAppHost> {
  GoRouter? _router;
  AppBloc? _appBloc;
  AppExperienceController? _experience;
  AppLifecycleListener? _lifecycle;
  Widget? _tree;
  bool _switching = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _syncReminders);
    widget.manager.opener = _open;
    widget.manager.deletionOpener = (guest, erase) =>
        _open(guest, enterApp: false, beforeOpen: erase);
    widget.manager.maintenanceOpener = (action) =>
        _open(widget.manager.current!, enterApp: true, beforeOpen: action);
    unawaited(_initialize(widget.initialLocation));
  }

  Future<void> _initialize(String initialLocation) async {
    try {
      await _compose(initialLocation);
      if (mounted) setState(() => _switching = false);
    } catch (error) {
      if (mounted) {
        setState(() {
          _switching = false;
          _error = 'No se pudo abrir el espacio de trabajo: $error';
        });
      }
    }
  }

  Future<void> _compose(String initialLocation) async {
    await _ensureRegistrationPreferences();
    _syncReminders();
    _experience = AppExperienceController(
      locator<SharedPrefsService>(),
      demo: widget.manager.isDemo,
    );
    _router = createAppRouter(
      initialLocation: initialLocation,
      onboardingError: _error,
    );
    _error = null;
    final appBloc = AppBloc(prefs: locator<SharedPrefsService>())
      ..add(const AppStarted());
    _appBloc = appBloc;
    _tree = MultiBlocProvider(
      key: UniqueKey(),
      providers: [
        BlocProvider(
          create: (_) =>
              ThemeBloc(repository: locator<ThemeRepository>())
                ..add(const ThemeStarted()),
        ),
        BlocProvider<AppBloc>(create: (_) => appBloc, lazy: false),
      ],
      child: AppExperienceScope(
        controller: _experience!,
        child: MyApp(router: _router!),
      ),
    );
    if (locator<SharedPrefsService>().getBool(
          RegistrationPreferences.recordsMigrationKey,
        ) ==
        false) {
      unawaited(_mergeExistingRegistrationData());
    }
  }

  Future<void> _ensureRegistrationPreferences() async {
    final prefs = locator<SharedPrefsService>();
    if (prefs.getString(RegistrationPreferences.storageKey) != null) {
      final current = RegistrationPreferences.decode(
        prefs.getString(RegistrationPreferences.storageKey),
      );
      if (!current.configured) {
        await prefs.setString(
          RegistrationPreferences.storageKey,
          RegistrationPreferences.defaults.encode(),
        );
        await prefs.setBool(RegistrationPreferences.recordsMigrationKey, false);
      } else if (current.careProfile == null) {
        // Add an inferred presentation profile to prior preference documents.
        await prefs.setBool(RegistrationPreferences.recordsMigrationKey, false);
      } else if (prefs.getBool(RegistrationPreferences.recordsMigrationKey) ==
          null) {
        await prefs.setBool(RegistrationPreferences.recordsMigrationKey, true);
      }
      return;
    }

    final controller = RegistrationPreferencesController(prefs);
    var selection = controller.value;
    if (widget.manager.isDemo) {
      selection = selection.copyWith(
        preferredSpecies: RegistrationPreferences.allSpecies,
        includePlants: true,
        configured: true,
      );
      await prefs.setBool(RegistrationPreferences.recordsMigrationKey, true);
    } else {
      // Keep this pending across restarts until existing records have been
      // inspected and merged into the translated legacy selection.
      await prefs.setBool(RegistrationPreferences.recordsMigrationKey, false);
    }
    await controller.setPreferences(selection);
    controller.dispose();
  }

  Future<void> _mergeExistingRegistrationData() async {
    final prefs = locator<SharedPrefsService>();
    if (prefs.getBool(RegistrationPreferences.recordsMigrationKey) != false) {
      return;
    }

    final animalRepository = locator<AnimalRepository>();
    final cultivationRepository = locator<CultivationRepository>();
    try {
      final existingAnimals = await animalRepository.getAll();
      final registeredSpecies =
          animalRepository is RegisteredAnimalSpeciesReader
          ? await (animalRepository as RegisteredAnimalSpeciesReader)
                .getRegisteredSpecies()
          : existingAnimals.map((animal) => animal.species).toSet();
      final hasPlants = (await cultivationRepository.getAll()).isNotEmpty;
      final stored = RegistrationPreferences.decode(
        prefs.getString(RegistrationPreferences.storageKey),
      );
      final merged = stored.copyWith(
        preferredSpecies: {...stored.preferredSpecies, ...registeredSpecies},
        includePlants: stored.includePlants || hasPlants,
        careProfile:
            stored.careProfile ??
            inferCareProfileFromAnimals(existingAnimals) ??
            inferCareProfileFromSpecies({
              ...stored.preferredSpecies,
              ...registeredSpecies,
            }),
        configured:
            stored.configured || registeredSpecies.isNotEmpty || hasPlants,
      );
      await prefs.setString(
        RegistrationPreferences.storageKey,
        merged.encode(),
      );
      await prefs.setBool(RegistrationPreferences.recordsMigrationKey, true);
    } catch (error, stack) {
      debugPrint('No se pudieron migrar las especies registradas: $error');
      debugPrintStack(stackTrace: stack);
    }
  }

  void _syncReminders() {
    unawaited(
      LiteNotificationService.syncFromRepository().then(
        (_) {},
        onError: (Object error, StackTrace stack) {
          debugPrint('No se pudieron sincronizar los avisos: $error');
        },
      ),
    );
  }

  Future<void> _open(
    LocalWorkspace workspace, {
    required bool enterApp,
    Future<void> Function()? beforeOpen,
  }) async {
    final previous = locator.isRegistered<LocalWorkspace>()
        ? locator<LocalWorkspace>()
        : null;
    final previousPrefs = locator.isRegistered<SharedPrefsService>()
        ? locator<SharedPrefsService>()
        : null;
    setState(() {
      _switching = true;
      _tree = null;
    });
    await WidgetsBinding.instance.endOfFrame;
    _router?.dispose();
    _router = null;
    _experience?.dispose();
    _experience = null;
    try {
      await LiteNotificationService.cancelForWorkspaceChange();
      if (previous != null && previous.id != workspace.id) {
        await WeatherAlertsService.cancelForWorkspaceChange();
      }
      await _appBloc?.close();
      await disposeLocator();
      await beforeOpen?.call();
      if (previous?.isDemo ?? false) {
        await discardDemoFiles(previous!);
        await previousPrefs?.clearWorkspace();
      }
      await setupLocator(workspace: workspace);
      locator.registerSingleton<WorkspaceManager>(widget.manager);
      await locator<WeatherAlertsService>().syncExisting(
        workspace: workspace,
        experience: AppExperience.complete,
      );
      if (workspace.isDemo) {
        if (!locator.isRegistered<DemoScenarioService>()) {
          throw UnsupportedError('La demo está disponible en Android.');
        }
        await locator<DemoScenarioService>().install();
      }
      await widget.manager.registry.preferences.setInt('onboarding.page.v2', 4);
      if (!mounted) return;
      await _compose(enterApp ? AppRoutes.inicio : AppRoutes.onboarding);
      if (mounted) setState(() => _switching = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _switching = false;
          _error =
              'No se pudo preparar el espacio. Tus registros siguen guardados. Puedes reintentar.';
        });
      }
      rethrow;
    }
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    widget.manager.opener = null;
    widget.manager.maintenanceOpener = null;
    _router?.dispose();
    _experience?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_switching && _tree != null) return _tree!;
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _switching
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error ?? 'No se pudo abrir el espacio de trabajo.',
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () async {
                            try {
                              await _open(
                                widget.manager.current ??
                                    widget.manager.registry.guest,
                                enterApp: widget.manager.current != null,
                              );
                            } catch (_) {}
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
