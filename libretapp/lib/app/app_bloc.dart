import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/eventos/data/eventos_repository.dart';
import 'package:libretapp/features/eventos/data/eventos_reminder_sync_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/services/batch_migration_service.dart';

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
    await _purgeEventsOnce();
    await _syncAutomaticReminders();

    // Ejecutar migración de lotes si es necesaria
    try {
      final migrationService = BatchMigrationService(
        animalRepository: locator(),
        lotesRepository: locator(),
      );
      await migrationService.migrate();
    } catch (e, st) {
      // La migracion no bloquea el arranque, pero debe dejar traza para diagnostico.
      LoggerService.e(
        'Error durante migracion inicial de lotes: $e',
        tag: 'AppBloc',
        stackTrace: st,
      );
    }

    final languageCode = await _resolveInitialLanguage();
    emit(AppReady(languageCode: languageCode));
  }

  Future<void> _purgeEventsOnce() async {
    final alreadyDone = _prefs.getBool(PrefsKeys.eventsInitialPurgeV1Done);
    if (alreadyDone == true) return;

    try {
      final eventosRepository = locator<EventosRepository>();
      await eventosRepository.clearAll();
      await _prefs.setBool(PrefsKeys.eventsInitialPurgeV1Done, true);
      LoggerService.i(
        'Limpieza inicial de eventos aplicada (v1)',
        tag: 'AppBloc',
      );
    } catch (e, st) {
      LoggerService.e(
        'Error al limpiar eventos iniciales: $e',
        tag: 'AppBloc',
        stackTrace: st,
      );
    }
  }

  Future<void> _syncAutomaticReminders() async {
    try {
      final syncService = locator<EventosReminderSyncService>();
      final generated = await syncService.sync();
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
