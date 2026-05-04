/// app › theme › theme_bloc — BLoC controlling app theme (light/dark).
///
/// Persists the selected theme via [ThemeRepository].
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/theme_repository.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({ThemeRepository? repository, Brightness? platformBrightness})
    : _repository = repository ?? locator<ThemeRepository>(),
      _platformBrightness = platformBrightness,
      super(const ThemeState(themeMode: ThemeMode.system)) {
    on<ThemeStarted>(_onStarted);
    on<ThemeModeChanged>(_onModeChanged);
    on<ThemeToggled>(_onToggled);
  }

  final ThemeRepository _repository;
  final Brightness? _platformBrightness;

  Future<void> _onStarted(ThemeStarted event, Emitter<ThemeState> emit) async {
    final fallback = _platformBrightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;
    final saved = await _repository.loadThemeMode(fallback: fallback);
    emit(ThemeState(themeMode: saved));
  }

  Future<void> _onModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    await _repository.saveThemeMode(event.themeMode);
    emit(ThemeState(themeMode: event.themeMode));
  }

  Future<void> _onToggled(ThemeToggled event, Emitter<ThemeState> emit) async {
    final nextMode = switch (state.themeMode) {
      ThemeMode.dark => ThemeMode.light,
      _ => ThemeMode.dark,
    };
    await _repository.saveThemeMode(nextMode);
    emit(ThemeState(themeMode: nextMode));
  }
}
