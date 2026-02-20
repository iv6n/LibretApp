import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/app/app_bloc.dart';
import 'package:libretapp/app/app_router.dart';
import 'package:libretapp/core/widgets/responsive_scaler.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (previous, current) =>
          _languageCodeOf(previous) != _languageCodeOf(current),
      builder: (context, state) {
        final languageCode = "es"; //_languageCodeOf(state);
        return MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale(languageCode),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light, //ThemeMode.system,
          routerConfig: router,
          builder: (context, child) =>
              ResponsiveScaler(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }

  String _languageCodeOf(AppState state) {
    if (state is AppLanguageUpdated) return state.languageCode;
    if (state is AppReady) return state.languageCode;
    return 'es';
  }
}
