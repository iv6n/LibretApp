import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/l10n/app_localizations.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({SharedPrefsService? prefs})
    : _prefs = prefs ?? locator<SharedPrefsService>(),
      _supportedLanguageCodes = AppLocalizations.supportedLocales
          .map((l) => l.languageCode)
          .toSet(),
      super(const AppInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AppLanguageChanged>(_onLanguageChanged);
  }

  final SharedPrefsService _prefs;
  final Set<String> _supportedLanguageCodes;

  Future<void> _onAppStarted(AppStarted event, Emitter<AppState> emit) async {
    final languageCode = await _resolveInitialLanguage();
    emit(AppReady(languageCode: languageCode));
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

    final systemCode = PlatformDispatcher.instance.locale.languageCode;
    if (_isSupported(systemCode)) return systemCode;

    return 'es';
  }

  bool _isSupported(String? code) {
    if (code == null || code.isEmpty) return false;
    return _supportedLanguageCodes.contains(code);
  }
}
