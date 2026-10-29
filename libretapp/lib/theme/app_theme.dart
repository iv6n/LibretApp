/// theme › app_theme — global ThemeData definitions for light and dark themes.
library;

import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2F5D50); // Verde Bosque
  static const primaryDark = Color(0xFF18362D); // Verde Bosque deep
  static const sage = Color(0xFFDDECE3);
  static const secondary = Color(0xFF4A7C95); // Azul Vaquero
  static const accent = Color(0xFF7B4B2A); // Cafe Cuero
  static const earth = Color(0xFFB08968); // Cafe Tierra
  static const info = secondary;
  static const amber = Color(0xFFC58B2A);
  static const success = Color(0xFF136F35);
  static const warning = Color(0xFF8D5D00);
  static const error = Color(0xFFB91C1C);
}

class LightColors {
  static const _cream = Color(0xFFF6F1E8); // Crema
  static const _boneWhite = Color(0xFFFFFDF8); // Blanco Calido
  static const _creamSoft = Color(0xFFFAF6EE); // Crema ligera

  /// Page scaffold and app bar background.
  static const background = _boneWhite;

  /// Segmented tab track and accent surfaces.
  static const elevated = _cream;

  /// Card and chip surfaces — lighter than [elevated].
  static const cardSurface = _creamSoft;

  static const surface = cardSurface;

  /// Inputs and subtle inset controls placed inside cream surfaces.
  static const surfaceAlt = _boneWhite;

  static const surfaceContainerLow = _boneWhite;
  static const surfaceContainerHighest = _cream;

  static const textPrimary = Color(0xFF0F1F1A);
  static const textSecondary = Color(0xFF2F3F38);
  static const textMuted = Color(0xFF6A7C73);
  static const border = Color(0xFFE4D8C9);
  static const borderSoft = Color(0xFFEDE2D3);
  static const navBackground = Color(0xFFFFFDF8);
}

class DarkColors {
  static const surface = Color(0xFF0F1B1F); // Inky teal charcoal
  static const surfaceAlt = Color(0xFF15262C);
  static const textPrimary = Color(0xFFE5EEF1);
  static const textSecondary = Color(0xFFBCCAD0);
  static const textMuted = Color(0xFF8DA1A9);
  static const border = Color.fromRGBO(255, 255, 255, 0.10);
  static const navBackground = AppColors.primaryDark;
}

class ShellChromeTheme extends ThemeExtension<ShellChromeTheme> {
  // Nav/FAB chrome colors for shell; tweak per theme.
  const ShellChromeTheme({
    required this.navBackground,
    required this.navShadow,
    required this.navSelectedItem,
    required this.navUnselectedItem,
    required this.fabBackground,
    required this.fabForeground,
  });

  final Color navBackground;
  final Color navShadow;

  /// Icon, label and indicator of the selected nav destination.
  ///
  /// Kept as its own token rather than read from `colorScheme.primary`: in
  /// dark mode the scheme's primary is the same forest green as
  /// [DarkColors.navBackground], which put the selected destination at a
  /// 1.75:1 contrast ratio against the bar it sits on — below the 3:1 the
  /// WCAG guidance asks of a UI component, and in practice invisible.
  final Color navSelectedItem;
  final Color navUnselectedItem;

  final Color fabBackground;
  final Color fabForeground;

  @override
  ShellChromeTheme copyWith({
    Color? navBackground,
    Color? navShadow,
    Color? navSelectedItem,
    Color? navUnselectedItem,
    Color? fabBackground,
    Color? fabForeground,
  }) {
    return ShellChromeTheme(
      navBackground: navBackground ?? this.navBackground,
      navShadow: navShadow ?? this.navShadow,
      navSelectedItem: navSelectedItem ?? this.navSelectedItem,
      navUnselectedItem: navUnselectedItem ?? this.navUnselectedItem,
      fabBackground: fabBackground ?? this.fabBackground,
      fabForeground: fabForeground ?? this.fabForeground,
    );
  }

  @override
  ShellChromeTheme lerp(ThemeExtension<ShellChromeTheme>? other, double t) {
    if (other is! ShellChromeTheme) return this;
    return ShellChromeTheme(
      navBackground:
          Color.lerp(navBackground, other.navBackground, t) ?? navBackground,
      navShadow: Color.lerp(navShadow, other.navShadow, t) ?? navShadow,
      navSelectedItem:
          Color.lerp(navSelectedItem, other.navSelectedItem, t) ??
          navSelectedItem,
      navUnselectedItem:
          Color.lerp(navUnselectedItem, other.navUnselectedItem, t) ??
          navUnselectedItem,
      fabBackground:
          Color.lerp(fabBackground, other.fabBackground, t) ?? fabBackground,
      fabForeground:
          Color.lerp(fabForeground, other.fabForeground, t) ?? fabForeground,
    );
  }
}

class AppStatusTheme extends ThemeExtension<AppStatusTheme> {
  const AppStatusTheme({
    required this.info,
    required this.success,
    required this.warning,
    required this.error,
  });

  final Color info;
  final Color success;
  final Color warning;
  final Color error;

  @override
  AppStatusTheme copyWith({
    Color? info,
    Color? success,
    Color? warning,
    Color? error,
  }) => AppStatusTheme(
    info: info ?? this.info,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    error: error ?? this.error,
  );

  @override
  AppStatusTheme lerp(ThemeExtension<AppStatusTheme>? other, double t) {
    if (other is! AppStatusTheme) return this;
    return AppStatusTheme(
      info: Color.lerp(info, other.info, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

class AppControlMetrics {
  static const double minHeight = 48;
  static const double compactHeight = 40;
  static const double iconButtonSize = 48;
  static const double compactIconButtonSize = 40;
}

class AppTextStyles {
  static const TextStyle titleLg = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  static const TextStyle titleMd = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
}

class AppTheme {
  static TextTheme _textTheme({
    required Brightness brightness,
    required Color primary,
    required Color muted,
  }) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    return base
        .apply(
          bodyColor: primary,
          displayColor: primary,
          decorationColor: muted,
        )
        .copyWith(
          headlineSmall: AppTextStyles.titleLg.copyWith(color: primary),
          titleLarge: AppTextStyles.titleLg.copyWith(color: primary),
          titleMedium: AppTextStyles.titleMd.copyWith(color: primary),
          bodyLarge: AppTextStyles.body.copyWith(color: primary),
          bodyMedium: AppTextStyles.body.copyWith(color: primary),
          bodySmall: AppTextStyles.bodySmall.copyWith(color: muted),
          labelLarge: AppTextStyles.label.copyWith(color: primary),
          labelMedium: AppTextStyles.label.copyWith(color: primary),
          labelSmall: AppTextStyles.bodySmall.copyWith(color: muted),
        );
  }

  static ButtonStyle _buttonStyle({
    required Color backgroundColor,
    required Color foregroundColor,
    required double minHeight,
    bool outlined = false,
  }) {
    return ButtonStyle(
      minimumSize: WidgetStatePropertyAll<Size>(Size(0, minHeight)),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      ),
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return outlined
              ? Colors.transparent
              : backgroundColor.withValues(alpha: 0.38);
        }
        if (states.contains(WidgetState.pressed)) {
          return backgroundColor.withValues(alpha: outlined ? 0.10 : 0.86);
        }
        if (outlined) return Colors.transparent;
        return backgroundColor;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return foregroundColor.withValues(alpha: 0.46);
        }
        return foregroundColor;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return foregroundColor.withValues(alpha: outlined ? 0.08 : 0.10);
        }
        if (states.contains(WidgetState.focused)) {
          return foregroundColor.withValues(alpha: 0.14);
        }
        return null;
      }),
      side: outlined
          ? WidgetStateProperty.resolveWith((states) {
              final color = states.contains(WidgetState.disabled)
                  ? foregroundColor.withValues(alpha: 0.30)
                  : foregroundColor.withValues(alpha: 0.72);
              return BorderSide(color: color);
            })
          : null,
    );
  }

  static ThemeData get lightTheme {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );
    final lightTextTheme = _textTheme(
      brightness: Brightness.light,
      primary: LightColors.textPrimary,
      muted: LightColors.textMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: baseScheme.copyWith(
        primary: AppColors.primary,
        primaryContainer: AppColors.sage,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: LightColors.cardSurface,
        surfaceContainerLow: LightColors.surfaceContainerLow,
        surfaceContainer: LightColors.cardSurface,
        surfaceContainerHigh: LightColors.cardSurface,
        surfaceContainerHighest: LightColors.surfaceContainerHighest,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: LightColors.textPrimary,
        onSurfaceVariant: LightColors.textSecondary,
        outline: LightColors.border,
        outlineVariant: LightColors.borderSoft,
      ),
      scaffoldBackgroundColor: LightColors.background,
      extensions: const [
        AppStatusTheme(
          info: Color(0xFF366079),
          success: AppColors.success,
          warning: AppColors.warning,
          error: AppColors.error,
        ),
        // Shell chrome palette (nav background/shadow, FAB colors).
        ShellChromeTheme(
          navBackground: LightColors.navBackground,
          navShadow: Color(0x24000000),
          navSelectedItem: AppColors.primary,
          navUnselectedItem: LightColors.textMuted,
          fabBackground: AppColors.primary,
          fabForeground: Colors.white,
        ),
      ],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: LightColors.background,
        foregroundColor: LightColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.titleMd.copyWith(
          color: LightColors.textPrimary,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStatePropertyAll<Color>(Colors.transparent),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: EdgeInsets.zero,
        color: Color.alphaBlend(
          Colors.black.withValues(alpha: 0.04),
          LightColors.cardSurface,
        ),
        shadowColor: AppColors.accent.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: const BorderSide(color: LightColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: LightColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: LightColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: LightColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        alignLabelWithHint: true,
        prefixIconColor: LightColors.textMuted,
        suffixIconColor: LightColors.textMuted,
        labelStyle: const TextStyle(color: LightColors.textMuted),
        hintStyle: const TextStyle(color: LightColors.textMuted),
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _buttonStyle(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minHeight: AppControlMetrics.minHeight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buttonStyle(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minHeight: AppControlMetrics.minHeight,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buttonStyle(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primary,
          minHeight: AppControlMetrics.minHeight,
          outlined: true,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: _buttonStyle(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primary,
          minHeight: AppControlMetrics.minHeight,
          outlined: true,
        ).copyWith(side: const WidgetStatePropertyAll<BorderSide?>(null)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(
            AppControlMetrics.iconButtonSize,
            AppControlMetrics.iconButtonSize,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: LightColors.textPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        side: const BorderSide(color: LightColors.border),
        selectedColor: AppColors.sage,
        backgroundColor: LightColors.cardSurface,
      ),
      dividerTheme: const DividerThemeData(
        space: AppSpacing.md,
        color: LightColors.border,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LightColors.navBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: LightColors.textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        backgroundColor: AppColors.primary,
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      textTheme: lightTextTheme,
      primaryTextTheme: lightTextTheme,
    );
  }

  static ThemeData get darkTheme {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );
    final darkTextTheme = _textTheme(
      brightness: Brightness.dark,
      primary: DarkColors.textPrimary,
      muted: DarkColors.textMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: baseScheme.copyWith(
        primary: const Color(0xFF9DE5CB),
        primaryContainer: const Color(0xFF28473D),
        onPrimaryContainer: AppColors.sage,
        secondary: const Color(0xFF9CCBE5),
        tertiary: const Color(0xFFE8BA94),
        surface: DarkColors.surface,
        surfaceContainerLow: DarkColors.surface,
        surfaceContainer: DarkColors.surfaceAlt,
        surfaceContainerHigh: DarkColors.surfaceAlt,
        surfaceContainerHighest: const Color(0xFF1D3338),
        onPrimary: const Color(0xFF0C3027),
        onSecondary: DarkColors.surface,
        onTertiary: DarkColors.surface,
        onSurface: DarkColors.textPrimary,
        onSurfaceVariant: DarkColors.textSecondary,
        outline: DarkColors.border,
        outlineVariant: DarkColors.border,
      ),
      scaffoldBackgroundColor: DarkColors.surface,
      extensions: [
        const AppStatusTheme(
          info: Color(0xFF9CCBE5),
          success: Color(0xFF9ADEA8),
          warning: Color(0xFFF3C677),
          error: Color(0xFFFFB4AB),
        ),
        // Shell chrome palette for dark mode.
        const ShellChromeTheme(
          navBackground: DarkColors.navBackground,
          navShadow: Color(0x66000000),
          navSelectedItem: DarkColors.textPrimary,
          navUnselectedItem: DarkColors.textMuted,
          fabBackground: Color(0xFF9DE5CB),
          fabForeground: Color(0xFF0C3027),
        ),
      ],
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: DarkColors.navBackground,
        foregroundColor: DarkColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      tabBarTheme: const TabBarThemeData(
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStatePropertyAll<Color>(Colors.transparent),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        margin: EdgeInsets.zero,
        color: Color.alphaBlend(
          Colors.black.withValues(alpha: 0.08),
          DarkColors.surface,
        ),
        shadowColor: AppColors.primary.withValues(alpha: 0.16),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: const BorderSide(color: DarkColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: DarkColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: DarkColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: DarkColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: Color(0xFF9DE5CB), width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 1.6),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        alignLabelWithHint: true,
        prefixIconColor: DarkColors.textMuted,
        suffixIconColor: DarkColors.textMuted,
        labelStyle: const TextStyle(color: DarkColors.textMuted),
        hintStyle: const TextStyle(color: DarkColors.textMuted),
        errorStyle: const TextStyle(
          color: Color(0xFFFFB4AB),
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _buttonStyle(
          backgroundColor: const Color(0xFF9DE5CB),
          foregroundColor: const Color(0xFF0C3027),
          minHeight: AppControlMetrics.minHeight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buttonStyle(
          backgroundColor: const Color(0xFF9DE5CB),
          foregroundColor: const Color(0xFF0C3027),
          minHeight: AppControlMetrics.minHeight,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buttonStyle(
          backgroundColor: const Color(0xFF9DE5CB),
          foregroundColor: const Color(0xFF9DE5CB),
          minHeight: AppControlMetrics.minHeight,
          outlined: true,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: _buttonStyle(
          backgroundColor: const Color(0xFF9DE5CB),
          foregroundColor: const Color(0xFF9DE5CB),
          minHeight: AppControlMetrics.minHeight,
          outlined: true,
        ).copyWith(side: const WidgetStatePropertyAll<BorderSide?>(null)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(
            AppControlMetrics.iconButtonSize,
            AppControlMetrics.iconButtonSize,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: DarkColors.textPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        side: const BorderSide(color: DarkColors.border),
        selectedColor: const Color(0xFF28473D),
        backgroundColor: const Color(0xFF123430),
      ),
      dividerTheme: const DividerThemeData(
        space: AppSpacing.md,
        color: DarkColors.border,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DarkColors.navBackground,
        selectedItemColor: DarkColors.textPrimary,
        unselectedItemColor: DarkColors.textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        backgroundColor: const Color(0xFF123430),
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF9DE5CB),
        foregroundColor: Color(0xFF0C3027),
      ),
      textTheme: darkTextTheme,
      primaryTextTheme: darkTextTheme,
    );
  }
}
