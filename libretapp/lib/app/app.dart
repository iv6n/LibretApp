/// app › app — root widget of the LibretApp application.
///
/// Builds the [MaterialApp.router] from GoRouter and provides the top-level
/// BLoC providers consumed by every page.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';
import 'package:libretapp/app/widgets/workspace_demo_frame.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/app_bloc.dart';
import 'package:libretapp/app/theme/theme_bloc.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (previous, current) =>
          _languageCodeOf(previous) != _languageCodeOf(current),
      builder: (context, state) {
        final languageCode = _languageCodeOf(state);
        return BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appTitle,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale(languageCode),
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.themeMode,
              routerConfig: router,
              builder: (context, child) {
                final brightness = Theme.of(context).brightness;
                final overlayStyle = SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarDividerColor: Colors.transparent,
                  statusBarIconBrightness: brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark,
                  systemNavigationBarIconBrightness:
                      brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark,
                  systemNavigationBarContrastEnforced: false,
                );
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: overlayStyle,
                  child: ResponsiveScaler(
                    child:
                        locator.isRegistered<WorkspaceManager>() &&
                            locator<WorkspaceManager>().isDemo
                        ? WorkspaceDemoFrame(
                            manager: locator<WorkspaceManager>(),
                            child: child ?? const SizedBox.shrink(),
                          )
                        : child ?? const SizedBox.shrink(),
                  ),
                );
              },
            );
          },
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
