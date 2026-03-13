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
  const AppReady({this.languageCode = 'es'});
  final String languageCode;

  @override
  List<Object> get props => [languageCode];
}

class AppLanguageUpdated extends AppState {
  const AppLanguageUpdated(this.languageCode);
  final String languageCode;

  @override
  List<Object> get props => [languageCode];
}
