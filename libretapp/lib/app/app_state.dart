part of 'app_bloc.dart';

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

class AppInitial extends AppState {
  const AppInitial();
}

class AppReady extends AppState {
  final String languageCode;

  const AppReady({this.languageCode = 'es'});

  @override
  List<Object> get props => [languageCode];
}

class AppLanguageUpdated extends AppState {
  final String languageCode;

  const AppLanguageUpdated(this.languageCode);

  @override
  List<Object> get props => [languageCode];
}
