part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AppEvent {
  const AppStarted();
}

class AppLanguageChanged extends AppEvent {
  const AppLanguageChanged(this.languageCode);

  final String languageCode;

  @override
  List<Object> get props => [languageCode];
}
