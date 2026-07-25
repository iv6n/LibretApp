/// theme › app_theme — global ThemeData definitions for light and dark themes.
library;

import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2F5D50); // Verde Bosque
  static const primaryDark = Color(0xFF18362D); // Verde Bosque deep
  static const secondary = Color(0xFF4A7C95); // Azul Vaquero
  static const accent = Color(0xFF7B4B2A); // Cafe Cuero
  static const earth = Color(0xFFB08968); // Cafe Tierra
  static const amber = Color(0xFFC58B2A);
  static const success = Color(0xFF15803D);
  static const warning = amber;
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
    required this.fabBackground,
    required this.fabForeground,
  });

  final Color navBackground;
  final Color navShadow;
  final Color fabBackground;
  final Color fabForeground;

  @override
  ShellChromeTheme copyWith({
    Color? navBackground,
    Color? navShadow,
    Color? fabBackground,
    Color? fabForeground,
  }) {
    return ShellChromeTheme(
      navBackground: navBackground ?? this.navBackground,
      navShadow: navShadow ?? this.navShadow,
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
      fabBackground:
          Color.lerp(fabBackground, other.fabBackground, t) ?? fabBackground,
      fabForeground:
          Color.lerp(fabForeground, other.fabForeground, t) ?? fabForeground,
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
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );
    final lightTextTheme = ThemeData.light().textTheme.apply(
      bodyColor: LightColors.textPrimary,
      displayColor: LightColors.textPrimary,
      decorationColor: LightColors.textMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: baseScheme.copyWith(
        primary: AppColors.primary,
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
        outline: LightColors.border,
        outlineVariant: LightColors.borderSoft,
      ),
      scaffoldBackgroundColor: LightColors.background,
      extensions: const [
        // Shell chrome palette (nav background/shadow, FAB colors).
        ShellChromeTheme(
          navBackground: LightColors.navBackground,
          navShadow: Color(0x24000000),
          fabBackground: AppColors.accent,
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
          borderRadius: BorderRadius.circular(AppRadii.md),
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
          borderSide: const BorderSide(color: AppColors.accent, width: 1.6),
        ),
        prefixIconColor: LightColors.textMuted,
        suffixIconColor: LightColors.textMuted,
        labelStyle: const TextStyle(color: LightColors.textMuted),
        hintStyle: const TextStyle(color: LightColors.textMuted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
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
        selectedColor: AppColors.accent.withValues(alpha: 0.14),
        backgroundColor: LightColors.cardSurface,
      ),
      dividerTheme: const DividerThemeData(
        space: AppSpacing.md,
        color: LightColors.border,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LightColors.navBackground,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: LightColors.textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
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
    final darkTextTheme = ThemeData.dark().textTheme.apply(
      bodyColor: DarkColors.textPrimary,
      displayColor: DarkColors.textPrimary,
      decorationColor: DarkColors.textMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: baseScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: DarkColors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: DarkColors.textPrimary,
        outline: DarkColors.border,
      ),
      scaffoldBackgroundColor: DarkColors.surface,
      extensions: [
        // Shell chrome palette for dark mode.
        const ShellChromeTheme(
          navBackground: DarkColors.navBackground,
          navShadow: Color(0x66000000),
          fabBackground: AppColors.accent,
          fabForeground: Colors.white,
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
          borderRadius: BorderRadius.circular(AppRadii.md),
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
          borderSide: const BorderSide(color: AppColors.accent, width: 1.6),
        ),
        prefixIconColor: DarkColors.textMuted,
        suffixIconColor: DarkColors.textMuted,
        labelStyle: const TextStyle(color: DarkColors.textMuted),
        hintStyle: const TextStyle(color: DarkColors.textMuted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
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
        selectedColor: AppColors.accent.withValues(alpha: 0.22),
        backgroundColor: const Color(0xFF123430),
      ),
      dividerTheme: const DividerThemeData(
        space: AppSpacing.md,
        color: DarkColors.border,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DarkColors.navBackground,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: DarkColors.textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        backgroundColor: const Color(0xFF123430),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
      ),
      textTheme: darkTextTheme,
      primaryTextTheme: darkTextTheme,
    );
  }
}
