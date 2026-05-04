/// app › theme › theme_event — events for [ThemeBloc].
part of 'theme_bloc.dart';

/// Base sealed class for all [ThemeBloc] events.
sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ThemeStarted extends ThemeEvent {
  const ThemeStarted();
}

class ThemeModeChanged extends ThemeEvent {
  const ThemeModeChanged(this.themeMode);

  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}

class ThemeToggled extends ThemeEvent {
  const ThemeToggled();
}
