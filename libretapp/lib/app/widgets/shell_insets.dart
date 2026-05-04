/// app › widgets › shell_insets — inherited widget exposing bottom inset for shell chrome.
library;

import 'package:flutter/widgets.dart';
import 'package:libretapp/app/widgets/shell_chrome.dart';

class ShellInsets {
  static const double defaultBarHeight = 67;
  static const double defaultBarBottomGap = 10;

  /// Computes bottom padding needed to keep content above the nav bar or keyboard.
  static double bottomSafePadding(
    BuildContext context, {
    double barHeight = defaultBarHeight,
    double barBottomGap = defaultBarBottomGap,
    double extra = 2,
  }) {
    final chromeVisible = ShellChromeVisibility.of(context)?.visible ?? true;
    final effectiveBarHeight = chromeVisible ? barHeight : 0;
    final effectiveBarBottomGap = chromeVisible ? barBottomGap : 0;
    final effectiveExtra = chromeVisible ? extra : 0;

    final media = MediaQuery.of(context);
    final safeBottom = media.padding.bottom;
    final keyboard = media.viewInsets.bottom;
    final inset =
        effectiveBarHeight +
        effectiveBarBottomGap +
        effectiveExtra +
        safeBottom;
    final effective = keyboard > 0
        ? keyboard + effectiveBarBottomGap + 4
        : inset;
    return effective.clamp(0, 260).toDouble();
  }

  /// Padding to dock the shell FAB just above the nav bar.
  static double fabDockPadding(
    BuildContext context, {
    double barHeight = defaultBarHeight,
    double barBottomGap = defaultBarBottomGap,
    double lift = 0,
  }) {
    final chromeVisible = ShellChromeVisibility.of(context)?.visible ?? true;
    if (!chromeVisible) return 0;
    final inset = bottomSafePadding(
      context,
      barHeight: barHeight,
      barBottomGap: barBottomGap,
    );
    return (inset - (barHeight - 20) + lift).clamp(0, 220).toDouble();
  }
}
