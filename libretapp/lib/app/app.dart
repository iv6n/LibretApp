import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/app/app_bloc.dart';
import 'package:libretapp/app/app_router.dart';
import 'package:libretapp/app/theme/theme_bloc.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                final navPadding = MediaQuery.of(context).padding.bottom;
                final scrimHeight = (navPadding > 0 ? navPadding : 16.0) + 20.0;
                final brightness = Theme.of(context).brightness;
                final base = brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white;
                // Stronger fade: intensify stops and swap to white in light mode.
                final topOpacity = brightness == Brightness.dark ? 0.28 : 0.24;
                final midOpacity = brightness == Brightness.dark ? 0.48 : 0.40;
                final bottomOpacity = brightness == Brightness.dark
                    ? 0.68
                    : 0.56;
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
                return Stack(
                  children: [
                    AnnotatedRegion<SystemUiOverlayStyle>(
                      value: overlayStyle,
                      child: ResponsiveScaler(
                        child: child ?? const SizedBox.shrink(),
                      ),
                    ),
                    // Soft fade from transparent to dark behind the system navigation bar.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: scrimHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                base.withValues(alpha: 0.0),
                                base.withValues(alpha: topOpacity),
                                base.withValues(alpha: midOpacity),
                                base.withValues(alpha: bottomOpacity),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
