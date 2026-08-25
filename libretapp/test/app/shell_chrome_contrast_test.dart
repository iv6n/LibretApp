/// Contrast guard for the shell chrome.
///
/// The bottom navigation bar is on screen for most of the app's life, and its
/// colours come from [ShellChromeTheme] rather than the global scheme. That
/// made one regression easy to miss: in dark mode the selected destination
/// used to read `colorScheme.primary`, which the dark theme overrides to the
/// same forest green as the bar's own background — 1.75:1, effectively
/// invisible. Nothing failed, because nothing was checking.
///
/// These are contrast ratios, not colours, so a deliberate repalette stays
/// free; only a repalette that makes the chrome unreadable fails.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/theme/app_theme.dart';

/// WCAG 2.1 minimum for a non-text UI component (1.4.11).
const _minComponentContrast = 3.0;

double _relativeLuminance(Color color) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

double _contrast(Color a, Color b) {
  final la = _relativeLuminance(a);
  final lb = _relativeLuminance(b);
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  for (final (name, theme) in [
    ('light', AppTheme.lightTheme),
    ('dark', AppTheme.darkTheme),
  ]) {
    group('$name shell chrome', () {
      final chrome = theme.extension<ShellChromeTheme>();

      test('registers a ShellChromeTheme', () {
        expect(
          chrome,
          isNotNull,
          reason:
              'AppBottomNavBar falls back to the colour scheme without it, '
              'which is what caused the invisible selected destination.',
        );
      });

      test('nav destinations are legible against the bar', () {
        final bar = chrome!.navBackground;
        for (final (label, color) in [
          ('selected', chrome.navSelectedItem),
          ('unselected', chrome.navUnselectedItem),
        ]) {
          expect(
            _contrast(color, bar),
            greaterThanOrEqualTo(_minComponentContrast),
            reason:
                '$label nav item vs nav background in $name theme '
                '(${_contrast(color, bar).toStringAsFixed(2)}:1)',
          );
        }
      });

      test('the selected destination is distinguishable from the rest', () {
        expect(
          _contrast(chrome!.navSelectedItem, chrome.navUnselectedItem),
          greaterThan(1.2),
          reason:
              'Selection is signalled by colour and a 2px indicator; if the '
              'two item colours converge, only the indicator carries it.',
        );
      });

      test('the FAB label is legible on the FAB', () {
        expect(
          _contrast(chrome!.fabForeground, chrome.fabBackground),
          greaterThanOrEqualTo(_minComponentContrast),
          reason: 'FAB foreground vs background in $name theme',
        );
      });
    });
  }
}
