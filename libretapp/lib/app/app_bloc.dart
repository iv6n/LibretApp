/// app › app_bloc — application-level BLoC controlling auth/session state.
///
/// Manages high-level app lifecycle events such as startup and authentication
/// state changes.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/features/agenda/domain/operational_planning_service.dart';
import 'package:libretapp/features/directorio/animales/domain/services/care_calendar_service.dart';
import 'package:libretapp/features/directorio/animales/domain/services/default_care_rules.dart';
import 'app_migrations.dart';

part 'app_event.dart';
part 'app_state.dart';

/// Root application BLoC that initializes app-level state and preferences.
class AppBloc extends Bloc<AppEvent, AppState> {
  /// Creates the app bloc and wires startup/language handlers.
  AppBloc({SharedPrefsService? prefs})
    : _prefs = prefs ?? locator<SharedPrefsService>(),
      _supportedLanguageCodes = const {'es'},
      super(const AppInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AppLanguageChanged>(_onLanguageChanged);
  }

  final SharedPrefsService _prefs;
  final Set<String> _supportedLanguageCodes;

  Future<void> _onAppStarted(AppStarted event, Emitter<AppState> emit) async {
    await _preloadCareDefaults();

    // Ejecutar migración de enums de ubicaciones (Spanish → English strings)
    try {
      await runLocationEnumMigrationIfRegistered();
    } catch (e, st) {
      LoggerService.e(
        'Error durante migracion de enums de ubicaciones: $e',
        tag: 'AppBloc',
        stackTrace: st,
      );
    }

    try {
      final migrated = await runCultivationMigrationIfRegistered();
      if (migrated > 0) {
        LoggerService.i(
          'Cultivos migrados desde ubicaciones: $migrated',
          tag: 'AppBloc',
        );
      }
    } catch (e, st) {
      LoggerService.e(
        'Error durante migracion de cultivos: $e',
        tag: 'AppBloc',
        stackTrace: st,
      );
    }

    // La agenda se genera después de migrar datos locales para no crear
    // ocurrencias contra tipos de ubicación todavía no normalizados.
    await _syncAutomaticReminders();

    await _finishStartup(emit);
  }

  Future<void> _finishStartup(Emitter<AppState> emit) async {
    final languageCode = await _resolveInitialLanguage();
    emit(AppReady(languageCode: languageCode));
  }

  Future<void> _preloadCareDefaults() async {
    try {
      if (!locator.isRegistered<CareCalendarService>()) return;
      final key = PrefsKeys.careDefaultsPreloaded(DefaultCareRules.version);
      final alreadyLoaded = _prefs.getBool(key) ?? false;
      await locator<CareCalendarService>().preloadDefaults(
        alreadyLoaded: alreadyLoaded,
      );
      if (!alreadyLoaded) await _prefs.setBool(key, true);
    } catch (e, st) {
      LoggerService.e(
        'Error al precargar el calendario sanitario por defecto: $e',
        tag: 'AppBloc',
        stackTrace: st,
      );
    }
  }

  Future<void> _syncAutomaticReminders() async {
    try {
      if (!locator.isRegistered<AgendaReminderSyncService>()) return;
      final syncService = locator<AgendaReminderSyncService>();
      final generated = await locator<OperationalPlanningService>()
          .reconcileAll(generator: syncService.sync);
      LoggerService.i(
        'Recordatorios automáticos sincronizados: $generated',
        tag: 'AppBloc',
      );
    } catch (e, st) {
      LoggerService.e(
        'Error al sincronizar recordatorios automáticos: $e',
        tag: 'AppBloc',
        stackTrace: st,
      );
    }
  }

  Future<void> _onLanguageChanged(
    AppLanguageChanged event,
    Emitter<AppState> emit,
  ) async {
    final code = _isSupported(event.languageCode) ? event.languageCode : 'es';
    await _prefs.setString(PrefsKeys.appLanguage, code);
    emit(AppLanguageUpdated(code));
  }

  Future<String> _resolveInitialLanguage() async {
    final saved = _prefs.getString(PrefsKeys.appLanguage);
    if (_isSupported(saved)) return saved!;
    return 'es';
  }

  bool _isSupported(String? code) {
    if (code == null || code.isEmpty) return false;
    return _supportedLanguageCodes.contains(code);
  }
}
