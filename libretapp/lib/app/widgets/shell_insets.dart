/// app › widgets › shell_insets — shared content and FAB spacing for the shell.
library;

import 'package:flutter/widgets.dart';
import 'package:libretapp/app/widgets/shell_chrome.dart';

class ShellInsets {
  // Compact dock that keeps the five destinations visible without taking
  // unnecessary space from the working area.
  static const double defaultBarHeight = 65;
  static const double defaultBarBottomGap = 6;
  static const double fabContentClearance = 64;

  /// Space at the end of a scrollable, or below fixed page content. With the
  /// dock visible, Scaffold includes its full height in MediaQuery.padding;
  /// otherwise only the remaining system safe area is included.
  static double bottomSafePadding(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom;

  /// Padding to dock the shell FAB just above the nav bar.
  static double fabDockPadding(
    BuildContext context, {
    double barHeight = defaultBarHeight,
    double barBottomGap = defaultBarBottomGap,
    double lift = 0,
  }) {
    final chromeVisible = ShellChromeVisibility.of(context)?.visible ?? true;
    if (!chromeVisible) return 0;
    final inset =
        barHeight + barBottomGap + 2 + MediaQuery.paddingOf(context).bottom;
    return (inset - (barHeight - 20) + lift).clamp(0, 220).toDouble();
  }
}
