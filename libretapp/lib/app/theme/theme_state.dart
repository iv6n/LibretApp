/// app › theme › theme_state — state emitted by [ThemeBloc].
part of 'theme_bloc.dart';

/// Holds the currently active [ThemeMode].
class ThemeState extends Equatable {
  const ThemeState({required this.themeMode});

  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}
